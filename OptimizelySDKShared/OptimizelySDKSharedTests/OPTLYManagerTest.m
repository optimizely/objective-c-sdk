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

#import <OptimizelySDKCore/OptimizelySDKCore.h>
#import <OptimizelySDKCore/OPTLYNetworkService.h>
#import <OptimizelySDKCore/OPTLYProjectConfig.h>
#import "OPTLYClient.h"
#import "OPTLYDatafileManager.h"
#import "OPTLYManager.h"
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
    id<OPTLYUserProfile> userProfile = [[OPTLYUserProfileNoOp alloc] init];
    
    // initialize Manager
    OPTLYManager *manager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.datafile = self.defaultDatafile;
        builder.datafileManager = datafileManager;
        builder.errorHandler = errorHandler;
        builder.eventDispatcher = eventDispatcher;
        builder.logger = logger;
        builder.projectId = kProjectId;
        builder.userProfile = userProfile;
    }];
    XCTAssertEqual(manager.datafileManager, datafileManager);
    
    // get the client
    OPTLYClient *client = [manager initializeClient];
    XCTAssertEqual(client.logger, logger);
    
    // check optimizely core has been initialized correctly
    Optimizely *optimizely = client.optimizely;
    XCTAssertNotNil(optimizely);
    XCTAssertEqual(optimizely.errorHandler, errorHandler);
    XCTAssertEqual(optimizely.eventDispatcher, eventDispatcher);
    XCTAssertEqual(optimizely.logger, logger);
    XCTAssertEqual(optimizely.userProfile, userProfile);
}

- (void)testInitializeClientWithoutDatafileReturnsDummy {
    // initialize manager without datafile
    OPTLYManager *manager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    
    // make sure the manager is initialized correctly
    XCTAssertNotNil(manager);
    XCTAssertNotNil(manager.projectId);
    XCTAssertNil(manager.datafile);
    
    // try to initialize client
    OPTLYClient *client = [manager initializeClient];
    
    // make sure we get a dummy client back
    XCTAssertNotNil(client);
    XCTAssertNil(client.optimizely);
    XCTAssertNotNil(client.logger);
}

- (void)testInitializeClientWithDefaults {
    // initialize manager
    OPTLYManager *manager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.datafile = self.defaultDatafile;
        builder.projectId = kProjectId;
    }];
    
    // make sure manager is initialized correctly
    XCTAssertNotNil(manager);
    XCTAssertNotNil(manager.datafile);
    XCTAssertEqual(manager.datafile, self.defaultDatafile);
    
    // initialize client
    OPTLYClient *client = [manager initializeClient];
    
    // test client initialization
    XCTAssertNotNil(client);
    XCTAssertNotNil(client.optimizely);
    XCTAssertNotNil(client.logger);
    XCTAssertEqual(client, manager.getOptimizely);
    
    [self checkConfigIsUsingDefaultDatafile:client.optimizely.config];
}

- (void)testInitializeClientWithCustomDatafile {
    // initialize manager
    OPTLYManager *manager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.datafile = self.defaultDatafile;
        builder.projectId = kProjectId;
    }];
    
    // make sure manager is initialized correctly
    XCTAssertNotNil(manager);
    XCTAssertNotNil(manager.datafile);
    XCTAssertEqual(manager.datafile, self.defaultDatafile);
    
    // initialize client
    OPTLYClient *client = [manager initializeClientWithDatafile:self.alternateDatafile];
    
    // test client initialization
    XCTAssertNotNil(client);
    XCTAssertNotNil(client.optimizely);
    XCTAssertNotNil(client.logger);
    XCTAssertEqual(client, manager.getOptimizely);
    
    [self checkConfigIsUsingAlternativeDatafile:client.optimizely.config];
}

- (void)testInitializeClientAsync {
    // initialize manager
    OPTLYManager *manager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
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
    [manager initializeClientWithCallback:^(NSError * _Nullable error, OPTLYClient * _Nullable client) {
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
