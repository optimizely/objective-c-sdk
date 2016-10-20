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
#import "OPTLYTestHelper.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYExperiment.h"
#import "OPTLYAudience.h"
#import "OPTLYEvent.h"
#import "OPTLYGroup.h"
#import "OPTLYAttribute.h"

// static data from datafile
static NSString * const kDataModelDatafileName = @"datafile_6372300739";
static NSString * const kVersion = @"1";
static NSString * const kRevision = @"58";
static NSString * const kProjectId = @"6372300739";
static NSString * const kAccountId = @"6365361536";

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

- (void)testInitWithDatafile
{
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithDatafile:datafile withLogger:nil withErrorHandler:nil];
    [self checkProjectConfigProperties:projectConfig];
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
    NSAssert([projectConfig.version isEqualToString:kVersion], @"Invalid version number.");
    
    // validate revision number
    NSAssert([projectConfig.revision isEqualToString:kRevision], @"Invalid revision number.");
    
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
