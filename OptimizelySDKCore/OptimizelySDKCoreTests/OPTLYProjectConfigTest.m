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

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#import "OPTLYAttribute.h"
#import "OPTLYAudience.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYEvent.h"
#import "OPTLYExperiment.h"
#import "OPTLYGroup.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYUserProfile.h"
#import "OPTLYTestHelper.h"

// static data from datafile
static NSString * const kDataModelDatafileName = @"datafile_6372300739";
static NSString * const kDatafileNameAnonymizeIPFalse = @"test_data_25_experiments";
static NSString * const kRevision = @"58";
static NSString * const kProjectId = @"6372300739";
static NSString * const kAccountId = @"6365361536";

static NSString * const kInvalidDatafileVersionDatafileName = @"InvalidDatafileVersionDatafile";

@interface OPTLYProjectConfigTest : XCTestCase
@end

@implementation OPTLYProjectConfigTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitWithBuilderBlock
{
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    OPTLYProjectConfig *projectConfig = [OPTLYProjectConfig initWithBuilderBlock:^(OPTLYProjectConfigBuilder * _Nullable builder){
        builder.datafile = datafile;
        builder.logger = [OPTLYLoggerDefault new];
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }];
    
    XCTAssertNotNil(projectConfig, @"project config should not be nil.");
    XCTAssertNotNil(projectConfig.logger, @"logger should not be nil.");
    XCTAssertNotNil(projectConfig.errorHandler, @"error handler should not be nil.");
    XCTAssertNotNil(projectConfig.clientEngine);
    XCTAssertNotNil(projectConfig.clientVersion);
    XCTAssertEqualObjects(projectConfig.clientEngine, @"objective-c-sdk-core");
    XCTAssertEqualObjects(projectConfig.clientVersion, OPTIMIZELY_SDK_CORE_VERSION);
}

/**
 * Make sure we can pass in different values for client engine and client version to override the defaults.
 */
- (void)testClientEngineAndClientVersionAreConfigurable {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    NSString *clientEngine = @"clientEngine";
    NSString *clientVersion = @"clientVersion";
    
    OPTLYProjectConfig *projectConfig = [OPTLYProjectConfig initWithBuilderBlock:^(OPTLYProjectConfigBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.clientEngine = clientEngine;
        builder.clientVersion = clientVersion;
    }];
    XCTAssertNotNil(projectConfig);
    XCTAssertNotNil(projectConfig.clientEngine);
    XCTAssertNotNil(projectConfig.clientVersion);
    XCTAssertEqualObjects(projectConfig.clientEngine, clientEngine);
    XCTAssertEqualObjects(projectConfig.clientVersion, clientVersion);
}

- (void)testInitWithBuilderBlockNoDatafile
{
    OPTLYProjectConfig *projectConfig = [OPTLYProjectConfig initWithBuilderBlock:^(OPTLYProjectConfigBuilder * _Nullable builder){
        builder.datafile = nil;
    }];
    
    XCTAssertNil(projectConfig, @"project config should be nil.");
}

- (void)testInitWithBuilderBlockInvalidModulesFails {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    
    id<OPTLYUserProfile> userProfile = [NSObject new];
    id<OPTLYLogger> logger = [NSObject new];
    id<OPTLYErrorHandler> errorHandler = [NSObject new];
    
    OPTLYProjectConfig *projectConfig = [OPTLYProjectConfig initWithBuilderBlock:^(OPTLYProjectConfigBuilder * _Nullable builder){
        builder.datafile = datafile;
        builder.logger = logger;
        builder.errorHandler = errorHandler;
    }];
    
    XCTAssertNil(projectConfig, @"project config should not be able to be created with invalid modules.");
}

- (void)testInitWithDatafile
{
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithDatafile:datafile];
    [self checkProjectConfigProperties:projectConfig];
}

- (void)testInitWithAnonymizeIPFalse {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatafileNameAnonymizeIPFalse];
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithDatafile:datafile];
    
    XCTAssertFalse(projectConfig.anonymizeIP, @"IP anonymization should be set to false.");
}

#pragma mark - Helper Methods

// Check all properties in an ProjectConfig object
- (void)checkProjectConfigProperties:(OPTLYProjectConfig *)projectConfig
{
    XCTAssertNotNil(projectConfig, @"ProjectConfig is nil.");
    
    // validate projectId
    NSAssert([projectConfig.projectId isEqualToString:kProjectId], @"Invalid project id.");
    
    // validate accountID
    NSAssert([projectConfig.accountId isEqualToString:kAccountId], @"Invalid account id.");
    
    // validate version number
    NSAssert([projectConfig.version isEqualToString:kExpectedDatafileVersion], @"Invalid version number.");
    
    // validate revision number
    NSAssert([projectConfig.revision isEqualToString:kRevision], @"Invalid revision number.");
    
    // validate IP anonymization value
    XCTAssertTrue(projectConfig.anonymizeIP, @"IP anonymization should be set to true.");
    
    // check experiments
    NSAssert([projectConfig.experiments count] == 48, @"deserializeJSONArray failed to deserialize the right number of experiments objects in project config.");
    for (id experiment in projectConfig.experiments) {
        NSAssert([experiment isKindOfClass:[OPTLYExperiment class]], @"deserializeJSONArray failed to deserialize the experiment object in project config.");
    }
    
    // check audiences
    NSAssert([projectConfig.audiences count] == 8, @"deserializeJSONArray failed to deserialize the right number of audience objects in project config.");
    for (id audience in projectConfig.audiences) {
        NSAssert([audience isKindOfClass:[OPTLYAudience class]], @"deserializeJSONArray failed to deserialize the audience object in project config.");
    }
    
    // check attributes
    NSAssert([projectConfig.attributes count] == 1, @"deserializeJSONArray failed to deserialize the right number of attribute objects in project config.");
    for (id attribute in projectConfig.attributes) {
        NSAssert([attribute isKindOfClass:[OPTLYAttribute class]], @"deserializeJSONArray failed to deserialize the attribute object in project config.");
    }
    
    // check groups
    NSAssert([projectConfig.groups count] == 1, @"deserializeJSONArray failed to deserialize the right number of group objects in project config.");
    for (id group in projectConfig.groups) {
        NSAssert([group isKindOfClass:[OPTLYGroup class]], @"deserializeJSONArray failed to deserialize the group object in project config.");
    }
    
    // check events
    NSAssert([projectConfig.events count] == 7, @"deserializeJSONArray failed to deserialize the right number of event objects in project config.");
    for (id event in projectConfig.events) {
        NSAssert([event isKindOfClass:[OPTLYEvent class]], @"deserializeJSONArray failed to deserialize the event object in project config.");
    }
}

@end
