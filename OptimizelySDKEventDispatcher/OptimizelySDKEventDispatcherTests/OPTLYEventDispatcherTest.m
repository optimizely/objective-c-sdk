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
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OptimizelySDKShared/OptimizelySDKShared.h>
#import "OPTLYEventDispatcher.h"
#import "OPTLYEventDispatcherBuilder.h"

static NSInteger const kEventHandlerDispatchInterval = 3;
static NSString * const kTestURLString = @"testURL";

typedef void (^EventDispatchCallback)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface OPTLYEventDispatcherDefault(test)
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger flushEventAttempts;
- (NSURL *)URLForEvent:(OPTLYDataStoreEventType)eventType;
- (void)flushEvents:(void(^)())callback;
- (void)flushSavedEvents:(OPTLYDataStoreEventType)eventType callback:(void(^)())callback;
- (void)dispatchEvent:(nonnull NSDictionary *)params
            eventType:(OPTLYDataStoreEventType)eventType
             callback:(nullable OPTLYEventDispatcherResponse)callback;
- (void)dispatchNewEvent:(nonnull NSDictionary *)params
               eventType:(OPTLYDataStoreEventType)eventType
                callback:(nullable OPTLYEventDispatcherResponse)callback;
- (BOOL)isTimerEnabled;
- (void)setupNetworkTimer:(void(^)())completion;
- (void)disableNetworkTimer;
- (NSInteger )numberOfEvents:(OPTLYDataStoreEventType)eventType;
@end

@interface OPTLYEventDispatcherTest : XCTestCase
@property (nonatomic, strong ) NSURL *testURL;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) OPTLYEventDispatcherDefault *eventDispatcher;
@end

@implementation OPTLYEventDispatcherTest

- (void)setUp {
    [super setUp];
    self.testURL = [NSURL URLWithString:kTestURLString];
    self.parameters = @{@"testKey1" : @"testValue2", @"testKey2" : @"testValue2"};
    self.eventDispatcher = [OPTLYEventDispatcherDefault new];
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
    OPTLYEventDispatcherDefault *eventDispatcher = [OPTLYEventDispatcherDefault initWithBuilderBlock:^(OPTLYEventDispatcherBuilder *builder) {
        builder.eventDispatcherDispatchInterval = kEventHandlerDispatchInterval;
        builder.logger = [OPTLYLoggerDefault new];
    }];
    
    XCTAssertNotNil(eventDispatcher);
    XCTAssert(eventDispatcher.eventDispatcherDispatchInterval == kEventHandlerDispatchInterval, @"Invalid dispatch timeout set.");
    XCTAssertNotNil(eventDispatcher.logger);
    XCTAssert([eventDispatcher.logger isKindOfClass:[OPTLYLoggerDefault class]]);
    
    eventDispatcher = [OPTLYEventDispatcherDefault initWithBuilderBlock:^(OPTLYEventDispatcherBuilder *builder) {
    }];
    
    XCTAssertNotNil(eventDispatcher);
    XCTAssert(eventDispatcher.eventDispatcherDispatchInterval == OPTLYEventDispatcherDefaultDispatchIntervalTime_s, @"Invalid default dispatch interval set.");
    XCTAssertNil(eventDispatcher.logger);
}

#pragma mark - dispatchImpressionEvent and dispatchConversionEvent Test Scenarios

// Test that a successful dispatch:
//  - no events are persisted
//  - flushEvents is called
- (void)testDispatchImpressionEventSuccess {
    [self stubSuccessResponse];
    
    OPTLYEventDispatcherDefault *eventDispatcher = [OPTLYEventDispatcherDefault new];
    id eventDispatcherMock = [OCMockObject partialMockForObject:eventDispatcher];
    [[eventDispatcherMock expect] flushEvents];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for dispatchImpressionEvent success."];
    __weak typeof(self) weakSelf = self;
    [eventDispatcherMock dispatchImpressionEvent:self.parameters callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger numberOfSavedEvents = [weakSelf.eventDispatcher numberOfEvents:OPTLYDataStoreEventTypeImpression];
        XCTAssert(numberOfSavedEvents == 0, @"Impression events should not have been saved.");
        [eventDispatcherMock verify];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for dispatchImpressionEvent: %@", error);
        }
    }];
}

- (void)testDispatchConversionEventSuccess {
    [self stubSuccessResponse];
    
    OPTLYEventDispatcherDefault *eventDispatcher = [OPTLYEventDispatcherDefault new];
    id eventDispatcherMock = [OCMockObject partialMockForObject:eventDispatcher];
    [[eventDispatcherMock expect] flushEvents];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for dispatchConversionEvent success."];
    __weak typeof(self) weakSelf = self;
    [eventDispatcherMock dispatchConversionEvent:self.parameters callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger numberOfSavedEvents = [weakSelf.eventDispatcher numberOfEvents:OPTLYDataStoreEventTypeImpression];
        XCTAssert(numberOfSavedEvents == 0, @"Conversion events should not have been saved.");
        [eventDispatcherMock verify];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for dispatchConversionEvent: %@", error);
        }
    }];
}

// Test that a failed dispatch:
//  - Event saved matches expected value
//  - flushEvents is called
- (void)testDispatchImpressionEventFailure {
    [self stubFailureResponse];
    
    OPTLYEventDispatcherDefault *eventDispatcher = [OPTLYEventDispatcherDefault new];
    id eventDispatcherMock = [OCMockObject partialMockForObject:eventDispatcher];
    [[eventDispatcherMock expect] flushEvents];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for dispatchImpressionEvent failure."];
    __weak typeof(self) weakSelf = self;
    [eventDispatcherMock dispatchImpressionEvent:self.parameters callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger numberOfSavedEvents = [weakSelf.eventDispatcher numberOfEvents:OPTLYDataStoreEventTypeImpression];
        XCTAssert(numberOfSavedEvents == 1, @"Impression events should have been saved.");
        [eventDispatcherMock verify];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for dispatchImpressionEvent: %@", error);
        }
    }];
}

- (void)testDispatchConversionEventFailure {
    [self stubFailureResponse];
    
    OPTLYEventDispatcherDefault *eventDispatcher = [OPTLYEventDispatcherDefault new];
    id eventDispatcherMock = [OCMockObject partialMockForObject:eventDispatcher];
    [[eventDispatcherMock expect] flushEvents];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for dispatchConversionEvent failure."];
    __weak typeof(self) weakSelf = self;
    [eventDispatcherMock dispatchConversionEvent:self.parameters callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger numberOfSavedEvents = [weakSelf.eventDispatcher numberOfEvents:OPTLYDataStoreEventTypeConversion];
        XCTAssert(numberOfSavedEvents == 1, @"Conversion events should have been saved.");
        [eventDispatcherMock verify];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for dispatchConversionEvent: %@", error);
        }
    }];
}

#pragma mark - flushEvents Test Scenarios

// if events are saved and flushEvents succeeds,
//  - then the timer should be enabled (the next flushEvents call would disable the timer)
//  - all events should be flushed
- (void)testFlushEventsWithSavedEventsSuccess {
    [self stubSuccessResponse];
    for (NSInteger i = 0; i < 3; ++i) {
        [self.eventDispatcher.dataStore saveEvent:self.parameters
                                        eventType:OPTLYDataStoreEventTypeImpression
                                            error:nil];
    }
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for testFlushEventsWithSavedEventsSuccess failure."];
    __weak typeof(self) weakSelf = self;
    [self.eventDispatcher flushEvents:^{
        NSArray *savedEvents = [weakSelf.eventDispatcher.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression
                                                                          error:nil];
        XCTAssert([savedEvents count] == 0, @"No events should be saved: %lu.", [savedEvents count]);
        
        // next flushEvents call should disable the network timer and reset flush attempt count
        [weakSelf.eventDispatcher flushEvents:^{
            [weakSelf checkNetworkTimerIsDisabled:weakSelf.eventDispatcher];
            XCTAssert(weakSelf.eventDispatcher.flushEventAttempts == 0, @"Flush event attempts should have been reset %lu.", weakSelf.eventDispatcher.flushEventAttempts);
           [expectation fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testFlushEventsWithSavedEventsSuccess: %@", error);
        }
    }];
}

// if events are saved and flushEvents fail,
//  - then the timer should be disabled
//  - events should be stored
- (void)testFlushEventsWithSavedEventsFailure {
    
    [self stubFailureResponse];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for testFlushEventsWithSavedEventsFailure failure."];
    [self.eventDispatcher setupNetworkTimer:nil];
    
    NSInteger numberOfEventsSaved = 3;
    for (NSInteger i = 0; i < numberOfEventsSaved; ++i) {
        [self.eventDispatcher.dataStore saveEvent:self.parameters
                                        eventType:OPTLYDataStoreEventTypeConversion
                                            error:nil];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.eventDispatcher flushEvents:^{
        NSArray *savedEvents = [weakSelf.eventDispatcher.dataStore getAllEvents:OPTLYDataStoreEventTypeConversion
                                                                      error:nil];
        XCTAssert([savedEvents count] == numberOfEventsSaved, @"Events should be saved : %lu.", [savedEvents count]);
        XCTAssert(weakSelf.eventDispatcher.flushEventAttempts == 1, @"Flush event attempts is invalid.");
        [weakSelf checkNetworkTimerIsEnabled:self.eventDispatcher timeInterval:OPTLYEventDispatcherDefaultDispatchIntervalTime_s];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testFlushEventsWithSavedEventsFailure: %@", error);
        }
    }];
}

// if there are no saved events and flushEvents succeeds,
//  - then the timer should be disabled
//  - no events should be saved
- (void)testFlushEventsNoSavedEventsSuccess {
    
    [self stubSuccessResponse];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for testFlushEventsNoSavedEventsSuccess failure."];
    [self.eventDispatcher setupNetworkTimer:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.eventDispatcher flushEvents:^{
        NSArray *savedEvents = [self.eventDispatcher.dataStore getAllEvents:OPTLYDataStoreEventTypeConversion
                                                                      error:nil];
        XCTAssert([savedEvents count] == 0, @"No events should be saved.");
        [weakSelf checkNetworkTimerIsDisabled:weakSelf.eventDispatcher];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testFlushEventsNoSavedEventsSuccess: %@", error);
        }
    }];
}

// if there are no saved events and flushEvents fails,
//  - then the timer should be disabled
//  - no events should be saved
- (void)testFlushEventsNoSavedEventsFailure {
    
    [self stubFailureResponse];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for testFlushEventsNoSavedEventsFailure failure."];
    [self.eventDispatcher setupNetworkTimer:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.eventDispatcher flushEvents:^{
        NSArray *savedEvents = [self.eventDispatcher.dataStore getAllEvents:OPTLYDataStoreEventTypeConversion
                                                                      error:nil];
        XCTAssert([savedEvents count] == 0, @"No events should be saved.");
        [weakSelf checkNetworkTimerIsDisabled:weakSelf.eventDispatcher];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testFlushEventsNoSavedEventsFailure: %@", error);
        }
    }];
}

#pragma mark - dispatchNewEvent Test Cases
- (void)testDispatchNewEventSuccess
{
    [self stubSuccessResponse];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for testDispatchNewEventSuccess failure."];
    [self.eventDispatcher dispatchNewEvent:self.parameters eventType:OPTLYDataStoreEventTypeConversion callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSArray *savedEvents = [self.eventDispatcher.dataStore getAllEvents:OPTLYDataStoreEventTypeConversion
                                                                      error:nil];
        XCTAssert([savedEvents count] == 0, @"No events should have been saved.");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testDispatchNewEventSuccess: %@", error);
        }
    }];
}

- (void)testDispatchNewEventFailure
{
    [self stubFailureResponse];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for testDispatchNewEventFailure failure."];
    [self.eventDispatcher dispatchNewEvent:self.parameters eventType:OPTLYDataStoreEventTypeConversion callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSArray *savedEvents = [self.eventDispatcher.dataStore getAllEvents:OPTLYDataStoreEventTypeConversion
                                                                      error:nil];
        XCTAssert([savedEvents count] == 1, @"An event should have been saved.");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testDispatchNewEventFailure: %@", error);
        }
    }];
}

// make sure that if flush events is called more than the max allowed time
// [OPTLYEventDispatcherMaxFlushEventAttempts], then flush event attempts will stop
- (void)testFlushEventAttempts {
    
    [self stubFailureResponse];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for testFlushEventAttempts failure."];
    
    OPTLYEventDispatcherDefault *eventDispatcher = [OPTLYEventDispatcherDefault initWithBuilderBlock:^(OPTLYEventDispatcherBuilder *builder) {
        builder.eventDispatcherDispatchInterval = 1;
        builder.logger = [OPTLYLoggerDefault new];
    }];
    

    [eventDispatcher.dataStore saveEvent:self.parameters
                               eventType:OPTLYDataStoreEventTypeConversion
                                   error:nil];
    
    __block NSInteger attempts = 0;
    typedef void (^FlushEventsBlock)();
    __block __weak FlushEventsBlock weakFlushEvents = nil;
    __weak typeof(self) weakSelf = self;
    __block void (^flushEvents)() = ^(){
        FlushEventsBlock strongFlushEvents = weakFlushEvents;
        attempts++;
        [eventDispatcher flushEvents:^{
            strongFlushEvents();
        }];
        if (attempts == OPTLYEventDispatcherMaxFlushEventAttempts + 1) {
            [weakSelf checkNetworkTimerIsDisabled:weakSelf.eventDispatcher];
            XCTAssert(eventDispatcher.flushEventAttempts == OPTLYEventDispatcherMaxFlushEventAttempts, @"Flush event attempts should have reached max value %lu.", eventDispatcher.flushEventAttempts);
            [expectation fulfill];
            return;
        }
    };
    weakFlushEvents = flushEvents;
    flushEvents();
    
    [self waitForExpectationsWithTimeout:self.eventDispatcher.flushEventAttempts+5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testFlushEventAttempts: %@", error);
        }
    }];
}

#pragma mark - Helper Methods
- (void)checkNetworkTimerIsEnabled:(OPTLYEventDispatcherDefault *)eventDispatcher timeInterval:(NSInteger)timeInterval
{
    // check that the timer is set correctly
    XCTAssertNotNil(eventDispatcher.timer, @"Timer should not be nil.");
    XCTAssertTrue(eventDispatcher.timer.valid, @"Timer is not valid.");
    XCTAssert(eventDispatcher.timer.timeInterval == timeInterval, @"Invalid time interval set - %f.", eventDispatcher.timer.timeInterval);
}

- (void)checkNetworkTimerIsDisabled:(OPTLYEventDispatcherDefault *)eventDispatcher
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
