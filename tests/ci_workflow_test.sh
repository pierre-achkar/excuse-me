#!/usr/bin/env bash
# tests/ci_workflow_test.sh
#
# Validates the checked-in CI workflow's expected structure and commands.
# GitHub Actions remains the authoritative YAML parser on the hosted runner.

set -euo pipefail

WORKFLOW=".github/workflows/ci.yml"
PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); printf '  PASS: %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '  FAIL: %s\n' "$1"; }

job_block() {
  local job="$1"
  awk -v job="$job" '
    $0 == "  " job ":" { in_job = 1; print; next }
    in_job && $0 ~ /^  [A-Za-z0-9_-]+:/ { exit }
    in_job { print }
  ' "$WORKFLOW"
}

trigger_block() {
  local trigger="$1"
  awk -v trigger="$trigger" '
    $0 == "  " trigger ":" { in_trigger = 1; print; next }
    in_trigger && $0 ~ /^  [A-Za-z0-9_-]+:/ { exit }
    in_trigger { print }
  ' "$WORKFLOW"
}

contains() {
  local block="$1"
  local pattern="$2"
  printf '%s\n' "$block" | grep -Fq -- "$pattern"
}

assert_block_contains() {
  local block_name="$1"
  local block="$2"
  local pattern="$3"
  local description="$4"
  if contains "$block" "$pattern"; then
    pass "$description"
  else
    fail "$description (missing: $pattern in $block_name)"
  fi
}

echo "=== CI Workflow Validation ==="
echo

if [ -f "$WORKFLOW" ]; then
  pass "$WORKFLOW found"
else
  fail "$WORKFLOW not found"
  exit 1
fi

# ---- Trigger scope ----
PULL_REQUEST=$(trigger_block pull_request)
PUSH=$(trigger_block push)
if contains "$PULL_REQUEST" "  pull_request:" && contains "$PULL_REQUEST" "    branches: [main]"; then
  pass "pull_request trigger is scoped to main"
else
  fail "pull_request trigger is not explicitly scoped to main"
fi
if contains "$PUSH" "  push:" && contains "$PUSH" "    branches: [main]"; then
  pass "push trigger is scoped to main"
else
  fail "push trigger is not explicitly scoped to main"
fi

# ---- Permissions ----
PERMISSIONS=$(awk '/^permissions:/{in_block=1} in_block && /^jobs:/{exit} in_block {print}' "$WORKFLOW")
if contains "$PERMISSIONS" "permissions:" && contains "$PERMISSIONS" "  contents: read" \
  && ! contains "$PERMISSIONS" "write"; then
  pass "least-privilege contents: read permission set"
else
  fail "least-privilege permissions are missing or overly broad"
fi

# ---- Required jobs and job-scoped commands ----
ANALYZE=$(job_block analyze)
TEST=$(job_block test)
ANDROID=$(job_block android-build)
IOS=$(job_block ios-build)

for name in analyze test android-build ios-build; do
  if [ -n "$(job_block "$name")" ]; then
    pass "job '$name' defined"
  else
    fail "job '$name' not found"
  fi
done

assert_block_contains analyze "$ANALYZE" "    runs-on: ubuntu-latest" "analyze runs on ubuntu-latest"
assert_block_contains analyze "$ANALYZE" "dart format --output=none --set-exit-if-changed lib test" "format check belongs to analyze"
assert_block_contains analyze "$ANALYZE" "flutter analyze" "analyzer belongs to analyze"
assert_block_contains test "$TEST" "    needs: analyze" "test depends on analyze"
assert_block_contains test "$TEST" "    runs-on: ubuntu-latest" "test runs on ubuntu-latest"
assert_block_contains test "$TEST" "flutter test" "Flutter tests belong to test"
assert_block_contains android-build "$ANDROID" "    needs: analyze" "Android build depends on analyze"
assert_block_contains android-build "$ANDROID" "    runs-on: ubuntu-latest" "Android build runs on ubuntu-latest"
assert_block_contains android-build "$ANDROID" "flutter build apk --debug" "Android debug build belongs to android-build"
assert_block_contains ios-build "$IOS" "    needs: analyze" "iOS build depends on analyze"
assert_block_contains ios-build "$IOS" "    runs-on: macos-latest" "iOS build runs on macos-latest"
assert_block_contains ios-build "$IOS" "flutter build ios --release --no-codesign" "iOS no-codesign build belongs to ios-build"

# ---- Cache paths and setup, per job ----
for name in analyze test android-build ios-build; do
  block=$(job_block "$name")
  assert_block_contains "$name" "$block" "uses: actions/cache@v4" "$name uses actions/cache"
  assert_block_contains "$name" "$block" "path: ~/.pub-cache" "$name caches the standard pub directory"
  assert_block_contains "$name" "$block" "hashFiles('pubspec.lock')" "$name cache is keyed by pubspec.lock"
  assert_block_contains "$name" "$block" "uses: subosito/flutter-action@v2" "$name provisions Flutter"
done

# ---- No signing secrets or artifacts in workflow ----
if grep -q "actions/upload-artifact" "$WORKFLOW"; then
  fail "workflow uploads build artifacts before release controls are defined"
else
  pass "workflow has no artifact upload step"
fi
if grep -qE '\$\{\{\s*secrets\.' "$WORKFLOW"; then
  fail "workflow references GitHub secrets"
else
  pass "workflow references no GitHub secrets"
fi
SIGNING_FOUND=0
for term in keystore certificate provisioning-profile p12 jks; do
  if grep -qi "$term" "$WORKFLOW"; then
    fail "workflow contains signing artifact reference: $term"
    SIGNING_FOUND=1
  fi
done
if [ "$SIGNING_FOUND" -eq 0 ]; then
  pass "workflow contains no keystore/certificate/provisioning references"
fi

printf '\n=== Summary ===\nPassed: %s\nFailed: %s\n' "$PASS" "$FAIL"
if [ "$FAIL" -gt 0 ]; then
  printf '\nVALIDATION FAILED\n'
  exit 1
fi
printf '\nALL CHECKS PASSED\n'
