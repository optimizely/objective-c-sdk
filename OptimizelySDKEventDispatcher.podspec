Pod::Spec.new do |s|
  s.name                    = "OptimizelySDKEventDispatcher"
  s.version                 = "2.0.2-beta2"
  s.summary                 = "Optimizely server-side testing event dispatcher framework."
  s.homepage                = "http://developers.optimizely.com/server/reference/index.html?language=objectivec"
  s.license                 = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author                  = { "Optimizely" => "support@optimizely.com" }
  s.ios.deployment_target   = "8.0"
  s.tvos.deployment_target  = "9.0"
  s.source                  = {
    :git => "https://github.com/optimizely/objective-c-sdk.git",
    :tag => "v"+s.version.to_s
  }
  s.source_files            = "OptimizelySDKEventDispatcher/OptimizelySDKEventDispatcher/*.{h,m}"
  s.public_header_files     = "OptimizelySDKEventDispatcher/OptimizelySDKEventDispatcher/*.h"
  s.framework               = "Foundation"
  s.requires_arc            = true
  s.xcconfig                = { 'GCC_PREPROCESSOR_DEFINITIONS' => "OPTIMIZELY_SDK_VERSION=@\\\"#{s.version}\\\"" }
  s.dependency 'OptimizelySDKShared', '2.0.2-beta2'
end
