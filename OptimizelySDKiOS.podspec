Pod::Spec.new do |s|
  s.name                    = "OptimizelySDKiOS"
  s.version                 = "1.1.0"
  s.summary                 = "Optimizely server-side testing framework for iOS."
  s.homepage                = "http://developers.optimizely.com/server"
  s.license                 = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author                  = "Optimizely"
  s.platform                = :ios, '10.1'
  s.ios.deployment_target   = "8.0"
  s.source                  = {
    :git => "https://github.com/optimizely/objective-c-sdk.git",
    :tag => "iOS-"+s.version.to_s
  }
  s.source_files            = "OptimizelySDKiOS/OptimizelySDKiOS/*.{h,m}"
  s.public_header_files     = "OptimizelySDKiOS/OptimizelySDKiOS/*.h"
  s.framework               = "Foundation"
  s.requires_arc            = true
  s.xcconfig                = { 'GCC_PREPROCESSOR_DEFINITIONS' => "OPTIMIZELY_SDK_iOS_VERSION=@\\\"#{s.version}\\\"" }
  s.dependency 'OptimizelySDKEventDispatcher', '1.1.0'
  s.dependency 'OptimizelySDKUserProfileService', '1.1.0'
  s.dependency 'OptimizelySDKDatafileManager', '1.1.0'
end
