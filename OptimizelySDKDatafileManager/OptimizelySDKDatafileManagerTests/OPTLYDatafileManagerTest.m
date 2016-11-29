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
#import <OptimizelySDKShared/OPTLYDataStore.h>
#import <OptimizelySDKShared/OPTLYNetworkService.h>
#import "OPTLYDatafileManager.h"
#import "OPTLYTestHelper.h"

static NSString *const kProjectId = @"6372300739";
static NSString *const kDatamodelDatafileName = @"datafile_6372300739";
static NSTimeInterval kDatafileDownloadInteval = 5;
static NSString *const kLastModifiedDate = @"Mon, 28 Nov 2016 06:10:59 GMT";

@interface OPTLYDatafileManager(test)
@property (nonatomic, strong) NSTimer *datafileDownloadTimer;
- (void)downloadDatafile:(NSString *)projectId completionHandler:(OPTLYHTTPRequestManagerResponse)completion;
- (void)saveDatafile:(NSData *)datafile;
- (nullable NSString *)getLastModifiedDate:(nonnull NSString *)projectId;
@end

@interface OPTLYDatafileManagerTest : XCTestCase
@property (nonatomic, strong) OPTLYDatafileManager *datafileManager;
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@end

@implementation OPTLYDatafileManagerTest

+ (void)setUp {
    [super setUp];
    
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
    self.datafileManager = [OPTLYDatafileManager initWithBuilderBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
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
    [self stubResponse:400];
    
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

}

- (void)testSaveDatafileMethod {
    XCTAssertNotNil(self.datafileManager);
    XCTAssertFalse([self.dataStore fileExists:kProjectId type:OPTLYDataStoreDataTypeDatafile]);
    
    // get the datafile
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatamodelDatafileName];
    
    // save the datafile
    [self.datafileManager saveDatafile:datafile];
    
    // test the datafile was saved correctly
    bool fileExists = [self.dataStore fileExists:kProjectId type:OPTLYDataStoreDataTypeDatafile];
    XCTAssertTrue(fileExists, @"save Datafile did not save the datafile to disk");
    NSError *error;
    NSData *savedData = [self.dataStore getFile:kProjectId
                                           type:OPTLYDataStoreDataTypeDatafile
                                          error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(savedData);
    XCTAssertNotEqual(datafile, savedData, @"we should not be referencing the same object. Saved data should be a new NSData object created from disk.");
    XCTAssertEqualObjects(datafile, savedData, @"retrieved saved data from disk should be equivalent to the datafile we wanted to save to disk");
}

// if 200 response, save the {projectID : lastModifiedDate} and datafile
- (void)testDatafileManagerDownloadDatafileSavesDatafile {
    
    XCTAssertNotNil(self.datafileManager);
    XCTAssertFalse([self.dataStore fileExists:kProjectId type:OPTLYDataStoreDataTypeDatafile], @"no datafile sould exist yet.");

    // setup stubbing and listener expectation
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testInitializeClientAsync"];
    [self stubResponse:200];
    
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
}

// timer is enabled if the download intervao is > 0
- (void)testNetworkTimerIsEnabled
{
    OPTLYDatafileManager *datafileManager = [OPTLYDatafileManager initWithBuilderBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
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
    OPTLYDatafileManager *datafileManager = [OPTLYDatafileManager initWithBuilderBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
        builder.datafileFetchInterval = 0;
    }];
    
    // check that the timer is set correctly
    XCTAssertNil(datafileManager.datafileDownloadTimer, @"Timer should be nil.");
    XCTAssertFalse(datafileManager.datafileDownloadTimer.valid, @"Timer shoul not be valid.");
    
    datafileManager = [OPTLYDatafileManager initWithBuilderBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
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
    
    // get the datafile
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatamodelDatafileName];
    
    // save the datafile
    [self.datafileManager saveDatafile:datafile];
    
    XCTAssertTrue(self.datafileManager.isDatafileCached, @"Datafile cached flag should be true.");
}

// if 304 response datafile and last modified date should not have been saved
- (void)test304Response
{
    [self stubResponse:304];
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"downloadDatafile304Response"];
    [self.datafileManager downloadDatafile:kProjectId completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        XCTAssertFalse([self.dataStore fileExists:kProjectId type:OPTLYDataStoreDataTypeDatafile], @"Datafile should not have been saved.");
        NSString *savedLastModifiedData = [self.datafileManager getLastModifiedDate:kProjectId];
        XCTAssertNil(savedLastModifiedData, @"No modified date should have been saved.");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

# pragma mark - Helper Methods
- (void)stubResponse:(int)statusCode {
    NSURL *hostURL = [NSURL URLWithString:OPTLYNetworkServiceCDNServerURL];
    NSString *hostName = [hostURL host];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return [request.URL.host isEqualToString:hostName];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatamodelDatafileName]
                                          statusCode:statusCode
                                             headers:@{@"Content-Type":@"application/json",
                                                       @"Last-Modified":kLastModifiedDate}];
    }];
}

     
@end
