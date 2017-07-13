/****************************************************************************
 * Copyright 2017, Optimizely, Inc. and contributors                        *
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
#import "Optimizely.h"
#import "OPTLYBucketer.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYDecisionService.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYExperiment.h"
#import "OPTLYUserProfile.h"
#import "OPTLYUserProfileServiceBasic.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYVariation.h"
#import "OPTLYTestHelper.h"

static NSString * const kDatafileName = @"test_data_10_experiments";
static NSString * const kUserId = @"6369992312";
static NSString * const kUserNotInExperimentId = @"6358043286";

// whitelisting test constants
static NSString * const kWhitelistingTestDatafileName = @"validator_whitelisting_test_datafile";
static NSString * const kWhitelistedUserId = @"whitelisted_user";
static NSString * const kWhitelistedExperiment = @"whitelist_testing_experiment";
static NSString * const kWhitelistedVariation = @"a";
// whitelisting test constants from "test_data_10_experiments.json"
static NSString * const kWhitelistedUserId_test_data_10_experiments = @"forced_variation_user";
static NSString * const kWhitelistedExperiment_test_data_10_experiments = @"testExperiment6";
static NSString * const kWhitelistedVariation_test_data_10_experiments = @"variation";

// events with experiment and audiences
static NSString * const kExperimentWithAudienceKey = @"testExperimentWithFirefoxAudience";
static NSString * const kExperimentWithAudienceId = @"6383811281";
static NSString * const kExperimentWithAudienceVariationId = @"6333082303";
static NSString * const kExperimentWithAudienceVariationKey = @"control";

// experiment not running parameters
static NSString * const kExperimentNotRunningKey = @"testExperimentNotRunning";
static NSString * const kExperimentNotRunningId = @"6367444440";


static NSString * const kAttributeKey = @"browser_type";
static NSString * const kAttributeValue = @"firefox";

// experiment with no audience
static NSString * const kExperimentNoAudienceKey = @"testExperiment4";
static NSString * const kExperimentNoAudienceId = @"6358043286";
static NSString * const kExperimentNoAudienceVariationId = @"6373141147";
static NSString * const kExperimentNoAudienceVariationKey = @"control";


@interface OPTLYDecisionServiceTest : XCTestCase
@property (nonatomic, strong) Optimizely *optimizely;
@property (nonatomic, strong) OPTLYProjectConfig *config;
@property (nonatomic, strong) OPTLYDecisionService *decisionService;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, strong) OPTLYUserProfile *userProfileWithFirefoxAudience;
@end

@interface OPTLYDecisionService()
- (BOOL)userPassesTargeting:(OPTLYProjectConfig *)config
              experimentKey:(NSString *)experimentKey
                     userId:(NSString *)userId
                 attributes:(NSDictionary *)attributes;
    
- (BOOL)isExperimentActive:(OPTLYProjectConfig *)config
             experimentKey:(NSString *)experimentKey;
    
- (void)saveUserProfile:(NSDictionary *)userProfileDict
              variation:(nonnull OPTLYVariation *)variation
             experiment:(nonnull OPTLYExperiment *)experiment
                 userId:(nonnull NSString *)userId;
@end


@implementation OPTLYDecisionServiceTest
    
- (void)setUp {
    [super setUp];
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatafileName];

    id<OPTLYUserProfileService> profileService = [OPTLYUserProfileServiceNoOp new];

    self.optimizely = [Optimizely init:^(OPTLYBuilder *builder) {
        builder.datafile = datafile;
        builder.userProfileService = profileService;
    }];
    self.config = self.optimizely.config;
    OPTLYBucketer *bucketer = [[OPTLYBucketer alloc] initWithConfig:self.config];
    self.decisionService = [[OPTLYDecisionService alloc] initWithProjectConfig:self.config bucketer:bucketer];
    self.attributes = @{ kAttributeKey : kAttributeValue };
    
    self.userProfileWithFirefoxAudience = @{ OPTLYDatafileKeysUserProfileServiceUserId : kUserId,
                      OPTLYDatafileKeysUserProfileServiceExperimentBucketMap : @{ kExperimentWithAudienceId : @{ OPTLYDatafileKeysUserProfileServiceVariationId : kExperimentWithAudienceVariationId } } };
}
    
- (void)tearDown {
    [super tearDown];
    self.config = nil;
    self.attributes = nil;
}
    
    // experiment is running, user is in experiment
- (void)testValidatePreconditions
{
    BOOL isValid = [self.decisionService userPassesTargeting:self.config
                                               experimentKey:kExperimentWithAudienceKey
                                                      userId:kUserId
                                                  attributes:self.attributes];
    NSAssert(isValid == true, @"Experiment running with user in experiment should pass validation.");
}

// experiment is not running, validator should return false
- (void)testValidatePreconditionsExperimentNotRunning
{
    BOOL isActive = [self.decisionService isExperimentActive:self.config
                                               experimentKey:kExperimentNotRunningKey];
    NSAssert(isActive == false, @"Experiment not running with user in experiment should fail validation.");
}

// experiment is running, user is in experiment, bad attributes
- (void)testValidatePreconditionsBadAttributes
{
    NSDictionary *badAttributes = @{@"badAttributeKey":@"12345"};
    BOOL isValid = [self.decisionService userPassesTargeting:self.config
                                               experimentKey:kExperimentWithAudienceKey
                                                      userId:kUserId
                                                  attributes:badAttributes];
    NSAssert(isValid == false, @"Experiment running with user in experiment, but with bad attributes should fail validation.");
}
    
- (void)testValidatePreconditionsAllowsWhiteListedUserToOverrideAudienceEvaluation {
    NSData *whitelistingDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kWhitelistingTestDatafileName];
    Optimizely *optimizely = [Optimizely init:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = whitelistingDatafile;
    }];
    
    // user should not be bucketed if userId is not a match and they do not pass attributes
    OPTLYVariation *variation = [optimizely variation:kWhitelistedExperiment
                                               userId:kUserId
                                           attributes:self.attributes];
    XCTAssertNil(variation);
    
    // user should be bucketed if userID is whitelisted
    variation = [optimizely variation:kWhitelistedExperiment
                               userId:kWhitelistedUserId
                           attributes:self.attributes];
    XCTAssertNotNil(variation);
    XCTAssertEqualObjects(variation.variationKey, kWhitelistedVariation);
}

// if the experiment is not running should return nil for getVariation
- (void)testGetVariationExperimentNotRunning
{
    OPTLYExperiment *experimentNotRunning = [self.config getExperimentForKey:kExperimentNotRunningKey];
    OPTLYVariation *variation = [self.decisionService getVariation:kUserId experiment:experimentNotRunning attributes:nil];
    XCTAssertNil(variation, @"Get variation on an experiment not running should return nil: %@", variation);
}

// if the experiment is not running should return nil for getVariation even after setForcedVariation
- (void)testSetForcedVariationExperimentNotRunning
{
    OPTLYExperiment *experimentNotRunning = [self.config getExperimentForKey:kExperimentNotRunningKey];
    XCTAssert([self.optimizely setForcedVariation:kExperimentNotRunningKey
                                           userId:kUserId
                                     variationKey:kExperimentNoAudienceVariationKey]);
    OPTLYVariation *variation = [self.decisionService getVariation:kUserId experiment:experimentNotRunning attributes:nil];
    XCTAssertNil(variation, @"Set forced variation on an experiment not running should return nil: %@", variation);
}
    
// setForcedVariation called on invalid experimentKey (empty string)
- (void)testSetForcedVariationCalledOnInvalidExperimentKey1
{
    NSString *invalidExperimentKey = @"";
    XCTAssertFalse([self.optimizely setForcedVariation:invalidExperimentKey
                                                userId:kUserId
                                          variationKey:kExperimentNoAudienceVariationKey]);
}

// setForcedVariation called on invalid experimentKey (non-existent experiment)
- (void)testSetForcedVariationCalledOnInvalidExperimentKey2
{
    NSString *invalidExperimentKey = @"invalid_experiment_key_3817";
    XCTAssertFalse([self.optimizely setForcedVariation:invalidExperimentKey
                                                userId:kUserId
                                          variationKey:kExperimentNoAudienceVariationKey]);
}

// setForcedVariation called on invalid variationKey (empty string)
- (void)testSetForcedVariationCalledOnInvalidVariationKey1
{
    NSString *invalidVariationKey = @"";
    XCTAssertFalse([self.optimizely setForcedVariation:kExperimentNotRunningKey
                                                userId:kUserId
                                          variationKey:invalidVariationKey]);
}

// setForcedVariation called on invalid variationKey (non-existent variation)
- (void)testSetForcedVariationCalledOnInvalidVariationKey2
{
    NSString *invalidVariationKey = @"invalid_variation_key_3817";
    XCTAssertFalse([self.optimizely setForcedVariation:kExperimentNotRunningKey
                                                userId:kUserId
                                          variationKey:invalidVariationKey]);
}

// setForcedVariation called on invalid userId (empty string)
- (void)testSetForcedVariationCalledOnInvalidUserId
{
    NSString *invalidUserId = @"";
    XCTAssertFalse([self.optimizely setForcedVariation:kExperimentNotRunningKey
                                                userId:invalidUserId
                                          variationKey:kExperimentNoAudienceVariationKey]);
}

// whitelisted user should return the whitelisted variation for getVariation
- (void)testGetVariationWithWhitelistedVariation
{
    OPTLYExperiment *experimentWhitelisted = [self.config getExperimentForKey:kWhitelistedExperiment_test_data_10_experiments];
    OPTLYVariation *variation = [self.decisionService getVariation:kWhitelistedUserId_test_data_10_experiments
                                                        experiment:experimentWhitelisted
                                                        attributes:nil];
    XCTAssert([variation.variationKey isEqualToString:kWhitelistedVariation_test_data_10_experiments], @"Get variation on a whitelisted variation should return: %@, but instead returns: %@.", kWhitelistedVariation_test_data_10_experiments, variation.variationKey);
}

// whitelisted user should return the whitelisted variation for getVariation overridden by call to setForcedVariation
- (void)testGetVariationWithWhitelistedVariationOverriddenBySetForcedVariation
{
    [self.optimizely setForcedVariation:kWhitelistedExperiment_test_data_10_experiments
                                 userId:kWhitelistedUserId_test_data_10_experiments
                           variationKey:kExperimentNoAudienceVariationKey];
    OPTLYExperiment *experimentWhitelisted = [self.config getExperimentForKey:kWhitelistedExperiment_test_data_10_experiments];
    OPTLYVariation *variation = [self.decisionService getVariation:kWhitelistedUserId_test_data_10_experiments
                                                        experiment:experimentWhitelisted
                                                        attributes:nil];
    XCTAssertFalse([variation.variationKey isEqualToString:kWhitelistedVariation_test_data_10_experiments], @"Get variation on a whitelisted variation should be overridden by setForcedVariation");
    XCTAssertEqualObjects(variation.variationKey, kExperimentNoAudienceVariationKey, @"Should be the forced varation %@ .", kExperimentNoAudienceVariationKey);
}

// whitelisted user should return the whitelisted variation for getVariation after setForcedVariation is cleared
- (void)testGetVariationWithWhitelistedVariationAfterClearingSetForcedVariation
{
    // Set a forced variation
    [self.optimizely setForcedVariation:kWhitelistedExperiment_test_data_10_experiments
                                 userId:kWhitelistedUserId_test_data_10_experiments
                           variationKey:kExperimentNoAudienceVariationKey];
    OPTLYExperiment *experimentWhitelisted = [self.config getExperimentForKey:kWhitelistedExperiment_test_data_10_experiments];
    OPTLYVariation *variation = [self.decisionService getVariation:kWhitelistedUserId_test_data_10_experiments
                                                        experiment:experimentWhitelisted
                                                        attributes:nil];
    XCTAssertFalse([variation.variationKey isEqualToString:kWhitelistedVariation_test_data_10_experiments], @"Get variation on a whitelisted variation should be overridden by setForcedVariation");
    XCTAssertEqualObjects(variation.variationKey, kExperimentNoAudienceVariationKey, @"Should be the forced varation %@ .", kExperimentNoAudienceVariationKey);
    // Clear the forced variation
    [self.optimizely setForcedVariation:kWhitelistedExperiment_test_data_10_experiments
                                 userId:kWhitelistedUserId_test_data_10_experiments
                           variationKey:nil];
    // Confirm return to variation expected in absence of a forced variation.
    variation = [self.decisionService getVariation:kWhitelistedUserId_test_data_10_experiments
                                        experiment:experimentWhitelisted
                                        attributes:nil];
    XCTAssert([variation.variationKey isEqualToString:kWhitelistedVariation_test_data_10_experiments], @"Get variation on a whitelisted variation should return: %@, but instead returns: %@.", kWhitelistedVariation_test_data_10_experiments, variation.variationKey);
}

// whitelisted user should return the whitelisted variation for getVariation overridden by call to setForcedVariation twice
- (void)testGetVariationWithWhitelistedVariationOverriddenBySetForcedVariationTwice
{
    // First call to setForcedVariation:userId:variationKey:
    [self.optimizely setForcedVariation:kWhitelistedExperiment_test_data_10_experiments
                                 userId:kWhitelistedUserId_test_data_10_experiments
                           variationKey:kExperimentNoAudienceVariationKey];
    OPTLYExperiment *experimentWhitelisted = [self.config getExperimentForKey:kWhitelistedExperiment_test_data_10_experiments];
    OPTLYVariation *variation = [self.decisionService getVariation:kWhitelistedUserId_test_data_10_experiments
                                                        experiment:experimentWhitelisted
                                                        attributes:nil];
    XCTAssertFalse([variation.variationKey isEqualToString:kWhitelistedVariation_test_data_10_experiments], @"Get variation on a whitelisted variation should be overridden by setForcedVariation");
    XCTAssertEqualObjects(variation.variationKey, kExperimentNoAudienceVariationKey, @"Should be the forced varation %@ .", kExperimentNoAudienceVariationKey);
    // Second call to setForcedVariation:userId:variationKey: to a different forced variation
    [self.optimizely setForcedVariation:kWhitelistedExperiment_test_data_10_experiments
                                 userId:kWhitelistedUserId_test_data_10_experiments
                           variationKey:kWhitelistedVariation_test_data_10_experiments];
    variation = [self.decisionService getVariation:kWhitelistedUserId_test_data_10_experiments
                                        experiment:experimentWhitelisted
                                        attributes:nil];
    XCTAssertFalse([variation.variationKey isEqualToString:kExperimentNoAudienceVariationKey], @"Variation should agree with second call to setForcedVariation");
    XCTAssertEqualObjects(variation.variationKey, kWhitelistedVariation_test_data_10_experiments, @"Should be the forced varation %@ .", kWhitelistedVariation_test_data_10_experiments);
}

// two different users experience two different setForcedVariation's in the same experiment differently
- (void)testGetVariationWithWhitelistedVariationOverriddenBySetForcedVariationForTwoDifferentUsers
{
    // First call to setForcedVariation:userId:variationKey:
    [self.optimizely setForcedVariation:kWhitelistedExperiment_test_data_10_experiments
                                 userId:kWhitelistedUserId
                           variationKey:kExperimentNoAudienceVariationKey];
    // Second call to setForcedVariation:userId:variationKey: to a different variation
    [self.optimizely setForcedVariation:kWhitelistedExperiment_test_data_10_experiments
                                 userId:kWhitelistedUserId_test_data_10_experiments
                           variationKey:kWhitelistedVariation_test_data_10_experiments];
    // Query variation's experienced by the two different users
    OPTLYExperiment *experimentWhitelisted = [self.config getExperimentForKey:kWhitelistedExperiment_test_data_10_experiments];
    OPTLYVariation *variation1 = [self.decisionService getVariation:kWhitelistedUserId
                                                        experiment:experimentWhitelisted
                                                        attributes:nil];
    OPTLYVariation *variation2 = [self.decisionService getVariation:kWhitelistedUserId_test_data_10_experiments
                                                         experiment:experimentWhitelisted
                                                         attributes:nil];
    // Confirm the two variations are different and they agree with predictions
    XCTAssertNotEqualObjects(variation1.variationKey,variation2.variationKey,@"Expecting two different forced variations for the two different users in this experiment");
    XCTAssertEqualObjects(variation1.variationKey,kExperimentNoAudienceVariationKey,@"Should have been variation predicted for the first user");
    XCTAssertEqualObjects(variation2.variationKey,kWhitelistedVariation_test_data_10_experiments,@"Should have been variation predicted for the second user");
}

// invalid audience should return nil for getVariation
- (void)testGetVariationWithInvalidAudience
{
    OPTLYExperiment *experimentWithAudience = [self.config getExperimentForKey:kExperimentWithAudienceKey];
    OPTLYVariation *variation = [self.decisionService getVariation:kUserId
                                                        experiment:experimentWithAudience
                                                        attributes:nil];
    XCTAssertNil(variation, @"Get variation with an invalid audience should return nil: %@", variation);
}

// invalid audience should return nil for getVariation overridden by call to setForcedVariation
- (void)testGetVariationWithInvalidAudienceOverriddenBySetForcedVariation
{
    [self.optimizely setForcedVariation:kExperimentWithAudienceKey
                                 userId:kUserId
                           variationKey:kExperimentNoAudienceVariationKey];
    OPTLYExperiment *experimentWithAudience = [self.config getExperimentForKey:kExperimentWithAudienceKey];
    OPTLYVariation *variation = [self.decisionService getVariation:kUserId
                                                        experiment:experimentWithAudience
                                                        attributes:nil];
    XCTAssertNotNil(variation, @"Get variation with an invalid audience  should be overridden by setForcedVariation");
    XCTAssertEqualObjects(variation.variationKey, kExperimentNoAudienceVariationKey, @"Should be the forced varation %@ .", kExperimentNoAudienceVariationKey);
}

// if the experiment is running and the user is not whitelisted,
// lookup should be called to get the stored variation
- (void)testGetVariationNoAudience
{
    id decisionServiceMock = OCMPartialMock(self.decisionService);
    id userProfileServiceMock = OCMPartialMock(self.config.userProfileService);
    
    NSDictionary *variationDict = @{ @"id" : kExperimentWithAudienceVariationId, @"key" : kExperimentWithAudienceVariationKey };
    OPTLYVariation *variation = [[OPTLYVariation alloc] initWithDictionary:variationDict error:nil];
    OPTLYExperiment *experiment = [self.config getExperimentForKey:kExperimentWithAudienceKey];

    [[[userProfileServiceMock stub] andReturn:self.userProfileWithFirefoxAudience] lookup:[OCMArg isNotNil]];
    
    OPTLYVariation *storedVariation = [decisionServiceMock getVariation:kUserId experiment:experiment attributes:self.attributes];
    
    OCMVerify([userProfileServiceMock lookup:[OCMArg isNotNil]]);
    
    XCTAssertNotNil(storedVariation, @"Stored variation should not be nil.");
    
    [decisionServiceMock stopMocking];
    [userProfileServiceMock stopMocking];
}

// for decision service saves, the user profile service save should be called with the expected user profile
- (void)testSaveVariation
{
    id decisionServiceMock = OCMPartialMock(self.decisionService);
    id userProfileServiceMock = OCMPartialMock(self.config.userProfileService);
    
    NSDictionary *variationDict = @{ OPTLYDatafileKeysVariationId  : kExperimentWithAudienceVariationId,
                                     OPTLYDatafileKeysVariationKey : kExperimentWithAudienceVariationKey };
    OPTLYVariation *variation = [[OPTLYVariation alloc] initWithDictionary:variationDict error:nil];
    
    OPTLYExperiment *experiment = [self.config getExperimentForKey:kExperimentWithAudienceKey];
    [self.decisionService saveUserProfile:nil variation:variation experiment:experiment userId:kUserId];
    
    OCMVerify([userProfileServiceMock save:self.userProfileWithFirefoxAudience]);
    
    [decisionServiceMock stopMocking];
    [userProfileServiceMock stopMocking];
}
    
// check the format of the user profile object when saving multiple experiment-to-variation bucket value for a single user
- (void)testSaveMultipleVariations
{
    id decisionServiceMock = OCMPartialMock(self.decisionService);
    id userProfileServiceMock = OCMPartialMock(self.config.userProfileService);
    
    OPTLYUserProfile *userProfileMultipleExperimentValues = @{ OPTLYDatafileKeysUserProfileServiceUserId : kUserId,
                                                               OPTLYDatafileKeysUserProfileServiceExperimentBucketMap : @{
                                                                       kExperimentWithAudienceId : @{ OPTLYDatafileKeysUserProfileServiceVariationId : kExperimentWithAudienceVariationId },
                                                                       kExperimentNoAudienceId : @{ OPTLYDatafileKeysUserProfileServiceVariationId : kExperimentNoAudienceVariationId } } };
    
    NSDictionary *variationWithAudienceDict = @{ OPTLYDatafileKeysVariationId  : kExperimentWithAudienceVariationId,
                                                 OPTLYDatafileKeysVariationKey : kExperimentWithAudienceVariationKey };
    OPTLYVariation *variationWithAudience = [[OPTLYVariation alloc] initWithDictionary:variationWithAudienceDict error:nil];
    OPTLYExperiment *experimentWithAudience = [self.config getExperimentForKey:kExperimentWithAudienceKey];
    [self.decisionService saveUserProfile:nil variation:variationWithAudience experiment:experimentWithAudience userId:kUserId];
    
    NSDictionary *variationNoAudienceDict = @{ OPTLYDatafileKeysVariationId  : kExperimentNoAudienceVariationId,
                                               OPTLYDatafileKeysVariationKey : kExperimentNoAudienceVariationKey };
    OPTLYVariation *variationNoAudience = [[OPTLYVariation alloc] initWithDictionary:variationNoAudienceDict error:nil];
    OPTLYExperiment *experimentNoAudience = [self.config getExperimentForKey:kExperimentNoAudienceKey];
    [self.decisionService saveUserProfile:self.userProfileWithFirefoxAudience variation:variationNoAudience experiment:experimentNoAudience userId:kUserId];
    
    // make sure that the user profile service save is called on a user profile object with the expected values
    OCMVerify([userProfileServiceMock save:userProfileMultipleExperimentValues]);
    
    [decisionServiceMock stopMocking];
    [userProfileServiceMock stopMocking];
}
@end
