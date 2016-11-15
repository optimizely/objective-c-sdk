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
#import <OptimizelySDKShared/OPTLYFileManager.h>

#import "OPTLYDatafileManager.h"

@interface OPTLYDatafileManagerTest : XCTestCase

@end

@interface OPTLYDatafileManager ()

- (void)saveDatafile:(NSData *)datafile;

@end

@interface OPTLYFileManager ()

@property NSString *baseDir;
- (NSString *)stringForDataTypeEnum:(OPTLYFileManagerDataType)dataType;

@end

static NSString *const kProjectId = @"6372300739";
static NSString *const kDatamodelDatafileName = @"datafile_6372300739";

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

- (void)testSaveDatafile {
    // setup datafile manager
    OPTLYDatafileManager *datafileManager = [OPTLYDatafileManager initWithBuilderBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    XCTAssertNotNil(datafileManager);
    
    // get the datafile
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatamodelDatafileName];
    
    // save the datafile
    [datafileManager saveDatafile:datafile];
    
    // test the datafile was saved correctly
    NSString *expectedFilePath = [self getExpectedFilePathForProjectId:datafileManager.projectId];
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    bool fileExists = [defaultFileManager fileExistsAtPath:expectedFilePath];
    XCTAssertTrue(fileExists, @"datafile was not saved properly");
    NSData *fileData = [NSData dataWithContentsOfFile:expectedFilePath options:0 error:nil];
    XCTAssert(fileData != nil, @"Saved file has no content.");
    XCTAssert([fileData isEqualToData:datafile],  @"Invalid file content of saved file.");
}

- (NSString *)getExpectedFilePathForProjectId:(NSString *)projectId {
    OPTLYFileManager *fileManager = [OPTLYFileManager new];
    NSString *fileDir = [fileManager.baseDir stringByAppendingPathComponent:[fileManager stringForDataTypeEnum:OPTLYFileManagerDataTypeDatafile]];
    NSString *filePath = [fileDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", projectId]];
    return filePath;
}

@end
