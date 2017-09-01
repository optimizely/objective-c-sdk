workspace 'OptimizelySDK.xcworkspace'

def common_test_pods
  pod 'OHHTTPStubs', '5.2.2'
  pod 'OCMock', '3.3.1'
end

def analytics_pods
    pod 'Amplitude-iOS'
    pod 'Google/Analytics'
    pod 'Localytics'
    pod 'Mixpanel-swift'
end

use_frameworks!
  
# OptimizelySDKCore targets
target 'OptimizelySDKCoreiOSTests' do
  project 'OptimizelySDKCore/OptimizelySDKCore.xcodeproj/'
  platform :ios, '8.0'
  common_test_pods
end

target 'OptimizelySDKCoreTVOSTests' do
  project 'OptimizelySDKCore/OptimizelySDKCore.xcodeproj/'
  platform :tvos, '9.0'
  common_test_pods
end

# OptimizelySDKiOS targets
target 'OptimizelySDKiOSTests' do
  project 'OptimizelySDKiOS/OptimizelySDKiOS.xcodeproj/'
  platform :ios, '8.0'
  common_test_pods
end

# OptimizelySDKTVOS targets
target 'OptimizelySDKTVOSTests' do
  project 'OptimizelySDKTVOS/OptimizelySDKTVOS.xcodeproj/'
  platform :tvos, '9.0'
  common_test_pods
end

# OptimizelySDKShared targets
target 'OptimizelySDKSharediOSTests' do
  project 'OptimizelySDKShared/OptimizelySDKShared.xcodeproj/'
  platform :ios, '8.0'
  common_test_pods
end

target 'OptimizelySDKSharedTVOSTests' do
  project 'OptimizelySDKShared/OptimizelySDKShared.xcodeproj/'
  platform :tvos, '9.0'
  common_test_pods
end

# OptimizelySDKDatafileManager targets
target 'OptimizelySDKDatafileManageriOSTests' do
  project 'OptimizelySDKDatafileManager/OptimizelySDKDatafileManager.xcodeproj/'
  platform :ios, '8.0'
  common_test_pods
end

target 'OptimizelySDKDatafileManagerTVOSTests' do
  project 'OptimizelySDKDatafileManager/OptimizelySDKDatafileManager.xcodeproj/'
  platform :tvos, '9.0'
  common_test_pods
end

# OptimizelySDKEventDispatcher targets
target 'OptimizelySDKEventDispatcheriOSTests' do
  project 'OptimizelySDKEventDispatcher/OptimizelySDKEventDispatcher.xcodeproj/'
  platform :ios, '8.0'
  common_test_pods
end

target 'OptimizelySDKEventDispatcherTVOSTests' do
  project 'OptimizelySDKEventDispatcher/OptimizelySDKEventDispatcher.xcodeproj/'
  platform :tvos, '9.0'
  common_test_pods
end

# OptimizelySDKUserProfileService targets
target 'OptimizelySDKUserProfileServiceiOSTests' do
  project 'OptimizelySDKUserProfileService/OptimizelySDKUserProfileService.xcodeproj/'
  platform :ios, '8.0'
  common_test_pods
end

target 'OptimizelySDKUserProfileServiceTVOSTests' do
  project 'OptimizelySDKUserProfileService/OptimizelySDKUserProfileService.xcodeproj/'
  platform :tvos, '9.0'
  common_test_pods
end

# OptimizelyiOSDemoApp target
target 'OptimizelyiOSDemoApp' do
  project 'OptimizelyDemoApp/OptimizelyDemoApp.xcodeproj/'
  platform :ios, '8.0'
  use_frameworks!
  analytics_pods
end

# OptimizelyTVOSDemoApp target
target 'OptimizelyTVOSDemoApp' do
  project 'OptimizelyDemoApp/OptimizelyDemoApp.xcodeproj/'
  platform :tvos, '9.0'
end

# OptimizelySDKiOSUniversal target
target 'OptimizelySDKiOSUniversalTests' do
    project 'OptimizelySDKUniversal/OptimizelySDKUniversal.xcodeproj/'
    platform :ios, '8.0'
    use_frameworks!
    common_test_pods
end

# OptimizelySDKTVOSUniversal targets
target 'OptimizelySDKTVOSUniversalTests' do
    project 'OptimizelySDKUniversal/OptimizelySDKUniversal.xcodeproj/'
    platform :tvos, '9.0'
    common_test_pods
end
