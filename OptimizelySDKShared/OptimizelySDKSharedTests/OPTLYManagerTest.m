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
#import <OptimizelySDKCore/OptimizelySDKCore.h>
#import <OptimizelySDKCore/OPTLYNetworkService.h>
#import <OptimizelySDKCore/OPTLYProjectConfig.h>
#import <OptimizelySDKShared/OPTLYManagerBase.h>
#import "OPTLYClient.h"
#import "OPTLYDatafileManagerBasic.h"
#import "OPTLYManagerBasic.h"
#import "OPTLYManagerBuilder.h"
#import "OPTLYTestHelper.h"


// static datafile name
static NSString *const defaultDatafileFileName = @"datafile_6372300739";
static NSString *const kProjectId = @"6372300739";
static NSString *const kAlternateDatafilename = @"validator_whitelisting_test_datafile";

@interface OPTLYManagerTest : XCTestCase
@property (nonatomic, strong) NSData *defaultDatafile;
@property (nonatomic, strong) NSData *alternateDatafile;
@end

@implementation OPTLYManagerTest

- (void)setUp {
    [super setUp];
    self.defaultDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:defaultDatafileFileName];
    self.alternateDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kAlternateDatafilename];
}

- (void)tearDown {
    [super tearDown];
    [OHHTTPStubs removeAllStubs];
    self.defaultDatafile = nil;
    self.alternateDatafile = nil;
}

- (void)testInitializationSettingsGetPropogatedToClientAndCore {
    // initialize manager settings
    id<OPTLYDatafileManager> datafileManager = [[OPTLYDatafileManagerNoOp alloc] init];
    id<OPTLYErrorHandler> errorHandler = [[OPTLYErrorHandlerNoOp alloc] init];
    id<OPTLYEventDispatcher> eventDispatcher = [[OPTLYEventDispatcherBasic alloc] init];
    id<OPTLYLogger> logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelOff];
    id<OPTLYUserProfileService> userProfileService = [[OPTLYUserProfileServiceNoOp alloc] init];
    
    // initialize Manager
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.datafile = self.defaultDatafile;
        builder.datafileManager = datafileManager;
        builder.errorHandler = errorHandler;
        builder.eventDispatcher = eventDispatcher;
        builder.logger = logger;
        builder.projectId = kProjectId;
        builder.userProfileService = userProfileService;
    }];
    XCTAssertEqual(manager.datafileManager, datafileManager);
    
    // get the client
    OPTLYClient *client = [manager initialize];
    XCTAssertEqual(client.logger, logger);
    
    // check optimizely core has been initialized correctly
    Optimizely *optimizely = client.optimizely;
    XCTAssertNotNil(optimizely);
    XCTAssertEqual(optimizely.errorHandler, errorHandler);
    XCTAssertEqual(optimizely.eventDispatcher, eventDispatcher);
    XCTAssertEqual(optimizely.logger, logger);
    XCTAssertEqual(optimizely.userProfileService, userProfileService);
    XCTAssertNotNil(optimizely.config);
    XCTAssertNotNil(optimizely.config.clientEngine);
    XCTAssertNotNil(optimizely.config.clientVersion);
    {
        NSDictionary *dict = client.defaultAttributes;
        XCTAssert([dict[OptimizelySDKVersionKey]
                   isEqualToString:optimizely.config.clientVersion]);
    }
}

- (void)testInitializeClientWithoutDatafileReturnsDummy {
    // initialize manager without datafile
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    
    // make sure the manager is initialized correctly
    XCTAssertNotNil(manager);
    XCTAssertNotNil(manager.projectId);
    XCTAssertNil(manager.datafile);
    
    // try to initialize client
    OPTLYClient *client = [manager initialize];
    
    // make sure we get a dummy client back
    XCTAssertNotNil(client);
    XCTAssertNil(client.optimizely);
    XCTAssertNotNil(client.logger);
}

- (void)testInitializeClientWithDefaults {
    // initialize manager
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.datafile = self.defaultDatafile;
        builder.projectId = kProjectId;
    }];
    
    // make sure manager is initialized correctly
    XCTAssertNotNil(manager);
    XCTAssertNotNil(manager.datafile);
    XCTAssertEqual(manager.datafile, self.defaultDatafile);
    
    // initialize client
    OPTLYClient *client = [manager initialize];
    
    // test client initialization
    XCTAssertNotNil(client);
    XCTAssertNotNil(client.optimizely);
    XCTAssertNotNil(client.logger);
    XCTAssertEqual(client, manager.getOptimizely);
    
    [self checkConfigIsUsingDefaultDatafile:client.optimizely.config];
}

- (void)testInitializeClientUsesSavedDatafile {
    // initialize manager
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    
    // save the datafile
    [manager.datafileManager saveDatafile:self.defaultDatafile];
    
    // initialize client
    OPTLYClient *client = [manager initialize];
    
    // make sure manager is initialized correctly
    // the manager datafile is set only after initialize is called
    XCTAssertEqual(manager.datafile, self.defaultDatafile);
    
    // test client initialization
    XCTAssertNotNil(client.optimizely);
    XCTAssertNotNil(client.logger);
    XCTAssertEqual(client, manager.getOptimizely);
}

- (void)testInitializeClientWithCustomDatafile {
    // initialize manager
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.datafile = self.defaultDatafile;
        builder.projectId = kProjectId;
    }];
    
    // make sure manager is initialized correctly
    XCTAssertNotNil(manager);
    XCTAssertNotNil(manager.datafile);
    XCTAssertEqual(manager.datafile, self.defaultDatafile);
    
    // initialize client
    OPTLYClient *client = [manager initializeWithDatafile:self.alternateDatafile];
    
    // test client initialization
    XCTAssertNotNil(client);
    XCTAssertNotNil(client.optimizely);
    XCTAssertNotNil(client.logger);
    XCTAssertEqual(client, manager.getOptimizely);
    
    [self checkConfigIsUsingAlternativeDatafile:client.optimizely.config];
}

- (void)checkClientDefaultAttributes: (OPTLYClient *)client {
    XCTAssertNotNil(client);
    XCTAssertNotNil(client.defaultAttributes);
    XCTAssert([client.defaultAttributes isKindOfClass:[NSDictionary class]]);
    NSArray* expectedKeys = @[OptimizelyAppVersionKey,
                              OptimizelyDeviceModelKey,
                              OptimizelyOSVersionKey,
                              OptimizelySDKVersionKey];
    NSDictionary* dict=(NSDictionary*)client.defaultAttributes;
    XCTAssert(dict.count==expectedKeys.count);
    [client.defaultAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        XCTAssert([key isKindOfClass:[NSString class]]);
        XCTAssert([expectedKeys containsObject:key]);
        XCTAssert([value isKindOfClass:[NSString class]]);
        NSLog(@"key == \"%@\", value == \"%@\"",key,value);
    }];
    // For good measure
    XCTAssert([dict[OptimizelyDeviceModelKey]
               isEqualToString:[[UIDevice currentDevice] model]]);
    XCTAssert([dict[OptimizelyOSVersionKey]
               isEqualToString:[[UIDevice currentDevice] systemVersion]]);
}

- (void)testInitializeClientAsync {
    // initialize manager
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.datafile = self.defaultDatafile;
        builder.projectId = kProjectId;
        builder.datafileManager = [OPTLYDatafileManagerBasic new];
    }];
    
    // make sure manager is initialized correctly
    XCTAssertNotNil(manager);
    XCTAssertNotNil(manager.datafile);
    XCTAssertEqual(manager.datafile, self.defaultDatafile);
    
    // stub network call
    [self stubResponse:200];
    
    // setup async expectation
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testInitializeClientAsync"];
    // initialize client
    __block OPTLYClient *optimizelyClient;
    [manager initializeWithCallback:^(NSError * _Nullable error, OPTLYClient * _Nullable client) {
        // retain a reference to the client
        optimizelyClient = client;
        // check client in callback
        XCTAssertNotNil(client);
        XCTAssertNotNil(client.optimizely, @"Client needs to have an optimizely instance");
        XCTAssertNotNil(client.logger);
        [self checkConfigIsUsingAlternativeDatafile:client.optimizely.config];
        [expectation fulfill];
    }];
    
    // wait for async start to finish
    [self waitForExpectationsWithTimeout:2 handler:nil];
    XCTAssertEqual(optimizelyClient, manager.getOptimizely);
    [self checkClientDefaultAttributes:optimizelyClient];
}

- (void)checkConfigIsUsingDefaultDatafile: (OPTLYProjectConfig *)config {
    XCTAssertEqualObjects(config.revision, @"58");
    XCTAssertEqualObjects(config.projectId, @"6372300739");
    XCTAssertEqualObjects(config.accountId, @"6365361536");
}

- (void)checkConfigIsUsingAlternativeDatafile: (OPTLYProjectConfig *)config {
    XCTAssertEqualObjects(config.revision, @"6");
    XCTAssertEqualObjects(config.projectId, @"7519590183");
    XCTAssertEqualObjects(config.accountId, @"3244610124");
}

# pragma mark - Helper Methods
- (void)stubResponse:(int)statusCode {
    NSURL *hostURL = [NSURL URLWithString:OPTLYNetworkServiceCDNServerURL];
    NSString *hostName = [hostURL host];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return [request.URL.host isEqualToString:hostName];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:self.alternateDatafile
                                          statusCode:statusCode
                                             headers:@{@"Content-Type":@"application/json"}];
    }];
}

@end
