//
//  Localytics.h
//  Copyright (C) 2016 Char Software Inc., DBA Localytics
//
//  This code is provided under the Localytics Modified BSD License.
//  A copy of this license has been distributed in a file called LICENSE
//  with this source code.
//
// Please visit www.localytics.com for more information.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <CoreLocation/CoreLocation.h>
#import <Localytics/LLCustomer.h>
#import <Localytics/LocalyticsTypes.h>

@protocol LLAnalyticsDelegate;

#if !TARGET_OS_TV

#import <Localytics/LLCampaignBase.h>
#import <Localytics/LLWebViewCampaign.h>
#import <Localytics/LLInboxCampaign.h>
#import <Localytics/LLPlacesCampaign.h>
#import <Localytics/LLRegion.h>
#import <Localytics/LLGeofence.h>
#import <Localytics/LLInboxViewController.h>
#import <Localytics/LLInboxDetailViewController.h>

@protocol LLMessagingDelegate;
@protocol LLLocationDelegate;

@class UNMutableNotificationContent;
#define LOCALYTICS_LIBRARY_VERSION      @"4.2.0" //iOS version

#else

#define LOCALYTICS_LIBRARY_VERSION      @"1.0.0" //tvOS version

#endif

@protocol Localytics <JSExport>

#pragma mark - SDK Integration
/** ---------------------------------------------------------------------------------------
 * @name Localytics SDK Integration
 *  ---------------------------------------------------------------------------------------
 */

/** Auto-integrates the Localytic SDK into the application.
 
 Use this method to automatically integrate the Localytics SDK in a single line of code. Automatic
 integration is accomplished by proxing the AppDelegate and "inserting" a Localytics AppDelegate
 behind the applications AppDelegate. The proxy will first call the applications AppDelegate and
 then call the Localytics AppDelegate.
 
 @param appKey The unique key for each application generated at www.localytics.com
 @param launchOptions The launchOptions provided by application:DidFinishLaunchingWithOptions:
 */
+ (void)autoIntegrate:(nonnull NSString *)appKey launchOptions:(nullable NSDictionary *)launchOptions;

/** Manually integrate the Localytic SDK into the application.
 
 Use this method to manually integrate the Localytics SDK. The developer still has to make sure to
 open and close the Localytics session as well as call upload to ensure data is uploaded to
 Localytics
 
 @param appKey The unique key for each application generated at www.localytics.com
 @see openSession
 @see closeSession
 @see upload
 */
+ (void)integrate:(nonnull NSString *)appKey;

/** Opens the Localytics session.
 The session time as presented on the website is the time between <code>open</code> and the
 final <code>close</code> so it is recommended to open the session as early as possible, and close
 it at the last moment. It is recommended that this call be placed in <code>applicationDidBecomeActive</code>.
 <br>
 If for any reason this is called more than once every subsequent open call will be ignored.
 
 Resumes the Localytics session.  When the App enters the background, the session is
 closed and the time of closing is recorded.  When the app returns to the foreground, the session
 is resumed.  If the time since closing is greater than BACKGROUND_SESSION_TIMEOUT, (15 seconds
 by default) a new session is created, and uploading is triggered.  Otherwise, the previous session
 is reopened.
 */
+ (void)openSession;

/** Closes the Localytics session.  This should be called in
 <code>applicationWillResignActive</code>.
 <br>
 If close is not called, the session will still be uploaded but no
 events will be processed and the session time will not appear. This is
 because the session is not yet closed so it should not be used in
 comparison with sessions which are closed.
 */
+ (void)closeSession;

/** Creates a low priority thread which uploads any Localytics data already stored
 on the device.  This should be done early in the process life in order to
 guarantee as much time as possible for slow connections to complete.  It is also reasonable
 to upload again when the application is exiting because if the upload is cancelled the data
 will just get uploaded the next time the app comes up.
 */
+ (void)upload;

#pragma mark - Event Tagging
/** ---------------------------------------------------------------------------------------
 * @name Event Tagging
 *  ---------------------------------------------------------------------------------------
 */

/** Tag an event
 @param eventName The name of the event which occurred.
 @see tagEvent:attributes:customerValueIncrease:
 */
+ (void)tagEvent:(nonnull NSString *)eventName;

/** Tag an event with attributes
 @param eventName The name of the event which occurred.
 @param attributes An object/hash/dictionary of key-value pairs, contains
 contextual data specific to the event.
 @see tagEvent:attributes:customerValueIncrease:
 */
+ (void)tagEvent:(nonnull NSString *)eventName attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/** Allows a session to tag a particular event as having occurred.  For
 example, if a view has three buttons, it might make sense to tag
 each button click with the name of the button which was clicked.
 For another example, in a game with many levels it might be valuable
 to create a new tag every time the user gets to a new level in order
 to determine how far the average user is progressing in the game.
 <br>
 <strong>Tagging Best Practices</strong>
 <ul>
 <li>DO NOT use tags to record personally identifiable information.</li>
 <li>The best way to use tags is to create all the tag strings as predefined
 constants and only use those.  This is more efficient and removes the risk of
 collecting personal information.</li>
 <li>Do not set tags inside loops or any other place which gets called
 frequently.  This can cause a lot of data to be stored and uploaded.</li>
 </ul>
 <br>
 See the tagging guide at: http://wiki.localytics.com/
 @param eventName The name of the event which occurred.
 @param attributes (Optional) An object/hash/dictionary of key-value pairs, contains
 contextual data specific to the event.
 @param customerValueIncrease (Optional) Numeric value, added to customer lifetime value.
 Integer expected. Try to use lowest possible unit, such as cents for US currency.
 */
+ (void)tagEvent:(nonnull NSString *)eventName attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes customerValueIncrease:(nullable NSNumber *)customerValueIncrease;

#pragma mark - Standard Event Tagging
/** ---------------------------------------------------------------------------------------
 * @name Standard Event Tagging
 *  ---------------------------------------------------------------------------------------
 */

/**
 * A standard event to tag a single item purchase event (after the action has occurred)
 *
 * @param itemName      The name of the item purchased (optional, can be null)
 * @param itemId        A unique identifier of the item being purchased, such as a SKU (optional, can be null)
 * @param itemType      The type of item (optional, can be null)
 * @param itemPrice     The price of the item (optional, can be null). Will be added to customer lifetime value. Try to use lowest possible unit, such as cents for US currency.
 * @param attributes    Any additional attributes to attach to this event (optional, can be null)
 */
+ (void)tagPurchased:(nullable NSString *)itemName itemId:(nullable NSString *)itemId itemType:(nullable NSString *)itemType itemPrice:(nullable NSNumber *)itemPrice attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * A standard event to tag the addition of a single item to a cart (after the action has occurred)
 *
 * @param itemName      The name of the item purchased (optional, can be null)
 * @param itemId        A unique identifier of the item being purchased, such as a SKU (optional, can be null)
 * @param itemType      The type of item (optional, can be null)
 * @param itemPrice     The price of the item (optional, can be null). Will NOT be added to customer lifetime value.
 * @param attributes    Any additional attributes to attach to this event (optional, can be null)
 */
+ (void)tagAddedToCart:(nullable NSString *)itemName itemId:(nullable NSString *)itemId itemType:(nullable NSString *)itemType itemPrice:(nullable NSNumber *)itemPrice attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * A standard event to tag the start of the checkout process (after the action has occurred)
 *
 * @param totalPrice    The total price of all the items in the cart (optional, can be null). Will NOT be added to customer lifetime value.
 * @param itemCount     Total count of items in the cart (optional, can be null)
 * @param attributes    Any additional attributes to attach to this event (optional, can be null)
 */
+ (void)tagStartedCheckout:(nullable NSNumber *)totalPrice itemCount:(nullable NSNumber *)itemCount attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * A standard event to tag the conclusions of the checkout process (after the action has occurred)
 *
 * @param totalPrice    The total price of all the items in the cart (optional, can be null). Will be added to customer lifetime value. Try to use lowest possible unit, such as cents for US currency.
 * @param itemCount     Total count of items in the cart (optional, can be null)
 * @param attributes    Any additional attributes to attach to this event (optional, can be null)
 */
+ (void)tagCompletedCheckout:(nullable NSNumber *)totalPrice itemCount:(nullable NSNumber *)itemCount attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * A standard event to tag the viewing of content (after the action has occurred)
 *
 * @param contentName   The name of the content being viewed (such as article name) (optional, can be null)
 * @param contentId     A unique identifier of the content being viewed (optional, can be null)
 * @param contentType   The type of content (optional, can be null)
 * @param attributes    Any additional attributes to attach to this event (optional, can be null)
 */
+ (void)tagContentViewed:(nullable NSString *)contentName contentId:(nullable NSString *)contentId contentType:(nullable NSString *)contentType attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * A standard event to tag a search event (after the action has occurred)
 *
 * @param queryText     The query user for the search (optional, can be null)
 * @param contentType   The type of content (optional, can be null)
 * @param resultCount   The number of results returned by the query (optional, can be null)
 * @param attributes    Any additional attributes to attach to this event (optional, can be null)
 */
+ (void)tagSearched:(nullable NSString *)queryText contentType:(nullable NSString *)contentType resultCount:(nullable NSNumber *)resultCount attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * A standard event to tag a share event (after the action has occurred)
 *
 * @param contentName   The name of the content being viewed (such as article name) (optional, can be null)
 * @param contentId     A unique identifier of the content being viewed (optional, can be null)
 * @param contentType   The type of content (optional, can be null)
 * @param methodName    The method by which the content was shared such as Twitter, Facebook, Native (optional, can be null)
 * @param attributes    Any additional attributes to attach to this event (optional, can be null)
 */
+ (void)tagShared:(nullable NSString *)contentName contentId:(nullable NSString *)contentId contentType:(nullable NSString *)contentType methodName:(nullable NSString *)methodName attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * A standard event to tag the rating of content (after the action has occurred)
 *
 * @param contentName   The name of the content being viewed (such as article name) (optional, can be null)
 * @param contentId     A unique identifier of the content being viewed (optional, can be null)
 * @param contentType   The type of content (optional, can be null)
 * @param rating        A rating of the content (optional, can be null)
 * @param attributes    Any additional attributes to attach to this event (optional, can be null)
 */
+ (void)tagContentRated:(nullable NSString *)contentName contentId:(nullable NSString *)contentId contentType:(nullable NSString *)contentType rating:(nullable NSNumber *)rating attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * A standard event to tag the registration of a user (after the action has occurred)
 *
 * @param customer      An object providing information about the customer that registered (optional, can be null)
 * @param methodName    The method by which the user was registered such as Twitter, Facebook, Native (optional, can be null)
 * @param attributes    Any additional attributes to attach to this event (optional, can be null)
 */
+ (void)tagCustomerRegistered:(nullable LLCustomer *)customer methodName:(nullable NSString *)methodName attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * A standard event to tag the logging in of a user (after the action has occurred)
 *
 * @param customer      An object providing information about the customer that logged in (optional, can be null)
 * @param methodName    The method by which the user was logged in such as Twitter, Facebook, Native (optional, can be null)
 * @param attributes    Any additional attributes to attach to this event (optional, can be null)
 */
+ (void)tagCustomerLoggedIn:(nullable LLCustomer *)customer methodName:(nullable NSString *)methodName attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * A standard event to tag the logging out of a user (after the action has occurred)
 *
 * @param attributes    Any additional attributes to attach to this event (optional, can be null)
 */
+ (void)tagCustomerLoggedOut:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * A standard event to tag the invitation of a user (after the action has occured)
 *
 * @param methodName    The method by which the user was invited such as Twitter, Facebook, Native (optional, can be null)
 * @param attributes    Any additional attributes to attach to this event (optional, can be null)
 */
+ (void)tagInvited:(nullable NSString *)methodName attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

#pragma mark - Tag Screen Method

/** Allows tagging the flow of screens encountered during the session.
 @param screenName The name of the screen
 */
+ (void)tagScreen:(nonnull NSString *)screenName;

#pragma mark - Custom Dimensions
/** ---------------------------------------------------------------------------------------
 * @name Custom Dimensions
 *  ---------------------------------------------------------------------------------------
 */

/** Sets the value of a custom dimension. Custom dimensions are dimensions
 which contain user defined data unlike the predefined dimensions such as carrier, model, and country.
 Once a value for a custom dimension is set, the device it was set on will continue to upload that value
 until the value is changed. To clear a value pass nil as the value.
 The proper use of custom dimensions involves defining a dimension with less than ten distinct possible
 values and assigning it to one of the four available custom dimensions. Once assigned this definition should
 never be changed without changing the App Key otherwise old installs of the application will pollute new data.
 @param value The value to set the custom dimension to
 @param dimension The dimension to set the value of
 @see valueForCustomDimension:
 */
+ (void)setValue:(nullable NSString *)value forCustomDimension:(NSUInteger)dimension;

/** Gets the custom value for a given dimension. Avoid calling this on the main thread, as it
 may take some time for all pending database execution.
 @param dimension The custom dimension to return a value for
 @return The current value for the given custom dimension
 @see setValue:forCustomDimension:
 */
+ (nullable NSString *)valueForCustomDimension:(NSUInteger)dimension;

#pragma mark - Identifiers
/** ---------------------------------------------------------------------------------------
 * @name Identifiers
 *  ---------------------------------------------------------------------------------------
 */

/** Sets the value of a custom identifier. Identifiers are a form of key/value storage
 which contain custom user data. Identifiers might include things like email addresses,
 customer IDs, twitter handles, and facebook IDs. Once a value is set, the device it was set
 on will continue to upload that value until the value is changed.
 To delete a property, pass in nil as the value.
 @param value The value to set the identifier to. To delete a propert set the value to nil
 @param identifier The name of the identifier to have it's value set
 @see valueForIdentifier:
 */
+ (void)setValue:(nullable NSString *)value forIdentifier:(nonnull NSString *)identifier;

/** Gets the identifier value for a given identifier. Avoid calling this on the main thread, as it
 may take some time for all pending database execution.
 @param identifier The identifier to return a value for
 @return The current value for the given identifier
 @see setValue:forCustomDimension:
 */
+ (nullable NSString *)valueForIdentifier:(nonnull NSString *)identifier;

/** Set the identifier for the customer. This valued is used when setting profile attributes,
 targeting users for push and mapping data exported from Localytics to a user.
 @param customerId The value to set the customer identifier to
 */
+ (void)setCustomerId:(nullable NSString *)customerId;

/** Gets the customer id. Avoid calling this on the main thread, as it
 may take some time for all pending database execution.
 @return The current value for customer id
 */
+ (nullable NSString *)customerId;


#pragma mark - Profile
/** ---------------------------------------------------------------------------------------
 * @name Profile
 *  ---------------------------------------------------------------------------------------
 */

/** Sets the value of a profile attribute.
 @param value The value to set the profile attribute to. value can be one of the following: NSString,
 NSNumber(long & int), NSDate, NSSet of Strings, NSSet of NSNumbers(long & int), NSSet of Date,
 nil. Passing in a 'nil' value will result in that attribute being deleted from the profile
 @param attribute The name of the profile attribute to be set
 @param scope The scope of the attribute governs the visability of the profile attribute (application
 only or organization wide)
 */
+ (void)setValue:(nonnull id)value forProfileAttribute:(nonnull NSString *)attribute withScope:(LLProfileScope)scope;

/** Sets the value of a profile attribute (scope: Application).
 @param value The value to set the profile attribute to. value can be one of the following: NSString,
 NSNumber(long & int), NSDate, NSSet of Strings, NSSet of NSNumbers(long & int), NSSet of Date,
 nil. Passing in a 'nil' value will result in that attribute being deleted from the profile
 @param attribute The name of the profile attribute to be set
 */
+ (void)setValue:(nonnull id)value forProfileAttribute:(nonnull NSString *)attribute;

/** Adds values to a profile attribute that is a set
 @param values The value to be added to the profile attributes set.
 @param attribute The name of the profile attribute to have it's set modified
 @param scope The scope of the attribute governs the visability of the profile attribute (application
 only or organization wide)
 */
+ (void)addValues:(nonnull NSArray *)values toSetForProfileAttribute:(nonnull NSString *)attribute withScope:(LLProfileScope)scope;

/** Adds values to a profile attribute that is a set (scope: Application).
 @param values The value to be added to the profile attributes set
 @param attribute The name of the profile attribute to have it's set modified
 */
+ (void)addValues:(nonnull NSArray *)values toSetForProfileAttribute:(nonnull NSString *)attribute;

/** Removes values from a profile attribute that is a set
 @param values The value to be removed from the profile attributes set
 @param attribute The name of the profile attribute to have it's set modified
 @param scope The scope of the attribute governs the visability of the profile attribute (application
 only or organization wide)
 */
+ (void)removeValues:(nonnull NSArray *)values fromSetForProfileAttribute:(nonnull NSString *)attribute withScope:(LLProfileScope)scope;

/** Removes values from a profile attribute that is a set (scope: Application).
 @param values The value to be removed from the profile attributes set
 @param attribute The name of the profile attribute to have it's set modified
 */
+ (void)removeValues:(nonnull NSArray *)values fromSetForProfileAttribute:(nonnull NSString *)attribute;

/** Increment the value of a profile attribute.
 @param value An NSInteger to be added to an existing profile attribute value.
 @param attribute The name of the profile attribute to have it's value incremented
 @param scope The scope of the attribute governs the visability of the profile attribute (application
 only or organization wide)
 */
+ (void)incrementValueBy:(NSInteger)value forProfileAttribute:(nonnull NSString *)attribute withScope:(LLProfileScope)scope;

/** Increment the value of a profile attribute (scope: Application).
 @param value An NSInteger to be added to an existing profile attribute value.
 @param attribute The name of the profile attribute to have it's value incremented
 */
+ (void)incrementValueBy:(NSInteger)value forProfileAttribute:(nonnull NSString *)attribute;

/** Decrement the value of a profile attribute.
 @param value An NSInteger to be subtracted from an existing profile attribute value.
 @param attribute The name of the profile attribute to have it's value decremented
 @param scope The scope of the attribute governs the visability of the profile attribute (application
 only or organization wide)
 */
+ (void)decrementValueBy:(NSInteger)value forProfileAttribute:(nonnull NSString *)attribute withScope:(LLProfileScope)scope;

/** Decrement the value of a profile attribute (scope: Application).
 @param value An NSInteger to be subtracted from an existing profile attribute value.
 @param attribute The name of the profile attribute to have it's value decremented
 */
+ (void)decrementValueBy:(NSInteger)value forProfileAttribute:(nonnull NSString *)attribute;

/** Delete a profile attribute
 @param attribute The name of the attribute to be deleted
 @param scope The scope of the attribute governs the visability of the profile attribute (application
 only or organization wide)
 */
+ (void)deleteProfileAttribute:(nonnull NSString *)attribute withScope:(LLProfileScope)scope;

/** Delete a profile attribute (scope: Application)
 @param attribute The name of the attribute to be deleted
 */
+ (void)deleteProfileAttribute:(nonnull NSString *)attribute;

/** Convenience method to set a customer's email as both a profile attribute and
 as a customer identifier (scope: Organization)
 @param email Customer's email
 */
+ (void)setCustomerEmail:(nullable NSString *)email;

/** Convenience method to set a customer's first name as both a profile attribute and
 as a customer identifier (scope: Organization)
 @param firstName Customer's first name
 */
+ (void)setCustomerFirstName:(nullable NSString *)firstName;

/** Convenience method to set a customer's last name as both a profile attribute and
 as a customer identifier (scope: Organization)
 @param lastName Customer's last name
 */
+ (void)setCustomerLastName:(nullable NSString *)lastName;

/** Convenience method to set a customer's full name as both a profile attribute and
 as a customer identifier (scope: Organization)
 @param fullName Customer's full name
 */
+ (void)setCustomerFullName:(nullable NSString *)fullName;


#pragma mark - Developer Options
/** ---------------------------------------------------------------------------------------
 * @name Developer Options
 *  ---------------------------------------------------------------------------------------
 */

/**
 * Customize the behavior of the SDK by setting custom values for various options.
 * In each entry, the key specifies the option to modify, and the value specifies what value
 * to set the option to. Options can be restored to default by passing in a value of NSNull,
 * or an empty string for values with type NSString.
 * @param options The dictionary of options and values to modify
 */
+ (void)setOptions:(nullable NSDictionary<NSString *, NSObject *> *)options;

/** Returns whether the Localytics SDK is set to emit logging information
 @return YES if logging is enabled, NO otherwise
 */
+ (BOOL)isLoggingEnabled;

/** Set whether Localytics SDK should emit logging information. By default the Localytics SDK
 is set to not to emit logging information. It is recommended that you only enable logging
 for debugging purposes.
 @param loggingEnabled Set to YES to enable logging or NO to disable it
 */
+ (void)setLoggingEnabled:(BOOL)loggingEnabled;

/** Returns whether or not the application will collect user data.
 @return YES if the user is opted out, NO otherwise. Default is NO
 @see setOptedOut:
 */
+ (BOOL)isOptedOut;

/** Allows the application to control whether or not it will collect user data.
 Even if this call is used, it is necessary to continue calling upload().  No new data will be
 collected, so nothing new will be uploaded but it is necessary to upload an event telling the
 server this user has opted out.
 @param optedOut YES if the user is opted out, NO otherwise.
 @see isOptedOut
 */
+ (void)setOptedOut:(BOOL)optedOut;

/** Returns the install id
 @return the install id as an NSString
 */
+ (nullable NSString *)installId;

/** Returns the version of the Localytics SDK
 @return the version of the Localytics SDK as an NSString
 */
+ (nonnull NSString *)libraryVersion;

/** Returns the app key currently set in Localytics
 @return the app key currently set in Localytics as an NSString
 */
+ (nullable NSString *)appKey;

#pragma mark - Analytics Delegate
/** ---------------------------------------------------------------------------------------
 * @name Analytics Delegate
 *  ---------------------------------------------------------------------------------------
 */

/** Set an Analytics delegate
 @param delegate An object implementing the LLAnalyticsDelegate protocol.
 @see LLAnalyticsDelegate
 */
+ (void)setAnalyticsDelegate:(nullable id<LLAnalyticsDelegate>)delegate;

/** Stores the user's location.  This will be used in all event and session calls.
 If your application has already collected the user's location, it may be passed to Localytics
 via this function.  This will cause all events and the session close to include the location
 information.  It is not required that you call this function.
 @param location The user's location.
 */
+ (void)setLocation:(CLLocationCoordinate2D)location;

#if !TARGET_OS_TV

#pragma mark - Push
/** ---------------------------------------------------------------------------------------
 * @name Push
 *  ---------------------------------------------------------------------------------------
 */

/** Returns the device's APNS token if one has been set via setPushToken: previously.
 @return The device's APNS token if one has been set otherwise nil
 @see setPushToken:
 */
+ (nullable NSString *)pushToken;

/** Stores the device's APNS token. This will be used in all event and session calls.
 @param pushToken The devices APNS token returned by application:didRegisterForRemoteNotificationsWithDeviceToken:
 @see pushToken
 */
+ (void)setPushToken:(nullable NSData *)pushToken;

/** Used to record performance data for notifications
 @param notificationInfo The dictionary from either didFinishLaunchingWithOptions, didReceiveRemoteNotification,
 or didReceiveLocalNotification should be passed on to this method
 */
+ (void)handleNotification:(nonnull NSDictionary *)notificationInfo;

/** Use to record performance data for notifications when using UNUserNotificationCenterDelegate
 @param userInfo The UNNotificationResponse's userInfo retrieved by calling response.notification.request.content.userInfo
 */
+ (void)didReceiveNotificationResponseWithUserInfo:(nonnull NSDictionary *)userInfo;

/** Used to notify the Localytics SDK that notification settings have changed
 */
+ (void)didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings;

/** Used to notify the Localytics SDK that user notification authorization has changed
 */
+ (void)didRequestUserNotificationAuthorizationWithOptions:(NSUInteger)options granted:(BOOL)granted;

#pragma mark - In-App Message
/** ---------------------------------------------------------------------------------------
 * @name In-App Message
 *  ---------------------------------------------------------------------------------------
 */

/**
 @param url The URL to be handled
 @return YES if the URL was successfully handled or NO if the attempt to handle the
 URL failed.
 */
+ (BOOL)handleTestModeURL:(nonnull NSURL *)url;

/** Set the image to be used for dimissing an In-App message
 @param image The image to be used for dismissing an In-App message. By default this is a
 circle with an 'X' in the middle of it
 */
+ (void)setInAppMessageDismissButtonImage:(nullable UIImage *)image;

/** Set the image to be used for dimissing an In-App message by providing the name of the
 image to be loaded and used
 @param imageName The name of an image to be loaded and used for dismissing an In-App
 message. By default the image is a circle with an 'X' in the middle of it
 */
+ (void)setInAppMessageDismissButtonImageWithName:(nullable NSString *)imageName;

/** Set the location of the dismiss button on an In-App msg
 @param location The location of the button (left or right)
 @see InAppDismissButtonLocation
 */
+ (void)setInAppMessageDismissButtonLocation:(LLInAppMessageDismissButtonLocation)location;

/** Returns the location of the dismiss button on an In-App msg
 @return InAppDismissButtonLocation
 @see InAppDismissButtonLocation
 */
+ (LLInAppMessageDismissButtonLocation)inAppMessageDismissButtonLocation;

+ (void)triggerInAppMessage:(nonnull NSString *)triggerName;
+ (void)triggerInAppMessage:(nonnull NSString *)triggerName withAttributes:(nonnull NSDictionary<NSString *,NSString *> *)attributes;

+ (void)dismissCurrentInAppMessage;

#pragma mark - Inbox

/** Returns an array of all Inbox campaigns that are enabled and ready for display.
 @return an array of LLInboxCampaign objects
 */
+ (nonnull NSArray<LLInboxCampaign *> *)inboxCampaigns;

/** Refresh inbox campaigns from the Localytics server.
 @param completionBlock the block invoked with refresh is complete
 */
+ (void)refreshInboxCampaigns:(nonnull void (^)(NSArray<LLInboxCampaign *> * _Nullable inboxCampaigns))completionBlock;

/** Set an Inbox campaign as read. Read state can be used to display opened but not disabled Inbox
 campaigns differently (e.g. greyed out).
 @param campaignId the campaign ID of the Inbox campaign.
 @param read YES to mark the campaign as read, NO to mark it as unread
 @see [LLInboxCampaign class]
 */
+ (void)setInboxCampaignId:(NSInteger)campaignId asRead:(BOOL)read;

/** Get the count of unread inbox messages
 @return the count of unread inbox messages
 */
+ (NSInteger)inboxCampaignsUnreadCount;

/** Returns a inbox campaign detail view controller with the given inbox campaign data.
 @return a LLInboxDetailViewController from a given LLInboxCampaign object
 */
+ (nonnull LLInboxDetailViewController *)inboxDetailViewControllerForCampaign:(nonnull LLInboxCampaign *)campaign;

#pragma mark - Location

/** Enable or disable location monitoring for geofence monitoring. Enabling location monitoring
 will prompt the user for location permissions. The NSLocationAlwaysUsageDescription key must
 also be set in your Info.plist
 @param enabled YES to enable location monitoring, NO to disable monitoring
 */
+ (void)setLocationMonitoringEnabled:(BOOL)enabled;

/** Retrieve the closest 20 geofences to monitor based on the devices current location. This method
 should be used if you would rather manage location updates and region monitoring instead of
 allowing the Localytics SDK to manage location updates and region monitoring automatically when
 using setLocationMonitoringEnabled. This method should be used in conjunction with triggerRegion:withEvent:
 and triggerRegions:withEvent: to notify the Localytics SDK that regions have been entered or exited.
 @param currentCoordinate The devices current location coordinate
 @see triggerRegion:withEvent:
 @see triggerRegions:withEvent:
 */
+ (nonnull NSArray<LLRegion *> *)geofencesToMonitor:(CLLocationCoordinate2D)currentCoordinate;

/** Trigger a region with a certain event. This method should be used in conjunction with geofencesToMonitor:.
 @param region The CLRegion that is triggered
 @param event The triggering event (enter or exit)
 @see geofencesToMonitor:
 */
+ (void)triggerRegion:(nonnull CLRegion *)region withEvent:(LLRegionEvent)event;

/** Trigger regions with a certain event. This method should be used in conjunction with geofencesToMonitor:.
 @param region An array of CLRegion object that are triggered
 @param event The triggering event (enter or exit)
 @see geofencesToMonitor:
 */
+ (void)triggerRegions:(nonnull NSArray<CLRegion *> *)regions withEvent:(LLRegionEvent)event;


/** Returns whether the Localytics SDK is currently in test mode or not. When in test mode
 a small Localytics tab will appear on the left side of the screen which enables a developer
 to see/test all the campaigns currently available to this customer.
 @return YES if test mode is enabled, NO otherwise
 */
+ (BOOL)isTestModeEnabled;

/** Set whether Localytics SDK should enter test mode or not. When set to YES the a small
 Localytics tab will appear on the left side of the screen, enabling a developer to see/test
 all campaigns currently available to this customer.
 Setting testModeEnabled to NO will cause Localytics to exit test mode, if it's currently
 in it.
 @param enabled Set to YES to enable test mode, NO to disable test mode
 */
+ (void)setTestModeEnabled:(BOOL)enabled;


#pragma mark - In-App Message Delegate
/** ---------------------------------------------------------------------------------------
 * @name In-App Message Delegate
 *  ---------------------------------------------------------------------------------------
 */

/** Set a Messaging delegate
 @param delegate An object that implements the LLMessagingDelegate and is called
 when an In-App message will display, did display, will hide, and did hide.
 @see LLMessagingDelegate
 */
+ (void)setMessagingDelegate:(nullable id<LLMessagingDelegate>)delegate;

/** Returns whether the ADID parameter is added to In-App call to action URLs
 @return YES if parameter is added, NO otherwise
 */
+ (BOOL)isInAppAdIdParameterEnabled;

/** Set whether ADID parameter is added to In-App call to action URLs. By default
 the ADID parameter will be added to call to action URLs.
 @param enabled Set to YES to enable the ADID parameter or NO to disable it
 */
+ (void)setInAppAdIdParameterEnabled:(BOOL)enabled;


#pragma mark - Location Delegate
/** ---------------------------------------------------------------------------------------
 * @name Location Delegate
 *  ---------------------------------------------------------------------------------------
 */

/** Set a Location delegate
 @param delegate An object implementing the LLLocationDelegate protocol.
 @see LLLocationDelegate
 */
+ (void)setLocationDelegate:(nullable id<LLLocationDelegate>)delegate;

#endif

@end

/**
 @discussion The class which manages creating, collecting, & uploading a Localytics session.
 Please see the following guides for information on how to best use this
 library, sample code, and other useful information:
 <ul>
 <li><a href="http://wiki.localytics.com/index.php?title=Developer's_Integration_Guide">
 Main Developer's Integration Guide</a></li>
 </ul>
 
 <strong>Best Practices</strong>
 <ul>
 <li>Integrate Localytics in <code>applicationDidFinishLaunching</code>.</li>
 <li>Open your session and begin your uploads in <code>applicationDidBecomeActive</code>. This way the
 upload has time to complete and it all happens before your users have a
 chance to begin any data intensive actions of their own.</li>
 <li>Close the session in <code>applicationWillResignActive</code>.</li>
 <li>Do not call any Localytics functions inside a loop.  Instead, calls
 such as <code>tagEvent</code> should follow user actions.  This limits the
 amount of data which is stored and uploaded.</li>
 <li>Do not instantiate a Localtyics object, instead use only the exposed class methods.</li>
 </ul>
 */
@interface Localytics : NSObject <Localytics>
@end

#pragma mark -

@protocol LLAnalyticsDelegate <NSObject, JSExport>
@optional

- (void)localyticsSessionWillOpen:(BOOL)isFirst isUpgrade:(BOOL)isUpgrade isResume:(BOOL)isResume;
- (void)localyticsSessionDidOpen:(BOOL)isFirst isUpgrade:(BOOL)isUpgrade isResume:(BOOL)isResume;

- (void)localyticsDidTagEvent:(nonnull NSString *)eventName
                   attributes:(nullable NSDictionary<NSString *,NSString *> *)attributes
        customerValueIncrease:(nullable NSNumber *)customerValueIncrease;

- (void)localyticsSessionWillClose;

@end


#if !TARGET_OS_TV

@protocol LLMessagingDelegate <NSObject>
@optional

- (void)localyticsWillDisplayInAppMessage;
- (void)localyticsDidDisplayInAppMessage;
- (void)localyticsWillDismissInAppMessage;
- (void)localyticsDidDismissInAppMessage;
- (BOOL)localyticsShouldDisplayPlacesCampaign:(nonnull LLPlacesCampaign *)campaign;

- (nonnull UILocalNotification *)localyticsWillDisplayNotification:(nonnull UILocalNotification *)notification forPlacesCampaign:(nonnull LLPlacesCampaign *)campaign;

- (nonnull UNMutableNotificationContent *)localyticsWillDisplayNotificationContent:(nonnull UNMutableNotificationContent *)notification forPlacesCampaign:(nonnull LLPlacesCampaign *)campaign;

@end

@protocol LLLocationDelegate <NSObject>
@optional

- (void)localyticsDidUpdateLocation:(nonnull CLLocation *)location;
- (void)localyticsDidUpdateMonitoredRegions:(nonnull NSArray<LLRegion *> *)addedRegions removeRegions:(nonnull NSArray<LLRegion *> *)removedRegions;
- (void)localyticsDidTriggerRegions:(nonnull NSArray<LLRegion *> *)regions withEvent:(LLRegionEvent)event;

@end

#endif
