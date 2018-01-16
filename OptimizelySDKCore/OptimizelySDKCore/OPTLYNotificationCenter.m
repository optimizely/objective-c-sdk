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

#import "OPTLYNotificationCenter.h"
#import "OPTLYLogger.h"
#import "OPTLYExperiment.h"
#import "OPTLYVariation.h"

@interface OPTLYNotificationCenter()

// Associative array of notification type to notification id and notification pair.
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, OPTLYNotificationHolder *> *notifications;
@property (nonatomic, strong) id<OPTLYLogger> logger;

@end

@implementation OPTLYNotificationCenter : NSObject

-(instancetype)init {
    self = [super init];
    if (self != nil) {
        _notificationId = 1;
        _logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelAll];
        _notifications = [NSMutableDictionary new];
        for (NSUInteger i = OPTLYNotificationTypeActivate; i <= OPTLYNotificationTypeTrack; i++) {
            NSNumber *number = [NSNumber numberWithUnsignedInteger:i];
            _notifications[number] = [NSMutableDictionary new];
        }
    }
    return self;
}

#pragma mark - Public Methods

-(NSUInteger)notificationsCount {
    NSUInteger notificationsCount = 0;
    for (OPTLYNotificationHolder *notificationsMap in _notifications.allValues) {
        notificationsCount += notificationsMap.count;
    }
    return notificationsCount;
}

- (NSInteger)addNotification:(OPTLYNotificationType)type activateListener:(OPTLYActivateNotificationListener)activateListener {
    if (![self isNotificationTypeValid:type expectedNotificationType:OPTLYNotificationTypeActivate])
        return 0;
    return [self addNotification:type listener:activateListener];
}

- (NSInteger)addNotification:(OPTLYNotificationType)type trackListener:(OPTLYTrackNotificationListener)trackListener {
    if (![self isNotificationTypeValid:type expectedNotificationType:OPTLYNotificationTypeTrack])
        return 0;
    return [self addNotification:type listener:trackListener];
}

- (BOOL)removeNotification:(NSUInteger)notificationId {
    for (NSNumber *notificationType in _notifications.allKeys) {
        OPTLYNotificationHolder *notificationMap = _notifications[notificationType];
        if (notificationMap != nil && [notificationMap.allKeys containsObject:@(notificationId)]) {
            [notificationMap removeObjectForKey:@(notificationId)];
            return YES;
        }
    }
    return NO;
}

- (void)clearNotifications:(OPTLYNotificationType)type {
    [_notifications[@(type)] removeAllObjects];
}

- (void)clearAllNotifications {
    for (NSNumber *notificationType in _notifications.allKeys) {
        [self clearNotifications:[notificationType unsignedIntegerValue]];
    }
}

- (void)sendNotifications:(OPTLYNotificationType)type args:(id)firstArg, ... {
    OPTLYNotificationHolder *notification = _notifications[@(type)];
    for (id object in notification.allValues) {
        @try {
            va_list args;
            va_start(args, firstArg);
            if (type == OPTLYNotificationTypeActivate)
                [self notifyActivateListener:object firstArg:firstArg otherArgs:args];
            else
                [self notifyTrackListener:object firstArg:firstArg otherArgs:args];
            va_end(args);
        } @catch (NSException *exception) {
            NSString *logMessage = [NSString stringWithFormat:@"Problem calling notify callback. Error: %@", exception.reason];
            [_logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        }
    }
}

#pragma mark - Private Methods

- (NSInteger)addNotification:(OPTLYNotificationType)type listener:(id)listener {
    NSNumber *notificationTypeNumber = [NSNumber numberWithUnsignedInteger:type];
    NSNumber *notificationIdNumber = [NSNumber numberWithUnsignedInteger:_notificationId];
    OPTLYNotificationHolder *notificationHoldersList = _notifications[notificationTypeNumber];
    
    if (![_notifications.allKeys containsObject:notificationTypeNumber] || notificationHoldersList.count == 0) {
        notificationHoldersList[notificationIdNumber] = listener;
    } else {
        for (id<OPTLYNotificationListener> notificationListener in notificationHoldersList.allValues) {
            if (notificationListener == listener) {
                [_logger logMessage:@"The notification callback already exists." withLevel:OptimizelyLogLevelError];
                return -1;
            }
        }
        notificationHoldersList[notificationIdNumber] = listener;
    }
    
    return _notificationId++;
}

- (BOOL)isNotificationTypeValid:(OPTLYNotificationType)notificationType expectedNotificationType:(OPTLYNotificationType)expectedNotificationType {
    if (notificationType != expectedNotificationType) {
        NSString *logMessage = [NSString stringWithFormat:@"Invalid notification type provided for %lu listener.", (unsigned long)expectedNotificationType];
        [_logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        return NO;
    }
    return YES;
}

- (void)notifyActivateListener:(OPTLYActivateNotificationListener)listener firstArg:(id)firstArg otherArgs:(va_list)args {
    
    OPTLYExperiment *experiment = (OPTLYExperiment *)firstArg;
    assert(experiment);
    assert([experiment isKindOfClass:[OPTLYExperiment class]]);
    
    NSString *userId = va_arg(args, NSString *);
    assert(userId);
    assert([userId isKindOfClass:[NSString class]]);
    
    NSDictionary *attributes = va_arg(args, NSDictionary *);
    assert(attributes);
    assert([attributes isKindOfClass:[NSDictionary class]]);
    
    OPTLYVariation *variation = va_arg(args, OPTLYVariation *);
    assert(variation);
    assert([variation isKindOfClass:[OPTLYVariation class]]);
    
    NSDictionary *logEvent = va_arg(args, NSDictionary *);
    assert(logEvent);
    assert([logEvent isKindOfClass:[NSDictionary class]]);
    
    va_end(args);
    
    listener(experiment, userId, attributes, variation, logEvent);
}

- (void)notifyTrackListener:(OPTLYTrackNotificationListener)listener firstArg:(id)firstArg otherArgs:(va_list)args {
    
    NSString *eventKey = (NSString *)firstArg;
    assert(eventKey);
    assert([eventKey isKindOfClass:[NSString class]]);
    
    NSString *userId = va_arg(args, NSString *);
    assert(userId);
    assert([userId isKindOfClass:[NSString class]]);
    
    NSDictionary *attributes = va_arg(args, NSDictionary *);
    assert(attributes);
    assert([attributes isKindOfClass:[NSDictionary class]]);
    
    NSDictionary *eventTags = va_arg(args, NSDictionary *);
    assert(eventTags);
    assert([eventTags isKindOfClass:[NSDictionary class]]);
    
    NSDictionary *logEvent = va_arg(args, NSDictionary *);
    assert(logEvent);
    assert([logEvent isKindOfClass:[NSDictionary class]]);
    
    va_end(args);
    
    listener(eventKey, userId, attributes, eventTags, logEvent);
}

@end
