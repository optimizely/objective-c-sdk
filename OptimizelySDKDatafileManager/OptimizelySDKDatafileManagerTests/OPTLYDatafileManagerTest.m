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
#import <OptimizelySDKCore/OPTLYProjectConfig.h>
#import <OptimizelySDKCore/OPTLYNetworkService.h>
#import <OptimizelySDKShared/OptimizelySDKShared.h>
#import "OPTLYDatafileManager.h"
#import "OPTLYTestHelper.h"

static NSString *const kProjectId = @"6372300739";
static NSString *const kDatamodelDatafileName = @"datafile_6372300739";
static NSTimeInterval kDatafileDownloadInteval = 5; // in seconds
static NSString *const kLastModifiedDate = @"Mon, 28 Nov 2016 06:10:59 GMT";
static NSData *kDatafileData;
static NSDictionary *kCDNResponseHeaders = nil;

@interface OPTLYDatafileManagerDefault(test)
@property (nonatomic, strong) NSTimer *datafileDownloadTimer;
- (void)saveDatafile:(NSData *)datafile;
- (nullable NSString *)getLastModifiedDate:(nonnull NSString *)projectId;
- (void)downloadDatafile:(NSString *)projectId completionHandler:(OPTLYHTTPRequestManagerResponse)completion;
@end

@interface OPTLYDatafileManagerTest : XCTestCase
@property (nonatomic, strong) OPTLYDatafileManagerDefault *datafileManager;
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@end

@implementation OPTLYDatafileManagerTest

+ (void)setUp {
    [super setUp];
    
    kCDNResponseHeaders = @{@"Content-Type":@"application/json",
                            @"Last-Modified":kLastModifiedDate};
    kDatafileData = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatamodelDatafileName];
    
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
    // make sure we have removed all stubs
    [OHHTTPStubs removeAllStubs];
}

- (void)setUp {
    [super setUp];
    self.dataStore = [OPTLYDataStore new];
    [self.dataStore removeAll:nil];
    [self stub400Response];
    self.datafileManager = [OPTLYDatafileManagerDefault init:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
}

- (void)tearDown {
    [super tearDown];
    [self.dataStore removeAll:nil];
    self.dataStore = nil;
    self.datafileManager = nil;
}

- (void)testRequestDatafileHandlesCompletionEvenWithBadRequest {

    XCTAssertNotNil(self.datafileManager);
    
    // stub network call
    id<OHHTTPStubsDescriptor> stub = [self stub400Response];
    
    // setup async expectation
    __block Boolean completionWasCalled = false;
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testInitializeClientAsync"];
    
    // request datafile
    [self.datafileManager downloadDatafile:self.datafileManager.projectId
                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        completionWasCalled = true;
                        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 400);
                        [expectation fulfill];
    }];
    
    // wait for async start to finish
    [self waitForExpectationsWithTimeout:2 handler:nil];
    XCTAssertTrue(completionWasCalled);

    // clean up stub
    [OHHTTPStubs removeStub:stub];
}

- (void)testSaveDatafileMethod {
    XCTAssertNotNil(self.datafileManager);
    XCTAssertFalse([self.dataStore fileExists:kProjectId type:OPTLYDataStoreDataTypeDatafile]);
    
    // save the datafile
    [self.datafileManager saveDatafile:kDatafileData];
    
    // test the datafile was saved correctly
    bool fileExists = [self.dataStore fileExists:kProjectId type:OPTLYDataStoreDataTypeDatafile];
    XCTAssertTrue(fileExists, @"save Datafile did not save the datafile to disk");
    NSError *error;
    NSData *savedData = [self.dataStore getFile:kProjectId
                                           type:OPTLYDataStoreDataTypeDatafile
                                          error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(savedData);
    XCTAssertNotEqual(kDatafileData, savedData, @"we should not be referencing the same object. Saved data should be a new NSData object created from disk.");
    XCTAssertEqualObjects(kDatafileData, savedData, @"retrieved saved data from disk should be equivalent to the datafile we wanted to save to disk");
}

// if 200 response, save the {projectID : lastModifiedDate} and datafile
- (void)testDatafileManagerDownloadDatafileSavesDatafile {
    
    XCTAssertNotNil(self.datafileManager);
    XCTAssertFalse([self.dataStore fileExists:kProjectId type:OPTLYDataStoreDataTypeDatafile], @"no datafile sould exist yet.");

    // setup stubbing and listener expectation
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testInitializeClientAsync"];
    id<OHHTTPStubsDescriptor> stub = [self stub200Response];
    
    // Call download datafile
    [self.datafileManager downloadDatafile:self.datafileManager.projectId
                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        XCTAssertTrue([self.dataStore fileExists:kProjectId type:OPTLYDataStoreDataTypeDatafile], @"we should have stored the datafile");
                        NSString *savedLastModifiedDate = [self.datafileManager getLastModifiedDate:kProjectId];
                        XCTAssert([savedLastModifiedDate isEqualToString:kLastModifiedDate], @"Modified date saved is invalid: %@.", savedLastModifiedDate);
                        [expectation fulfill];
    }];
    
    // make sure we were able to save the datafile
    [self waitForExpectationsWithTimeout:2 handler:nil];
    
    // clean up stub
    [OHHTTPStubs removeStub:stub];
}

// timer is enabled if the download interval is > 0
- (void)testNetworkTimerIsEnabled
{
    OPTLYDatafileManagerDefault *datafileManager = [OPTLYDatafileManagerDefault init:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
        builder.datafileFetchInterval = kDatafileDownloadInteval;
    }];
    
    // check that the timer is set correctly
    XCTAssertNotNil(datafileManager.datafileDownloadTimer, @"Timer should not be nil.");
    XCTAssertTrue(datafileManager.datafileDownloadTimer.valid, @"Timer is not valid.");
    XCTAssert(datafileManager.datafileDownloadTimer.timeInterval == kDatafileDownloadInteval, @"Invalid time interval set - %f.", datafileManager.datafileDownloadTimer.timeInterval);
}

// timer is disabled if the datafile download interval is <= 0
- (void)testNetworkTimerIsDisabled
{
    OPTLYDatafileManagerDefault *datafileManager = [OPTLYDatafileManagerDefault init:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
        builder.datafileFetchInterval = 0;
    }];
    
    // check that the timer is set correctly
    XCTAssertNil(datafileManager.datafileDownloadTimer, @"Timer should be nil.");
    XCTAssertFalse(datafileManager.datafileDownloadTimer.valid, @"Timer should not be valid.");
    
    datafileManager = [OPTLYDatafileManagerDefault init:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
        builder.datafileFetchInterval = -5;
    }];
    
    // check that the timer is set correctly
    XCTAssertNil(datafileManager.datafileDownloadTimer, @"Timer should be nil.");
    XCTAssertFalse(datafileManager.datafileDownloadTimer.valid, @"Timer should not be valid.");
}

- (void)testIsDatafileCachedFlag
{
    XCTAssertFalse(self.datafileManager.isDatafileCached, @"Datafile cached flag should be false.");
    
    // save the datafile
    [self.datafileManager saveDatafile:kDatafileData];
    
    XCTAssertTrue(self.datafileManager.isDatafileCached, @"Datafile cached flag should be true.");
}

// if 304 response datafile and last modified date should not have been saved
- (void)test304Response
{
    // stub response
    id<OHHTTPStubsDescriptor> stub200 = [self stub200Response];
    
    // make sure we get a 200 the first time around and save that datafile
    __weak XCTestExpectation *expect200 = [self expectationWithDescription:@"should get a 200 on first try"];
    XCTAssertFalse([self.datafileManager isDatafileCached]);
    [self.datafileManager downloadDatafile:kProjectId
                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                             XCTAssertEqual(((NSHTTPURLResponse *)response).statusCode , 200);
                             XCTAssertTrue([self.datafileManager isDatafileCached]);
                             [expect200 fulfill];
                         }];
    // wait for datafile download to finish
    [self waitForExpectationsWithTimeout:2 handler:nil];
    // remove stub
    [OHHTTPStubs removeStub:stub200];
    
    id<OHHTTPStubsDescriptor> stub304 = [self stub304Response];
    __weak XCTestExpectation *expect304 = [self expectationWithDescription:@"downloadDatafile304Response"];
    XCTAssertTrue([self.dataStore fileExists:kProjectId type:OPTLYDataStoreDataTypeDatafile]);
    XCTAssertNotNil([self.datafileManager getLastModifiedDate:kProjectId]);
    [self.datafileManager downloadDatafile:kProjectId completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertEqual(((NSHTTPURLResponse *)response).statusCode, 304);
        XCTAssertEqual([data length], 0);
        [expect304 fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
    
    // test datafile manager works in optly manager class
    OPTLYManager *manager = [OPTLYManager init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
        builder.datafileManager = self.datafileManager;
    }];
    XCTAssertNotNil(manager);
    XCTAssertNotNil(manager.datafileManager);
    XCTAssertEqual(manager.datafileManager, self.datafileManager);
    
    // setup async expectation
    __weak XCTestExpectation *clientExpectation = [self expectationWithDescription:@"testInitializeClientAsync"];
    // initialize client
    __block OPTLYClient *optimizelyClient;
    [manager initializeWithCallback:^(NSError * _Nullable error, OPTLYClient * _Nullable client) {
        // retain a reference to the client
        optimizelyClient = client;
        // check client in callback
        XCTAssertNotNil(client);
        XCTAssertNotNil(client.optimizely, @"Client needs to have an optimizely instance");
        OPTLYProjectConfig *expectedConfig = [[OPTLYProjectConfig alloc] initWithDatafile:kDatafileData];
        XCTAssertEqualObjects(client.optimizely.config.accountId, expectedConfig.accountId);
        [clientExpectation fulfill];
    }];
    
    // wait for async start to finish
    [self waitForExpectationsWithTimeout:2 handler:nil];
    XCTAssertEqual(optimizelyClient, manager.getOptimizely);
    
    
    // remove stub
    [OHHTTPStubs removeStub:stub304];
}

# pragma mark - Helper Methods
- (id<OHHTTPStubsDescriptor>)stub200Response {
    NSURL *hostURL = [NSURL URLWithString:OPTLYNetworkServiceCDNServerURL];
    NSString *hostName = [hostURL host];
    
    return [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return [request.URL.host isEqualToString:hostName];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:kDatafileData
                                          statusCode:200
                                             headers:kCDNResponseHeaders];
    }];
}

// 304 returns nil data
- (id<OHHTTPStubsDescriptor>)stub304Response {
    NSURL *hostURL = [NSURL URLWithString:OPTLYNetworkServiceCDNServerURL];
    NSString *hostName = [hostURL host];
    
    return [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return [request.URL.host isEqualToString:hostName];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        if ([request.allHTTPHeaderFields objectForKey:@"If-Modified-Since"] != nil) {
            return [OHHTTPStubsResponse responseWithData:nil
                                              statusCode:304
                                                 headers:kCDNResponseHeaders];
        }
        else {
            return [OHHTTPStubsResponse responseWithData:kDatafileData
                                              statusCode:200
                                                 headers:kCDNResponseHeaders];

        }
    }];
}

// 400 returns nil data
- (id<OHHTTPStubsDescriptor>)stub400Response {
    NSURL *hostURL = [NSURL URLWithString:OPTLYNetworkServiceCDNServerURL];
    NSString *hostName = [hostURL host];
    
    return [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return [request.URL.host isEqualToString:hostName];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:400
                                             headers:kCDNResponseHeaders];
    }];
}

@end
