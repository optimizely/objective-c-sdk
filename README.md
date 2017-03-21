# Objective-C SDK
[![Build Status](https://travis-ci.org/optimizely/objective-c-sdk.svg?branch=master)](https://travis-ci.org/optimizely/objective-c-sdk/)
[![Apache 2.0](https://img.shields.io/github/license/nebula-plugins/gradle-extra-configurations-plugin.svg)](http://www.apache.org/licenses/LICENSE-2.0)

This repository houses the Optimizely Mobile and OTT experimentation SDKs.


## Getting Started

### Using the SDK

See the [Mobile developer documentation](https://developers.optimizely.com/x/solutions/sdks/reference/index.html?language=objectivec&platform=mobile) or [OTT developer documentation](https://developers.optimizely.com/x/solutions/sdks/reference/index.html?language=objectivec&platform=ott) to learn how to set
up an Optimizely X project and start using the SDK.

### Requirements
* iOS 8.0+ / tvOS 9.0+
* [FMDB](https://github.com/ccgus/fmdb)
* [JSONModel](https://github.com/jsonmodel/jsonmodel)

### Installing the SDK
 
Please note below that _\<platform\>_ is used to represent the platform on which you are building your app. Currently, we support ```iOS``` and ```tvOS``` platforms.

#### Cocoapod 
1. Add the following line to the _Podfile_:<pre>pod 'OptimizelySDK\<platform\>'</pre>

2. Run the following command: <pre>``` pod install ```</pre>

Further installation instructions for Cocoapods: https://guides.cocoapods.org/using/getting-started.html

#### Carthage
1. Add the following lines to the _Cartfile_:<pre> 
github "optimizely/objective-c-sdk"
github "jsonmodel/jsonmodel"
github "ccgus/fmdb"
</pre>

2. Run the following command:<pre>```carthage update```</pre>

3. Link the frameworks to your project. Go to your project target's **Link Binary With Libraries** and drag over the following from the _Carthage/Build/\<platform\>_ folder: <pre> 
      FMDB.framework
      JSONModel.framework
      OptimizelySDKCore.framework
      OptimizelySDKDatafileManager.framework
      OptimizelySDKEventDispatcher.framework
      OptimizelySDKShared.framework
      OptimizelySDKUserProfile.framework<
      OptimizelySDK\<platform\>.framework</pre>

4. To ensure that proper bitcode-related files and dSYMs are copied when archiving your app, you will need to install a Carthage build script:
      - Add a new **Run Script** phase in your target's **Build Phase**.</br>
      - In the script area include:<pre>
      ```/usr/local/bin/carthage copy-frameworks```</pre> 
      - Add the frameworks to the **Input Files** list:<pre>
            ```$(SRCROOT)/Carthage/Build/<platform>/FMDB.framework```
            ```$(SRCROOT)/Carthage/Build/<platform>/JSONModel.framework```
            ```$(SRCROOT)/Carthage/Build/<platform>/OptimizelySDKCore.framework```
            ```$(SRCROOT)/Carthage/Build/<platform>/OptimizelySDKDatafileManager.framework```
            ```$(SRCROOT)/Carthage/Build/<platform>/OptimizelySDKEventDispatcher.framework```
            ```$(SRCROOT)/Carthage/Build/<platform>/OptimizelySDKShared.framework```
            ```$(SRCROOT)/Carthage/Build/<platform>/OptimizelySDKUserProfile.framework```
            ```$(SRCROOT)/Carthage/Build/<platform>/OptimizelySDK<platform>.framework```</pre>

Futher installation instructions for Carthage: https://github.com/Carthage/Carthage

#### Clone Source
Clone repo and manually add source to project to build. 

### Contributing
Please see [CONTRIBUTING](CONTRIBUTING.md).

