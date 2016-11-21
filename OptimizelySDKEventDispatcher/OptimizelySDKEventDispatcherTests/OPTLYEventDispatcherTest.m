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

#import <XCTest/XCTest.h>
#import <OptimizelySDKShared/OptimizelySDKShared.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "OPTLYEventDispatcher.h"
#import "OPTLYEventDispatcherBuilder.h"

static NSInteger const kEventHandlerDispatchInterval = 3;
static NSInteger const kEventHandlerDispatchTimeout = 10;
static NSString * const kTestURLString = @"testURL";

typedef void (^EventDispatchCallback)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface OPTLYEventDispatcher(test)
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger maxDispatchBackoffRetries;
@property (nonatomic, assign) uint32_t flushEventBackoffRetries;
@property (nonatomic, assign) uint32_t flushEventCall;
- (void)flushSavedEvent:(NSDictionary *)event
              eventType:(OPTLYDataStoreEventType)eventType
             cachedData:(BOOL)cachedData
               callback:(OPTLYEventDispatcherResponse)callback;
- (NSURL *)URLForEvent:(OPTLYDataStoreEventType)eventType;
- (void)flushSavedEvents:(OPTLYDataStoreEventType)eventType
              cachedData:(BOOL)cachedData
                callback:(OPTLYEventDispatcherResponse)callback;
- (void)flushEvents:(void(^)())callback;
- (BOOL)isTimerEnabled;
- (void)saveEvent:(NSDictionary *)params
        eventType:(OPTLYDataStoreEventType)eventType
            error:(NSError **)error;
- (void)setupNetworkTimer:(void(^)())completion;
- (void)disableNetworkTimer:(void(^)())completion;
@end

@interface OPTLYEventDispatcherTest : XCTestCase
@property (nonatomic, strong ) NSURL *testURL;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@property (nonatomic, strong) OPTLYEventDispatcher *eventDispatcher;
@end

@implementation OPTLYEventDispatcherTest

- (void)setUp {
    [super setUp];
    self.testURL = [NSURL URLWithString:kTestURLString];
    self.parameters = @{@"testKey1" : @"testValue2", @"testKey2" : @"testValue2"};
    self.eventDispatcher = [OPTLYEventDispatcher new];
    self.eventDispatcher.flushEventBackoffRetries = 0;
}

- (void)tearDown {
    self.testURL = nil;
    self.parameters = nil;
    [self.eventDispatcher.dataStore removeAll:nil];
    self.eventDispatcher.dataStore = nil;
    self.eventDispatcher = nil;
    [super tearDown];
}

- (void)testEventDispatcherInitWithBuilderBlock
{
    OPTLYEventDispatcher *eventDispatcher = [OPTLYEventDispatcher initWithBuilderBlock:^(OPTLYEventDispatcherBuilder *builder) {
        builder.eventHandlerDispatchInterval = kEventHandlerDispatchInterval;
        builder.eventHandlerDispatchTimeout = kEventHandlerDispatchTimeout;
        builder.logger = [OPTLYLoggerDefault new];
    }];
    
    XCTAssertNotNil(eventDispatcher);
    XCTAssert(eventDispatcher.eventHandlerDispatchInterval == kEventHandlerDispatchInterval, @"Invalid dispatch timeout set.");
    XCTAssert(eventDispatcher.eventHandlerDispatchTimeout == kEventHandlerDispatchTimeout, @"Invalid dispatch timeout set.");
    XCTAssertNotNil(eventDispatcher.logger);
    XCTAssert([eventDispatcher.logger isKindOfClass:[OPTLYLoggerDefault class]]);
    
    eventDispatcher = [OPTLYEventDispatcher initWithBuilderBlock:^(OPTLYEventDispatcherBuilder *builder) {
    }];
    
    XCTAssertNotNil(eventDispatcher);
    XCTAssert(eventDispatcher.eventHandlerDispatchInterval == OPTLYEventDispatcherDefaultDispatchIntervalTime_ms, @"Invalid default dispatch interval set.");
    XCTAssert(eventDispatcher.eventHandlerDispatchTimeout == OPTLYEventDispatcherDefaultDispatchTimeout_ms, @"Invalid default dispatch timeout set.");
    XCTAssertNil(eventDispatcher.logger);
}

// Test that a successful dispatch:
//  - data does not persist events in db or cache
//  - the timer is also disabled
- (void)testDispatchImpressionEventSuccess {
    [self stubSuccessResponse];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for dispatchImpressionEvent success."];
    [self.eventDispatcher dispatchImpressionEvent:self.parameters callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self eventDispatchSuccessCheck:OPTLYDataStoreEventTypeImpression];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for dispatchImpressionEvent: %@", error);
        }
    }];
}

- (void)testDispatchConversionEventSuccess {
    [self stubSuccessResponse];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for dispatchConversionEvent success."];
    [self.eventDispatcher dispatchConversionEvent:self.parameters callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self eventDispatchSuccessCheck:OPTLYDataStoreEventTypeConversion];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for dispatchConversionEvent: %@", error);
        }
    }];
}

- (void)eventDispatchSuccessCheck:(OPTLYDataStoreEventType)eventType {
    NSInteger numberOfSavedEvents = [self.dataStore numberOfEvents:eventType cachedData:NO error:nil];
    XCTAssert(numberOfSavedEvents == 0, @"Events should not have been saved.");
    NSInteger numberOfCachedEvents = [self.dataStore numberOfEvents:eventType cachedData:YES error:nil];
    XCTAssert(numberOfCachedEvents == 0, @"Events should not have been cached.");
    
    [self checkNetworkTimerIsDisabled:self.eventDispatcher];
}

// Test that a failed dispatch:
//  - Saves event (in cache for tvOS and db for iOS)
//  - Event saved matches expected value
//  - Timer is started
- (void)testDispatchImpressionEventFailure {
    [self stubFailureResponse];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for dispatchImpressionEvent failure."];
    [self.eventDispatcher dispatchImpressionEvent:self.parameters callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self eventDispatchFailureCheck:OPTLYDataStoreEventTypeImpression];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for dispatchImpressionEvent: %@", error);
        }
    }];
}

- (void)testDispatchConversionEventFailure {
    [self stubFailureResponse];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for dispatchConversionEvent failure."];
    [self.eventDispatcher dispatchConversionEvent:self.parameters callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self eventDispatchFailureCheck:OPTLYDataStoreEventTypeConversion];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for dispatchConversionEvent: %@", error);
        }
    }];
}

- (void)eventDispatchFailureCheck:(OPTLYDataStoreEventType)eventType {
    // event should have been stored
    NSArray *savedEvents = [self.eventDispatcher.dataStore getAllEvents:eventType cachedData:NO error:nil];
    NSArray *cachedEvents = [self.eventDispatcher.dataStore getAllEvents:eventType cachedData:YES error:nil];
    
    NSInteger numberOfSavedEvents, numberOfCachedEvents;
#if TARGET_OS_IOS
    numberOfSavedEvents = 1;
    numberOfCachedEvents = 0;
#elif TARGET_OS_TV
    numberOfSavedEvents  = 0;
    numberOfCachedEvents = 1;
#endif
    XCTAssert([savedEvents count] == numberOfSavedEvents, @"Invalid number of saved events.");
    XCTAssert([cachedEvents count] == numberOfCachedEvents, @"Invalid number of cached events.");
    
    [self checkNetworkTimerIsEnabled:self.eventDispatcher timeInterval:OPTLYEventDispatcherDefaultDispatchIntervalTime_ms];
}

// test dispatch attempt does not exceed the max retries
// also check that the dispatch attempt is only made at power of 2 attempt count
- (void)testMaxDispatchBackoffRetriesAndPowerOf2 {
    [self stubFailureResponse];
    
    OPTLYEventDispatcher *eventDispatcher = [OPTLYEventDispatcher initWithBuilderBlock:^(OPTLYEventDispatcherBuilder *builder) {
        builder.eventHandlerDispatchInterval = kEventHandlerDispatchInterval;
        builder.eventHandlerDispatchTimeout = kEventHandlerDispatchTimeout;
        builder.logger = [OPTLYLoggerDefault new];
    }];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for dispatchConversionEvent failure."];
    [eventDispatcher setupNetworkTimer:nil];
    
    NSInteger numberOfRetries = 10;
    for (NSInteger i = 0; i < numberOfRetries; ++i) {
        [eventDispatcher saveEvent:self.parameters
                         eventType:OPTLYDataStoreEventTypeImpression
                             error:nil];
    }
    __weak typeof(self) weakSelf = self;
    for (NSInteger i = 1; i < numberOfRetries; ++i) {
        //NSLog(@"Dispatch attempt - %ld. Dispatch event call - %u", i, eventDispatcher.flushEventCall);
        [eventDispatcher flushEvents:^{
            NSLog(@"************ i - %ld, backoff retry - %u, dispatch call - %u", i, eventDispatcher.flushEventBackoffRetries, eventDispatcher.flushEventCall);
            // check that the dispatch attempt is only made at power of 2 attempt count
            NSInteger backoffRetryExpected = log2(i)+1;
            XCTAssert(eventDispatcher.flushEventBackoffRetries == backoffRetryExpected, @"Invalid value for the backoff retry count - %ld, %u, %ld", i, eventDispatcher.flushEventBackoffRetries, backoffRetryExpected);
            
            XCTAssert(eventDispatcher.flushEventBackoffRetries <= eventDispatcher.maxDispatchBackoffRetries + 1, @"dispatch retries exceeded max - %u", eventDispatcher.flushEventBackoffRetries);
            
            NSLog(@"flushEventCall - %u", eventDispatcher.flushEventCall);
            if (eventDispatcher.flushEventCall == numberOfRetries - 1) {
                [weakSelf checkNetworkTimerIsEnabled:eventDispatcher
                                        timeInterval:kEventHandlerDispatchInterval];
                [expectation fulfill];
            }
        }];
    }

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for dispatchConversionEvent: %@", error);
        }
    }];
}

- (void)testflushEventsSuccessSavedEvents {
    
    [self stubSuccessResponse];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for dispatchConversionEvent failure."];
    [self.eventDispatcher setupNetworkTimer:nil];
    
    for (NSInteger i = 0; i < 3; ++i) {
        [self.eventDispatcher saveEvent:self.parameters
                              eventType:OPTLYDataStoreEventTypeImpression
                                  error:nil];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.eventDispatcher flushEvents:^{
        [weakSelf checkNetworkTimerIsEnabled:weakSelf.eventDispatcher timeInterval:OPTLYEventDispatcherDefaultDispatchIntervalTime_ms];
        [expectation fulfill];
        
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for dispatchConversionEvent: %@", error);
        }
    }];
}

- (void)testflushEventsSuccessNoSavedEvents {
    
    [self stubSuccessResponse];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for dispatchConversionEvent failure."];
    [self.eventDispatcher setupNetworkTimer:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.eventDispatcher flushEvents:^{
        [weakSelf checkNetworkTimerIsDisabled:weakSelf.eventDispatcher];
        [expectation fulfill];
        
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for dispatchConversionEvent: %@", error);
        }
    }];
}

- (void)testflushEventsFailureSavedEvents {
    
    [self stubSuccessResponse];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for dispatchConversionEvent failure."];
    [self.eventDispatcher setupNetworkTimer:nil];
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.eventDispatcher flushEvents:^{
        [weakSelf checkNetworkTimerIsDisabled:weakSelf.eventDispatcher];
        [expectation fulfill];
        
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for dispatchConversionEvent: %@", error);
        }
    }];
}

- (void)testFlushSavedEventSuccess
{
    BOOL usedCachedData = NO;
#if TARGET_OS_TV
    usedCachedData = YES;
#endif
    [self stubSuccessResponse];
    [self.eventDispatcher setupNetworkTimer:nil];
    [self.eventDispatcher saveEvent:self.parameters eventType:OPTLYDataStoreEventTypeConversion error:nil];
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for dispatchConversionEvent failure."];
    [self.eventDispatcher flushSavedEvent:self.parameters eventType:OPTLYDataStoreEventTypeConversion cachedData:usedCachedData callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSArray *events = [self.eventDispatcher.dataStore getAllEvents:OPTLYDataStoreEventTypeConversion
                                                            cachedData:usedCachedData
                                                                 error:nil];
        XCTAssert([events count] == 0, @"Event should have been removed.");
        [self eventDispatchSuccessCheck:OPTLYDataStoreEventTypeConversion];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for dispatchConversionEvent: %@", error);
        }
    }];
}

- (void)testFlushSavedEventFailure
{
    BOOL usedCachedData = NO;
#if TARGET_OS_TV
    usedCachedData = YES;
#endif
    
    [self stubFailureResponse];
    [self.eventDispatcher setupNetworkTimer:nil];
    [self.eventDispatcher saveEvent:self.parameters eventType:OPTLYDataStoreEventTypeConversion error:nil];
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for dispatchConversionEvent failure."];
    [self.eventDispatcher flushSavedEvent:self.parameters eventType:OPTLYDataStoreEventTypeConversion cachedData:usedCachedData callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSArray *events = [self.eventDispatcher.dataStore getAllEvents:OPTLYDataStoreEventTypeConversion
                                                            cachedData:usedCachedData
                                                                 error:nil];
        XCTAssert([events count] == 1, @"Event should be saved.");
        [self eventDispatchFailureCheck:OPTLYDataStoreEventTypeConversion];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for dispatchConversionEvent: %@", error);
        }
    }];
}

- (void)testSaveEventSuccess
{
    // save success
    NSError *error = nil;
    [self.eventDispatcher saveEvent:self.parameters eventType:OPTLYDataStoreEventTypeImpression error:&error];
    NSArray *savedEvents = [self.eventDispatcher.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression cachedData:NO error:nil];
    NSArray *cachedEvents = [self.eventDispatcher.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression cachedData:YES error:nil];
    
    NSInteger numberOfSavedEvents, numberOfCachedEvents;
#if TARGET_OS_IOS
    numberOfSavedEvents = 1;
    numberOfCachedEvents = 0;
#elif TARGET_OS_TV
    numberOfSavedEvents  = 0;
    numberOfCachedEvents = 1;
#endif
    
    XCTAssert([savedEvents count] == numberOfSavedEvents, @"Invalid number of saved events.");
    XCTAssert([cachedEvents count] == numberOfCachedEvents, @"Invalid number of cached events.");
}

- (void)testSavedEventFailure
{
    // force a save fail to make sure that the event is cached
    NSError *error = [NSError errorWithDomain:@"saveEventTest" code:0 userInfo:nil];
    [self.eventDispatcher saveEvent:self.parameters eventType:OPTLYDataStoreEventTypeImpression error:&error];
    NSArray *cachedEvents = [self.eventDispatcher.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression cachedData:YES error:nil];
    XCTAssert([cachedEvents count] == 1, @"Invalid number of cached events.");
}

#pragma mark -- Helper Methods

- (void)checkNetworkTimerIsEnabled:(OPTLYEventDispatcher *)eventDispatcher timeInterval:(NSInteger)timeInterval
{
    // check that the timer is set correctly
    XCTAssertNotNil(eventDispatcher.timer, @"Timer should not be nil.");
    XCTAssertTrue(eventDispatcher.timer.valid, @"Timer is not valid.");
    XCTAssert(eventDispatcher.timer.timeInterval == timeInterval, @"Invalid time interval set - %f.", eventDispatcher.timer.timeInterval);
}

- (void)checkNetworkTimerIsDisabled:(OPTLYEventDispatcher *)eventDispatcher
{
    // check that the timer is reset
    XCTAssertNil(eventDispatcher.timer, @"Timer should be nil.");
}

- (void)stubFailureResponse
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return YES; // Stub ALL requests without any condition
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:NSURLErrorTimedOut
                                         userInfo:nil];
        return [OHHTTPStubsResponse responseWithError:error];
    }];
}

- (void)stubSuccessResponse
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return YES; // Stub ALL requests without any condition
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSData* stubData = [@"Data sent!" dataUsingEncoding:NSUTF8StringEncoding];
        return [OHHTTPStubsResponse responseWithData:stubData statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
}
@end
