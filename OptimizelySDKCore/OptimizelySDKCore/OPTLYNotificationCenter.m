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
#import "OPTLYProjectConfig.h"
#import "OPTLYLogger.h"
#import "OPTLYExperiment.h"
#import "OPTLYVariation.h"
#import <objc/runtime.h>
#import "OPTLYNotificationDelegate.h"

@interface OPTLYNotificationCenter()

// Associative array of notification type to notification id and notification pair.
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, OPTLYNotificationHolder *> *notifications;
@property (nonatomic, strong) OPTLYProjectConfig *config;

@end

@implementation OPTLYNotificationCenter : NSObject

-(instancetype)initWithProjectConfig:(OPTLYProjectConfig *)config {
    self = [super init];
    if (self != nil) {
        _notificationId = 1;
        _config = config;
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

- (NSInteger)addActivateNotificationListener:(ActivateListener)activateListener {
    return [self addNotification:OPTLYNotificationTypeActivate listener:(GenericListener) activateListener];
}

- (NSInteger)addTrackNotificationListener:(TrackListener)trackListener {
    return [self addNotification:OPTLYNotificationTypeTrack listener:(GenericListener)trackListener];
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

- (void)sendNotifications:(OPTLYNotificationType)type args:(NSArray *)args {
    OPTLYNotificationHolder *notification = _notifications[@(type)];
    for (GenericListener object in notification.allValues) {
        @try {
            if (type == OPTLYNotificationTypeActivate)
                ((ActivateListener) object)(args[0], args[1], args[2], args[3], args[4]);
            else
                ((TrackListener) object)(args[0], args[1], args[2], args[3], args[4]);
        } @catch (NSException *exception) {
            NSString *logMessage = [NSString stringWithFormat:@"Problem calling notify callback. Error: %@", exception.reason];
            [_config.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        }
    }
}

#pragma mark - Private Methods

- (NSInteger)addNotification:(OPTLYNotificationType)type listener:(GenericListener)listener {
    NSNumber *notificationTypeNumber = [NSNumber numberWithUnsignedInteger:type];
    NSNumber *notificationIdNumber = [NSNumber numberWithUnsignedInteger:_notificationId];
    OPTLYNotificationHolder *notificationHoldersList = _notifications[notificationTypeNumber];
    
    if (![_notifications.allKeys containsObject:notificationTypeNumber] || notificationHoldersList.count == 0) {
        notificationHoldersList[notificationIdNumber] = listener;
    } else {
        for (GenericListener notificationListener in notificationHoldersList.allValues) {
            if (notificationListener == listener) {
                [_config.logger logMessage:@"The notification callback already exists." withLevel:OptimizelyLogLevelError];
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
        [_config.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        return NO;
    }
    return YES;
}

- (void)invokeSelector:(id)object selector:(SEL)selector arguments:(NSArray *)arguments {
    Method method = class_getInstanceMethod([object class], selector);
    int argumentCount = method_getNumberOfArguments(method);
    
    // The first two arguments are the hidden arguments self and _cmd
    int hiddenArguments = 2;
    
    if(argumentCount > [arguments count] + hiddenArguments) {
        NSString *logMessage = [NSString stringWithFormat:@"Not enough arguments to call %@ for notification Delegate.", object];
        [_config.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        return; // Not enough arguments in the array
    }
    
    NSMethodSignature *signature = [object methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:object];
    [invocation setSelector:selector];
    
    for(int i=0; i<[arguments count]; i++) {
        id arg = [arguments objectAtIndex:i];
        [invocation setArgument:&arg atIndex:i+hiddenArguments];
    }
    
    [invocation invoke]; // Invoke the selector
}

@end
