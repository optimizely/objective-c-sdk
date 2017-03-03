Pod::Spec.new do |s|
  s.name                    = "OptimizelySDKTVOS"
  s.version                 = "1.0.1-alpha1"
  s.summary                 = "Optimizely server-side testing framework for tvOS."
  s.homepage                = "http://developers.optimizely.com/server/reference/index.html?language=objectivec"
  s.license                 = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author                  = { "Optimizely" => "developers@optimizely.com" }
  s.platform                = :tvos, '10.0'
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
  s.subspec "JSONModel" do |ss|
      ss.dependency 'JSONModel', '= 1.3.0'
      ss.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/JSONModel" }
  end
  s.dependency 'OptimizelySDKEventDispatcher', '1.0.1-alpha1'
  s.dependency 'OptimizelySDKUserProfile', '1.0.1-alpha1'
  s.dependency 'OptimizelySDKDatafileManager', '1.0.1-alpha1'
end
