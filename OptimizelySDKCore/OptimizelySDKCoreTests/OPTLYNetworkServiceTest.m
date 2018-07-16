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
#import <OptimizelySDKShared/OPTLYDatafileConfig.h>
#import "OPTLYNetworkService.h"
#import "OPTLYTestHelper.h"

static NSString *const kDatafileVersion = @"3";

static NSString *const kDatamodelDatafileName = @"optimizely_6372300739";
static NSString *const kLastModifiedDate = @"Mon, 28 Nov 2016 06:10:59 GMT";
static NSString *const kProjectId = @"6372300739";

static NSData *kDatafileData;
static NSDictionary *kCDNResponseHeaders = nil;

@interface OPTLYNetworkServiceTest : XCTestCase

@property (nonatomic, strong) OPTLYNetworkService *network;

@end

@implementation OPTLYNetworkServiceTest

+ (void)setUp {
    [super setUp];
    kDatafileData = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatamodelDatafileName];
    kCDNResponseHeaders = @{@"Content-Type":@"application/json",
                            @"Last-Modified":kLastModifiedDate};
}

+ (void)tearDown {
    // Remove all stubs
    [OHHTTPStubs removeAllStubs];
    [super tearDown];
}

- (void)setUp {
    [super setUp];
    self.network = [OPTLYNetworkService new];
}

- (void)tearDown {
    self.network = nil;
    [super tearDown];
}

- (void)testDownloadProjectConfigRequestRetrievesProperDatafileVersion {
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testDownloadProjectConfigRequestRetrievesProperDatafileVersion"];
    [self stub200Response];
    
    NSString *cdnPath = [OPTLYDatafileConfig defaultProjectIdCdnPath:kProjectId];
    
    [self.network downloadProjectConfig:[NSURL URLWithString:cdnPath]
                           backoffRetry:NO
                      completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                          NSDictionary *datafile = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:kNilOptions
                                                                                     error:&error];
                          XCTAssertEqualObjects(kDatafileVersion, datafile[@"version"], @"Datafile version retrieved should match expected datafile version for this SDK version.");
                          [expectation fulfill];
                      }];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
    
}

- (void)testDownloadProjectConfigWithLastModifiedRequestRetrievesProperDatafileVersion {
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testDownloadProjectConfigWithLastModifiedRequestRetrievesProperDatafileVersion"];
    [self stub200Response];
    NSString *cdnPath = [OPTLYDatafileConfig defaultProjectIdCdnPath:kProjectId];

    [self.network downloadProjectConfig:[NSURL URLWithString:cdnPath]
                           backoffRetry:NO
                           lastModified:kLastModifiedDate
                      completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                          NSDictionary *datafile = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:kNilOptions
                                                                                     error:&error];
                          XCTAssertEqualObjects(kDatafileVersion, datafile[@"version"], @"Datafile version retrieved should match expected datafile version for this SDK version.");
                          [expectation fulfill];
                      }];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

# pragma mark - Helper Methods
- (id<OHHTTPStubsDescriptor>)stub200Response {
    NSString *filePath = [OPTLYDatafileConfig defaultProjectIdCdnPath:kProjectId];
    
     NSURL *hostURL = [NSURL URLWithString:filePath];
    NSString *hostName = [hostURL host];
    
    return [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return [request.URL.host isEqualToString:hostName];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:kDatafileData
                                          statusCode:200
                                             headers:kCDNResponseHeaders];
    }];
}

@end
