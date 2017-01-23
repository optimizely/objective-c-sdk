# Optimizely Objective-C SDK Changelog
## 1.0.0
January 23, 2017

### GA Release

## 0.5.0
January 18, 2017

### New Features
*  Event Dispatcher: You can now specify a limit for how many events to persist on disk when the SDK is unable to send them.
*  Improved log messages. 

### Breaking Changes
*  All APIs have been changed to be more compatible with Swift language conventions. 

### Bug Fixes
*  User Profile: Persist experiment and variation IDs instead of keys. Allow multiple experiment and variation mappings to be stored for each user.
*  Whitelisting: Whitelisted variations will not be persisted in User Profile. Whitelisting will not check User Profile for bucketing information.
*  Track Event: Conversion events will no longer be sent if the experiments the event is part of do not pass audience evaluation.

## 0.3.0 
December 22, 2016

### New Features
*  IP Anonymization: Anonymize the IPs of your end users. Optimizely will remove the last octect of IPV4 addresses before storing them.
*  Datafile Versioning: Each Optimizely SDK will download a specific datafile version matching the SDK to ensure backwards compatibility.
*  Optimizely Notifications: Optimizely will post notifications to the notification center when activate or track are called successfully. Developers can subscribe to these notifications to send the bucketing information to other analytics SDKs. 

### Breaking Changes
*  Live variable getters have been changed.

## 0.2.1 
December 9, 2016

### New Features
*  Introduced the `OPTLYDatafileManager` to manage fetching, syncing, and persisting the Optimizely datafile.
*  Introduced the `OPTLYUserProfile` module to persist experiment and variation bucketing for users.
*  Created the `OptimizelySDKEventDispatcher` to keep a reference to a more advanced `OPTLYEventDispatcher`.
*  Introduced `OPTLYManager` and `OPTLYClient`  as part of the OptimizelySDKShared module. The Client wraps the Optimizely core in order to prevent crashes. The Manager oversees the datafile manager and uses it to initialize Client instances and caches the most recently updated Client for easy of access.
*  When you initialize the Manager, you can pass in your own custom modules of the Datafile Manager, Event Dispatcher, Error Handler, Logger, and User Profile and these will be passed on to the Client and Optimizely Core when they are initialized. 
*  Live Variables: experiment on variable values in real-time. You can control these values from the Optimizely UI to roll out features and tweak behavior of your app in real time.

## 0.1.0 
September 27, 2016

Initial Release

*  Released Optimizely SDK AB Testing SDKs through CocoaPods. 
*  Developers can activate experiments and track experiments. 
