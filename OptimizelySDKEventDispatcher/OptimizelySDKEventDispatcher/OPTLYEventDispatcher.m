/****************************************************************************
 * Copyright 2017, Optimizely, Inc. and contributors                        *
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

#import <OptimizelySDKCore/OPTLYNetworkService.h>
#import "OPTLYEventDispatcher.h"

// TODO - Flush events when network connection has become available.

// --- Event URLs ----
NSString * const OPTLYEventDispatcherImpressionEventURL   = @"https://logx.optimizely.com/log/decision";
NSString * const OPTLYEventDispatcherConversionEventURL   = @"https://logx.optimizely.com/log/event";

// Default interval and timeout values (in s) if not set by users
const NSInteger OPTLYEventDispatcherDefaultDispatchIntervalTime_s = 1 * 1000;
// The max number of events that can be flushed at a time
const NSInteger OPTLYEventDispatcherMaxDispatchEventBatchSize = 20;
// The max number of times flush events are attempted
const NSInteger OPTLYEventDispatcherMaxFlushEventAttempts = 10;
// default max number of events to store before overwriting older events
const NSInteger OPTLYEventDispatcherDefaultMaxNumberOfEventsToSave = 1000;

@interface OPTLYEventDispatcherDefault()
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) OPTLYNetworkService *networkService;
@property (nonatomic, strong) NSMutableSet *pendingDispatchEvents;
@property (nonatomic, assign) NSInteger flushEventAttempts;
@end

@implementation OPTLYEventDispatcherDefault : NSObject

+ (nullable instancetype)init:(nonnull OPTLYEventDispatcherBuilderBlock)builderBlock {
    return [[self alloc] initWithBuilder:[OPTLYEventDispatcherBuilder builderWithBlock:builderBlock]];
}

- (instancetype)init {
    return [self initWithBuilder:nil];
}

- (instancetype)initWithBuilder:(OPTLYEventDispatcherBuilder *)builder {
    self = [super init];
    if (self != nil) {
        _flushEventAttempts = 0;
        _timer = nil;
        _eventDispatcherDispatchInterval = OPTLYEventDispatcherDefaultDispatchIntervalTime_s;
        _pendingDispatchEvents = [NSMutableSet new];
        _logger = builder.logger;
        _maxNumberOfEventsToSave = OPTLYEventDispatcherDefaultMaxNumberOfEventsToSave;
        if (builder.maxNumberOfEventsToSave > 0) {
            _maxNumberOfEventsToSave = builder.maxNumberOfEventsToSave;
        }
        
        if (builder.eventDispatcherDispatchInterval > 0) {
            _eventDispatcherDispatchInterval = builder.eventDispatcherDispatchInterval;
        } else {
            NSString *logMessage =  [NSString stringWithFormat: OPTLYLoggerMessagesEventDispatcherInvalidInterval, builder.eventDispatcherDispatchInterval];
            [_logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        }
        
        [self setupApplicationNotificationHandlers];
        
        NSString *logMessage =  [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherProperties, _eventDispatcherDispatchInterval];
        [_logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return self;
}

// Create global serial GCD queue for flush events
// later optimization would run events flushing concurrently
dispatch_queue_t flushEventsQueue()
{
    static dispatch_queue_t _flushEventsQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _flushEventsQueue = dispatch_queue_create("com.Optimizely.flushEvents", DISPATCH_QUEUE_SERIAL);
    });
    return _flushEventsQueue;
}

dispatch_queue_t dispatchEventQueue()
{
    static dispatch_queue_t _dispatchEventQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dispatchEventQueue = dispatch_queue_create("com.Optimizely.dispatchEvent", DISPATCH_QUEUE_CONCURRENT);
    });
    return _dispatchEventQueue;
}

-(OPTLYNetworkService *)networkService {
    if (!_networkService) {
        _networkService = [OPTLYNetworkService new];
    }
    return _networkService;
}

- (OPTLYDataStore *)dataStore {
    if (!_dataStore) {
        _dataStore = [[OPTLYDataStore alloc] initWithLogger:_logger];
        _dataStore.maxNumberOfEventsToSave = _maxNumberOfEventsToSave;
    }
    return _dataStore;
}

# pragma mark - Network Timer
// Set up the network timer when saved events are detected
// The timer must be dispatched on the main thread.
- (void)setupNetworkTimer:(void(^)())completion
{
    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf.eventDispatcherDispatchInterval > 0) {
            strongSelf.timer = [NSTimer scheduledTimerWithTimeInterval:strongSelf.eventDispatcherDispatchInterval
                                                                target:strongSelf
                                                              selector:@selector(flushEvents)
                                                              userInfo:nil
                                                               repeats:YES];
            
            NSString *logMessage =  [NSString stringWithFormat: OPTLYLoggerMessagesEventDispatcherNetworkTimerEnabled, self.eventDispatcherDispatchInterval];
            [_logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            
            if (completion) {
                completion();
            }
        }
    };
    
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

// The network timer should be reset when all saved event queue
//  are empty and event is successfully sent
- (void)disableNetworkTimer
{
    if (![self isTimerEnabled]) {
        return;
    }
    
    [self.timer invalidate];
    self.timer = nil;
    
    [self.logger logMessage:OPTLYLoggerMessagesEventDispatcherNetworkTimerDisabled withLevel:OptimizelyLogLevelDebug];
}

# pragma mark - Dispatch Events
- (void)dispatchImpressionEvent:(nonnull NSDictionary *)params
                       callback:(nullable OPTLYEventDispatcherResponse)callback {
    [self dispatchNewEvent:params backoffRetry:YES eventType:OPTLYDataStoreEventTypeImpression callback:callback];
}

- (void)dispatchConversionEvent:(nonnull NSDictionary *)params
                       callback:(nullable OPTLYEventDispatcherResponse)callback {
    [self dispatchNewEvent:params backoffRetry:YES eventType:OPTLYDataStoreEventTypeConversion callback:callback];
}



// New events should be saved before a dispatch attempt is made
// This preserves the event in case the app crashes or is dismissed before the dispatch completes
- (void)dispatchNewEvent:(nonnull NSDictionary *)params
            backoffRetry:(BOOL)backoffRetry
               eventType:(OPTLYDataStoreEventType)eventType
                callback:(nullable OPTLYEventDispatcherResponse)callback {
    
    NSString *eventName = [OPTLYDataStore stringForDataEventEnum:eventType];
    NSError *saveError = nil;
    [self.dataStore saveEvent:params eventType:eventType error:&saveError];
    if (!saveError) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventSaved, eventName, params];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    
    [self dispatchEvent:params backoffRetry:backoffRetry eventType:eventType callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self flushEvents];
        if (callback) {
            callback(data, response, error);
        }
    }];
}

- (void)dispatchEvent:(nonnull NSDictionary *)event
         backoffRetry:(BOOL)backoffRetry
            eventType:(OPTLYDataStoreEventType)eventType
             callback:(nullable OPTLYEventDispatcherResponse)callback {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatchEventQueue(), ^{
        __typeof__(self) strongSelf = weakSelf;
        __block NSString *logMessage =  @"";
        
        // prevent the same event from getting dispatched multiple times
        if ([strongSelf.pendingDispatchEvents containsObject:event]) {
            logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherPendingEvent, event];
            [strongSelf.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            return;
        } else {
            [strongSelf.pendingDispatchEvents addObject:event];
        }
        
        NSURL *url = [strongSelf URLForEvent:eventType];
        [self.networkService dispatchEvent:event
                              backoffRetry:backoffRetry
                                     toURL:url
                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                             
                             NSString *eventName = [OPTLYDataStore stringForDataEventEnum:eventType];
                             if (!error) {
                                 [strongSelf.dataStore removeEvent:event eventType:eventType error:&error];
                                 logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherRemovedEvent, eventName, event];
                             } else {
                                 logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherDispatchFailed, eventName, error];
                             }
                             [strongSelf.pendingDispatchEvents removeObject:event];
                             [strongSelf.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
                             if (callback) {
                                 callback(data, response, error);
                             }
                         }];
    });
}

- (void)flushEvents {
    [self flushEvents:nil];
}

// flushed saved events
- (void)flushEvents:(void(^)())callback
{
    [self.logger logMessage:OPTLYLoggerMessagesEventDispatcherFlushingEvents withLevel:OptimizelyLogLevelDebug];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(flushEventsQueue(), ^{
        __typeof__(self) strongSelf = weakSelf;
        
        if (strongSelf.flushEventAttempts > OPTLYEventDispatcherMaxFlushEventAttempts) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherFlushEventsMax, self.flushEventAttempts];
            [strongSelf.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            
            [strongSelf disableNetworkTimer];
            if (callback) {
                callback();
            }
            return;
        }
        
        // return if no events to send
        if ([strongSelf numberOfEvents] == 0) {
            [strongSelf.logger logMessage:OPTLYLoggerMessagesEventDispatcherFlushEventsNoEvents withLevel:OptimizelyLogLevelDebug];
            strongSelf.flushEventAttempts = 0;
            [strongSelf disableNetworkTimer];
            if (callback) {
                callback();
            }
            return;
        }
        
        // setup the network timer if needed
        if (![strongSelf isTimerEnabled]) {
            [strongSelf setupNetworkTimer:nil];
        }
        
        strongSelf.flushEventAttempts++;
        
        // ---- For Testing ----
        // call the completion block when all impression and conversion events have returned
        // TODO: Wrap in TEST preprocessor
        if (callback) {
            
            dispatch_group_t dispatchEventsGroup = dispatch_group_create();
            dispatch_group_enter(dispatchEventsGroup);
            [strongSelf flushSavedEvents:OPTLYDataStoreEventTypeImpression callback:^{
                dispatch_group_leave(dispatchEventsGroup);
            }];
            
            dispatch_group_enter(dispatchEventsGroup);
            [strongSelf flushSavedEvents:OPTLYDataStoreEventTypeConversion callback:^{
                dispatch_group_leave(dispatchEventsGroup);
            }];
            
            dispatch_group_wait(dispatchEventsGroup, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)));
            
            callback();
            return;
        }
        
        [strongSelf flushSavedEvents:OPTLYDataStoreEventTypeImpression callback:nil];
        [strongSelf flushSavedEvents:OPTLYDataStoreEventTypeConversion callback:nil];
        
    });
}

// The completion block is called when all dispatch event complete
- (void)flushSavedEvents:(OPTLYDataStoreEventType)eventType callback:(void(^)())callback
{
    NSString *eventName = [OPTLYDataStore stringForDataEventEnum:eventType];
    NSError *error = nil;
    NSArray *events = [self.dataStore getFirstNEvents:OPTLYEventDispatcherMaxDispatchEventBatchSize
                                            eventType:eventType
                                                error:&error];
    NSInteger numberOfEvents = [events count];
    
    if (error) {
        if (callback) {
            callback();
        }
        return;
    }
    
    NSString *logMessage = @"";
    if (numberOfEvents == 0) {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherFlushSavedEventsNoEvents, eventName];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        if (callback) {
            callback();
        }
        return;
    }
    
    logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherFlushingSavedEvents, eventName, numberOfEvents];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    
    // ---- For Testing ----
    // call the completion block when ALL event dispatch has completed
    // TODO: Wrap in TEST preprocessor
    if (callback) {
        dispatch_group_t dispatchEventGroup = dispatch_group_create();
        
        // This will be batched in the near future...
        for (NSInteger i = 0 ; i < numberOfEvents; ++i) {
            NSDictionary *event = events[i];
            dispatch_group_enter(dispatchEventGroup);
            
            [self dispatchEvent:event backoffRetry:NO eventType:eventType callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_group_leave(dispatchEventGroup);
            }];
        }
        
        dispatch_group_wait(dispatchEventGroup, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)));
        callback();
        return;
    }
    
    // This will be batched in the near future...
    for (NSInteger i = 0 ; i < numberOfEvents; ++i) {
        NSDictionary *event = events[i];
        [self dispatchEvent:event backoffRetry:YES eventType:eventType callback:nil];
    }
}

#pragma mark - Application Lifecycle Handlers

- (void)setupApplicationNotificationHandlers {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    UIApplication *app = [UIApplication sharedApplication];
    
    [defaultCenter addObserver:self
                      selector:@selector(applicationDidFinishLaunching:)
                          name:UIApplicationDidFinishLaunchingNotification
                        object:app];
    
    [defaultCenter addObserver:self
                      selector:@selector(applicationDidBecomeActive:)
                          name:UIApplicationDidBecomeActiveNotification
                        object:app];
    
    [defaultCenter addObserver:self
                      selector:@selector(applicationDidEnterBackground:)
                          name:UIApplicationDidEnterBackgroundNotification
                        object:app];
    
    [defaultCenter addObserver:self
                      selector:@selector(applicationWillEnterForeground:)
                          name:UIApplicationWillEnterForegroundNotification
                        object:app];
    
    [defaultCenter addObserver:self
                      selector:@selector(applicationWillResignActive:)
                          name:UIApplicationWillResignActiveNotification
                        object:app];
    
    [defaultCenter addObserver:self
                      selector:@selector(applicationWillTerminate:)
                          name:UIApplicationWillTerminateNotification
                        object:app];
}


- (void)applicationDidFinishLaunching:(id)notificaton {
    OPTLYLogInfo(@"applicationDidFinishLaunching");
}

- (void)applicationDidBecomeActive:(id)notificaton {
    [self flushEvents];
    OPTLYLogInfo(@"applicationDidBecomeActive");
}

- (void)applicationDidEnterBackground:(id)notification {
    // flush events is not guaranteed to finish before the app is suspended
    [self flushEvents];
    OPTLYLogInfo(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(id)notification {
    OPTLYLogInfo(@"applicationWillEnterForeground");
}

- (void)applicationWillResignActive:(id)notification {
    OPTLYLogInfo(@"applicationWillResignActive");
}

- (void)applicationWillTerminate:(id)notification {
    [self flushEvents];
    OPTLYLogInfo(@"applicationWillTerminate");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

# pragma mark - Helper Methods
- (NSInteger )numberOfEvents:(OPTLYDataStoreEventType)eventType
{
    NSInteger numberOfEvents = [self.dataStore numberOfEvents:eventType
                                                        error:nil];
    return numberOfEvents;
}

- (NSInteger)numberOfEvents
{
    NSInteger numberOfImpressionEventsSaved = [self numberOfEvents:OPTLYDataStoreEventTypeImpression];
    NSInteger numberOfConversionEventsSaved = [self numberOfEvents:OPTLYDataStoreEventTypeConversion];
    return numberOfImpressionEventsSaved + numberOfConversionEventsSaved;
}

- (NSURL *)URLForEvent:(OPTLYDataStoreEventType)eventType {
    NSURL *url = nil;
    switch(eventType) {
        case OPTLYDataStoreEventTypeImpression:
            url = [NSURL URLWithString:OPTLYEventDispatcherImpressionEventURL];
            break;
        case OPTLYDataStoreEventTypeConversion:
            url = [NSURL URLWithString:OPTLYEventDispatcherConversionEventURL];
            break;
        default:
            break;
    }
    return url;
}

- (BOOL)isTimerEnabled
{
    BOOL timerIsNotNil = self.timer != nil;
    BOOL timerIsValid = self.timer.valid;
    BOOL timerIntervalIsSet = (self.timer.timeInterval == self.eventDispatcherDispatchInterval) && (self.eventDispatcherDispatchInterval > 0);
    
    return timerIsNotNil && timerIntervalIsSet && timerIsValid;
}
@end

