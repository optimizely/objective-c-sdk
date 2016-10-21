Pod::Spec.new do |s|
  s.name                    = "OptimizelySDKTVOS"
  s.version                 = "0.1.6"
  s.summary                 = "Optimizely server-side testing framework for tvOS."
  s.homepage                = "http://developers.optimizely.com/server/reference/index.html?language=objectivec"
  s.license                 = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author                  = { "Optimizely" => "developers@optimizely.com" }
  s.platform                = :tvos, '9.2'
  s.tvos.deployment_target  = "9.0"
  s.source                  = { 
    :git => "https://github.com/optimizely/objective-c-sdk.git",
    :tag => "tvOS-"+s.version.to_s
  }
  s.source_files            = "OptimizelySDKTVOS/OptimizelySDKTVOS/*.{h,m}"
  s.public_header_files     = "OptimizelySDKTVOS/OptimizelySDKTVOS/*.h"
  s.framework               = "Foundation"
  s.requires_arc            = true
  xcconfig_path             = "OptimizelySDKTVOS/Config/OptimizelySDKTVOS.xcconfig"
  s.preserve_path           = xcconfig_path
  s.xcconfig                = File.open(File.join(Dir.pwd, xcconfig_path)) { |file| Hash[file.each_line.map { |line| line.split("=", 2) }] }
  s.subspec "JSONModel" do |ss|
      ss.dependency 'JSONModel', '~> 1.3.0'
      ss.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/JSONModel" }
  end
  s.dependency 'OptimizelySDKCore'
end
