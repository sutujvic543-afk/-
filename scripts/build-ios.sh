#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/Payload/Lintalk.app
APP="$PWD/build/Payload/Lintalk.app"
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
xcrun --sdk iphoneos swiftc -parse-as-library -swift-version 5 -O -sdk "$SDK" -target arm64-apple-ios15.0 -framework UIKit -framework WebKit -Xlinker -rpath -Xlinker /usr/lib/swift ios/App.swift -o "$APP/Lintalk"
python3 - <<'PY'
import plistlib, pathlib
p = {
'CFBundleDevelopmentRegion':'zh_CN', 'CFBundleDisplayName':'临语',
'CFBundleExecutable':'Lintalk', 'CFBundleIdentifier':'chat.lintalk.ios',
'CFBundleInfoDictionaryVersion':'6.0', 'CFBundleName':'Lintalk',
'CFBundlePackageType':'APPL', 'CFBundleShortVersionString':'0.3.1',
'CFBundleVersion':'4', 'MinimumOSVersion':'15.0',
'LSRequiresIPhoneOS':True, 'UIDeviceFamily':[1,2],
'CFBundleSupportedPlatforms':['iPhoneOS'],
'UILaunchScreen':{}, 'UIRequiresFullScreen':True,
'UISupportedInterfaceOrientations':['UIInterfaceOrientationPortrait'],
'UISupportedInterfaceOrientations~ipad':['UIInterfaceOrientationPortrait','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight'],
'ITSAppUsesNonExemptEncryption':True
}
with open('build/Payload/Lintalk.app/Info.plist','wb') as f: plistlib.dump(p,f)
PY
plutil -lint "$APP/Info.plist"
file "$APP/Lintalk"
lipo "$APP/Lintalk" -verify_arch arm64
# This is intentionally not distribution-signed. The signing provider must
# add its provisioning profile, entitlements, and valid distribution signature.
codesign --remove-signature "$APP/Lintalk" 2>/dev/null || true
cd build
zip -qry Lintalk-0.3.1-unsigned.ipa Payload
unzip -t Lintalk-0.3.1-unsigned.ipa
shasum -a 256 Lintalk-0.3.1-unsigned.ipa > SHA256.txt
