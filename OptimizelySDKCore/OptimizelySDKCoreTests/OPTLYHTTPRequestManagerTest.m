/****************************************************************************
 * Copyright 2016-2017, Optimizely, Inc. and contributors                   *
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
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "OPTLYHTTPRequestManager.h"
#import "OPTLYTestHelper.h"

static NSString * const kTestURLString = @"testURL";
static NSString * const kLastModifiedDate = @"Mon, 28 Nov 2016 06:10:59 GMT";
static NSInteger const kRetryAttempts = 3;
static NSInteger const kBackoffRetryInterval = 1;

@interface OPTLYHTTPRequestManager(test)
@property (nonatomic, assign) NSInteger retryAttemptTest;
@property (nonatomic, strong) NSMutableArray *delaysTest;
@end

@interface OPTLYHTTPRequestManagerTest : XCTestCase
@property (nonatomic, strong) NSURL *testURL;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSMutableArray *expectedDelays;
@end

@implementation OPTLYHTTPRequestManagerTest

- (void)setUp {
    [super setUp];
    self.testURL = [NSURL URLWithString:kTestURLString];
    self.parameters = @{@"testKey1" : @"testValue2", @"testKey2" : @"testValue2"};
    
    self.expectedDelays = [NSMutableArray new];
    for (NSInteger i = 0; i < kRetryAttempts+1; ++i) {
        uint32_t exponentialMultiplier = pow(2.0, i);
        uint64_t delay_ns = kBackoffRetryInterval * exponentialMultiplier * NSEC_PER_MSEC;
        self.expectedDelays[i] = [NSNumber numberWithLongLong:delay_ns];
    }
    
}

- (void)tearDown {
    [OHHTTPStubs removeAllStubs];
    self.testURL = nil;
    self.parameters = nil;
    self.expectedDelays = nil;
    [super tearDown];
}

- (void)testGETSuccess
{
    [OPTLYTestHelper stubSuccessResponse];
    OPTLYHTTPRequestManager *requestManager = [OPTLYHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for GET success."];
    [requestManager GETWithURL:self.testURL completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        [expectation fulfill];
        NSAssert(data != nil, @"Network service GET does not return data as expected.");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGETSuccess: %@", error);
        }
    }];
}

- (void)testGETFailure
{
    [OPTLYTestHelper stubFailureResponse];
    OPTLYHTTPRequestManager *requestManager = [OPTLYHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for GET failure."];
    [requestManager GETWithURL:self.testURL completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        [expectation fulfill];
        NSAssert(error != nil, @"Network service GET does not return error as expected.");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGETFailure: %@", error);
        }
    }];
}

- (void)testGETWithParametersSuccess
{
    [OPTLYTestHelper stubSuccessResponse];
    OPTLYHTTPRequestManager *requestManager = [OPTLYHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for GETWithParameters success."];
    [requestManager GETWithParameters:self.parameters url:self.testURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [expectation fulfill];
        NSAssert(data != nil, @"Network service GETWithParameters does not return data as expected.");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for GETWithParameters: %@", error);
        }
    }];
}

- (void)testGETWithParametersFailure
{
    [OPTLYTestHelper stubFailureResponse];
    OPTLYHTTPRequestManager *requestManager = [OPTLYHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for GETWithParameters failure."];
    [requestManager GETWithParameters:self.parameters url:self.testURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [expectation fulfill];
        NSAssert(error != nil, @"Network service GETWithParameters does not return error as expected.");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for GETWithParameters: %@", error);
        }
    }];
}

- (void)testPOSTWithParametersSuccess
{
    [OPTLYTestHelper stubSuccessResponse];
    OPTLYHTTPRequestManager *requestManager = [OPTLYHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for POSTWithParameters success."];
    [requestManager POSTWithParameters:self.parameters url:self.testURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [expectation fulfill];
        NSAssert(data != nil, @"Network service POSTWithParameters does not return data as expected.");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for POSTWithParameters: %@", error);
        }
    }];
}

- (void)testPOSTWithParametersFailure
{
    [OPTLYTestHelper stubFailureResponse];
    OPTLYHTTPRequestManager *requestManager = [OPTLYHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for POSTWithParameters failure."];
    [requestManager POSTWithParameters:self.parameters url:self.testURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [expectation fulfill];
        NSAssert(error != nil, @"Network service POSTWithParameters does not return error as expected.");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for POSTWithParameters: %@", error);
        }
    }];
}

// Tests the following for the POST with backoff retry:
// 1. correct number of recursive calls
// 2. the right delays are set at each retry attempt
- (void)testPOSTWithParametersBackoffRetryFailure
{
    [OPTLYTestHelper stubFailureResponse];
    OPTLYHTTPRequestManager *requestManager = [OPTLYHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for POSTWithParameters failure."];
    [requestManager POSTWithParameters:self.parameters
                                   url:self.testURL
                  backoffRetryInterval:kBackoffRetryInterval
                               retries:kRetryAttempts
                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self checkMaxRetries:requestManager];
        [expectation fulfill];
        NSAssert(error != nil, @"Network service POSTWithParameters does not return error as expected.");
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for POSTWithParameters: %@", error);
        }
    }];
    
    
}

- (void)testPOSTWithParametersBackoffRetrySuccess
{
    [OPTLYTestHelper stubSuccessResponse];
    OPTLYHTTPRequestManager *requestManager = [OPTLYHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for POSTWithParameters failure."];
    [requestManager POSTWithParameters:self.parameters
                                   url:self.testURL
                  backoffRetryInterval:kBackoffRetryInterval
                               retries:kRetryAttempts
                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self checkNoRetries:requestManager];
        [expectation fulfill];
        NSAssert(error == nil, @"Network service POSTWithParameters does not return error as expected.");
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for POSTWithParameters: %@", error);
        }
    }];
}
- (void)testGETRetryFailure
{
    [OPTLYTestHelper stubFailureResponse];
    OPTLYHTTPRequestManager *requestManager = [OPTLYHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for GETWithBackoffRetry failure."];
    [requestManager GETWithBackoffRetryInterval:kBackoffRetryInterval
                                            url:self.testURL
                                        retries:kRetryAttempts
                              completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self checkMaxRetries:requestManager];
        [expectation fulfill];
        NSAssert(error != nil, @"Network service GETWithBackoffRetry does not return error as expected.");
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for GETWithBackoffRetry: %@", error);
        }
    }];
}

- (void)testGETBackoffRetrySuccess
{
    [OPTLYTestHelper stubSuccessResponse];
    OPTLYHTTPRequestManager *requestManager = [OPTLYHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for GETWithBackoffRetry failure."];
    [requestManager GETWithBackoffRetryInterval:kBackoffRetryInterval
                                            url:self.testURL
                                        retries:kRetryAttempts
                              completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self checkNoRetries:requestManager];
        [expectation fulfill];
        NSAssert(error == nil, @"Network service GETWithBackoffRetry returns an unexpected error.");
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for GETWithBackoffRetry: %@", error);
        }
    }];
}

- (void)testGETWithParametersBackoffRetryFailure
{
    [OPTLYTestHelper stubFailureResponse];
    OPTLYHTTPRequestManager *requestManager = [OPTLYHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for GETWithParameters failure."];
    [requestManager GETWithParameters:self.parameters
                                  url:self.testURL
                 backoffRetryInterval:kBackoffRetryInterval
                              retries:kRetryAttempts
                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self checkMaxRetries:requestManager];
        [expectation fulfill];
        NSAssert(error != nil, @"Network service GETWithParameters does not return error as expected.");
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for GETWithParameters: %@", error);
        }
    }];
}

- (void)testGETWithParametersBackoffRetrySuccess
{
    [OPTLYTestHelper stubSuccessResponse];
    OPTLYHTTPRequestManager *requestManager = [OPTLYHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for GETWithParameters failure."];
    [requestManager GETWithParameters:self.parameters
                                  url:self.testURL
                 backoffRetryInterval:kBackoffRetryInterval
                              retries:kRetryAttempts
                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self checkNoRetries:requestManager];
        [expectation fulfill];
        NSAssert(error == nil, @"Network service GETWithParameters returns an unexpected error.");
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for GETWithParameters: %@", error);
        }
    }];
}

- (void)testGETIfModifiedBackoffRetryFailure
{
    [OPTLYTestHelper stubFailureResponse];
    OPTLYHTTPRequestManager *requestManager = [OPTLYHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for GETIfModifiedSince failure."];
    [requestManager GETIfModifiedSince:kLastModifiedDate
                                   url:self.testURL
                  backoffRetryInterval:kBackoffRetryInterval
                               retries:kRetryAttempts
                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self checkMaxRetries:requestManager];
        [expectation fulfill];
        NSAssert(error != nil, @"Network service GETIfModifiedSince does not return error as expected.");
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for GETIfModifiedSince: %@", error);
        }
    }];
}

- (void)testGETIfModifiedBackoffRetrySuccess
{
    [OPTLYTestHelper stubSuccessResponse];
    OPTLYHTTPRequestManager *requestManager = [OPTLYHTTPRequestManager new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for GETIfModifiedSince failure."];
    [requestManager GETIfModifiedSince:kLastModifiedDate
                                   url:self.testURL
                  backoffRetryInterval:kBackoffRetryInterval
                               retries:kRetryAttempts
                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self checkNoRetries:requestManager];
        [expectation fulfill];
        NSAssert(error == nil, @"Network service GETIfModifiedSince returns an unexpected error.");
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for GETIfModifiedSince: %@", error);
        }
    }];
}

#pragma mark - Helper Methods

- (void)checkNoRetries:(OPTLYHTTPRequestManager *)requestManager {
    XCTAssertTrue(requestManager.retryAttemptTest == 0, @"Invalid number of retries.");
    XCTAssertTrue([requestManager.delaysTest isEqualToArray:@[]], @"Invalid delays set for backoff retry.");
}

- (void)checkMaxRetries:(OPTLYHTTPRequestManager *)requestManager {
    XCTAssertTrue(requestManager.retryAttemptTest == kRetryAttempts+1, @"Invalid number of retries.");
    XCTAssertTrue([requestManager.delaysTest isEqualToArray:self.expectedDelays], @"Invalid delays set for backoff retry.");
}
@end
