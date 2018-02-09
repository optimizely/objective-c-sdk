/****************************************************************************
 * Copyright 2018, Optimizely, Inc. and contributors                        *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    http://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/

#import <Foundation/Foundation.h>

@class OPTLYProjectConfig, OPTLYExperiment, OPTLYVariation;
@protocol OPTLYNotificationDelegate;

/// Enum representing notification types.
typedef NS_ENUM(NSUInteger, OPTLYNotificationType) {
    OPTLYNotificationTypeActivate,
    OPTLYNotificationTypeTrack
};

typedef void (^ActivateListener)(OPTLYExperiment * experiment, NSString * userId,
                                 NSDictionary<NSString *,NSString *> * attributes,
                                 OPTLYVariation * variation,
                                 NSDictionary<NSString *,NSObject *> * event);

typedef void (^TrackListener)(NSString * eventKey,NSString * userId, NSDictionary<NSString *,NSString *> *attributes,
                              NSDictionary *eventTags, NSDictionary<NSString *,NSObject *> *event);


typedef void (^GenericListener)(NSArray * args);

typedef NSMutableDictionary<NSNumber *, GenericListener > OPTLYNotificationHolder;

@interface OPTLYNotificationCenter : NSObject

// Notification Id represeting id of notification.
@property (nonatomic, readonly) NSUInteger notificationId;

/**
 * Initializer for the Notification Center.
 *
 * @param config The project configuration.
 * @return An instance of the notification center.
 */
- (nullable instancetype)initWithProjectConfig:(nonnull OPTLYProjectConfig *)config;

/**
 * Add an activate notification listener to the notification center.
 *
 * @param activateListener - Notification to add.
 * @return the notification id used to remove the notification. It is greater than 0 on success.
 */
- (NSInteger)addActivateNotificationListener:(nonnull ActivateListener) activateListener;

/**
 * Add a track notification listener to the notification center.
 *
 * @param trackListener - Notification to add.
 * @return the notification id used to remove the notification. It is greater than 0 on success.
 */
- (NSInteger)addTrackNotificationListener:(TrackListener _Nonnull )trackListener;

/**
 * Remove the notification listener based on the notificationId passed back from addNotification.
 * @param notificationId the id passed back from add notification.
 * @return true if removed otherwise false (if the notification is already removed, it returns false).
 */
- (BOOL)removeNotification:(NSUInteger)notificationId;

/**
 * Clear notification listeners by notification type.
 * @param type type of OPTLYNotificationType to remove.
 */
- (void)clearNotifications:(OPTLYNotificationType)type;

/**
 * Clear out all the notification listeners.
 */
- (void)clearAllNotifications;

//
/**
 * fire notificaitons of a certain type.
 * @param type type of OPTLYNotificationType to fire.
 * @param args The arg list changes depending on the type of notification sent.
 */
- (void)sendNotifications:(OPTLYNotificationType)type args:(nullable NSArray *)args;
@end
