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
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "OPTLYTestHelper.h"
#import "OptimizelySDKTVOS.h"

// static datafile name
static NSString *const defaultDatafileFileName = @"datafile_6372300739";
static NSString *const kProjectId = @"6372300739";
static NSString *const kLastModifiedDate = @"Mon, 28 Nov 2016 06:10:59 GMT";
static NSString * const kClientEngine = @"tvos-sdk";
static NSData *kDefaultDatafile;
static NSDictionary *kCDNResponseHeaders = nil;

@interface OptimizelySDKTVOSTests : XCTestCase
@end

@implementation OptimizelySDKTVOSTests

+ (void)setUp {
    [super setUp];
    
    kCDNResponseHeaders = @{@"Content-Type":@"application/json",
                            @"Last-Modified":kLastModifiedDate};
    kDefaultDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:defaultDatafileFileName];
    
    // stub all requests
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        // every requests passes this test
        return true;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        // return bad request
        return [OHHTTPStubsResponse responseWithData:[[NSData alloc] init]
                                          statusCode:400
                                             headers:@{@"Content-Type":@"application/json"}];
    }];
}

+ (void)tearDown {
    [super tearDown];
    [OHHTTPStubs removeAllStubs];
    kDefaultDatafile = nil;
}

- (void)testTVOSSDKInitializedWithOverrides {
    OPTLYManager *manager = [OPTLYManager init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.datafile = kDefaultDatafile;
        builder.projectId = kProjectId;
    }];

    XCTAssertNotNil(manager);
    XCTAssertNotNil(manager.datafileManager);
    XCTAssertNotNil(manager.errorHandler);
    XCTAssertNotNil(manager.eventDispatcher);
    XCTAssertNotNil(manager.logger);
    XCTAssertNotNil(manager.userProfileService);
    XCTAssertEqual([manager.datafileManager class], [OPTLYDatafileManagerDefault class]);
    XCTAssertEqual([manager.eventDispatcher class], [OPTLYEventDispatcherDefault class]);
    XCTAssertEqual([manager.userProfileService class], [OPTLYUserProfileServiceDefault class]);
    XCTAssertEqual([manager.logger class], [OPTLYLoggerDefault class]);
    XCTAssertEqual([manager.errorHandler class], [OPTLYErrorHandlerNoOp class]);
    
    // test initializing the client works
    OPTLYClient *client = [manager initialize];
    XCTAssertNotNil(client);
    XCTAssertNotNil(client.optimizely);
    
    // test initializing optimizely core works fine
    Optimizely *optimizely = client.optimizely;
    XCTAssertNotNil(optimizely.config);
    XCTAssertNotNil(optimizely.errorHandler);
    XCTAssertNotNil(optimizely.eventDispatcher);
    XCTAssertNotNil(optimizely.logger);
    XCTAssertNotNil(optimizely.userProfileService);
    // test components from manager are passed to core properly
    XCTAssertEqual(optimizely.errorHandler, manager.errorHandler);
    XCTAssertEqual(optimizely.eventDispatcher, manager.eventDispatcher);
    XCTAssertEqual(optimizely.logger, manager.logger);
    XCTAssertEqual(optimizely.userProfileService, manager.userProfileService);
    
    // test client engine and version were set correctly
    XCTAssertEqualObjects([optimizely.config clientEngine], kClientEngine);
    XCTAssertEqualObjects([optimizely.config clientVersion], OPTIMIZELY_SDK_TVOS_VERSION);
}

@end
