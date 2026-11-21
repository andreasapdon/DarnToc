#!/bin/bash
# Builds a distributable, notarised DarnToc disk image:  build/DarnToc-<version>.dmg
#
# One-time setup (see RELEASING.md):
#   1. A "Developer ID Application" certificate in your keychain.
#   2. Notary credentials stored as a keychain profile named "ClipCut-notary":
#        xcrun notarytool store-credentials "ClipCut-notary" --apple-id YOU@EXAMPLE.COM --team-id TEAMID
#
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="DarnToc"
PROFILE="${NOTARY_PROFILE:-ClipCut-notary}"
VERSION="$(sed -n 's/^VERSION="\(.*\)"/\1/p' make-app.sh)"
APP="build/${APP_NAME}.app"
DMG="build/${APP_NAME}-${VERSION}.dmg"

# Find the Developer ID identity unless one is given.
if [[ -z "${SIGN_ID:-}" ]]; then
    SIGN_ID="$(security find-identity -v -p codesigning | sed -n 's/.*"\(Developer ID Application: .*\)"/\1/p' | head -1)"
fi
if [[ -z "$SIGN_ID" ]]; then
    echo "✗ No 'Developer ID Application' certificate found in your keychain. See RELEASING.md, step 1."
    exit 1
fi
if ! xcrun notarytool history --keychain-profile "$PROFILE" >/dev/null 2>&1; then
    echo "✗ Notary profile '$PROFILE' isn't set up (or the password has expired). See RELEASING.md, step 2."
    exit 1
fi

echo "━━ 1/5  Build and sign the app"
SIGN_ID="$SIGN_ID" ./make-app.sh

echo "━━ 2/5  Make the disk image"
STAGE="$(mktemp -d)"
ditto "$APP" "$STAGE/${APP_NAME}.app"
ln -s /Applications "$STAGE/Applications"
rm -f "$DMG"
hdiutil create -volname "${APP_NAME} ${VERSION}" -srcfolder "$STAGE" -fs HFS+ -format UDZO -ov "$DMG" >/dev/null
codesign --force --timestamp --sign "$SIGN_ID" "$DMG"

echo "━━ 3/5  Notarise (usually 2–10 minutes)…"
if ! xcrun notarytool submit "$DMG" --keychain-profile "$PROFILE" --wait --output-format plist > build/notary.plist; then
    echo "✗ Notarisation request failed:"; cat build/notary.plist; exit 1
fi
STATUS="$(/usr/libexec/PlistBuddy -c 'Print :status' build/notary.plist 2>/dev/null || echo unknown)"
ID="$(/usr/libexec/PlistBuddy -c 'Print :id' build/notary.plist 2>/dev/null || echo '')"
if [[ "$STATUS" != "Accepted" ]]; then
    echo "✗ Apple returned: $STATUS. Details:"
    [[ -n "$ID" ]] && xcrun notarytool log "$ID" --keychain-profile "$PROFILE"
    exit 1
fi

echo "━━ 4/5  Staple the approval to the disk image"
xcrun stapler staple "$DMG"

echo "━━ 5/5  Check it the way a user's Mac will"
spctl --assess --type open --context context:primary-signature -v "$DMG"
xcrun stapler validate "$DMG"
codesign --verify --deep --strict -v "$APP"

echo
echo "✓ Ready to share: $(pwd)/${DMG}"
