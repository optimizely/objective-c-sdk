Pod::Spec.new do |s|
  s.name                    = "OptimizelySDKTVOS"
  s.version                 = "1.5.0-RC"
  s.summary                 = "Optimizely server-side testing framework for tvOS."
  s.homepage                = "http://developers.optimizely.com/server/reference/index.html?language=objectivec"
  s.license                 = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author                  = { "Optimizely" => "developers@optimizely.com" }
  s.platform                = :tvos, '11.0'
  s.tvos.deployment_target  = "9.0"
  s.source                  = { 
    :git => "https://github.com/optimizely/objective-c-sdk.git",
    :tag => "tvOS-"+s.version.to_s
  }
  s.source_files            = "OptimizelySDKTVOS/OptimizelySDKTVOS/*.{h,m}"
  s.public_header_files     = "OptimizelySDKTVOS/OptimizelySDKTVOS/*.h"
  s.framework               = "Foundation"
  s.requires_arc            = true
  s.xcconfig                = { 'GCC_PREPROCESSOR_DEFINITIONS' => "OPTIMIZELY_SDK_TVOS_VERSION=@\\\"#{s.version}\\\"" }
  s.dependency 'OptimizelySDKEventDispatcher', '1.5.0-RC'
  s.dependency 'OptimizelySDKUserProfileService', '1.5.0-RC'
  s.dependency 'OptimizelySDKDatafileManager', '1.5.0-RC'
end
