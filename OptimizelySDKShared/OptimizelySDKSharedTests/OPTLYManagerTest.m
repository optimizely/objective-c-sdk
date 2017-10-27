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

#import <OCMock/OCMock.h>
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
#import <XCTest/XCTest.h>

// static datafile name
static NSString *const kDefaultDatafileFileName = @"optimizely_6372300739";
static NSString *const kProjectId = @"6372300739";
static NSString *const kAccountId = @"6365361536";
static NSString *const kRevision = @"58";
static NSString *const kAlternateProjectId = @"7519590183";
static NSString *const kAlternateDatafilename = @"optimizely_7519590183";
static NSString * const kClientVersion = @"objective-c-sdk";
#if TARGET_OS_IOS
static NSString * const kClientEngine = @"ios-sdk";
#elif TARGET_OS_TV
static NSString * const kClientEngine = @"tvos-sdk";
#endif

@interface OPTLYManagerBase()
- (NSData *)loadBundleDatafile:(NSString *)projectId error:(NSError **)error;
@end

@interface OPTLYManagerTest : XCTestCase
@property (nonatomic, strong) NSData *defaultDatafile;
@property (nonatomic, strong) NSData *alternateDatafile;
@property (nonatomic, strong) OPTLYManagerBase *manager;
@end

@implementation OPTLYManagerTest

- (void)setUp {
    [super setUp];
    self.defaultDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDefaultDatafileFileName];
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
    [self stubResponse:200 data:self.alternateDatafile];
    
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

#pragma mark - Simplified Asynchronous Initialization (initAsync) Tests

// If the datafile download succeeds, the client should
//  be initialized with the downloaded datafile
- (void)testInitAsyncWithCachedDatafile
{
    [self stubResponse:200 data:self.alternateDatafile];
    
    // initialize manager
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kAlternateProjectId;
    }];
    
    // save the datafile (default)
    [manager.datafileManager saveDatafile:self.defaultDatafile];
    
    // setup async expectation
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testInitAsyncWithCachedDatafile"];
    // initialize client with alternate datafile
    __block OPTLYClient *optimizelyClient;
    __weak typeof(self) weakSelf = self;
    [manager initializeAsync:kAlternateProjectId
                    callback:^(NSError * _Nullable error, OPTLYClient * _Nullable client) {
                        [weakSelf isClientValid:client datafile:weakSelf.alternateDatafile];
                        // make sure the client is initialized with the alternate datafile
                        [self checkConfigIsUsingAlternativeDatafile:client.optimizely.config];
                        [expectation fulfill];
                    }];
    
    // wait for async start to finish
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

// If the datafile download fails and a datafile is cached,
//  the client should be initialized with the cached datafile
- (void)testInitAsyncDownloadErrorCachedDatafile
{
    [OPTLYTestHelper stubFailureResponse];
    
    // initialize manager
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kAlternateProjectId;
    }];

    // save the datafile (default)
    [manager.datafileManager saveDatafile:self.defaultDatafile];
    
    // setup async expectation
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testInitAsyncDownloadErrorCachedDatafile"];
    // initialize client with alternate datafile
    __weak typeof(self) weakSelf = self;
    [manager initializeAsync:kAlternateProjectId
                    callback:^(NSError * _Nullable error, OPTLYClient * _Nullable client) {

                        [weakSelf isClientValid:client datafile:weakSelf.defaultDatafile];
                        // make sure the client is initialized with the saved datafile (default)
                        [self checkConfigIsUsingDefaultDatafile:client.optimizely.config];
                        [expectation fulfill];
                    }];
    
    // wait for async start to finish
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

// If the datafile download gets a 304 response and a datafile is cached,
//  the client should be initialized with the cached datafile
- (void)testInitAsyncWithCachedDatafile304
{
    [self stubResponse:304 data:nil];
    
    // initialize manager
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kAlternateProjectId;
    }];
    // save the datafile (default)
    [manager.datafileManager saveDatafile:self.defaultDatafile];
    
    // setup async expectation
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testInitAsyncWithCachedDatafile304"];
    // initialize client with alternate datafile
    __weak typeof(self) weakSelf = self;
    [manager initializeAsync:kAlternateProjectId
                    callback:^(NSError * _Nullable error, OPTLYClient * _Nullable client) {
                        [weakSelf isClientValid:client datafile:weakSelf.defaultDatafile];
                        // make sure the client is initialized with the saved datafile (default)
                        [self checkConfigIsUsingDefaultDatafile:client.optimizely.config];
                        [expectation fulfill];
                    }];
    
    // wait for async start to finish
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

// If the datafile download fails and a datafile is not cached,
//  the client should be initialized with the bundled datafile
- (void)testInitAsyncDownloadErrorNoCachedDatafile
{
    [OPTLYTestHelper stubFailureResponse];
    
    // need to mock the manager bundled datafile load to read from the test bundle (default datafile)
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    id partialMockManager = OCMPartialMock(manager);
     OCMStub([partialMockManager loadBundleDatafile:[OCMArg any]
                                              error:((NSError __autoreleasing **)[OCMArg anyPointer])]).andReturn(self.defaultDatafile);
    
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testInitAsyncDownloadErrorNoCachedDatafile"];
    __weak typeof(self) weakSelf = self;
    [partialMockManager initializeAsync:kAlternateProjectId
                               callback:^(NSError * _Nullable error, OPTLYClient * _Nullable client) {
                                   [weakSelf isClientValid:client datafile:weakSelf.defaultDatafile];
                                   // make sure the client is initialized with the bundled datafile (default)
                                   [weakSelf checkConfigIsUsingDefaultDatafile:client.optimizely.config];
                                   [expectation fulfill];
                               }];
    
    // wait for async start to finish
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

// If the datafile download fails and a datafile is cached,
//  but there is an error loading the datafile,
//  the client should be initialized with the bundled datafile.
- (void)testInitAsyncDownloadErrorCachedDatafileBadLoad
{
    [OPTLYTestHelper stubFailureResponse];
    
    OPTLYDatafileManagerBasic *datafileManager = [OPTLYDatafileManagerBasic new];
    // save the datafile (alternate)
    [datafileManager saveDatafile:self.alternateDatafile];
    
    // mock a failed cached datafile load
    id partialDatafileManagerMock = OCMPartialMock(datafileManager);
    NSError *error = nil;
    OCMStub([partialDatafileManagerMock getSavedDatafile:((NSError __autoreleasing **)[OCMArg anyPointer])]).andReturn(nil);
    
    // need to mock the manager bundled datafile load to read from the test bundle (default datafile)
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
        builder.datafileManager = datafileManager;
    }];
    
    id partialMockManager = OCMPartialMock(manager);
    OCMStub([partialMockManager loadBundleDatafile:kAlternateProjectId
                                             error:((NSError __autoreleasing **)[OCMArg anyPointer])]).andReturn(self.defaultDatafile);
    
    // setup async expectation
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testInitAsyncDownloadErrorCachedDatafileBadLoad"];
    __weak typeof(self) weakSelf = self;
    [partialMockManager initializeAsync:kAlternateProjectId
                               callback:^(NSError * _Nullable error, OPTLYClient * _Nullable client) {
                                   OCMStub([partialMockManager loadBundleDatafile:[OCMArg isNotNil] error:nil]).andReturn(self.defaultDatafile);
                                   [weakSelf isClientValid:client datafile:weakSelf.defaultDatafile];
                                   // make sure the client is initialized with the bundled datafile (default)
                                   [weakSelf checkConfigIsUsingDefaultDatafile:client.optimizely.config];
                                   [expectation fulfill];
                               }];
    
    // wait for async start to finish
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

// If no datafile is cached or bundled and the datafile downloads fails,
//  the client should be nil
- (void)testInitAsyncDownloadErrorNoDatafile
{
    [OPTLYTestHelper stubFailureResponse];
    
    // need to mock the manager bundled datafile load to read from the test bundle (default datafile)
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
        
    }];
    id partialMockManager = OCMPartialMock(manager);
    OCMStub([partialMockManager loadBundleDatafile:[OCMArg isNotNil] error:nil]).andReturn(nil);
    
    // setup async expectation
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testInitAsyncDownloadErrorNoDatafile"];
    // initialize client with alternate datafile
    [manager initializeAsync:kAlternateProjectId
                    callback:^(NSError * _Nullable error, OPTLYClient * _Nullable client) {
                        // retain a reference to the client
                        XCTAssertNil(client.optimizely, @"Client config should be nil when no datafile is saved or bundled.");
                        [expectation fulfill];
                    }];
    
    // wait for async start to finish
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

#pragma mark - Simplified Synchronous Initialization (initSync) Tests

// If a datafile is cached, the client should be
//  initialized with the cached datafile
- (void)testInitSyncWithCachedDatafile
{
    // initialize manager
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kAlternateProjectId;
    }];
    
    // save the datafile
    [manager.datafileManager saveDatafile:self.alternateDatafile];
    OPTLYClient *client = [manager initializeSync:kAlternateProjectId];
    
    [self isClientValid:client
               datafile:self.alternateDatafile];
    [self checkConfigIsUsingAlternativeDatafile:client.optimizely.config];
}

// If no datafile is cached, the client should be initialized with
//  the bundled datafile.
- (void)testInitSyncNoCachedDatafile
{
    // need to mock the manager bundled datafile load to read from the test bundle
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    id partialMockManager = OCMPartialMock(manager);
    OCMStub([partialMockManager loadBundleDatafile:kProjectId error:nil]).andReturn(self.alternateDatafile);
    
    OPTLYClient *client = [partialMockManager initializeSync:kProjectId];
    
    [self isClientValid:client
               datafile:self.alternateDatafile];
    [self checkConfigIsUsingAlternativeDatafile:client.optimizely.config];
}

// If a datafile is cached, but there is an error loading the datafile,
//  the client should be initialized with the bundled datafile.
- (void)testInitSyncCachedDatafileBadLoad
{
    // need to mock the manager bundled datafile load to read from the test bundle (default datafile)
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
        
    }];
    // save the datafile (alternate datafile)
    [manager.datafileManager saveDatafile:self.alternateDatafile];
    id partialMockManager = OCMPartialMock(manager);
    OCMStub([partialMockManager loadBundleDatafile:[OCMArg isNotNil] error:nil]).andReturn(self.defaultDatafile);
    
    // mock a failed cached datafile load
    id partialDatafileManagerMock = OCMPartialMock(manager.datafileManager);
    OCMStub([partialDatafileManagerMock getSavedDatafile:nil]).andReturn(nil);
    
    OPTLYClient *client = [partialMockManager initializeSync:kProjectId];
    
    // client should be using the bundled datafile (default)
    [self isClientValid:client
               datafile:self.defaultDatafile];
    [self checkConfigIsUsingDefaultDatafile:client.optimizely.config];
}

// If no datafile is cached or bundled, the client should be nil
- (void)testInitSyncNoDatafile
{
    // need to mock the manager bundled datafile load to read from the test bundle (default datafile)
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
        
    }];
    id partialMockManager = OCMPartialMock(manager);
    OCMStub([partialMockManager loadBundleDatafile:[OCMArg isNotNil] error:nil]).andReturn(nil);
    
    OPTLYClient *client = [partialMockManager initializeSync:kProjectId];
    
    XCTAssertNil(client.optimizely, @"Client config should be nil when no datafile is saved or bundled.");
}

# pragma mark - Helper Methods
- (void)isClientValid:(OPTLYClient *)client
             datafile:(NSData *)datafile
{
    Optimizely *optly = [Optimizely init:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.clientEngine = kClientEngine;
        builder.clientVersion = kClientVersion;
    }];
    OPTLYProjectConfig *projectConfig = optly.config;
    
    XCTAssertNotNil(client, @"Client should not be nil.");
    // TODO (Alda): Need to write equality methods for the data models to properly make this assertion
    //XCTAssert([projectConfig isEqual:client.optimizely.config], @"Optimizely config is invalid.");
    XCTAssertNotNil(client.optimizely, @"Optimizely config should not be nil.");
    XCTAssertNotNil(client.logger, @"Logger should not be nil.");
}

- (void)checkConfigIsUsingDefaultDatafile:(OPTLYProjectConfig *)config {
    XCTAssertEqualObjects(config.revision, @"58");
    XCTAssertEqualObjects(config.projectId, @"6372300739");
    XCTAssertEqualObjects(config.accountId, @"6365361536");
}

- (void)checkConfigIsUsingAlternativeDatafile: (OPTLYProjectConfig *)config {
    XCTAssertEqualObjects(config.revision, @"6");
    XCTAssertEqualObjects(config.projectId, @"7519590183");
    XCTAssertEqualObjects(config.accountId, @"3244610124");
}

- (void)stubResponse:(int)statusCode data:(NSData *)data{
    NSURL *hostURL = [NSURL URLWithString:OPTLYNetworkServiceCDNServerURL];
    NSString *hostName = [hostURL host];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return [request.URL.host isEqualToString:hostName];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:data
                                          statusCode:statusCode
                                             headers:@{@"Content-Type":@"application/json"}];
    }];
}

@end
