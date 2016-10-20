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

#import "OPTLYBucketer.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYVariation.h"
#import "OPTLYExperiment.h"
#import "OPTLYGroup.h"

static NSString *const kBucketerTestDatafileName = @"BucketerTestsDatafile";

@interface OPTLYBucketer ()

- (OPTLYExperiment *)bucketToExperiment:(OPTLYGroup *)group withUserId:(NSString *)userId;

@end

@interface OPTLYBucketerTest : XCTestCase

@end

@implementation OPTLYBucketerTest

- (void)testInitWithConfig {
    OPTLYProjectConfig *config = [[OPTLYProjectConfig alloc] init];
    OPTLYBucketer *bucketer = [[OPTLYBucketer alloc] initWithConfig:config];
    XCTAssertNotNil(bucketer);
}

- (void)testBucketingRandom {
    NSString *experimentId = @"1886780721";
    OPTLYBucketer *bucketer = [[OPTLYBucketer alloc] initWithConfig:[[OPTLYProjectConfig alloc] init]];
    
    // These test inputs/outputs should be reproduced exactly in all clients to make sure that they behave
    // consistently.
    NSArray *tests = @[@{@"userId": @"ppid1", @"experimentId": experimentId, @"expect": @(5254)},
                       @{@"userId": @"ppid2", @"experimentId": experimentId, @"expect": @(4299)},
                       // Same PPID as previous, diff experiment ID
                       @{@"userId": @"ppid2", @"experimentId": @"1886780722", @"expect": @(2434)},
                       @{@"userId": @"ppid3", @"experimentId": experimentId, @"expect": @(5439)},
                       @{@"userId": @"a very very very very very very very very very very very very very very very long ppd string", @"experimentId": experimentId, @"expect": @(6128)}];
    
    for (NSDictionary *test in tests) {
        NSString *bucketingId = [bucketer makeBucketingIdFromUserId:test[@"userId"] andEntityId:test[@"experimentId"]];
        int bucketingValue = [bucketer generateBucketValue:bucketingId];
        
        XCTAssertEqual([test[@"expect"] integerValue], bucketingValue);
    }
}

- (void)testBucketingWithExperiment {
    // Set up the Experiment right now since we don't have project config parsing datafile
    // TODO Josh W. parse datafile and replace this with optimizely project config
    OPTLYExperiment *experiment = [[OPTLYExperiment alloc] initWithDictionary:@{@"id" : @"1886780721",
                                                                                @"key" : @"Basic_Experiment",
                                                                                @"layerId": @"1234",
                                                                                @"status" : @"Running",
                                                                                @"audienceIds" : @[],
                                                                                @"forcedVariations" : @{},
                                                                                @"variations" : @[@{@"id" : @"6030714421",
                                                                                                    @"key" : @"Variation_A"},
                                                                                                  @{@"id": @"6030714422",
                                                                                                    @"key" : @"Variation_B"}],
                                                                                @"trafficAllocation": @[@{@"entityId" : @"6030714421",
                                                                                                          @"endOfRange" : @5000},
                                                                                                        @{@"entityId" : @"6030714422",
                                                                                                          @"endOfRange" : @10000}]
                                                                                }
                                                                        error:nil];
    
    
    
    // generate bucketer
    OPTLYBucketer *bucketer = [[OPTLYBucketer alloc] initWithConfig:[[OPTLYProjectConfig alloc] init]];
    
    // These test inputs/outputs should be reproduced exactly in all clients to make sure that they behave
    // consistently.
    NSArray *tests = @[@{@"userId": @"ppid1", @"expect": @"Variation_B"},
                       @{@"userId": @"ppid2", @"expect": @"Variation_A"},
                       @{@"userId": @"ppid3", @"expect": @"Variation_B"},
                       @{@"userId": @"a very very very very very very very very very very very very very very very long ppd string", @"expect": @"Variation_B"}];
    
    for (NSDictionary *test in tests) {
        OPTLYVariation *variation = [bucketer bucketExperiment:experiment withUserId:test[@"userId"]];
        XCTAssertEqualObjects(test[@"expect"], variation.variationKey);
    }
}

- (void)testBucketExperimentInMutexGroup {
    
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kBucketerTestDatafileName];
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithDatafile:datafile withLogger:nil withErrorHandler:nil];
    XCTAssertNotNil(projectConfig);
    OPTLYGroup * group = [projectConfig getGroupForGroupId:@"1886780721"];
    
    // generate bucketer
    OPTLYBucketer *bucketer = [[OPTLYBucketer alloc] initWithConfig:projectConfig];
    
    // These test inputs/outputs should be reproduced exactly in all clients to make sure that they behave
    // consistently.
    NSArray *tests = @[@{@"userId": @"ppid1", @"expect": @"experiment2"},
                       @{@"userId": @"ppid2", @"expect": @"experiment1"},
                       @{@"userId": @"ppid3", @"expect": @"experiment2"},
                       @{@"userId": @"a very very very very very very very very very very very very very very very long ppd string", @"expect": @"nil"}];
    
    for (NSDictionary *test in tests) {
        OPTLYExperiment *experiment = [bucketer bucketToExperiment:group withUserId:test[@"userId"]];
        if ([test[@"expect"] isEqualToString:@"nil"]) {
            XCTAssertNil(experiment);
        }
        else {
            XCTAssertEqualObjects(test[@"expect"], experiment.experimentKey);
        }
    }
}

- (void)testBucketReturnsNilWhenExperimentIsExcludedFromMutex {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kBucketerTestDatafileName];
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithDatafile:datafile withLogger:nil withErrorHandler:nil];
    XCTAssertNotNil(projectConfig);
    
    // generate bucketer
    OPTLYBucketer *bucketer = [[OPTLYBucketer alloc] initWithConfig:projectConfig];
    
    // These test inputs/outputs should be reproduced exactly in all clients to make sure that they behave
    // consistently.
    NSArray *tests = @[@{@"userId": @"ppid1", @"experiment": @"experiment2", @"expect": @"variationOfExperiment2"},
                       @{@"userId": @"ppid2", @"experiment": @"experiment1", @"expect": @"variationOfExperiment1"},
                       @{@"userId": @"ppid3", @"experiment": @"experiment2", @"expect": @"variationOfExperiment2"},
                       @{@"userId": @"a very very very very very very very very very very very very very very very long ppd string", @"experiment": @"nil", @"expect": @"nil"}];
    
    OPTLYExperiment *experiment1 = [projectConfig getExperimentForKey:@"experiment1"];
    OPTLYExperiment *experiment2 = [projectConfig getExperimentForKey:@"experiment2"];
    OPTLYVariation *variation;
    
    for (NSDictionary *test in tests) {
        if ([test[@"experiment"] isEqualToString:@"experiment1"]) {
            variation = [bucketer bucketExperiment:experiment1 withUserId:test[@"userId"]];
            XCTAssertNotNil(variation);
            XCTAssertEqualObjects(variation.variationKey, test[@"expect"]);
            variation = [bucketer bucketExperiment:experiment2 withUserId:test[@"userId"]];
            XCTAssertNil(variation);
        }
        else if([test[@"experiment"] isEqualToString:@"experiment2"]) {
            variation = [bucketer bucketExperiment:experiment2 withUserId:test[@"userId"]];
            XCTAssertNotNil(variation);
            XCTAssertEqualObjects(variation.variationKey, test[@"expect"]);
            variation = [bucketer bucketExperiment:experiment1 withUserId:test[@"userId"]];
            XCTAssertNil(variation);
        }
        else {
            variation = [bucketer bucketExperiment:experiment1 withUserId:test[@"userId"]];
            XCTAssertNil(variation);
            variation = [bucketer bucketExperiment:experiment2 withUserId:test[@"userId"]];
            XCTAssertNil(variation);
        }
    }
}

- (void)testBucketExperimentWithMutexDoesNotChangeExperimentReference {
    
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kBucketerTestDatafileName];
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithDatafile:datafile withLogger:nil withErrorHandler:nil];
    XCTAssertNotNil(projectConfig);
    OPTLYExperiment *experiment = [projectConfig getExperimentForId:@"2"];
    
    // generate bucketer
    OPTLYBucketer *bucketer = [[OPTLYBucketer alloc] initWithConfig:projectConfig];
    
    XCTAssertNotNil(experiment);
    OPTLYVariation *variation = [bucketer bucketExperiment:experiment withUserId:@"user"];
    XCTAssertNotNil(experiment);
    XCTAssertNil(variation);
}

- (void)testWhitelisting {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kBucketerTestDatafileName];
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithDatafile:datafile withLogger:nil withErrorHandler:nil];
    XCTAssertNotNil(projectConfig);
    OPTLYExperiment *experiment = [projectConfig getExperimentForId:@"3"];
    
    // generate bucketer
    OPTLYBucketer *bucketer = [[OPTLYBucketer alloc] initWithConfig:projectConfig];
    OPTLYVariation *variation = [bucketer bucketExperiment:experiment withUserId:@"userId"];
    XCTAssertNotNil(variation);
    XCTAssertEqualObjects(variation.variationId, @"variation4");
    XCTAssertEqualObjects(variation.variationKey, @"whiteListedVariation");
}


@end
