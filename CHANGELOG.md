# Optimizely Objective-C SDK Changelog

## 3.0.2
February 27th, 2019

This release removes type casting in Swift to NSObject in user attributes

### New Features
* No new features for this patch release.

### Bug Fixes:
* Change all instances of attributes and eventTags from NSDictionary<NSString*,NSObject*> to NSDictionary<NSString*,id>

## 3.0.1
February 26th, 2019

This includes a fix for a build error observed with some development settings  

### New Features
* No new features for this patch release.

### Bug Fixes:
* Type cast id<UserProfileService> to NSObject* to fix a build error with some development settings

## 3.0.0
February 14th, 2019

The 3.0 release improves event tracking and supports additional audience targeting functionality.

### New Features:
* Event tracking ([#359](https://github.com/optimizely/objective-c-sdk/pull/359)):
  * The Track method now dispatches its conversion event _unconditionally_, without first determining whether the user is targeted by a known experiment that uses the event. This may increase outbound network traffic.
  * In Optimizely results, conversion events sent by 3.0 SDKs don't explicitly name the experiments and variations that are currently targeted to the user. Instead, conversions are automatically attributed to variations that the user has previously seen, as long as those variations were served via 3.0 SDKs or by other clients capable of automatic attribution, and as long as our backend actually received the impression events for those variations.
  * Altogether, this allows you to track conversion events and attribute them to variations even when you don't know all of a user's attribute values, and even if the user's attribute values or the experiment's configuration have changed such that the user is no longer affected by the experiment. As a result, **you may observe an increase in the conversion rate for previously-instrumented events.** If that is undesirable, you can reset the results of previously-running experiments after upgrading to the 3.0 SDK.
  * This will also allow you to attribute events to variations from other Optimizely projects in your account, even though those experiments don't appear in the same datafile.
  * Note that for results segmentation in Optimizely results, the user attribute values from one event are automatically applied to all other events in the same session, as long as the events in question were actually received by our backend. This behavior was already in place and is not affected by the 3.0 release.
* Support for all types of attribute values, not just strings ([#309](https://github.com/optimizely/objective-c-sdk/pull/309)).
  * All values are passed through to notification listeners.
  * Strings, booleans, and valid numbers are passed to the event dispatcher and can be used for Optimizely results segmentation. A valid number is a finite number in the inclusive range [-2⁵³, 2⁵³]. 
  * Strings, booleans, and valid numbers are relevant for audience conditions.
* Support for additional matchers in audience conditions ([#337](https://github.com/optimizely/objective-c-sdk/pull/337)):
  * An `exists` matcher that passes if the user has a non-null value for the targeted user attribute and fails otherwise.
  * A `substring` matcher that resolves if the user has a string value for the targeted attribute.
  * `gt` (greater than) and `lt` (less than) matchers that resolve if the user has a valid number value for the targeted attribute. A valid number is a finite number in the inclusive range [-2⁵³, 2⁵³].
  * The original (`exact`) matcher can now be used to target booleans and valid numbers, not just strings.
* Support for A/B tests, feature tests, and feature rollouts whose audiences are combined using `"and"` and `"not"` operators, not just the `"or"` operator.
* Datafile-version compatibility check: The SDK will remain uninitialized (i.e., will gracefully fail to activate experiments and features) if given a datafile version greater than 4.
* Updated Pull Request template and commit message guidelines.
* Support for empty bucketing IDs when evaluating feature rollouts ([#367](https://github.com/optimizely/objective-c-sdk/pull/367)).

### Breaking Changes:
* Conversion events sent by 3.0 SDKs don't explicitly name the experiments and variations that are currently targeted to the user, so these events are unattributed in raw events data export. You must use the new _results_ export to determine the variations to which events have been attributed.
* Previously, notification listeners were only given string-valued user attributes because only strings could be passed into various method calls. That is no longer the case. The `ActivateListener` and `TrackListener` interfaces now receive user attributes as `NSDictionary<NSString *, NSObject *> * _Nullable` instead of  `NSDictionary<NSString *,NSString *> * _Nonnull`.
* The Localytics integration now relies on the user profile service to attribute events to the user's variations.
* Drops support for the `variableBoolean`, `variableDouble`, `variableInteger`, and `variableString` APIs. Please migrate to the Feature Management APIs which were introduced in the 2.x releases.

### Bug Fixes:
* Experiments and features can no longer activate when a negatively targeted attribute has a missing, null, or malformed value.
  * Audience conditions (except for the new `exists` matcher) no longer resolve to `false` when they fail to find an legitimate value for the targeted user attribute. The result remains `null` (unknown). Therefore, an audience that negates such a condition (using the `"not"` operator) can no longer resolve to `true` unless there is an unrelated branch in the condition tree that itself resolves to `true` ([#355](https://github.com/optimizely/objective-c-sdk/pull/355)). 
  * Support for empty user IDs ([#356](https://github.com/optimizely/objective-c-sdk/pull/356)).
* Updated `JSONModel` definitions ([#329](https://github.com/optimizely/objective-c-sdk/pull/329)).

## 2.1.6
January 25th, 2019

This includes a fix for revenue and metrics.  Numbers 0 and 1 were evaluated as false and true causing us to drop them from the event.  

### New Features
* No new features for this patch release.

### Bug Fixes:
* Check for BOOL type but allow number values 0 and 1 in revenue and metrics to go to results.
* Only remove old variation assignments from the user profile service when there are >= 100 persisted assignments.

## 2.1.5
December 6th, 2018

This includes a potential fix to a problem with lazy loading the OPTLYFileManager.

### New Features
* No new features for this patch release.

### Bug Fixes:
* Wrap fileManager accessor in a serial queue to avoid multiple threads creating multiple fileManagers causing an access to memory that is no longer valid.

## 2.1.4
November 19, 2018

This release fixes remaining issues having to cast to access data model objects.  Also, sets TLS minimum version. 

### New Features
* No new features for this patch release.

### Bug Fixes:
* Fix Swift 4 accessing data model properties without cast.
* Pin TLS minimum version.

## 2.1.3
November 8, 2018

This release fixes a possible issue with tvOS.  The issue is that if the app goes foreground and background the events get flushed.  However, there might be a removeEvent queued.  This remove event was failing because the queue was emptry.

### New Features
* No new features for this patch release.

### Bug Fixes:
* Fix tvOS issue with the event queue
* Fix Swift 4 accessing ProjectConfig properties such as experiments used to require a cast.  That is now fixed.

## 2.1.2
September 28, 2018

This release supports xcode 10 and Swift 4. This fixes the carthage issue.

### New Features
* No new features for this patch release.

### Bug Fixes:
* Fix nullable and nonnull tags so that Swift 4 functions properly.
* Rename protocol Optional for JSON to OPTLYOptional.
* Fix logging of attribute as missing when included.

## 2.1.1
September 27, 2018

This release supports xcode 10 and Swift 4. However, there seems to still be an issue with Carthage.

### New Features
* No new features for this patch release.

### Bug Fixes:
* Fix nullable and nonnull tags so that Swift 4 functions properly.
* Rename protocol Optional for JSON to OPTLYOptional.

## 2.1.0
August 2nd, 2018

This release is the 2.x general availability launch of the Objective-C SDK, which includes a number of significant new features that are now stable and fully supported. [Feature Management](https://developers.optimizely.com/x/solutions/sdks/reference/?language=objectivec#feature-introduction) is now generally available, which introduces  new APIs and which replaces the SDK's variable APIs (`getVariableBoolean`, etc.) with the feature variable APIs (`getFeatureVariableBoolean`, etc.).  

The primary difference between the new Feature Variable APIs and the older, Variable APIs is that they allow you to link your variables to a Feature (a new type of entity defined in the Optimizely UI) and to a feature flag in your application. This in turn allows you to run Feature Tests and Rollouts on both your Features and Feature Variables. For complete details of the Feature Management APIs, see the "New Features" section below.

To learn more about Feature Management, read our [knowledge base article introducing the feature](https://help.optimizely.com/Set_Up_Optimizely/Develop_a_product_or_feature_with_Feature_Management).

### New Features
* Introduces the `isFeatureEnabled` API, a featue flag used to determine whether to show a feature to a user. The `isFeatureEnabled` should be used in place of the `activate` API to activate experiments running on features. Specifically, calling this API causes the SDK to evaluate all [Feature Tests](https://developers.optimizely.com/x/solutions/sdks/reference/?language=objectivec#activate-feature-tests) and [Rollouts](https://developers.optimizely.com/x/solutions/sdks/reference/?language=objectivec#activate-feature-rollouts) associated with the provided feature key.
```
/**
 * Determine whether a feature is enabled.
 * Send an impression event if the user is bucketed into an experiment using the feature.
 * @param featureKey The key for the feature flag.
 * @param userId The user ID to be used for bucketing.
 * @param attributes The user's attributes.
 * @return YES if feature is enabled, false otherwise.
 */
- (BOOL)isFeatureEnabled:(nullable NSString *)featureKey userId:(nullable NSString *)userId attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;
```


* Get all enabled features for a user by calling the following method, which returns a list of strings representing the feature keys:
```
/**
 * Get array of features that are enabled for the user.
 * @param userId The user ID to be used for bucketing.
 * @param attributes The user's attributes.
 * @return NSArray<NSString> Array of feature keys that are enabled for the user.
 */
- (NSArray<NSString *> *_Nonnull)getEnabledFeatures:(nullable NSString *)userId
                                         attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;
```

* Introduces Feature Variables to configure or parameterize your feature. There are four variable types: `BOOL`, `double`, `int`, `NSString*`. Note that unlike the Variable APIs, the Feature Variable APIs do not dispatch impression events.  Instead, first call `isFeatureEnabled` to activate your experiments, then retrieve your variables.
```
/**
 * API's that get feature variable values.
 * @param featureKey The key for the feature flag.
 * @param variableKey The key for the variable.
 * @param userId The user ID to be used for bucketing.
 * @param attributes The user's attributes.
 * @return feature variable value.
 */
- (NSNumber *)getFeatureVariableBoolean:(nullable NSString *)featureKey
                      variableKey:(nullable NSString *)variableKey
                           userId:(nullable NSString *)userId
                       attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;
- (NSNumber *)getFeatureVariableDouble:(nullable NSString *)featureKey
                       variableKey:(nullable NSString *)variableKey
                            userId:(nullable NSString *)userId
                        attributes:(nullable NSDictionary<NSString *, id> *)attributes;
- (NSNumber *)getFeatureVariableInteger:(nullable NSString *)featureKey
                     variableKey:(nullable NSString *)variableKey
                          userId:(nullable NSString *)userId
                      attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;
- (NSString *_Nullable)getFeatureVariableString:(nullable NSString *)featureKey
                           variableKey:(nullable NSString *)variableKey
                                userId:(nullable NSString *)userId
                            attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;
```

* Introducing Optimizely Notification Center with Notification Listeners
Optimizely object now has a Notification Center
```
    @property (nonatomic, strong, readonly, nullable) OPTLYNotificationCenter *notificationCenter;
```
with Notification Listeners APIs
```
- (NSInteger)addActivateNotificationListener:(nonnull ActivateListener)activateListener;
- (NSInteger)addTrackNotificationListener:(TrackListener _Nonnull )trackListener;
- (BOOL)removeNotificationListener:(NSUInteger)notificationId;
- (void)clearNotificationListeners:(OPTLYNotificationType)type;
- (void)clearAllNotificationListeners;
```

* Introduces SDK Keys, which allow you to use Environments with the Objective-C SDK. Use an SDK Key to initialize your OptimizelyManager, and the SDK will retrieve the datafile for the environment associated with the SDK Key. This replaces initialization with Project ID.
```
// Create the manager and set the datafile manager
 OPTLYManager *manager = [OPTLYManager init:^(OPTLYManagerBuilder * _Nullable builder) {
     builder.sdkKey = @"SDK_KEY_HERE";
 }];
```

### Deprecations
* Version 2.1.0 deprecates the Variable APIs: `variableBoolean`, `variableDouble`, `variableInteger`, and `variableString` 

* Replace use of the Variable APIs with Feature Mangement's Feature Variable APIs, described above

* We will continue to support the Variable APIs until the 3.x release, but we encourage you to upgrade as soon as possible

* You will see a deprecation warning if using a 2.x SDK with the deprecated Variable APIs, but the APIs will continue to behave as they did in 1.x versions of the SDK

### Upgrading from 1.x

In order to begin using Feature Management, you must discontinue use of 1.x variables in your experiments.  First, pause and archive all experiments that use variables. Then, contact [Optimizely Support](https://optimizely.zendesk.com/hc/en-us/requests) in order to have your project converted from the 1.x SDK UI to the 2.x SDK UI. In addition to granting access to the Feature Management UI, upgrading to the 2.x SDK UI grants you access to [Environments](https://developers.optimizely.com/x/solutions/sdks/reference/?language=objectivec#environments) and other new features.
* *Note*: All future feature development on the Objective-C SDK will assume that your are using the 2.x SDK UI, so we encourage you to upgrade as soon as possible.


### Breaking changes
* The `track` API with revenue value as a stand-alone parameter has been removed. The revenue value should be passed in as an entry of the event tags map. The key for the revenue tag is `revenue` and will be treated by Optimizely as the key for analyzing revenue data in results.
```
NSDictionary *tags = @{@"revenue" : @6432};
 // reserved "revenue" tag
[optimizelyClient track:@"event_key" userId:@"user_1" attributes:nil eventTags:tags];
```

* We have removed deprecated classes with the `OPTLYNotificationBroadcaster` in favor of the new API with the `OPTLYNotificationCenter`. We have also added some convenience methods to add these listeners. Finally, some of the API names have changed slightly (e.g. `clearAllNotifications` is now `clearAllNotificationListener`)


## 2.0.2-beta4
August 1, 2018

** This is beta 4 and a release candidate.  There are several things to note about this pre-release.  This release includes Feature Management and is backward compatible. The APIs mentioned in beta 3 are included.  

### Bug Fixes:
* Force builderWithBlock for OPTLYManagerBuilder.
* Return nil for getFeatureVariable[Integer,Double,Boolean,String] if the value type is incorrect or the feature variable does not exist.

## 2.0.2-beta3
July 24, 2018

** This is beta 3 and a possible release candidate.  There are several things to note about this pre-release.  This release includes Feature Management and is backward compatible. The APIs mentioned in beta 2 are included.  

### New Features
Same as 2.0.2-beta2 (see below)

* Introduces support for bot filtering.
* Supports Mobile and Fullstack projects.
* Introduces support for Environments.
* Support for Feature Management (see previous release notes).
* Backward support for deprecated Live Variables.

### Bug Fixes:
* Fix static init methods that caused problems in Swift 4

## 2.0.2-beta2
Jun 25, 2018

**This "-beta2" pre-release corrects two significant bugs present in the
previous 2.0.x releases which have been withdrawn.  Please note that
2.0+ SDKs are incompatible with existing 1.x Mobile Optimizely
projects.  Before you use 2.0+ and Feature Management, please contact
your Optimizely account team.  If you are not upgrading to Feature
Management, we recommend remaining on your current 1.x SDK.**

This major release of the Optimizely SDK introduces APIs for Feature Management.

### New Features
* Introduces the `isFeatureEnabled:userId:attributes:` API to determine whether to show a feature to a user or not.
```
/**
 * Determine whether a feature is enabled.
 * Send an impression event if the user is bucketed into an experiment using the feature.
 * @param featureKey The key for the feature flag.
 * @param userId The user ID to be used for bucketing.
 * @param attributes The user's attributes.
 * @return YES if feature is enabled, false otherwise.
 */
- (BOOL)isFeatureEnabled:(nullable NSString *)featureKey userId:(nullable NSString *)userId attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;
```

* You can get all the enabled features for the user by calling the `getEnabledFeatures:attributes:` API which returns an array of strings representing the feature keys:
```
/**
 * Get array of features that are enabled for the user.
 * @param userId The user ID to be used for bucketing.
 * @param attributes The user's attributes.
 * @return NSArray<NSString> Array of feature keys that are enabled for the user.
 */
- (NSArray<NSString *> *_Nonnull)getEnabledFeatures:(nullable NSString *)userId
                                         attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;
```

* Introduces Feature Variables to configure or parameterize your feature. There are four variable types: `BOOL`, `double`, `int`, `NSString*`.
```
/**
 * API's that get feature variable values.
 * @param featureKey The key for the feature flag.
 * @param variableKey The key for the variable.
 * @param userId The user ID to be used for bucketing.
 * @param attributes The user's attributes.
 * @return feature variable value.
 */
- (BOOL)getFeatureVariableBoolean:(nullable NSString *)featureKey
                      variableKey:(nullable NSString *)variableKey
                           userId:(nullable NSString *)userId
                       attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;
- (double)getFeatureVariableDouble:(nullable NSString *)featureKey
                       variableKey:(nullable NSString *)variableKey
                            userId:(nullable NSString *)userId
                        attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;
- (int)getFeatureVariableInteger:(nullable NSString *)featureKey
                     variableKey:(nullable NSString *)variableKey
                          userId:(nullable NSString *)userId
                      attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;
- (NSString *_Nullable)getFeatureVariableString:(nullable NSString *)featureKey
                           variableKey:(nullable NSString *)variableKey
                                userId:(nullable NSString *)userId
                            attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;
```

* Introducing Optimizely Notification Center with Notification Listeners
Optimizely object now has a Notification Center
```
    @property (nonatomic, strong, readonly, nullable) OPTLYNotificationCenter *notificationCenter;
```
with Notification Listeners APIs
```
- (NSInteger)addActivateNotificationListener:(nonnull ActivateListener)activateListener;
- (NSInteger)addTrackNotificationListener:(TrackListener _Nonnull )trackListener;
- (BOOL)removeNotificationListener:(NSUInteger)notificationId;
- (void)clearNotificationListeners:(OPTLYNotificationType)type;
- (void)clearAllNotificationListeners;
```
* Add environments support to SDK with SDK key initialization. A new sdkKey property has been added to OPTLYManagerBuilder
that is an alternative to the older projectId property.
* Added `@"$opt_bucketing_id"` in the attribute map for overriding bucketing using the user id.  This string is
available as OptimizelyBucketId in OPTLYEventBuilder.h .

* Adding mobile 2.x data file CDN url change to support FullStack projects without Feature Management V2 schema.

### Bug Fixes:
* Fix single quote in events issue.  Event was sent repeatedly because it was
unable to be deleted from data store due to syntax error.
* Remove "Pod_..." static library from demo app "Embedded Frameworks".
* Fix red Xcode Project Navigator group folder.

### Breaking Changes
* Removed track APIs with revenue as a parameter.
* Deprecated live variable APIs.

## 1.5.2
June 15, 2018

### New Features
* Updated SDK targets to Xcode 9.4 recommended settings, pod update'd third party Cocoapods used by the 2 demo apps,
and eliminated Xcode 9.4 Build and Analyze warnings for SDK targets.

## 1.5.1
April 17, 2018

### Bug Fixes:
* Fix single quote in events issue.  Event was sent repeatedly because it was
unable to be deleted from data store due to syntax error.
* Remove "Pod_..." static library from demo app "Embedded Frameworks".
* Fix red Xcode Project Navigator group folder.

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
