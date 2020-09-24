  #xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelyiOSDemoApp -configuration Release "${action}"
  #xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelyTVOSDemoApp -configuration Release "${action}"
echo 'Testing OptimizelySDKUserProfileServiceiOS'
xcrun xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKUserProfileServiceiOS -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6,OS=9.2' \
  test
echo 'Testing OptimizelySDKUserProfileServiceTVOS'
xcrun xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKUserProfileServiceTVOS -sdk appletvsimulator -destination 'platform=tvOS Simulator,name=Apple TV,OS=12.0' \
  test
echo 'Testing OptimizelySDKSharediOS'
xcrun xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKSharediOS -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6,OS=9.2' \
  test
echo 'Testing OptimizelySDKSharedTVOS'
xcrun xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKSharedTVOS -sdk appletvsimulator -destination 'platform=tvOS Simulator,name=Apple TV,OS=12.0' \
  test
echo 'Testing OptimizelySDKCoreiOS'
xcrun xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKCoreiOS -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6,OS=9.2' \
  test
echo 'Testing OptimizelySDKCoretvOS'
xcrun xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKCoreTVOS -sdk appletvsimulator -destination 'platform=tvOS Simulator,name=Apple TV,OS=12.0' \
  test
echo 'Testing OptimizelySDKDatafileManageriOS'
xcrun xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKDatafileManageriOS -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6,OS=9.2' \
  test
echo 'Testing OptimizelySDKDatafileManagerTVOS'
xcrun xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKDatafileManagerTVOS -sdk appletvsimulator -destination 'platform=tvOS Simulator,name=Apple TV,OS=12.0' \
  test
echo 'Testing OptimizelySDKEventDispatcheriOS'
xcrun xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKEventDispatcheriOS -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6,OS=9.2' \
  test
echo 'Testing OptimizelySDKEventDispatcherTVOS'
xcrun xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKEventDispatcherTVOS -sdk appletvsimulator -destination 'platform=tvOS Simulator,name=Apple TV,OS=12.0' \
  test
echo 'Testing OptimizelySDKiOS'
xcrun xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOS -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6,OS=9.2' \
  test
echo 'Testing OptimizelySDKiOSUniversal'
xcrun xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKiOSUniversal -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6,OS=9.2' \
  test
echo 'Testing OptimizelySDKTVOS'
xcrun xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKTVOS -sdk appletvsimulator -destination 'platform=tvOS Simulator,name=Apple TV,OS=12.0' \
  test
  # Xcode IDE is happy with OptimizelySDKTVOSUniversal , we don't know what's up with our *.sh .
echo 'Testing OptimizelySDKTVOSUniversal'
xcrun xcodebuild -workspace OptimizelySDK.xcworkspace -scheme OptimizelySDKTVOSUniversal -sdk appletvsimulator -destination 'platform=tvOS Simulator,name=Apple TV,OS=12.0' \
  test
