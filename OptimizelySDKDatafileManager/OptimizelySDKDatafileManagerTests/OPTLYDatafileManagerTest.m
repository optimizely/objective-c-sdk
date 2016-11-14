//
//  OPTLYDatafileManagerTest.m
//  OptimizelySDKDatafileManager
//
//  Created by Josh Wang on 11/14/16.
//  Copyright © 2016 Optimizely. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

#import "OPTLYDatafileManager.h"

@interface OPTLYDatafileManagerTest : XCTestCase

@end

static NSString *kProjectId = @"projectId";

@implementation OPTLYDatafileManagerTest

- (void)testRequestDatafileHandlesCompletionEvenWithBadRequest {
    // setup datafile manager
    OPTLYDatafileManager *datafileManager = [OPTLYDatafileManager initWithBuilderBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    XCTAssertNotNil(datafileManager);
    
    // stub network call
    id<OHHTTPStubsDescriptor> stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"cdn.optimizely.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our "wsresponse.json" stub file (which is in same bundle as self)
        return [OHHTTPStubsResponse responseWithData:[[NSData alloc] init]
                                          statusCode:400
                                             headers:@{@"Content-Type":@"application/json"}];
    }];
    
    // setup async expectation
    __block Boolean completionWasCalled = false;
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testInitializeClientAsync"];
    
    // request datafile
    [datafileManager requestDatafile:datafileManager.projectId
                   completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                       completionWasCalled = true;
                       XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 400);
                       [expectation fulfill];
    }];
    
    // wait for async start to finish
    [self waitForExpectationsWithTimeout:2 handler:nil];
    XCTAssertTrue(completionWasCalled);
    
    // clean stubs
    [OHHTTPStubs removeStub:stub];
}

@end
