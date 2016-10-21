Pod::Spec.new do |s|
  s.name                    = "OptimizelySDKiOS"
  s.version                 = "0.1.6"
  s.summary                 = "Optimizely server-side testing framework for iOS."
  s.homepage                = "http://developers.optimizely.com/server"
  s.license                 = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author                  = "Optimizely"
  s.platform                = :ios, '9.3'
  s.ios.deployment_target   = "8.0"
  s.source                  = {
    :git => "https://github.com/optimizely/objective-c-sdk.git",
    :tag => "iOS-"+s.version.to_s
  }
  s.source_files            = "OptimizelySDKiOS/OptimizelySDKiOS/*.{h,m}"
  s.public_header_files     = "OptimizelySDKiOS/OptimizelySDKiOS/*.h"
  s.framework               = "Foundation"
  s.requires_arc            = true
  xcconfig_path             = "OptimizelySDKiOS/Config/OptimizelySDKiOS.xcconfig"
  s.preserve_path           = xcconfig_path
  s.xcconfig                = File.open(File.join(Dir.pwd, xcconfig_path)) { |file| Hash[file.each_line.map { |line| line.split("=", 2) }] }
  s.subspec "JSONModel" do |ss|
      ss.dependency 'JSONModel', '~> 1.3.0'
      ss.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/JSONModel" }
  end
  s.dependency 'OptimizelySDKCore'
end
