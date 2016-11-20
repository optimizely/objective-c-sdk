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

// --- Event URLs ----
NSString * const OPTLYEventDispatcherImpressionEventURL   = @"https://logx.optimizely.com/log/decision"; // @"https://p13nlog.dz.optimizely.com/log/decision";
NSString * const OPTLYEventDispatcherConversionEventURL   = @"https://logx.optimizely.com/log/event";    // @"https://p13nlog.dz.optimizely.com/log/event";

// Default interval and timeout values (in ms) if not set by users
NSInteger const OPTLYEventDispatcherDefaultDispatchIntervalTime_ms = 1000;
NSInteger const OPTLYEventDispatcherDefaultDispatchTimeout_ms = 10000;

@interface OPTLYEventDispatcher()
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) uint32_t dispatchEventBackoffRetries;
@property (nonatomic, assign) uint32_t dispatchEventCall;
@property (nonatomic, assign) NSInteger maxDispatchBackoffRetries;
@end

@implementation OPTLYEventDispatcher : NSObject

+ (nullable instancetype)initWithBuilderBlock:(nonnull OPTLYEventDispatcherBuilderBlock)block {
    return [[self alloc] initWithBuilder:[OPTLYEventDispatcherBuilder builderWithBlock:block]];
}

- (instancetype)init {
    return [self initWithBuilder:nil];
}

- (instancetype)initWithBuilder:(OPTLYEventDispatcherBuilder *)builder {
    self = [super init];
    if (self != nil) {
        _dispatchEventBackoffRetries = 0;
        _dispatchEventCall = 0;
        _timer = nil;
        _eventHandlerDispatchInterval = OPTLYEventDispatcherDefaultDispatchIntervalTime_ms;
        _eventHandlerDispatchTimeout = OPTLYEventDispatcherDefaultDispatchTimeout_ms;

        _logger = builder.logger;
        
        if (builder.eventHandlerDispatchInterval > 0) {
            _eventHandlerDispatchInterval = builder.eventHandlerDispatchInterval;
        } 
        
        if (builder.eventHandlerDispatchTimeout > 0) {
            _eventHandlerDispatchTimeout = builder.eventHandlerDispatchTimeout;
        }
        
        _maxDispatchBackoffRetries = (_eventHandlerDispatchInterval > 0) && (_eventHandlerDispatchTimeout > 0) ? _eventHandlerDispatchTimeout/_eventHandlerDispatchInterval : 0;
        
        _dataStore = [OPTLYDataStore new];
        
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherInterval, _eventHandlerDispatchInterval];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        [self setupApplicationNotificationHandlers];
        
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
        if (strongSelf.eventHandlerDispatchInterval > 0) {
            strongSelf.timer = [NSTimer scheduledTimerWithTimeInterval:strongSelf.eventHandlerDispatchInterval
                                                                target:strongSelf
                                                              selector:@selector(flushEvents)
                                                              userInfo:nil
                                                               repeats:YES];
            if (completion) {
                completion();
                OPTLYLogInfo(@"Network timer enabled.");
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
// Also kept timer invalidation on the main thread.
- (void)disableNetworkTimer:(void(^)())completion {
    
    if (![self isTimerEnabled]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        __typeof__(self) strongSelf = weakSelf;
        [strongSelf.timer invalidate];
        strongSelf.timer = nil;
        OPTLYLogInfo(@"Network timer disabled.");
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
    [self dispatchEvent:params eventType:OPTLYDataStoreEventTypeImpression callback:callback];
}

- (void)dispatchConversionEvent:(nonnull NSDictionary *)params
                       callback:(nullable OPTLYEventDispatcherResponse)callback {
    [self dispatchEvent:params eventType:OPTLYDataStoreEventTypeConversion callback:callback];
}

- (void)dispatchEvent:(nonnull NSDictionary *)event
            eventType:(OPTLYDataStoreEventType)eventType
             callback:(nullable OPTLYEventDispatcherResponse)callback {

    NSURL *url = [self URLForEvent:eventType];
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:url];
    __weak typeof(self) weakSelf = self;
    [requestManager POSTWithParameters:event completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (!error) {
            OPTLYLogInfo(@"Event [%ld] sent with parameters - %@.", eventType, event);
            [strongSelf flushEvents];
            if (callback) {
                callback(data, response, error);
            }
        } else {
            NSError *saveError = nil;
            [strongSelf saveEvent:event eventType:eventType error:&saveError];
            if (![strongSelf isTimerEnabled]) {
                strongSelf.dispatchEventBackoffRetries = 0;
                strongSelf.dispatchEventCall = 0;
                [strongSelf setupNetworkTimer:^{
                    if (callback) {
                        callback(data, response, error);
                    }
                }];
                OPTLYLogError(@"Event [%ld] not sent with parameters - %@. Saving event. Error received - %@.", eventType, event, error);
            } else {
                if (callback) {
                    callback(data, response, error);
                }
            }
        }
    }];
}

# pragma mark - Save Events

- (void)saveEvent:(NSDictionary *)params
        eventType:(OPTLYDataStoreEventType)eventType
            error:(NSError **)error {
    // TODO: Log save error
    
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
            OPTLYLogInfo(@"No events to send for flush saved events call.");
            [strongSelf disableNetworkTimer:^{
                if (callback) {
                    callback();
                }
            }];
            return;
        }
        
        // setup the network timer if needed and reset all the counters
        if (![strongSelf isTimerEnabled]) {
            strongSelf.dispatchEventBackoffRetries = 0;
            strongSelf.dispatchEventCall = 0;
            [strongSelf setupNetworkTimer:nil];
        }
        
        strongSelf.dispatchEventCall++;
        OPTLYLogInfo(@"Dispatch event call - %ld", strongSelf.dispatchEventCall);
        
        //exponential backoff: only dispatch at a power of two interval; o/w return
        if (![strongSelf isPowerOf2:strongSelf.dispatchEventCall]) {
            OPTLYLogInfo(@"At dispatch call %ld. Skipping dispatch retry.", strongSelf.dispatchEventCall);
            // TODO - generate an error for the callback and log
            if (callback) {
                callback();
            }
            return;
        }
        
        // stop trying to flush if max retries have been exceeded
        if (strongSelf.dispatchEventBackoffRetries > strongSelf.maxDispatchBackoffRetries) {
            OPTLYLogError(@"Attempt to dispatch saved events failed: re-tries have exceeded max allowed time.")
            [self disableNetworkTimer:^{
                // TODO - generate an error for the callback and log
                if (callback) {
                    callback();
                }
            }];
            return;
        }

        strongSelf.dispatchEventBackoffRetries++;
        OPTLYLogError(@"Backoff retry - %ld.", strongSelf.dispatchEventBackoffRetries);
        
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
    OPTLYLogInfo(@"Flushing a saved event [%ld] - %@.", eventType, event);
    
    if (![self haveEventsToSend:eventType cachedData:cachedData]) {
        OPTLYLogInfo(@"No events [%ld] to send for flush saved events call.", eventType);
        // TODO - generate an error for the callback and log
        if (callback) {
            callback(nil, nil, nil);
        }
        return;
    }
    
    NSURL *url = [self URLForEvent:eventType];
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:url];
    __weak typeof(self) weakSelf = self;
    [requestManager POSTWithParameters:event completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            // TODO - Log this info
            OPTLYLogInfo(@"Event [%ld] successfully sent with parameters - %@. Removing event from storage.", eventType, event);
            [self.dataStore removeOldestEvent:eventType cachedData:cachedData error:&error];
            // if the event has been successfully dispatched and there are no saved events, disable the timer
            if (![weakSelf haveEventsToSend]) {
                [weakSelf disableNetworkTimer:^{
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
            // TODO - Log this error
            OPTLYLogError(@"Event [%ld] not sent with parameters - %@.", eventType, event);
            // if the event failed to send, enable the network timer to retry at a later time
            
            if (![weakSelf isTimerEnabled]) {
                [weakSelf setupNetworkTimer:^{
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
    OPTLYLogInfo(@"Flushing saved events [%ld].", eventType);
    
    NSError *error = nil;
    NSInteger totalNumberOfEvents = [self.dataStore numberOfEvents:eventType cachedData:cachedData error:&error];
    NSArray *events = [self.dataStore getAllEvents:eventType cachedData:cachedData error:&error];
    
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

- (void)applicationDidBecomeActive:(id)notificaton {
    [self flushEvents];
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

- (bool)isPowerOf2:(uint32_t)x {
    uint32_t numberOf1s = 0;
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
    BOOL timerIntervalIsSet = (self.timer.timeInterval == self.eventHandlerDispatchInterval) && (self.eventHandlerDispatchInterval > 0);
    BOOL timeoutIsValid = self.maxDispatchBackoffRetries > 0;
    
    return timerIsNotNil && timerIsValid && timerIntervalIsSet && timeoutIsValid;
}
@end

