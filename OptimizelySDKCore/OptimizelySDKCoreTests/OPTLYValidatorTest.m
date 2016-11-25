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
#import <XCTest/XCTest.h>
#import "Optimizely.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYBucketer.h"
#import "OPTLYExperiment.h"
#import "OPTLYVariation.h"
#import "OPTLYTestHelper.h"
#import "OPTLYValidator.h"

static NSString * const kDatafileName = @"test_data_10_experiments";
static NSString * const kUserId = @"6369992312";
static NSString * const kUserNotInExperimentId = @"6358043286";

// whitelisting test constants
static NSString * const kWhitelistingTestDatafileName = @"validator_whitelisting_test_datafile";
static NSString * const kWhitelistedUserId = @"whitelisted_user";
static NSString * const kWhitelistedExperiment = @"whitelist_testing_experiment";
static NSString * const kWhitelistedVariation = @"a";

// events with experiment and audiences
static NSString * const kExperimentWithAudienceKey = @"testExperimentWithFirefoxAudience";
static NSString * const kExperimentWithAudienceId = @"6383811281";

// experiment not running parameters
static NSString * const kExperimentNotRunningKey = @"testExperimentNotRunning";
static NSString * const kExperimentNotRunningId = @"6367444440";

static NSString * const kAttributeKey = @"browser_type";
static NSString * const kAttributeValue = @"firefox";

@interface OPTLYValidatorTest : XCTestCase
@property (nonatomic, strong) OPTLYProjectConfig *config;
@property (nonatomic, strong) NSDictionary *attributes;
@end


@implementation OPTLYValidatorTest

- (void)setUp {
    [super setUp];
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatafileName];
    self.config = [[OPTLYProjectConfig alloc] initWithDatafile:datafile];
    self.attributes = @{kAttributeKey : kAttributeValue};
}

- (void)tearDown {
    [super tearDown];
    self.config = nil;
    self.attributes = nil;
}

// experiment is running, user is in experiment
- (void)testValidatePreconditions
{
    BOOL isValid = [OPTLYValidator validatePreconditions:self.config
                                           experimentKey:kExperimentWithAudienceKey
                                                  userId:kUserId
                                              attributes:self.attributes];
    NSAssert(isValid == true, @"Experiment running with user in experiment should pass validation.");
}

// experiment is not running, user is in experiment
- (void)testValidatePreconditionsExperimentNotRunning
{
    BOOL isValid = [OPTLYValidator validatePreconditions:self.config
                                           experimentKey:kExperimentNotRunningKey
                                                  userId:kUserId
                                              attributes:self.attributes];
    NSAssert(isValid == false, @"Experiment not running with user in experiment should fail validation.");
}

// experiment is running, user is in experiment, bad attributes
- (void)testValidatePreconditionsBadAttributes
{
    NSDictionary *badAttributes = @{@"badAttributeKey":@"12345"};
    BOOL isValid = [OPTLYValidator validatePreconditions:self.config
                                           experimentKey:kExperimentWithAudienceKey
                                                  userId:kUserId
                                              attributes:badAttributes];
    NSAssert(isValid == false, @"Experiment running with user in experiment, but with bad attributes should fail validation.");
}

- (void)testValidatePreconditionsAllowsWhiteListedUserToOverrideAudienceEvaluation {
    NSData *whitelistingDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kWhitelistingTestDatafileName];
    Optimizely *optimizely = [Optimizely initWithBuilderBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = whitelistingDatafile;
    }];
    
    // user should not be bucketed if userId is not a match and they do not pass attributes
    OPTLYVariation *variation = [optimizely getVariationForExperiment:kWhitelistedExperiment
                                                               userId:kUserId
                                                           attributes:self.attributes];
    XCTAssertNil(variation);
    
    // user should be bucketed if userID is whitelisted
    variation = [optimizely getVariationForExperiment:kWhitelistedExperiment
                                               userId:kWhitelistedUserId
                                           attributes:self.attributes];
    XCTAssertNotNil(variation);
    XCTAssertEqualObjects(variation.variationKey, kWhitelistedVariation);
}

@end
