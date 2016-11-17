//
//  OPTLYDatafileManagerTest.m
//  OptimizelySDKDatafileManager
//
//  Created by Josh Wang on 11/14/16.
//  Copyright © 2016 Optimizely. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OPTLYTestHelper.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OptimizelySDKShared/OPTLYDataStore.h>
#import <OptimizelySDKShared/OPTLYFileManager.h>

#import "OPTLYDatafileManager.h"

@interface OPTLYDatafileManager ()

- (void)saveDatafile:(NSData *)datafile;

@end

@interface OPTLYDataStore ()

@property OPTLYFileManager *fileManager;
- (NSString *)stringForDataTypeEnum:(OPTLYDataStoreDataType)dataType;

@end

@interface OPTLYFileManager ()

@property NSString *baseDir;

@end

static NSString *const kProjectId = @"6372300739";
static NSString *const kDatamodelDatafileName = @"datafile_6372300739";

@interface OPTLYDatafileManagerTest : XCTestCase

@property OPTLYDataStore *dataStore;

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
}

- (void)tearDown {
    [super tearDown];
    [self.dataStore removeAll:nil];
    self.dataStore = nil;
}

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

- (void)testSaveDatafileMethod {
    // setup datafile manager and datastore
    OPTLYDatafileManager *datafileManager = [OPTLYDatafileManager initWithBuilderBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    XCTAssertNotNil(datafileManager);
    XCTAssertFalse([self.dataStore fileExists:kProjectId type:OPTLYDataStoreDataTypeDatafile]);
    
    // get the datafile
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatamodelDatafileName];
    
    // save the datafile
    [datafileManager saveDatafile:datafile];
    
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
    XCTAssertEqualObjects(datafile, savedData, @"retrieved saved data from disk should be equivilent to the datafile we wanted to save to disk");
}

- (void)testDatafileManagerPullsDatafileOnInitialization {
    // setup stubbing and listener expectation
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testInitializeClientAsync"];
    id<OHHTTPStubsDescriptor> stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"cdn.optimizely.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our "wsresponse.json" stub file (which is in same bundle as self)
        [expectation fulfill];
        return [OHHTTPStubsResponse responseWithData:[OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatamodelDatafileName]
                                          statusCode:200
                                             headers:@{@"Content-Type":@"application/json"}];
    }];
    
    // instantiate datafile manager (it should fire off a request)
    XCTAssertFalse([self.dataStore fileExists:kProjectId type:OPTLYDataStoreDataTypeDatafile], @"no datafile sould exist yet.");
    OPTLYDatafileManager *datafileManager = [OPTLYDatafileManager initWithBuilderBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    XCTAssertNotNil(datafileManager);
    
    // make sure we were able to save the datafile
    [self waitForExpectationsWithTimeout:2 handler:nil];
    sleep(2); // not sure if there is a better way for to wait for disk write other than to sleep this thread
    XCTAssertTrue([self.dataStore fileExists:kProjectId type:OPTLYDataStoreDataTypeDatafile], @"we should have stored the datafile");
    
    // cleanup stubs
    [OHHTTPStubs removeStub:stub];
}

@end
