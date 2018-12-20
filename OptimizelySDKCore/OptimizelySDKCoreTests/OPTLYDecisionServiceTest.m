/****************************************************************************
 * Copyright 2017-2018, Optimizely, Inc. and contributors                   *
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
#import "OPTLYFeatureFlag.h"
#import "OPTLYRollout.h"
#import "OPTLYFeatureDecision.h"
#import "OPTLYControlAttributes.h"
#import "OPTLYLogger.h"

static NSString * const kDatafileName = @"test_data_10_experiments";
static NSString * const ktypeAudienceDatafileName = @"typed_audience_datafile";
static NSString * const kUserId = @"6369992312";
static NSString * const kUserNotInExperimentId = @"6358043286";

// whitelisting test constants
static NSString * const kWhitelistingTestDatafileName = @"optimizely_7519590183";
static NSString * const kWhitelistedUserId = @"whitelisted_user";
static NSString * const kWhitelistedExperiment = @"whitelist_testing_experiment";
static NSString * const kWhitelistedVariation = @"a";
// whitelisting test constants from "test_data_10_experiments.json"
static NSString * const kWhitelistedUserId_test_data_10_experiments = @"forced_variation_user";
static NSString * const kWhitelistedExperiment_test_data_10_experiments = @"testExperiment6";
static NSString * const kWhitelistedVariation_test_data_10_experiments = @"variation";

// events with experiment and audiences
static NSString * const kExperimentWithTypedAudienceKey = @"audience_combinations_experiment";
static NSString * const kExperimentWithTypedAudienceId = @"3988293898";

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
static NSString * const kAttributeValueChrome = @"chrome";
static NSString * const kAttributeKeyBrowserBuildNumberInt = @"browser_buildnumber";
static NSString * const kAttributeKeyBrowserVersionNumberInt = @"browser_version";
static NSString * const kAttributeKeyIsBetaVersionBool = @"browser_isbeta";

// experiment with no audience
static NSString * const kExperimentNoAudienceKey = @"testExperiment4";
static NSString * const kExperimentNoAudienceId = @"6358043286";
static NSString * const kExperimentNoAudienceVariationId = @"6373141147";
static NSString * const kExperimentNoAudienceVariationKey = @"control";

// experiment & feature flag with multiple variables
static NSString * const kExperimentMultiVariateKey = @"testExperimentMultivariate";
static NSString * const kExperimentMultiVariateVariationId = @"6373141147";
static NSString * const kFeatureFlagMultiVariateKey = @"multiVariateFeature";

// experiment & feature flag with mutex group
static NSString * const kExperimentMutexGroupKey = @"mutex_exp1";
static NSString * const kFeatureFlagMutexGroupKey = @"booleanFeature";

// feature flag with no experiment and rollout
static NSString * const kFeatureFlagEmptyKey = @"emptyFeature";

// feature flag with invalid experiment and rollout
static NSString * const kFeatureFlagInvalidGroupKey = @"invalidGroupIdFeature";
static NSString * const kFeatureFlagInvalidExperimentKey = @"invalidExperimentIdFeature";
static NSString * const kFeatureFlagInvalidRolloutKey = @"invalidRolloutIdFeature";

// feature flag with rollout id having no rule
static NSString * const kFeatureFlagEmptyRuleRolloutKey = @"stringSingleVariableFeature";

// feature flag with rollout id having no bucketed rule
static NSString * const kFeatureFlagNoBucketedRuleRolloutKey = @"booleanSingleVariableFeature";

@interface OPTLYDecisionServiceTest : XCTestCase
@property (nonatomic, strong) Optimizely *optimizely;
@property (nonatomic, strong) Optimizely *optimizelyTypedAudience;
@property (nonatomic, strong) OPTLYProjectConfig *config;
@property (nonatomic, strong) OPTLYDecisionService *decisionService;
@property (nonatomic, strong) OPTLYBucketer *bucketer;
@property (nonatomic, strong) OPTLYProjectConfig *typedAudienceConfig;
@property (nonatomic, strong) OPTLYDecisionService *typedAudienceDecisionService;
@property (nonatomic, strong) OPTLYBucketer *typedAudienceBucketer;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, strong) NSDictionary *userProfileWithFirefoxAudience;
@end

@interface OPTLYDecisionService()
- (BOOL)userPassesTargeting:(OPTLYProjectConfig *)config
              experiment:(OPTLYExperiment *)experiment
                     userId:(NSString *)userId
                 attributes:(NSDictionary *)attributes;
    
- (BOOL)isExperimentActive:(OPTLYProjectConfig *)config
             experimentKey:(NSString *)experimentKey;
    
- (void)saveUserProfile:(NSDictionary *)userProfileDict
              variation:(nonnull OPTLYVariation *)variation
             experiment:(nonnull OPTLYExperiment *)experiment
                 userId:(nonnull NSString *)userId;

- (BOOL)isUserInExperiment:(OPTLYProjectConfig *)config
                experiment:(OPTLYExperiment *)experiment
                attributes:(NSDictionary<NSString *, NSObject *> *)attributes;

- (BOOL)shouldEvaluateUsingAudienceConditions:(OPTLYExperiment *)experiment;

- (BOOL)evaluateAudienceConditionsForExperiment:(OPTLYExperiment *)experiment
                                         config:(OPTLYProjectConfig *)config
                                     attributes:(NSDictionary<NSString *, NSObject *> *)attributes;

- (BOOL)evaluateAudienceIdsForExperiment:(OPTLYExperiment *)experiment
                                  config:(OPTLYProjectConfig *)config
                              attributes:(NSDictionary<NSString *, NSObject *> *)attributes;

- (nullable NSNumber *)evaluateAudienceWithId:(NSString *)audienceId
                                       config:(OPTLYProjectConfig *)config
                                   attributes:(NSDictionary<NSString *, NSObject *> *)attributes;
@end

@implementation OPTLYDecisionServiceTest

#pragma mark - setUp and tearDown
    
- (void)setUp {
    [super setUp];
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatafileName];
    NSData *typedAudienceDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:ktypeAudienceDatafileName];

    id<OPTLYUserProfileService> profileService = [OPTLYUserProfileServiceNoOp new];

    self.optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.userProfileService = profileService;
    }]];
    self.optimizelyTypedAudience = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = typedAudienceDatafile;
        builder.logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelOff];;
    }]];
    
    self.config = self.optimizely.config;
    self.typedAudienceConfig = self.optimizelyTypedAudience.config;
    self.bucketer = [[OPTLYBucketer alloc] initWithConfig:self.config];
    self.typedAudienceBucketer = [[OPTLYBucketer alloc] initWithConfig:self.typedAudienceConfig];
    self.decisionService = [[OPTLYDecisionService alloc] initWithProjectConfig:self.config bucketer:self.bucketer];
    self.typedAudienceDecisionService = [[OPTLYDecisionService alloc] initWithProjectConfig:self.typedAudienceConfig bucketer:self.typedAudienceBucketer];
    self.attributes = @{ kAttributeKey : kAttributeValue };
    
    self.userProfileWithFirefoxAudience = @{ OPTLYDatafileKeysUserProfileServiceUserId : kUserId,
                      OPTLYDatafileKeysUserProfileServiceExperimentBucketMap : @{ kExperimentWithAudienceId : @{ OPTLYDatafileKeysUserProfileServiceVariationId : kExperimentWithAudienceVariationId } } };
}
    
- (void)tearDown {
    [super tearDown];
    self.config = nil;
    self.attributes = nil;
}

#pragma mark - Validate Preconditions
    
// experiment is running, user is in experiment
- (void)testValidatePreconditions
{
    OPTLYExperiment *experiment = [self.config getExperimentForKey:kExperimentWithAudienceKey];
    BOOL isValid = [self.decisionService userPassesTargeting:self.config
                                               experiment:experiment
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
    OPTLYExperiment *experiment = [self.config getExperimentForKey:kExperimentWithAudienceKey];
    BOOL isValid = [self.decisionService userPassesTargeting:self.config
                                               experiment:experiment
                                                      userId:kUserId
                                                  attributes:badAttributes];
    NSAssert(isValid == false, @"Experiment running with user in experiment, but with bad attributes should fail validation.");
}

- (void)testValidatePreconditionsAllowsWhiteListedUserToOverrideAudienceEvaluation {
    NSData *whitelistingDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kWhitelistingTestDatafileName];
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = whitelistingDatafile;
    }]];
    
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

- (void)testUserInExperimentWithEmptyAudienceIdAndConditions
{
    OPTLYExperiment *experiment = [self.typedAudienceConfig getExperimentForKey:kExperimentWithTypedAudienceKey];
    experiment.audienceIds = @[];
    experiment.audienceConditions = (NSArray<OPTLYCondition> *)@[];
    BOOL isValid = [self.typedAudienceDecisionService isUserInExperiment:self.typedAudienceConfig experiment:experiment attributes:self.attributes];
    
    XCTAssertTrue(isValid);
}

- (void)testUserInExperimentWithValidAudienceIdAndEmptyAudienceConditions
{
    OPTLYExperiment *experiment = [self.typedAudienceConfig getExperimentForKey:kExperimentWithTypedAudienceKey];
    experiment.audienceConditions = (NSArray<OPTLYCondition> *)@[];
    BOOL isValid = [self.typedAudienceDecisionService isUserInExperiment:self.typedAudienceConfig experiment:experiment attributes:self.attributes];
    XCTAssertTrue(isValid);
}

- (void)testUserInExperimentWithEmptyAudienceIdAndNilAudienceConditions
{
    OPTLYExperiment *experiment = [self.typedAudienceConfig getExperimentForKey:kExperimentWithTypedAudienceKey];
    experiment.audienceIds = @[];
    experiment.audienceConditions = nil;
    BOOL isValid = [self.typedAudienceDecisionService isUserInExperiment:self.typedAudienceConfig experiment:experiment attributes:self.attributes];
    XCTAssertTrue(isValid);
}

- (void)testIsUserInExperimentUsesNonNullAudienceConditionsWhenAudienceIdsAlsoAvailable
{
    OPTLYExperiment *experiment = [self.typedAudienceConfig getExperimentForKey:kExperimentWithTypedAudienceKey];
    XCTAssertTrue([self.typedAudienceDecisionService shouldEvaluateUsingAudienceConditions:experiment]);
}

- (void)testIsUserInExperimentUsesAudienceIdsWhenAudienceConditionsNull
{
    OPTLYExperiment *experiment = [self.typedAudienceConfig getExperimentForKey:kExperimentWithTypedAudienceKey];
    experiment.audienceConditions = nil;
    XCTAssertFalse([self.typedAudienceDecisionService shouldEvaluateUsingAudienceConditions:experiment]);
}

- (void)testIsUserInExperimentReturnsTrueWhenBothAudienceConditionsAndAudienceIdsNull
{
    OPTLYExperiment *experiment = [self.typedAudienceConfig getExperimentForKey:kExperimentWithTypedAudienceKey];
    experiment.audienceConditions = nil;
    experiment.audienceIds = @[];
    BOOL isValid = [self.typedAudienceDecisionService isUserInExperiment:self.typedAudienceConfig experiment:experiment attributes:self.attributes];
    XCTAssertTrue(isValid);
}

- (void)testIsUserInExperimentEvaluatesAudienceWhenAttributesEmpty
{
    OPTLYExperiment *experiment = [self.typedAudienceConfig getExperimentForKey:kExperimentWithTypedAudienceKey];
    id mock = [OCMockObject partialMockForObject:experiment];
    [[mock expect] evaluateConditionsWithAttributes:[OCMArg any] projectConfig:[OCMArg any]];
    [self.typedAudienceDecisionService isUserInExperiment:self.typedAudienceConfig experiment:experiment attributes:@{}];
    XCTAssertTrue([mock verify]);
    [mock stopMocking];
}

- (void)testIsUserInExperimentEvaluatesAudienceWhenAttributesEmptyAndAudienceConditionsNil
{
    OPTLYExperiment *experiment = [self.typedAudienceConfig getExperimentForKey:kExperimentWithTypedAudienceKey];
    experiment.audienceConditions = nil;
    OPTLYAudience *audience = [self.typedAudienceConfig getAudienceForId:experiment.audienceIds[0]];
    id mock = [OCMockObject partialMockForObject:audience];
    [[mock expect] evaluateConditionsWithAttributes:[OCMArg any] projectConfig:[OCMArg any]];
    [self.typedAudienceDecisionService isUserInExperiment:self.typedAudienceConfig experiment:experiment attributes:@{}];
    XCTAssertTrue([mock verify]);
    [mock stopMocking];
}

- (void)testIsUserInExperimentEvaluatesAudienceWhenAttributesNil
{
    OPTLYExperiment *experiment = [self.typedAudienceConfig getExperimentForKey:kExperimentWithTypedAudienceKey];
    id mock = [OCMockObject partialMockForObject:experiment];
    [[mock expect] evaluateConditionsWithAttributes:[OCMArg any] projectConfig:[OCMArg any]];
    [self.typedAudienceDecisionService isUserInExperiment:self.typedAudienceConfig experiment:experiment attributes:nil];
    XCTAssertTrue([mock verify]);
    [mock stopMocking];
}

- (void)testIsUserInExperimentEvaluatesAudienceWhenAttributesNilAndAudienceConditionsNil
{
    OPTLYExperiment *experiment = [self.typedAudienceConfig getExperimentForKey:kExperimentWithTypedAudienceKey];
    experiment.audienceConditions = nil;
    OPTLYAudience *audience = [self.typedAudienceConfig getAudienceForId:experiment.audienceIds[0]];
    id mock = [OCMockObject partialMockForObject:audience];
    [[mock expect] evaluateConditionsWithAttributes:[OCMArg any] projectConfig:[OCMArg any]];
    [self.typedAudienceDecisionService isUserInExperiment:self.typedAudienceConfig experiment:experiment attributes:nil];
    XCTAssertTrue([mock verify]);
    [mock stopMocking];
}

- (void)testIsUserInExperimentReturnsFalseWhenEvaluatorReturnsFalseOrNull
{
    OPTLYExperiment *experiment = [self.typedAudienceConfig getExperimentForKey:kExperimentWithTypedAudienceKey];
    id decisionServiceMock = OCMPartialMock(self.typedAudienceDecisionService);
    OCMStub([decisionServiceMock evaluateAudienceConditionsForExperiment:[OCMArg any] config:[OCMArg any] attributes:[OCMArg any]]).andReturn(false);
    BOOL isValid = [decisionServiceMock isUserInExperiment:self.typedAudienceConfig experiment:experiment attributes:self.attributes];
    XCTAssertFalse(isValid);
    [decisionServiceMock stopMocking];

    decisionServiceMock = OCMPartialMock(self.typedAudienceDecisionService);
    experiment.audienceConditions = nil;
    OCMStub([decisionServiceMock evaluateAudienceIdsForExperiment:[OCMArg any] config:[OCMArg any] attributes:[OCMArg any]]).andReturn(false);
    isValid = [decisionServiceMock isUserInExperiment:self.typedAudienceConfig experiment:experiment attributes:self.attributes];
    XCTAssertFalse(isValid);
    [decisionServiceMock stopMocking];
    
    decisionServiceMock = OCMPartialMock(self.typedAudienceDecisionService);
    OCMStub([decisionServiceMock evaluateAudienceWithId:[OCMArg any] config:[OCMArg any] attributes:[OCMArg any]]).andReturn(nil);
    isValid = [decisionServiceMock isUserInExperiment:self.typedAudienceConfig experiment:experiment attributes:self.attributes];
    XCTAssertFalse(isValid);
    [decisionServiceMock stopMocking];
}

- (void)testIsUserInExperimentReturnsTrueWhenEvaluatorReturnsTrue
{
    OPTLYExperiment *experiment = [self.typedAudienceConfig getExperimentForKey:kExperimentWithTypedAudienceKey];
    id decisionServiceMock = OCMPartialMock(self.typedAudienceDecisionService);
    OCMStub([decisionServiceMock evaluateAudienceConditionsForExperiment:[OCMArg any] config:[OCMArg any] attributes:[OCMArg any]]).andReturn(true);
    BOOL isValid = [decisionServiceMock isUserInExperiment:self.typedAudienceConfig experiment:experiment attributes:self.attributes];
    XCTAssertTrue(isValid);
    [decisionServiceMock stopMocking];
    
    decisionServiceMock = OCMPartialMock(self.typedAudienceDecisionService);
    experiment.audienceConditions = nil;
    OCMStub([decisionServiceMock evaluateAudienceIdsForExperiment:[OCMArg any] config:[OCMArg any] attributes:[OCMArg any]]).andReturn(true);
    isValid = [decisionServiceMock isUserInExperiment:self.typedAudienceConfig experiment:experiment attributes:self.attributes];
    XCTAssertTrue(isValid);
    [decisionServiceMock stopMocking];
}

#pragma mark - getVariation

// if the experiment is not running should return nil for getVariation
- (void)testGetVariationExperimentNotRunning
{
    OPTLYExperiment *experimentNotRunning = [self.config getExperimentForKey:kExperimentNotRunningKey];
    OPTLYVariation *variation = [self.decisionService getVariation:kUserId experiment:experimentNotRunning attributes:nil];
    XCTAssertNil(variation, @"Get variation on an experiment not running should return nil: %@", variation);
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

// whitelisted user having invalid whitelisted variation should return bucketed variation for getVariation
- (void)testGetVariationWithInvalidWhitelistedVariation {
    
    OPTLYExperiment *experimentWhitelisted = [self.config getExperimentForKey:@"testExperiment5"];
    OPTLYVariation *expectedVariation = experimentWhitelisted.variations[0];
    
    id bucketerMock = OCMPartialMock(self.bucketer);
    OCMStub([bucketerMock bucketExperiment:experimentWhitelisted
                           withBucketingId:kWhitelistedUserId_test_data_10_experiments]).andReturn(expectedVariation);
    
    self.decisionService = [[OPTLYDecisionService alloc] initWithProjectConfig:self.config
                                                                      bucketer:bucketerMock];

    OPTLYVariation *variation = [self.decisionService getVariation:kWhitelistedUserId_test_data_10_experiments
                                                        experiment:experimentWhitelisted
                                                        attributes:nil];
    XCTAssert([variation.variationKey isEqualToString:expectedVariation.variationKey], @"Get variation on an invalid whitelisted variation should return: %@, but instead returns: %@.", expectedVariation.variationKey, variation.variationKey);
    OCMVerify([bucketerMock bucketExperiment:experimentWhitelisted withBucketingId:kWhitelistedUserId_test_data_10_experiments]);
    [bucketerMock stopMocking];
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
    id userProfileServiceMock = OCMPartialMock((NSObject *)self.config.userProfileService);
    
    OPTLYExperiment *experiment = [self.config getExperimentForKey:kExperimentWithAudienceKey];

    [[[userProfileServiceMock stub] andReturn:self.userProfileWithFirefoxAudience] lookup:[OCMArg isNotNil]];
    
    OPTLYVariation *storedVariation = [decisionServiceMock getVariation:kUserId experiment:experiment attributes:self.attributes];
    
    OCMVerify([userProfileServiceMock lookup:[OCMArg isNotNil]]);
    
    XCTAssertNotNil(storedVariation, @"Stored variation should not be nil.");
    
    [decisionServiceMock stopMocking];
    [userProfileServiceMock stopMocking];
}

// if bucketingId attribute is not a string. Defaulted to userId
- (void)testGetVariationWithInvalidBucketingId {
    NSDictionary *attributes = @{OptimizelyBucketId: @YES};
    OPTLYExperiment *experiment = [self.config getExperimentForKey:kExperimentNoAudienceKey];
    OPTLYVariation *variation = [self.decisionService getVariation:kUserId experiment:experiment attributes:attributes];
    XCTAssertNotNil(variation, @"Get variation with invalid bucketing Id should use userId for bucketing.");
    XCTAssertEqualObjects(variation.variationKey, kExperimentWithAudienceVariationKey,
                   @"Get variation with invalid bucketing Id should return: %@, but instead returns: %@.",
                   kExperimentWithAudienceVariationKey, variation.variationKey);
}

- (void)testGetVariationAcceptAllTypeAttributes {
    
    OPTLYExperiment *experiment = [self.config getExperimentForKey:kExperimentNoAudienceKey];
    OPTLYVariation *variation = [self.decisionService getVariation:kUserId experiment:experiment attributes:@{kAttributeKey: kAttributeValue,
                                                                                                              kAttributeKeyBrowserBuildNumberInt: @(10), kAttributeKeyBrowserVersionNumberInt: @(0.23), kAttributeKeyIsBetaVersionBool: @(YES)}];

    XCTAssertNotNil(variation, @"Get variation with supported types should return valid variation.");
    XCTAssertEqualObjects(variation.variationKey, kExperimentWithAudienceVariationKey);
}

#pragma mark - setForcedVariation

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

- (void)testSetForcedVariationFollowedByGetForcedVariation
{
    // Call setForcedVariation:userId:variationKey:
    [self.optimizely setForcedVariation:kWhitelistedExperiment_test_data_10_experiments
                                 userId:kWhitelistedUserId_test_data_10_experiments
                           variationKey:kExperimentNoAudienceVariationKey];
    // Confirm getForcedVariation:userId: returns forced variation.
    OPTLYVariation *variation1 = [self.config getForcedVariation:kWhitelistedExperiment_test_data_10_experiments
                                                          userId:kWhitelistedUserId_test_data_10_experiments];
    XCTAssertFalse([variation1.variationKey isEqualToString:kWhitelistedVariation_test_data_10_experiments], @"Get variation on a whitelisted variation should be overridden by setForcedVariation");
    XCTAssertEqualObjects(variation1.variationKey, kExperimentNoAudienceVariationKey, @"Should be the forced varation %@ .", kExperimentNoAudienceVariationKey);
    // Confirm decisionService's getVariation:experiment:attributes: finds forced variation.
    OPTLYExperiment *experimentWhitelisted = [self.config getExperimentForKey:kWhitelistedExperiment_test_data_10_experiments];
    OPTLYVariation *variation2 = [self.decisionService getVariation:kWhitelistedUserId_test_data_10_experiments
                                                        experiment:experimentWhitelisted
                                                        attributes:nil];
    XCTAssertFalse([variation2.variationKey isEqualToString:kWhitelistedVariation_test_data_10_experiments], @"Get variation on a whitelisted variation should be overridden by setForcedVariation");
    XCTAssertEqualObjects(variation2.variationKey, kExperimentNoAudienceVariationKey, @"Should be the forced varation %@ .", kExperimentNoAudienceVariationKey);
    // The two answers should be the same.
    XCTAssertEqualObjects(variation1.variationKey, variation1.variationKey, @"Should be the same forced varation %@ .", kExperimentNoAudienceVariationKey);
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

#pragma mark - saveUserProfile

// for decision service saves, the user profile service save should be called with the expected user profile
- (void)testSaveVariation
{
    id decisionServiceMock = OCMPartialMock(self.decisionService);
    id userProfileServiceMock = OCMPartialMock((NSObject *)self.config.userProfileService);
    
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
    id userProfileServiceMock = OCMPartialMock((NSObject *)self.config.userProfileService);
    
    NSDictionary *userProfileMultipleExperimentValues = @{ OPTLYDatafileKeysUserProfileServiceUserId : kUserId,
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

#pragma mark - GetVariationForFeatureExperiment

// should return nil when the feature flag's experiment ids array is empty
- (void)testGetVariationForFeatureWithNoExperimentId {
    OPTLYFeatureFlag *emptyFeatureFlag = [self.config getFeatureFlagForKey:kFeatureFlagEmptyKey];
    OPTLYFeatureDecision *decision = [self.decisionService getVariationForFeature:emptyFeatureFlag userId:kUserId attributes:nil];
    XCTAssertNil(decision, @"Get variation for feature with no experiment should return nil: %@", decision);
}

// should return nil when the feature flag's group id is invalid
- (void)testGetVariationForFeatureWithInvalidGroupId {
    OPTLYFeatureFlag *invalidFeatureFlag = [self.config getFeatureFlagForKey:kFeatureFlagInvalidGroupKey];
    OPTLYFeatureDecision *decision = [self.decisionService getVariationForFeature:invalidFeatureFlag userId:kUserId attributes:nil];
    XCTAssertNil(decision, @"Get variation for feature with invalid group should return nil: %@", decision);
}

// should return nil when the feature flag's experiment id is invalid
- (void)testGetVariationForFeatureWithInvalidExperimentId {
    OPTLYFeatureFlag *booleanFeatureFlag = [self.config getFeatureFlagForKey:kFeatureFlagInvalidExperimentKey];
    OPTLYFeatureDecision *decision = [self.decisionService getVariationForFeature:booleanFeatureFlag userId:kUserId attributes:nil];
    XCTAssertNil(decision, @"Get variation for feature with invalid experiment should return nil: %@", decision);
}

// should return nil when the user is not bucketed into the feature flag's experiments
- (void)testGetVariationForFeatureWithNonMutexGroupAndUserNotBucketed {
    
    OPTLYExperiment *multiVariateExp = [self.config getExperimentForKey:kExperimentMultiVariateKey];

    id decisionServiceMock = OCMPartialMock(self.decisionService);
    OCMStub([decisionServiceMock getVariation:kUserId experiment:multiVariateExp attributes:nil]).andReturn(nil);
    
    OPTLYFeatureFlag *multiVariateFeatureFlag = [self.config getFeatureFlagForKey:kFeatureFlagMultiVariateKey];
    
    OPTLYFeatureDecision *decision = [decisionServiceMock getVariationForFeature:multiVariateFeatureFlag userId:kUserId attributes:nil];
    XCTAssertNil(decision, @"Get variation for feature with no bucketed experiment should return nil: %@", decision);
    
    OCMVerify([decisionServiceMock getVariation:kUserId experiment:multiVariateExp attributes:nil]);
    [decisionServiceMock stopMocking];
}

// should return nil when the user is not bucketed into any of the mutex experiments
- (void)testGetVariationForFeatureWithMutexGroupAndUserNotBucketed {
    OPTLYExperiment *mutexExperiment = [self.config getExperimentForKey:kExperimentMutexGroupKey];
    
    id decisionServiceMock = OCMPartialMock(self.decisionService);
    OCMStub([decisionServiceMock getVariation:[OCMArg any] experiment:[OCMArg any] attributes:[OCMArg any]]).andReturn(nil);
    
    OPTLYFeatureFlag *booleanFeatureFlag = [self.config getFeatureFlagForKey:kFeatureFlagMutexGroupKey];
    OPTLYFeatureDecision *decision = [decisionServiceMock getVariationForFeature:booleanFeatureFlag userId:kUserId attributes:@{}];
    
    XCTAssertNil(decision, @"Get variation for feature with no bucketed mutex experiment should return nil: %@", decision);
    
    OCMVerify([decisionServiceMock getVariation:kUserId experiment:mutexExperiment attributes:@{}]);
    [decisionServiceMock stopMocking];
}

// should return variation when the user is bucketed into a variation for the experiment on the feature flag
- (void)testGetVariationForFeatureWithNonMutexGroupAndUserIsBucketed {
    
    OPTLYExperiment *multiVariateExp = [self.config getExperimentForKey:kExperimentMultiVariateKey];
    OPTLYVariation *expectedVariation = [multiVariateExp getVariationForVariationId:kExperimentMultiVariateVariationId];
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:multiVariateExp
                                                                                    variation:expectedVariation
                                                                                         source:DecisionSourceExperiment];
    
    id decisionServiceMock = OCMPartialMock(self.decisionService);
    OCMStub([decisionServiceMock getVariation:kUserId experiment:multiVariateExp attributes:@{}]).andReturn(expectedVariation);
    
    OPTLYFeatureFlag *multiVariateFeatureFlag = [self.config getFeatureFlagForKey:kFeatureFlagMultiVariateKey];
    OPTLYFeatureDecision *decision = [decisionServiceMock getVariationForFeature:multiVariateFeatureFlag userId:kUserId attributes:@{}];
    
    XCTAssertNotNil(decision, @"Get variation for feature with bucketed experiment should return variation: %@", decision);
    XCTAssertEqualObjects(decision.variation, expectedDecision.variation);
    
    OCMVerify([decisionServiceMock getVariation:kUserId experiment:multiVariateExp attributes:@{}]);
    [decisionServiceMock stopMocking];
}

// should return variation when the user is bucketed into one of the experiments on the feature flag
- (void)testGetVariationForFeatureWithMutexGroupAndUserIsBucketed {
    OPTLYExperiment *mutexExperiment = [self.config getExperimentForKey:kExperimentMutexGroupKey];
    OPTLYVariation *expectedVariation = mutexExperiment.variations[0];
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:mutexExperiment
                                                                                    variation:expectedVariation
                                                                                         source:DecisionSourceExperiment];
    id decisionServiceMock = OCMPartialMock(self.decisionService);
    OCMStub([decisionServiceMock getVariation:kUserId experiment:mutexExperiment attributes:@{}]).andReturn(expectedVariation);

    OPTLYFeatureFlag *booleanFeatureFlag = [self.config getFeatureFlagForKey:kFeatureFlagMutexGroupKey];
    OPTLYFeatureDecision *decision = [decisionServiceMock getVariationForFeature:booleanFeatureFlag userId:kUserId attributes:@{}];
    
    XCTAssertNotNil(decision, @"Get variation for feature with one of the bucketed experiment should return variation: %@", decision);
    XCTAssertEqualObjects(decision.variation, expectedDecision.variation);
    
    OCMVerify([decisionServiceMock getVariation:kUserId experiment:mutexExperiment attributes:@{}]);
    [decisionServiceMock stopMocking];
}

#pragma mark - GetVariationForFeatureRollout

// should return nil when rollout doesn't exist for the feature.
- (void)testGetVariationForFeatureWithInvalidRolloutId {
    OPTLYFeatureFlag *booleanFeatureFlag = [self.config getFeatureFlagForKey:kFeatureFlagInvalidRolloutKey];
    OPTLYFeatureDecision *decision = [self.decisionService getVariationForFeature:booleanFeatureFlag userId:kUserId attributes:nil];
    XCTAssertNil(decision, @"Get variation for feature with invalid rollout should return nil: %@", decision);
}

// should return nil when rollout doesn't contain any rule.
- (void)testGetVariationForFeatureWithNoRule {
    OPTLYFeatureFlag *stringFeatureFlag = [self.config getFeatureFlagForKey:kFeatureFlagEmptyRuleRolloutKey];
    NSDictionary *userAttributes = @{ kAttributeKey: kAttributeValueChrome };
    
    OPTLYFeatureDecision *decision = [self.decisionService getVariationForFeature:stringFeatureFlag userId:kUserId attributes:userAttributes];
    
    XCTAssertNil(decision, @"Get variation for feature with rollout having no rule should return nil: %@", decision);
}

// should return nil when the user is not bucketed into targeting rule as well as "Fall Back" rule.
- (void)testGetVariationForFeatureWithNoBucketing {
    OPTLYFeatureFlag *booleanFeatureFlag = [self.config getFeatureFlagForKey:kFeatureFlagNoBucketedRuleRolloutKey];
    NSString *rolloutId = booleanFeatureFlag.rolloutId;
    OPTLYRollout *rollout = [self.config getRolloutForId:rolloutId];
    OPTLYExperiment *experiment = rollout.experiments[0];
    OPTLYExperiment *fallBackRule = rollout.experiments[rollout.experiments.count - 1];
    NSDictionary *userAttributes = @{ kAttributeKey: kAttributeValueChrome };
    
    id bucketerMock = OCMPartialMock(self.bucketer);
    OCMStub([bucketerMock bucketExperiment:[OCMArg any] withBucketingId:[OCMArg any]]).andReturn(nil);
    OPTLYDecisionService *decisionService = [[OPTLYDecisionService alloc] initWithProjectConfig:self.config bucketer:bucketerMock];
    
    OPTLYFeatureDecision *decision = [decisionService getVariationForFeature:booleanFeatureFlag userId:kUserId attributes:userAttributes];
    
    XCTAssertNil(decision, @"Get variation for feature with rollout having no bucketing rule should return nil: %@", decision);
    
    OCMVerify([bucketerMock bucketExperiment:experiment withBucketingId:kUserId]);
    OCMVerify([bucketerMock bucketExperiment:fallBackRule withBucketingId:kUserId]);
    [bucketerMock stopMocking];
}

// should return variation when the user is bucketed into targeting rule
- (void)testGetVariationForFeatureWithTargetingRuleBucketing {
    
    OPTLYFeatureFlag *booleanFeatureFlag = [self.config getFeatureFlagForKey:kFeatureFlagNoBucketedRuleRolloutKey];
    NSString *rolloutId = booleanFeatureFlag.rolloutId;
    OPTLYRollout *rollout = [self.config getRolloutForId:rolloutId];
    OPTLYExperiment *experiment = rollout.experiments[0];
    OPTLYVariation *expectedVariation = experiment.variations[0];
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment
                                                                                    variation:expectedVariation
                                                                                         source:DecisionSourceRollout];
    NSDictionary *userAttributes = @{ kAttributeKey: kAttributeValueChrome };
    
    id bucketerMock = OCMPartialMock(self.bucketer);
    OCMStub([bucketerMock bucketExperiment:[OCMArg any] withBucketingId:[OCMArg any]]).andReturn(expectedVariation);
    OPTLYDecisionService *decisionService = [[OPTLYDecisionService alloc] initWithProjectConfig:self.config bucketer:bucketerMock];
    
    OPTLYFeatureDecision *decision = [decisionService getVariationForFeature:booleanFeatureFlag userId:kUserId attributes:userAttributes];

    XCTAssertNotNil(decision, @"Get variation for feature with rollout having targeting rule should return variation: %@", decision);
    XCTAssertEqualObjects(decision.variation, expectedDecision.variation);
    
    OCMVerify([bucketerMock bucketExperiment:experiment withBucketingId:kUserId]);
    [bucketerMock stopMocking];
}

// should return variation when the user is bucketed into "Fall Back" rule instead of targeting rule
- (void)testGetVariationForFeatureWithFallBackRuleBucketing {
    OPTLYFeatureFlag *booleanFeatureFlag = [self.config getFeatureFlagForKey:kFeatureFlagNoBucketedRuleRolloutKey];
    NSString *rolloutId = booleanFeatureFlag.rolloutId;
    OPTLYRollout *rollout = [self.config getRolloutForId:rolloutId];
    OPTLYExperiment *experiment = rollout.experiments[0];
    OPTLYExperiment *fallBackRule = rollout.experiments[rollout.experiments.count - 1];
    OPTLYVariation *expectedVariation = fallBackRule.variations[0];
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:fallBackRule
                                                                                    variation:expectedVariation
                                                                                         source:DecisionSourceRollout];
    NSDictionary *userAttributes = @{ kAttributeKey: kAttributeValueChrome };
    
    id bucketerMock = OCMPartialMock(self.bucketer);
    OCMStub([bucketerMock bucketExperiment:experiment withBucketingId:[OCMArg any]]).andReturn(nil);
    OCMStub([bucketerMock bucketExperiment:fallBackRule withBucketingId:kAttributeValueChrome]).andReturn(expectedVariation);
    OPTLYDecisionService *decisionService = [[OPTLYDecisionService alloc] initWithProjectConfig:self.config bucketer:bucketerMock];

    OPTLYFeatureDecision *decision = [decisionService getVariationForFeature:booleanFeatureFlag userId:kUserId attributes:userAttributes];
    
    XCTAssertNotNil(decision, @"Get variation for feature with rollout having fall back rule should return variation: %@", decision);
    XCTAssertEqualObjects(decision.variation, expectedDecision.variation);
    
    OCMVerify([bucketerMock bucketExperiment:experiment withBucketingId:kUserId]);
    OCMVerify([bucketerMock bucketExperiment:fallBackRule withBucketingId:kUserId]);
    [bucketerMock stopMocking];
}

// should return variation when the user is bucketed into "Fall Back" after attempting to bucket into all targeting rules
- (void)testGetVariationForFeatureWithFallBackRuleBucketingButNoTargetingRule {
    OPTLYFeatureFlag *booleanFeatureFlag = [self.config getFeatureFlagForKey:kFeatureFlagNoBucketedRuleRolloutKey];
    NSString *rolloutId = booleanFeatureFlag.rolloutId;
    OPTLYRollout *rollout = [self.config getRolloutForId:rolloutId];
    OPTLYExperiment *fallBackRule = rollout.experiments[rollout.experiments.count - 1];
    OPTLYVariation *expectedVariation = fallBackRule.variations[0];
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:fallBackRule
                                                                                    variation:expectedVariation
                                                                                         source:DecisionSourceRollout];
    
    id bucketerMock = OCMPartialMock(self.bucketer);
    OCMStub([bucketerMock bucketExperiment:fallBackRule withBucketingId:[OCMArg any]]).andReturn(expectedVariation);
    OPTLYDecisionService *decisionService = [[OPTLYDecisionService alloc] initWithProjectConfig:self.config bucketer:bucketerMock];
    
    // Provide null attributes so that user does not qualify for audience.
    OPTLYFeatureDecision *decision = [decisionService getVariationForFeature:booleanFeatureFlag userId:kUserId attributes:nil];
    
    XCTAssertNotNil(decision, @"Get variation for feature with rollout having fall back rule after failing all targeting rules should return variation: %@", decision);
    XCTAssertEqualObjects(decision.variation, expectedDecision.variation);
    
    OCMVerify([bucketerMock bucketExperiment:fallBackRule withBucketingId:kUserId]);
    [bucketerMock stopMocking];
}

- (void)testGetVariationForFeatureWithFallBackRuleBucketingId {
    OPTLYFeatureFlag *featureFlag = [self.config getFeatureFlagForKey:kFeatureFlagNoBucketedRuleRolloutKey];
    OPTLYRollout *rollout = [self.config getRolloutForId:featureFlag.rolloutId];
    OPTLYExperiment *rolloutRuleExperiment = rollout.experiments[rollout.experiments.count - 1];
    OPTLYVariation *rolloutVariation = rolloutRuleExperiment.variations[0];
    NSString *bucketingId = @"user_bucketing_id";
    NSString *userId = @"user_id";
    NSDictionary *attributes = @{OptimizelyBucketId: bucketingId};
    
    id bucketerMock = OCMPartialMock(self.bucketer);
    OCMStub([bucketerMock bucketExperiment:rolloutRuleExperiment withBucketingId:userId]).andReturn(nil);
    OCMStub([bucketerMock bucketExperiment:rolloutRuleExperiment withBucketingId:bucketingId]).andReturn(rolloutVariation);
    
    OPTLYDecisionService *decisionService = [[OPTLYDecisionService alloc] initWithProjectConfig:self.config
                                                                                       bucketer:bucketerMock];
    
    OPTLYFeatureDecision *expectedFeatureDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:rolloutRuleExperiment
                                                                                           variation:rolloutVariation
                                                                                              source:DecisionSourceRollout];
    
    OPTLYFeatureDecision *featureDecision = [decisionService getVariationForFeature:featureFlag userId:userId attributes:attributes];
    
    XCTAssertEqualObjects(expectedFeatureDecision.experiment, featureDecision.experiment);
    XCTAssertEqualObjects(expectedFeatureDecision.variation, featureDecision.variation);
    XCTAssertEqualObjects(expectedFeatureDecision.source, featureDecision.source);
}

@end
