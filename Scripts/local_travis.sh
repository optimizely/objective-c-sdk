#!/bin/bash
set -e

# all diffs
pod spec lint --quick

#master
echo 'xcodebuild test -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphonesimulator -destination "platform=iOS Simulator,OS=9.1,name=iPad Air"'
xcodebuild test -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphonesimulator -destination "platform=iOS Simulator,OS=9.1,name=iPad Air"

echo 'xcodebuild test -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphonesimulator -destination "platform=iOS Simulator,OS=10.1,name=iPhone 7 Plus"'
xcodebuild test -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphonesimulator -destination "platform=iOS Simulator,OS=10.1,name=iPhone 7 Plus"

echo 'xcodebuild test -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphonesimulator -destination "platform=iOS Simulator,OS=10.2,name=iPhone 7"'
xcodebuild test -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphonesimulator -destination "platform=iOS Simulator,OS=10.2,name=iPhone 7"

echo 'xcodebuild test -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS-Universal -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphonesimulator -destination "platform=iOS Simulator,OS=9.3,name=iPhone 6s"'
xcodebuild test -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS-Universal -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphonesimulator -destination "platform=iOS Simulator,OS=9.3,name=iPhone 6s"

echo 'xcodebuild test -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKTVOS -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk appletvsimulator -destination "platform=tvOS Simulator,OS=10.1,name=Apple TV 1080p"'
xcodebuild test -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKTVOS -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk appletvsimulator -destination "platform=tvOS Simulator,OS=10.1,name=Apple TV 1080p"

echo 'xcodebuild test -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKTVOS-Universal -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk appletvsimulator -destination "platform=tvOS Simulator,OS=9.2,name=Apple TV 1080p"'
xcodebuild test -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKTVOS-Universal -configuration Release CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk appletvsimulator -destination "platform=tvOS Simulator,OS=9.2,name=Apple TV 1080p"
