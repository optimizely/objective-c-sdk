Pod::Spec.new do |s|
  s.name                    = "OptimizelySDKCore"
  s.version                 = "0.1.1"
  s.summary                 = "Optimizely server-side testing core framework."
  s.homepage                = "http://developers.optimizely.com/server/reference/index.html?language=objectivec"
  s.license                 = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author                  = { "Optimizely" => "support@optimizely.com" }
  s.platform                = :ios, '9.3', :tvos, '9.2'
  s.ios.deployment_target   = "8.0"
  s.tvos.deployment_target  = "9.0"
  s.source                  = {
    :git => "https://github.com/optimizely/objective-c-sdk.git",
    :tag => "core-"+s.version.to_s
  }
  s.source_files            = "OptimizelySDKCore/OptimizelySDKCore/*.{h,m}",  "OptimizelySDKCore/Frameworks/**/*.{c,h,m}"
  s.public_header_files     = "OptimizelySDKCore/OptimizelySDKCore/*.h"
  s.exclude_files           = "OPTLYMacros.h", "OPTLYLog.h", "OPTLYLog.m"
  s.framework               = "Foundation"
  s.requires_arc            = true
  xcconfig_path             = "OptimizelySDKCore/Config/OptimizelySDKCore.xcconfig"
  s.preserve_path           = xcconfig_path
  s.xcconfig                = File.open(File.join(Dir.pwd, xcconfig_path)) { |file| Hash[file.each_line.map { |line| line.split("=", 2) }] }
  s.subspec "JSONModel" do |ss|
      ss.dependency 'JSONModel', '= 1.3.0'
      ss.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/JSONModel" }
  end

end
