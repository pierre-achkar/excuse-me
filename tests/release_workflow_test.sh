#!/usr/bin/env bash
# tests/release_workflow_test.sh
#
# Structural validation of the protected manual release workflow.
# GitHub Actions remains the authoritative YAML parser and execution engine.
# This script is local, non-credential, structural support only.

set -euo pipefail

WORKFLOW=".github/workflows/release.yml"
PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); printf '  PASS: %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '  FAIL: %s\n' "$1"; }

contains() { printf '%s\n' "$1" | grep -Fq -- "$2"; }
matches() { printf '%s\n' "$1" | grep -Eq -- "$2"; }

echo "=== Release Workflow Validation ==="
echo

[ -f "$WORKFLOW" ] && pass "$WORKFLOW found" || { fail "$WORKFLOW not found"; exit 1; }

WORKFLOW_CONTENT=$(cat "$WORKFLOW")

# ---- Trigger: manual only ----
contains "$WORKFLOW_CONTENT" "workflow_dispatch:" \
  && pass "workflow_dispatch trigger present" \
  || fail "workflow_dispatch trigger missing"
if matches "$WORKFLOW_CONTENT" "^[[:space:]]+(push|pull_request|schedule):"; then
  fail "release workflow must not auto-trigger on push/pull_request/schedule"
else
  pass "release workflow has no push/pull_request/schedule trigger"
fi

# ---- Least-privilege permissions ----
PERMS=$(awk '/^permissions:/{in_block=1} in_block && /^jobs:/{exit} in_block {print}' "$WORKFLOW")
contains "$PERMS" "permissions:" && pass "permissions block present" || fail "permissions block missing"
contains "$PERMS" "contents: read" && pass "contents: read permission granted" || fail "contents: read missing"
if matches "$PERMS" "[[:space:]]+[a-zA-Z0-9_-]+:[[:space:]]*write"; then
  fail "a write permission is granted"
else
  pass "no write permission granted"
fi

# ---- Protected release environment ----
matches "$WORKFLOW_CONTENT" "^[[:space:]]+environment:[[:space:]]+release" \
  && pass "targets 'release' environment (protection is configured in GitHub settings)" \
  || fail "does not target the 'release' environment"

# ---- Runner temp decoding (never a committed / working source path) ----
contains "$WORKFLOW_CONTENT" "RUNNER_TEMP" \
  && pass "decodes keystore into the runner temp directory" \
  || fail "RUNNER_TEMP not used for temporary decode"

# ---- Fail-closed missing-secret checks ----
if matches "$WORKFLOW_CONTENT" "missing[[:space:]]+required[[:space:]]+release[[:space:]]+secret" \
   && matches "$WORKFLOW_CONTENT" "ANDROID_KEYSTORE_B64" \
   && matches "$WORKFLOW_CONTENT" "exit 1"; then
  pass "fail-closed: aborts when required Android release secrets are missing"
else
  fail "fail-closed missing-secret guard is incomplete"
fi

# ---- Cleanup traps ----
contains "$WORKFLOW_CONTENT" "trap 'rm -f" \
  && pass "uses a cleanup trap to remove temporary signing material" \
  || fail "no cleanup trap found"

# ---- Explicit version propagation ----
if matches "$WORKFLOW_CONTENT" "build-name" \
   && matches "$WORKFLOW_CONTENT" "build-number" \
   && matches "$WORKFLOW_CONTENT" "RELEASE_BUILD_NAME" \
   && matches "$WORKFLOW_CONTENT" "RELEASE_BUILD_NUMBER" \
   && contains "$WORKFLOW_CONTENT" '--build-name "$RELEASE_BUILD_NAME"' \
   && contains "$WORKFLOW_CONTENT" '--build-number "$RELEASE_BUILD_NUMBER"' \
   && ! contains "$WORKFLOW_CONTENT" "build_version"; then
  pass "manual inputs are propagated to the Android release build"
else
  fail "manual build version inputs are not propagated to the release build"
fi

# ---- Checkout token handling and permission minimization ----
if contains "$WORKFLOW_CONTENT" "persist-credentials: false" \
   && ! contains "$WORKFLOW_CONTENT" "actions: read"; then
  pass "checkout credentials are not persisted and no extra actions permission is granted"
else
  fail "release workflow retains unnecessary checkout credentials or permissions"
fi

# ---- Signed Android artifact only in this job; no iOS signing here ----
contains "$WORKFLOW_CONTENT" "flutter build appbundle --release" \
  && pass "release job produces the signed Android app bundle" \
  || fail "signed Android build step missing"
if matches "$WORKFLOW_CONTENT" "(provisioning-profile|codesign|xcodebuild|security import|iPhone Distribution)"; then
  fail "release workflow contains iOS signing material"
else
  pass "release workflow contains no iOS signing material"
fi

# ---- No artifact or secret leakage ----
if matches "$WORKFLOW_CONTENT" "echo[[:space:]]+[^|]*\$\{\{[[:space:]]*secrets\."; then
  fail "workflow echoes a secret value to the log"
else
  pass "no secret value is echoed to the log"
fi
matches "$WORKFLOW_CONTENT" "secrets\.[A-Z_]+" \
  && pass "secrets referenced via \${{ secrets.* }} (masked by GitHub)" \
  || fail "no \${{ secrets.* }} references found"

printf '\n=== Summary ===\nPassed: %s\nFailed: %s\n' "$PASS" "$FAIL"
if [ "$FAIL" -gt 0 ]; then
  printf '\nVALIDATION FAILED\n'
  exit 1
fi
printf '\nALL CHECKS PASSED\n'
