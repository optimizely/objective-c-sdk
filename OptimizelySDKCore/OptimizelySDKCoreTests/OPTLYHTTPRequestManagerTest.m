/*************************************************************************** 
* Copyright 2016 Optimizely                                                *
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
#import "OPTLYHTTPRequestManager.h"
#import "OPTLYTestHelper.h"

static NSString * const kTestURLString = @"testURL";

@interface OPTLYHTTPRequestManagerTest : XCTestCase
@property (nonatomic, strong ) NSURL *testURL;
@property (nonatomic, strong) NSDictionary *parameters;
@end

@implementation OPTLYHTTPRequestManagerTest

- (void)setUp {
    [super setUp];
    self.testURL = [NSURL URLWithString:kTestURLString];
    self.parameters = @{@"testKey1" : @"testValue2", @"testKey2" : @"testValue2"};
}

- (void)tearDown {
    self.testURL = nil;
    self.parameters = nil;
    [super tearDown];
}

// Test the initialization method to ensure that the url property is getting set properly
- (void)testInitWithURL
{
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:self.testURL];
    NSAssert([requestManager.url isEqual:self.testURL], @"Network service initialization produces invalid url.");
}

- (void)testGETSuccess
{
    [OPTLYTestHelper stubSuccessResponse];
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:self.testURL];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for GET success."];
    [requestManager GET:^(NSData *data, NSURLResponse *response, NSError *error) {
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
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:self.testURL];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for GET failure."];
    [requestManager GET:^(NSData *data, NSURLResponse *response, NSError *error) {
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
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:self.testURL];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for GETWithParameters success."];
    [requestManager GETWithParameters:self.parameters completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:self.testURL];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for GETWithParameters failure."];
    [requestManager GETWithParameters:self.parameters completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:self.testURL];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for POSTWithParameters success."];
    [requestManager POSTWithParameters:self.parameters completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:self.testURL];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for POSTWithParameters failure."];
    [requestManager POSTWithParameters:self.parameters completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [expectation fulfill];
        NSAssert(error != nil, @"Network service POSTWithParameters does not return error as expected.");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for POSTWithParameters: %@", error);
        }
    }];
}
@end
