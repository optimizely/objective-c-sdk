# Optimizely Objective-C SDK Changelog
## 1.1.5
Jul 13, 2017

### Bug Fixes
* Fixed a crash caused by a dangling pointer when `dispatchEvent` is called. `strongSelf` captures the state of self (which can be an `eventDispatcher` object or `nil`) at the time the block is called. `strongSelf` will hold onto whatever it is referencing for the duration of the block execution. Therefore, `strongSelf` is still pointing to `pendingDispatchEvents` even when it gets deallocated at the time the `eventDispatcher` is deallocated. This issue was resolved by not capturing `self` using `strongSelf` and keeping the `self` reference to `self` or `weakSelf`.

## 1.1.3
Jul 7, 2017

### Bug Fixes
* Added NS_SWIFT_NOTHROW to make 4 variableXxx:...:error: Swift method signatures more consistent in appearance.

### Breaking Changes
* Signatures for 2 existing variableXxx:...:error: Swift methods changed.

## 1.1.1
May 23, 2017

### New Features
* Added unexported_symbols.sh to create unexported_symbols.txt which hides all third-party dependency symbols in the Universal frameworks.

### Breaking Changes
* Supply your own FMDB or JSONModel if you previously counted on Universal frameworks exposing these third-party dependencies.

## 1.1.0
May 2, 2017

### New Features
* Added the Objective-C universal framework, which allows users to install the SDK without a third-party dependency manager.
* Added the event tags parameter in the track API, which allows user to pass in more than one event tags at a time. The new events parameter is a map of event tag names to event tag values, which can be an NSNumber that contains a float, double, integer, or boolean, or an NSString:
```
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId
    eventTags:(nonnull NSDictionary<NSString *, id> *)eventTags;
```
The track API with just one event value is still available, but will be deprecated after two releases:
``` 
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId
   eventValue:(nonnull NSNumber *)eventValue __attribute 
```

* Updated the README with instructions for Carthage and Universal framework installations. 

### Bug Fixes
* Fixed multiple base conditions audience parsing (merged the external pull request from @docsimon: https://github.com/optimizely/objective-c-sdk/pull/124).
* Fixed how NOT conditions are parsed in the audience evaluation. 
* Fixed event negative timestamps for 32-bit architecture devices. 

## 1.0.1
March 6, 2017

### New Features
* Created a tvOS demo app.
* Added integration sample code for iOS.

### Bug Fixes
* Initializing the client with the saved datafile `initialize()` or `-(OPTLYClient *)initialize` now pulls from the saved datafile (before, this method was dependent on the builder’s datafile).
* Fixed an SQLite error that was occurring when multiple FMDatabaseQueues were created. 
* Fixed a bug with the events cache for tvOS such that when the app is background, the events are not purged.
* Experiment status is now checked so that users are not bucketed into a variation if the experiment is paused. 
* Fixed linking errors when building and running demo apps on iOS and tvOS devices.
* Copyright header updates.

## 1.0.0
January 23, 2017

*  GA Release

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
