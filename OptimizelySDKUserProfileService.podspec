Pod::Spec.new do |s|
  s.name                    = "OptimizelySDKUserProfileService"
  s.version                 = "2.1.4"
  s.summary                 = "Optimizely server-side testing user profile framework."
  s.homepage                = "http://developers.optimizely.com/server/reference/index.html?language=objectivec"
  s.license                 = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author                  = { "Optimizely" => "support@optimizely.com" }
  s.ios.deployment_target   = "8.0"
  s.tvos.deployment_target  = "9.0"
  s.source                  = {
    :git => "https://github.com/optimizely/objective-c-sdk.git",
    :tag => "v"+s.version.to_s
  }
  s.source_files            = "OptimizelySDKUserProfileService/OptimizelySDKUserProfileService/*.{h,m}"
  s.public_header_files     = "OptimizelySDKUserProfileService/OptimizelySDKUserProfileService/*.h"
  s.framework               = "Foundation"
  s.requires_arc            = true
  s.xcconfig                = { 'GCC_PREPROCESSOR_DEFINITIONS' => "OPTIMIZELY_SDK_USER_PROFILE_VERSION=@\\\"#{s.version}\\\"" }
  s.dependency 'OptimizelySDKShared', '2.1.4'
end
