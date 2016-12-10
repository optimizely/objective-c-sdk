/****************************************************************************
 * Copyright 2016, Optimizely, Inc. and contributors                        *
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

#import "OPTLYEventDispatcher.h"

// TODO - Flush events when network connection has become available. 

// --- Event URLs ----
NSString * const OPTLYEventDispatcherImpressionEventURL   = @"https://logx.optimizely.com/log/decision";
NSString * const OPTLYEventDispatcherConversionEventURL   = @"https://logx.optimizely.com/log/event";

// Default interval and timeout values (in ms) if not set by users
NSInteger const OPTLYEventDispatcherDefaultDispatchIntervalTime_ms = 1000;
NSInteger const OPTLYEventDispatcherDefaultDispatchTimeout_ms = 10000;

@interface OPTLYEventDispatcherDefault()
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) uint64_t flushEventBackoffRetries;
@property (nonatomic, assign) uint64_t flushEventCall;
@property (nonatomic, assign) uint64_t maxDispatchBackoffRetries;
@end

@implementation OPTLYEventDispatcherDefault : NSObject

+ (nullable instancetype)initWithBuilderBlock:(nonnull OPTLYEventDispatcherBuilderBlock)block {
    return [[self alloc] initWithBuilder:[OPTLYEventDispatcherBuilder builderWithBlock:block]];
}

- (instancetype)init {
    return [self initWithBuilder:nil];
}

- (instancetype)initWithBuilder:(OPTLYEventDispatcherBuilder *)builder {
    self = [super init];
    if (self != nil) {
        _flushEventBackoffRetries = 0;
        _flushEventCall = 0;
        _timer = nil;
        _eventDispatcherDispatchInterval = OPTLYEventDispatcherDefaultDispatchIntervalTime_ms;
        _eventDispatcherDispatchTimeout = OPTLYEventDispatcherDefaultDispatchTimeout_ms;

        _logger = builder.logger;
        
        if (builder.eventDispatcherDispatchInterval > 0) {
            _eventDispatcherDispatchInterval = builder.eventDispatcherDispatchInterval;
        } else {
            NSString *logMessage =  [NSString stringWithFormat: OPTLYLoggerMessagesEventDispatcherInvalidInterval, builder.eventDispatcherDispatchInterval];
            [_logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        }
        
        if (builder.eventDispatcherDispatchTimeout > 0) {
            _eventDispatcherDispatchTimeout = builder.eventDispatcherDispatchTimeout;
        } else {
            NSString *logMessage =  [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherInvalidTimeout, builder.eventDispatcherDispatchTimeout];
            [_logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        }
        
        _maxDispatchBackoffRetries = (_eventDispatcherDispatchInterval > 0) && (_eventDispatcherDispatchTimeout > 0) ? _eventDispatcherDispatchTimeout/_eventDispatcherDispatchInterval : 0;
        
        _dataStore = [[OPTLYDataStore alloc] initWithLogger:_logger];

        [self setupApplicationNotificationHandlers];
        
        NSString *logMessage =  [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherProperties, _eventDispatcherDispatchInterval, _eventDispatcherDispatchTimeout, _maxDispatchBackoffRetries];
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

# pragma mark - Network Timer
// Set up the network timer when:
//      - saved events are detected
//      - event failed to send
// If the event handler dispatch interval is not set, then retries are disabled.
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
            
            NSString *logMessage =  [NSString stringWithFormat: OPTLYLoggerMessagesEventDispatcherNetworkTimerEnabled, self.eventDispatcherDispatchInterval, self.eventDispatcherDispatchTimeout, self.maxDispatchBackoffRetries];
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

// The network timer should be reset when:
//      - max retry time has been reached
//      - all saved event queue are empty and event is successfully sent
// The timer must be disabled on the main thread.
- (void)disableNetworkTimer:(void(^)())completion {
    
    if (![self isTimerEnabled]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        __typeof__(self) strongSelf = weakSelf;
        [strongSelf.timer invalidate];
        strongSelf.timer = nil;
        
        NSString *logMessage = OPTLYLoggerMessagesEventDispatcherNetworkTimerDisabled;
        [strongSelf.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        
        if (completion) {
            completion();
        }
    };
    
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

# pragma mark - Dispatch Events
- (void)dispatchImpressionEvent:(nonnull NSDictionary *)params
                       callback:(nullable OPTLYEventDispatcherResponse)callback {
    
    NSString *logMessage =  [NSString stringWithFormat:OPTLYLoggerMessagesDispatchingImpressionEvent, params];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    
    [self dispatchEvent:params eventType:OPTLYDataStoreEventTypeImpression callback:callback];
}

- (void)dispatchConversionEvent:(nonnull NSDictionary *)params
                       callback:(nullable OPTLYEventDispatcherResponse)callback {
    
    NSString *logMessage =  [NSString stringWithFormat:OPTLYLoggerMessagesDispatchingConversionEvent, params];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    
    [self dispatchEvent:params eventType:OPTLYDataStoreEventTypeConversion callback:callback];
}

- (void)dispatchEvent:(nonnull NSDictionary *)event
            eventType:(OPTLYDataStoreEventType)eventType
             callback:(nullable OPTLYEventDispatcherResponse)callback {

    NSString *eventName = [OPTLYDataStore stringForDataEventEnum:eventType];
    NSURL *url = [self URLForEvent:eventType];
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:url];
    __weak typeof(self) weakSelf = self;
    [requestManager POSTWithParameters:event completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (!error) {
            [strongSelf flushEvents];
            
            NSString *logMessage =  [NSString stringWithFormat: OPTLYLoggerMessagesEventDispatcherEventDispatchSuccess, eventName, event];
            [strongSelf.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            
            if (callback) {
                callback(data, response, error);
            }
        } else {
            NSError *saveError = nil;
            [strongSelf saveEvent:event eventType:eventType error:&saveError];
            
            NSString *logMessage =  [NSString stringWithFormat: OPTLYLoggerMessagesEventDispatcherEventDispatchFailed, eventName, event, error];
            [strongSelf.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            
            if (![strongSelf isTimerEnabled]) {
                strongSelf.flushEventBackoffRetries = 0;
                strongSelf.flushEventCall = 0;
                [strongSelf setupNetworkTimer:^{
                    if (callback) {
                        callback(data, response, error);
                    }
                }];
            } else {
                if (callback) {
                    callback(data, response, error);
                }
            }
        }
    }];
}

# pragma mark - Save Events

// save events only when the event dispatch fails or can't be completed at the current moment
- (void)saveEvent:(NSDictionary *)params
        eventType:(OPTLYDataStoreEventType)eventType
            error:(NSError **)error {
    // on iOS, save data to the database and only cache when database save fails
#if TARGET_OS_IOS
    [self.dataStore saveData:params eventType:eventType cachedData:NO error:error];
    if (error && *error) {
        [self.dataStore saveData:params eventType:eventType cachedData:YES error:error];
    }
    // database saves are not enabled for tvOS, cache for now
#elif TARGET_OS_TV
    [self.dataStore saveData:params eventType:eventType cachedData:YES error:error];
#endif
}

- (void)flushEvents {
    [self flushEvents:nil];
}

// flushed cached and saved events
- (void)flushEvents:(void(^)())callback
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(flushEventsQueue(), ^{
        __typeof__(self) strongSelf = weakSelf;
        
        // return if no events to save
        if (![strongSelf haveEventsToSend]) {
            
            NSString *logMessage = OPTLYLoggerMessagesEventDispatcherFlushEventsNoEvents;
            [strongSelf.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            
            [strongSelf disableNetworkTimer:^{
                if (callback) {
                    callback();
                }
            }];
            return;
        }
        
        // setup the network timer if needed and reset all the counters
        if (![strongSelf isTimerEnabled]) {
            strongSelf.flushEventBackoffRetries = 0;
            strongSelf.flushEventCall = 0;
            [strongSelf setupNetworkTimer:nil];
        }
        
        strongSelf.flushEventCall++;
        OPTLYLogDebug(@"Dispatch event call - %ld", strongSelf.flushEventCall);
        
        //exponential backoff: only dispatch at a power of two interval; o/w return
        if (![strongSelf isPowerOf2:strongSelf.flushEventCall]) {

            NSString *logMessage =  [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherFlushEventsBackoffSkipRetry, strongSelf.flushEventCall];
            [strongSelf.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    
            if (callback) {
                callback();
            }
            return;
        }
        
        // stop trying to flush if max retries have been exceeded
        if (strongSelf.flushEventBackoffRetries > strongSelf.maxDispatchBackoffRetries) {
        
            NSString *logMessage =  [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherFlushEventsBackoffMaxRetries, strongSelf.flushEventBackoffRetries];
            [strongSelf.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            
            [self disableNetworkTimer:^{
                if (callback) {
                    callback();
                }
            }];
            return;
        }

        strongSelf.flushEventBackoffRetries++;
        OPTLYLogDebug(@"Backoff retry - %ld.", strongSelf.flushEventBackoffRetries);
        
        [strongSelf flushSavedEvents:OPTLYDataStoreEventTypeImpression cachedData:YES];
        [strongSelf flushSavedEvents:OPTLYDataStoreEventTypeConversion cachedData:YES];
#if TARGET_OS_IOS
        [strongSelf flushSavedEvents:OPTLYDataStoreEventTypeImpression cachedData:NO];
        [strongSelf flushSavedEvents:OPTLYDataStoreEventTypeConversion cachedData:NO];
#endif
        if (callback) {
            callback();
        }
        return;
    });
}

// flushing saved events require deletion upon successfully dispatch
- (void)flushSavedEvent:(NSDictionary *)event
              eventType:(OPTLYDataStoreEventType)eventType
             cachedData:(BOOL)cachedData
               callback:(OPTLYEventDispatcherResponse)callback
{
    NSString *eventName = [OPTLYDataStore stringForDataEventEnum:eventType];
    OPTLYLogInfo(@"Flushing a saved %@ event - %@.", eventName, event);
    
    if (![self haveEventsToSend:eventType cachedData:cachedData]) {
        
        NSString *logMessage =  [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventDispatchFlushSavedEventNoEvents, eventName];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        
        if (callback) {
            callback(nil, nil, nil);
        }
        return;
    }
    
    NSURL *url = [self URLForEvent:eventType];
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:url];
    __weak typeof(self) weakSelf = self;
    [requestManager POSTWithParameters:event completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (!error) {
        
            NSString *logMessage =  [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherFlushSavedEventSuccess, eventName, event];
            [strongSelf.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            
            [strongSelf.dataStore removeOldestEvent:eventType cachedData:cachedData error:&error];
            // if the event has been successfully dispatched and there are no saved events, disable the timer
            if (![strongSelf haveEventsToSend]) {
                [strongSelf disableNetworkTimer:^{
                    if (callback) {
                        callback(data, response, error);
                    }
                }];
                return;
            }
            else {
                if (callback) {
                    callback(data, response, error);
                }
                return;
            }
        } else {
            NSString *logMessage =  [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherFlushSavedEventFailure, eventName, event];
            [strongSelf.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            
            // if the event failed to send, enable the network timer to retry at a later time
            if (![strongSelf isTimerEnabled]) {
                [strongSelf setupNetworkTimer:^{
                    if (callback) {
                        callback(data, response, error);
                    }
                }];
                return;
            } else {
                if (callback) {
                    callback(data, response, error);
                }
                return;
            }
        }
    }];
}

- (void)flushSavedEvents:(OPTLYDataStoreEventType)eventType
              cachedData:(BOOL)cachedData
{
    NSString *eventName = [OPTLYDataStore stringForDataEventEnum:eventType];
    OPTLYLogInfo(@"Flushing saved %@ events", eventName);
    
    NSError *error = nil;
    NSInteger totalNumberOfEvents = [self.dataStore numberOfEvents:eventType cachedData:cachedData error:&error];
    NSArray *events = [self.dataStore getAllEvents:eventType cachedData:cachedData error:&error];
    
    if (!totalNumberOfEvents) {
        return;
    }
    
    if (error) {
        NSString *logMessage =  [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherFlushSavedEventFailure, eventName, nil];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return;
    }
    
    // This will be batched in the near future...
    for (NSInteger i = 0 ; i < totalNumberOfEvents; ++i) {
        NSDictionary *event = events[i];
        [self flushSavedEvent:event eventType:eventType cachedData:cachedData callback:nil];
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
    [self flushEvents];
    OPTLYLogInfo(@"applicationDidFinishLaunching");
}

- (void)applicationDidBecomeActive:(id)notificaton {
    OPTLYLogInfo(@"applicationDidBecomeActive");
}

- (void)applicationDidEnterBackground:(id)notification {
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
- (BOOL)haveEventsToSend:(OPTLYDataStoreEventType)eventType cachedData:(BOOL)cachedData
{
    NSInteger numberOfEvents = [self.dataStore numberOfEvents:eventType
                                                   cachedData:cachedData
                                                        error:nil];
    return numberOfEvents;
}

- (BOOL)haveEventsToSend
{
    NSInteger numberOfImpressionEventsSaved = [self haveEventsToSend:OPTLYDataStoreEventTypeImpression cachedData:NO];
    NSInteger numberOfImpressionEventsCached = [self haveEventsToSend:OPTLYDataStoreEventTypeImpression cachedData:YES];
    NSInteger numberOfConversionEventsSaved = [self haveEventsToSend:OPTLYDataStoreEventTypeConversion cachedData:NO];
    NSInteger numberOfConversionEventsCached = [self haveEventsToSend:OPTLYDataStoreEventTypeConversion cachedData:YES];
    
    return (numberOfImpressionEventsSaved > 0 ||
            numberOfImpressionEventsCached > 0  ||
            numberOfConversionEventsSaved > 0 ||
            numberOfConversionEventsCached > 0);
}

- (bool)isPowerOf2:(uint64_t)x {
    uint64_t numberOf1s = 0;
    while (x) {
        numberOf1s += x & 1;
        x >>= 1;
    }
    return (numberOf1s == 1);
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
    BOOL timeoutIsValid = self.eventDispatcherDispatchTimeout > 0;
    
    return timerIsNotNil && timerIsValid && timerIntervalIsSet && timeoutIsValid;
}
@end

