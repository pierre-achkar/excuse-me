#!/usr/bin/env bash
# scripts/ios-sign.sh
#
# macOS-only helper for a signed iOS archive and IPA. It consumes external
# secret environment variables, keeps certificates/profiles in temporary paths,
# and contains no real credential, team identifier, or signing artifact.
#
# Required environment variables:
#   IOS_DISTRIBUTION_P12_B64       base64-encoded Apple distribution .p12
#   IOS_DISTRIBUTION_P12_PASSWORD  password for that .p12
#   IOS_PROVISIONING_PROFILE_B64   base64-encoded App Store .mobileprovision
#   IOS_TEAM_ID                    Apple Developer team identifier
#
# Optional:
#   IOS_BUNDLE_ID                  defaults to the checked-in Runner bundle id
#   IOS_OUTPUT_DIR                 defaults to build/ios/release
#
# The signed path is not tested in this Linux repository. Run it only on macOS
# with your own Apple Developer credentials and review the produced artifact.

set -euo pipefail

: "${IOS_DISTRIBUTION_P12_B64:?Set IOS_DISTRIBUTION_P12_B64 in the environment}"
: "${IOS_DISTRIBUTION_P12_PASSWORD:?Set IOS_DISTRIBUTION_P12_PASSWORD in the environment}"
: "${IOS_PROVISIONING_PROFILE_B64:?Set IOS_PROVISIONING_PROFILE_B64 in the environment}"
: "${IOS_TEAM_ID:?Set IOS_TEAM_ID in the environment}"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

IOS_BUNDLE_ID="${IOS_BUNDLE_ID:-com.pierreachkar.excuseMe}"
IOS_OUTPUT_DIR="${IOS_OUTPUT_DIR:-$PROJECT_ROOT/build/ios/release}"

for v in IOS_DISTRIBUTION_P12_B64 IOS_DISTRIBUTION_P12_PASSWORD \
         IOS_PROVISIONING_PROFILE_B64 IOS_TEAM_ID IOS_BUNDLE_ID; do
  val="${!v}"
  if [[ -z "$val" ]]; then
    echo "ERROR: ${v} is empty." >&2
    exit 1
  fi
  if [[ "$val" == *CHANGE_ME* ]]; then
    echo "ERROR: ${v} still contains the CHANGE_ME placeholder; refusing to run." >&2
    exit 1
  fi
done

if [[ ! "$IOS_TEAM_ID" =~ ^[A-Za-z0-9]{10}$ ]]; then
  echo "ERROR: IOS_TEAM_ID must be a 10-character alphanumeric value." >&2
  exit 1
fi
if [[ ! "$IOS_BUNDLE_ID" =~ ^[A-Za-z0-9.-]+$ ]]; then
  echo "ERROR: IOS_BUNDLE_ID contains unsupported characters." >&2
  exit 1
fi

for command_name in security xcodebuild flutter uuidgen; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "ERROR: required macOS command is unavailable: ${command_name}" >&2
    exit 1
  fi
done
if [[ ! -x /usr/libexec/PlistBuddy ]]; then
  echo "ERROR: /usr/libexec/PlistBuddy is unavailable." >&2
  exit 1
fi

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ios-sign.XXXXXX")"
P12="$TMP_DIR/distribution.p12"
PROFILE="$TMP_DIR/embedded.mobileprovision"
PROFILE_PLIST="$TMP_DIR/profile.plist"
KEYCHAIN="$TMP_DIR/ios-sign.keychain-db"
ARCHIVE_PATH="$TMP_DIR/Runner.xcarchive"
EXPORT_DIR="$TMP_DIR/export"
EXPORT_OPTIONS="$TMP_DIR/ExportOptions.plist"
KEYCHAIN_PASSWORD="$(uuidgen)"
PROFILE_DEST=""

# Preserve and restore the user's keychain search list. The helper never makes
# the temporary keychain the user's default keychain.
ORIGINAL_KEYCHAINS=()
while IFS= read -r keychain; do
  keychain="${keychain//\"/}"
  [[ -n "$keychain" ]] && ORIGINAL_KEYCHAINS+=("$keychain")
done < <(security list-keychains -d user)

cleanup() {
  if [[ -n "${PROFILE_DEST:-}" ]]; then
    rm -f -- "$PROFILE_DEST"
  fi
  if (( ${#ORIGINAL_KEYCHAINS[@]} > 0 )); then
    security list-keychains -d user -s "${ORIGINAL_KEYCHAINS[@]}" >/dev/null 2>&1 || true
  fi
  if [[ -n "${KEYCHAIN:-}" ]]; then
    security delete-keychain "$KEYCHAIN" >/dev/null 2>&1 || true
  fi
  rm -rf -- "$TMP_DIR"
}
trap cleanup EXIT

# Decode credentials only into the temporary directory.
printf '%s' "$IOS_DISTRIBUTION_P12_B64" | base64 -D > "$P12"
printf '%s' "$IOS_PROVISIONING_PROFILE_B64" | base64 -D > "$PROFILE"
chmod 600 "$P12" "$PROFILE"
if [[ ! -s "$P12" || ! -s "$PROFILE" ]]; then
  echo "ERROR: decoded certificate or provisioning profile is empty." >&2
  exit 1
fi

# Create and use one throwaway keychain password consistently.
security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN"
security set-keychain-settings -lut 21600 "$KEYCHAIN"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN"
security list-keychains -d user -s "$KEYCHAIN" "${ORIGINAL_KEYCHAINS[@]}"
security import "$P12" -P "$IOS_DISTRIBUTION_P12_PASSWORD" \
  -k "$KEYCHAIN" -T /usr/bin/codesign -T /usr/bin/security
security set-key-partition-list \
  -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN"

# Install the profile under its UUID only for the duration of the build.
security cms -D -i "$PROFILE" -o "$PROFILE_PLIST"
PROFILE_UUID="$(/usr/libexec/PlistBuddy -c 'Print:UUID' "$PROFILE_PLIST")"
PROFILE_NAME="$(/usr/libexec/PlistBuddy -c 'Print:Name' "$PROFILE_PLIST")"
if [[ ! "$PROFILE_UUID" =~ ^[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12}$ ]]; then
  echo "ERROR: provisioning profile UUID is invalid." >&2
  exit 1
fi
if [[ -z "$PROFILE_NAME" || "$PROFILE_NAME" == *'"'* || "$PROFILE_NAME" == *'\'* ]]; then
  echo "ERROR: provisioning profile name is invalid." >&2
  exit 1
fi
PROFILE_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"
mkdir -p "$PROFILE_DIR"
PROFILE_DEST="$PROFILE_DIR/$PROFILE_UUID.mobileprovision"
if [[ -e "$PROFILE_DEST" ]]; then
  echo "ERROR: provisioning profile destination already exists: $PROFILE_DEST" >&2
  exit 1
fi
cp "$PROFILE" "$PROFILE_DEST"

# Generate Flutter iOS configuration, then archive and export with explicit
# manual signing settings. Team/profile values come only from the environment
# and decoded profile; none are stored in the repository.
flutter build ios --release --config-only
xcodebuild \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -sdk iphoneos \
  -archivePath "$ARCHIVE_PATH" \
  DEVELOPMENT_TEAM="$IOS_TEAM_ID" \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="Apple Distribution" \
  PROVISIONING_PROFILE_SPECIFIER="$PROFILE_NAME" \
  PRODUCT_BUNDLE_IDENTIFIER="$IOS_BUNDLE_ID" \
  archive

mkdir -p "$IOS_OUTPUT_DIR" "$EXPORT_DIR"
touch "$EXPORT_OPTIONS"
/usr/libexec/PlistBuddy -c 'Add :method string app-store' "$EXPORT_OPTIONS"
/usr/libexec/PlistBuddy -c "Add :teamID string $IOS_TEAM_ID" "$EXPORT_OPTIONS"
/usr/libexec/PlistBuddy -c 'Add :signingStyle string manual' "$EXPORT_OPTIONS"
/usr/libexec/PlistBuddy -c 'Add :provisioningProfiles dict' "$EXPORT_OPTIONS"
/usr/libexec/PlistBuddy -c \
  "Add :provisioningProfiles:$IOS_BUNDLE_ID string $PROFILE_NAME" "$EXPORT_OPTIONS"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -exportPath "$EXPORT_DIR"

IPA_PATH="$(find "$EXPORT_DIR" -maxdepth 1 -type f -name '*.ipa' -print -quit)"
if [[ -z "$IPA_PATH" ]]; then
  echo "ERROR: signed IPA was not produced." >&2
  exit 1
fi
OUTPUT_IPA="$IOS_OUTPUT_DIR/$(basename "$IPA_PATH")"
cp "$IPA_PATH" "$OUTPUT_IPA"
printf 'Signed IPA: %s\n' "$OUTPUT_IPA"
printf 'Temporary keychain and provisioning profile will now be removed.\n'
