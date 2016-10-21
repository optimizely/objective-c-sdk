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
#import "Optimizely.h"
#import "OPTLYExperiment.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYTestHelper.h"
#import "OPTLYVariation.h"

@interface OptimizelyTest : XCTestCase

@end

@implementation OptimizelyTest

- (void)testBasicGetVariation {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:@"BucketerTestsDatafile"];
    
    Optimizely *optimizely = [Optimizely initWithBuilderBlock:^(OPTLYBuilder *builder) {
        builder.datafile = datafile;
    }];
    
    XCTAssertNotNil(optimizely);
    
    NSString *userId = @"ppid1";
    NSString *experimentKey = @"Basic_Experiment";
    OPTLYExperiment *experiment = [optimizely.config getExperimentForKey:experimentKey];
    XCTAssertNotNil(experiment);
    OPTLYVariation *variation;
    
    // test just experiment key
    variation = [optimizely getVariationForExperiment:experimentKey userId:userId];
    XCTAssertNotNil(variation);
    XCTAssertTrue([variation.variationKey isEqualToString:@"Variation_B"]);
    XCTAssertTrue([variation.variationId isEqualToString:@"6030714422"]);
    
    // test with bad experiment key
    variation = [optimizely getVariationForExperiment:@"bad" userId:userId];
    XCTAssertNil(variation);
    
}

- (void)testWithAudience {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:@"test_data_10_experiments"];
    
    Optimizely *optimizely = [Optimizely initWithBuilderBlock:^(OPTLYBuilder *builder) {
        builder.datafile = datafile;
    }];
    
    XCTAssertNotNil(optimizely);
    
    NSString *userId = @"userId";
    NSString *experimentKey = @"testExperimentWithFirefoxAudience";
    OPTLYExperiment *experiment = [optimizely.config getExperimentForKey:experimentKey];
    XCTAssertNotNil(experiment);
    OPTLYVariation *variation;
    NSDictionary *attributesWithUserNotInAudience = @{@"browser_type" : @"chrome"};
    NSDictionary *attributesWithUserInAudience = @{@"browser_type" : @"firefox"};
    
    // test get experiment without attributes
    variation = [optimizely getVariationForExperiment:experimentKey userId:userId];
    XCTAssertNil(variation);
    // test get experiment with bad attributes
    variation = [optimizely getVariationForExperiment:experimentKey
                                               userId:userId
                                           attributes:attributesWithUserNotInAudience];
    XCTAssertNil(variation);
    // test get experiment with good attributes
    variation = [optimizely getVariationForExperiment:experimentKey
                                               userId:userId
                                           attributes:attributesWithUserInAudience];
    XCTAssertNotNil(variation);
}


@end
