Pod::Spec.new do |s|
  s.name                    = "OptimizelySDKUserProfileService"
  s.version                 = "1.1.0"
  s.summary                 = "Optimizely server-side testing user profile framework."
  s.homepage                = "http://developers.optimizely.com/server/reference/index.html?language=objectivec"
  s.license                 = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author                  = { "Optimizely" => "support@optimizely.com" }
  s.platform                = :ios, '10.1', :tvos, '10.0'
  s.ios.deployment_target   = "8.0"
  s.tvos.deployment_target  = "9.0"
  s.source                  = {
    :git => "https://github.com/optimizely/objective-c-sdk.git",
    :tag => "userProfile-"+s.version.to_s
  }
  s.source_files            = "OptimizelySDKUserProfileService/OptimizelySDKUserProfileService/*.{h,m}"
  s.public_header_files     = "OptimizelySDKUserProfileService/OptimizelySDKUserProfileService/*.h"
  s.framework               = "Foundation"
  s.requires_arc            = true
  s.xcconfig                = { 'GCC_PREPROCESSOR_DEFINITIONS' => "OPTIMIZELY_SDK_USER_PROFILE_VERSION=@\\\"#{s.version}\\\"" }
  s.subspec "JSONModel" do |ss|
      ss.dependency 'JSONModel', '= 1.3.0'
      ss.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/JSONModel" }
  end
  s.dependency 'OptimizelySDKShared', '1.1.0'
end
