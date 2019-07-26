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
#import <OCMock/OCMock.h>
#import "OPTLYHTTPRequestManager.h"
#import "OPTLYTestHelper.h"

static NSString * const kTestURLString = @"testURL";

@interface TLSPinningTests : XCTestCase
@property (nonatomic, strong) NSURL *testURL;
@end

@implementation TLSPinningTests

- (void)setUp {
    [super setUp];
    self.testURL = [NSURL URLWithString:kTestURLString];
}

- (void)tearDown {
    [OHHTTPStubs removeAllStubs];
    self.testURL = nil;
    [super tearDown];
}

#pragma mark - TLS Certficates Pinning Tests

// test with correct root certficates
// - they should be connected successfully regardless of pinning enabled or disabled

- (void)testGETSuccessWhenPinningDisabled {
    NSArray *testUrls = @[@"https://cdn.optimizely.com",
                          @"https://api.optimizely.com",
                          @"https://logx.optimizely.com"];
    
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithTLSPinning:NO];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"a"];
    __block int completeCount = 0;
    for(NSString *url in testUrls) {
        [requestManager GETWithURL:[NSURL URLWithString:url] completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            completeCount++;
            if (completeCount == testUrls.count) {
                [expectation fulfill];
            }
            
            NSAssert(data != nil, @"Network service GET does not return data as expected.");
        }];
    }
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGETSuccess: %@", error);
        }
    }];
}

- (void)testGETSuccessWhenPinningEnabled {
    NSArray *testUrls = @[@"https://cdn.optimizely.com",
                          @"https://api.optimizely.com",
                          @"https://logx.optimizely.com"];
    
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithTLSPinning:YES];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"a"];
    __block int completeCount = 0;
    for(NSString *url in testUrls) {
        [requestManager GETWithURL:[NSURL URLWithString:url] completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            completeCount++;
            if (completeCount == testUrls.count) {
                [expectation fulfill];
            }
            
            NSAssert(data != nil, @"Network service GET does not return data as expected.");
        }];
    }
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGETSuccess: %@", error);
        }
    }];
}

// test with wrong root certficates
// - try to connect other urls using different root certificates
// - they're all valid certs but root cert will be rejected by comparing with pinned ones
// - when pinning is disabled (default), all connections to any ursl must be successful

- (void)testGETWithWrongCertificateWhenPinningDisabled {
    
    NSArray *testUrls = @[@"https://google.com",
                          @"https://amazon.com"];
    
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] init];   // default: no pinning
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"a"];
    __block int completeCount = 0;
    for(NSString *url in testUrls) {
        [requestManager GETWithURL:[NSURL URLWithString:url] completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            completeCount++;
            if (completeCount == testUrls.count) {
                [expectation fulfill];
            }
            
            NSAssert(data != nil, @"Network connection should be allowed since pinning is disabled.");
        }];
    }
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGETWithFakeCertificateWhenPinningDisabled: %@", error);
        }
    }];
    
}

- (void)testGETWithWrongCertificateWhenPinningEnabled {
    NSArray *testUrls = @[@"https://google.com",
                          @"https://amazon.com"];
    
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithTLSPinning:YES];   // default: no pinning
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"a"];
    __block int completeCount = 0;
    for(NSString *url in testUrls) {
        [requestManager GETWithURL:[NSURL URLWithString:url] completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            completeCount++;
            if (completeCount == testUrls.count) {
                [expectation fulfill];
            }
            
            NSAssert(error != nil, @"Network connection should be rejected by pinned certificate validation.");
        }];
    }
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGETWithWrongCertificateWhenPinningEnabled: %@", error);
        }
    }];
}

@end
