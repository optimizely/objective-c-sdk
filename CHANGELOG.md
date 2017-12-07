# Optimizely Objective-C SDK Changelog
## 1.5.0
December 6, 2017

### New Features
Introduced the following simplified initialization APIs:

* **Synchronous initialization** maximizes for speed by allowing the user to initialize the client immediately with the latest cached datafile. If no datafile is saved or there is an error retrieving the saved datafile, then the bundled datafile is used. If no bundled datafile is provided by the developer, then the SDK will return a dummy client.

```
/**
* Synchronously initializes the client using the latest
* cached datafile with a fallback of the bundled datafile
* (i.e., the datafile provided in the OPTLYManagerBuilder
* during the manager initialization).
*
* If the cached datafile fails to load, the bundled datafile
* is used.
*
*/
- (nullable OPTLYClient *)initialize;

```

* **Asynchronous initialization** allows the user to maximize having the most up-to-date datafile. The SDK attempts to download the datafile asynchronously. In the case that there is an error in the datafile download, the latest cached datafile (if one exists) is used. If there are no updates in the datafile, then the datafile is not downloaded and the latest cached datafile is used. If the cached datafile fails to load, then the bundled datafile is used.

```
/**
* Asynchronously initializes the client using the latest
* downloaded datafile with a fallback of the bundled datafile
* (i.e., the datafile provided in the OPTLYManagerBuilder
* during the manager initialization).
*
* In the case that there is an error in the datafile download,
*  the latest cached datafile (if one exists) is used.
*
* If there are no updates in the datafile, then the datafile is not
*  downloaded and the latest cached datafile is used.
*
* If the cached datafile fails to load, the bundled datafile
*  is used.
*
* @param callback The block called following the initialization
*   of the client.
*/
- (void)initializeWithCallback:(void(^ _Nullable)(NSError * _Nullable error,
OPTLYClient * _Nullable client))callback;
```
### Bug Fixes:
* Added `libsqlite3.tbd` to the Shared framework podspec and linked it in the build settings. 
* Crash caused by `Fatal Exception: NSRangeException` in `OPTLYHTTPRequestManager.m`. This crash occurred during a backoff retry in a datafile download or event dispatch because data strutures that were not threadsafe (used only for testing) were being modified. To resolve this, the data structures were wrapped in a flag and are only modifiable if unit tests are running.

### Cleanup:
* Fix migration to Xcode 9.0 compiler warnings regarding "NSError * __autoreleasing *" and "(^)(void) in blocks".
* DemoApp Swift code, icons, storyboards updated to Xcode 9.1.
* Pod updates.

## 1.4.0
October 6, 2017

### New Features
 * Numeric metrics, which allows the user to create an event tag that is tracked using numeric values
 
### Bug Fixes
*  Fixed crash when audience has no value.
*  Fixed datafile and event dispatcher backoff retry failure.
*  Fixed crash caused by missing value in attributes.
*  Removed obsolete segmentID as a key for attributes.
*  Pulled in JSONModel and FMDB to local source and renamed the class and libraries so that they are not pod dependencies.

### Breaking Changes
* Supply your own FMDB or JSONModel or use OPTLYFMDB or OPTLYJSONModel if you previously counted on third party FMDB or JSONModel being present.

## 1.3.0
August 28, 2017

### New Features
* Added the forced bucketing feature, which allows you to force users into variations in real time for QA purposes without requiring datafile downloads from the network. The following APIs have been introduced:

```
/**
* Force a user into a variation for a given experiment.
* The forced variation value does not persist across application launches.
*
* @param experimentKey The key for the experiment.
* @param userId The user ID to be used for bucketing.
* @param variationKey The variation key to force the user into.
*
* @return boolean A boolean value that indicates if the set completed successfully. 
*/
- (BOOL)setForcedVariation:(nonnull NSString *)experimentKey
                    userId:(nonnull NSString *)userId
              variationKey:(nonnull NSString *)variationKey;
```

```
/**
* Gets the forced variation for a given user and experiment.
*
* @param experimentKey The key for the experiment.
* @param userId The user ID to be used for bucketing.
*
* @return The variation the user was bucketed into. This value can be nil if the 
* forced variation fails. 
*/
- (nullable OPTLYVariation *)getForcedVariation:(nonnull NSString *)experimentKey
                                         userId:(nonnull NSString *)userId;
``` 
- Added the bucketing ID feature, which allows you to decouple bucketing from user identification so that a group of users who have the same bucketing ID are put into the same variation. 

- User Profile refactor, which includes a class rename to `User Profile Service`, along with the following API additions:

```
/**
 * Returns a user entity corresponding to the user ID.
 *
 * @param userId The user id to get the user entity of.
 * @returns A dictionary of the user profile details.
 **/
- (nullable NSDictionary *)lookup:(nonnull NSString *)userId;
```
```
/**
 * Saves the user profile.
 *
 * @param userProfile The user profile.
 **/
- (void)save:(nonnull NSDictionary *)userProfile;
```
- Added default attributes.

### Bug Fixes
* Fixed crash with string revenues in event tags. 

## 1.1.9
August 7, 2017

### New Features
* Added Apple App Extension support by adding `APPLICATION_EXTENSION_API_ONLY = YES` to Build Settings of all Optimizely frameworks.

### Bug Fixes
* Fixed potential bugs identified by Apple's Xcode static analyzer Analyze.

## 1.1.8
July 28, 2017

### Bug Fixes
* Fixed a `dispatchEvent` crash by changing a concurrent queue to a serial queue -- this was causing one of the properties we were accessing not thread-safe.

## 1.1.7
July 20, 2017

### Bug Fixes
* Fixed a crash caused by a dangling pointer when `dispatchEvent` is called. `strongSelf` captures the state of self (which can be an `eventDispatcher` object or `nil`) at the time the block is called. `strongSelf` will hold onto whatever it is referencing for the duration of the block execution. Therefore, `strongSelf` is still pointing to `pendingDispatchEvents` even when it gets deallocated at the time the `eventDispatcher` is deallocated. This issue was resolved by not capturing `self` using `strongSelf` and keeping the `self` reference to `self` or `weakSelf`.

## 1.1.3
July 7, 2017

### Bug Fixes
* Added `NS_SWIFT_NOTHROW` to make 4 `variableXxx:...:error:` Swift method signatures more consistent in appearance.

### Breaking Changes
* Signatures for 2 existing `variableXxx:...:error:` Swift methods changed.

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
