#!/usr/bin/env bash
# tests/ios_sign_test.sh
#
# Verifies the iOS signing helper fails closed and never runs without real
# secrets, and that it contains no embedded credentials/team id.

set -euo pipefail

SCRIPT="scripts/ios-sign.sh"
PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); printf '  PASS: %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '  FAIL: %s\n' "$1"; }

echo "=== iOS Sign Helper Validation ==="
echo

if [ ! -f "$SCRIPT" ]; then
  fail "$SCRIPT not found"
  exit 1
fi
pass "$SCRIPT found"

# 1) Fails closed when the required secrets are unset.
set +e
out=$(env -u IOS_DISTRIBUTION_P12_B64 \
  -u IOS_DISTRIBUTION_P12_PASSWORD \
  -u IOS_PROVISIONING_PROFILE_B64 \
  -u IOS_TEAM_ID bash "$SCRIPT" 2>&1)
rc=$?
set -e
if [ "$rc" -ne 0 ]; then
  pass "fails closed when required secrets are unset (rc=$rc)"
else
  fail "did NOT fail closed when required secrets are unset"
fi

# 2) Refuses to run when a secret is the CHANGE_ME placeholder.
set +e
out=$(IOS_DISTRIBUTION_P12_B64=CHANGE_ME \
  IOS_DISTRIBUTION_P12_PASSWORD=CHANGE_ME \
  IOS_PROVISIONING_PROFILE_B64=CHANGE_ME \
  IOS_TEAM_ID=CHANGE_ME bash "$SCRIPT" 2>&1)
rc=$?
set -e
if [ "$rc" -ne 0 ] && [[ "$out" == *CHANGE_ME* ]]; then
  pass "refuses CHANGE_ME placeholder secrets with an error"
else
  fail "did not reject CHANGE_ME placeholder secrets"
fi

# 3) Reuses one keychain password for create, unlock, and partition setup.
if grep -q 'KEYCHAIN_PASSWORD=' "$SCRIPT" \
  && grep -q 'create-keychain -p "$KEYCHAIN_PASSWORD"' "$SCRIPT" \
  && grep -q 'unlock-keychain -p "$KEYCHAIN_PASSWORD"' "$SCRIPT" \
  && grep -q 'set-key-partition-list' "$SCRIPT" \
  && grep -q -- '-k "$KEYCHAIN_PASSWORD"' "$SCRIPT"; then
  pass "reuses one temporary keychain password across setup"
else
  fail "temporary keychain password is not reused across setup"
fi

# 4) Uses explicit Xcode signing/archive/export settings, not a Dart define.
if grep -q 'xcodebuild' "$SCRIPT" \
  && grep -q -- '-archivePath' "$SCRIPT" \
  && grep -q 'DEVELOPMENT_TEAM=' "$SCRIPT" \
  && grep -q 'PROVISIONING_PROFILE_SPECIFIER=' "$SCRIPT" \
  && grep -q 'exportArchive' "$SCRIPT" \
  && ! grep -q 'APP_STORE_TEAM_ID' "$SCRIPT"; then
  pass "uses explicit Xcode archive and export signing settings"
else
  fail "signed iOS archive/export path is incomplete or uses an irrelevant Dart define"
fi

# 5) Validates identifiers before using them in paths or plist commands.
if grep -q 'IOS_TEAM_ID must be a 10-character alphanumeric value' "$SCRIPT" \
  && grep -q 'IOS_BUNDLE_ID contains unsupported characters' "$SCRIPT" \
  && grep -q 'provisioning profile UUID is invalid' "$SCRIPT" \
  && grep -q 'provisioning profile name is invalid' "$SCRIPT"; then
  pass "validates external identifiers and profile-derived plist/path values"
else
  fail "external identifiers or profile-derived values are not validated"
fi

# 6) Contains no embedded certificate base64 / team id.
if grep -q 'MIIC' "$SCRIPT"; then
  fail "helper embeds a base64 certificate"
else
  pass "helper embeds no base64 certificate"
fi
if grep -qE 'TEAMID[[:space:]]*=[[:space:]]*[A-Z0-9]{10}' "$SCRIPT"; then
  fail "helper embeds a concrete team id"
else
  pass "helper embeds no concrete team id"
fi

printf '\n=== Summary ===\nPassed: %s\nFailed: %s\n' "$PASS" "$FAIL"
if [ "$FAIL" -gt 0 ]; then
  printf '\nVALIDATION FAILED\n'
  exit 1
fi
printf '\nALL CHECKS PASSED\n'
