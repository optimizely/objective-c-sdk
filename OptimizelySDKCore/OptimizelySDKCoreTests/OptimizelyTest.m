/****************************************************************************
 * Copyright 2016-2017, Optimizely, Inc. and contributors                   *
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
#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "Optimizely.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYExperiment.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYTestHelper.h"
#import "OPTLYVariation.h"
#import "OPTLYFeatureFlag.h"
#import "OPTLYDecisionService.h"
#import "OPTLYRollout.h"
#import "OPTLYFeatureDecision.h"
#import "OPTLYFeatureVariable.h"
#import "OPTLYNotificationCenter.h"

static NSString *const kUserId = @"userId";
static NSString *const kExperimentKey = @"testExperimentWithFirefoxAudience";
static NSString *const kEventNameWithMultipleExperiments = @"testEventWithMultipleExperiments";

// datafiles
static NSString *const kBucketerTestDatafileName = @"BucketerTestsDatafile";

// user IDs
static NSString * const kUserIdForWhitelisting = @"userId";

// experiment Keys
static NSString * const kExperimentKeyForWhitelisting = @"whiteListExperiment";

// variation Keys
static NSString * const kVariationKeyForWhitelisting = @"whiteListedVariation";

// variation IDs
static NSString * const kVariationIDForWhitelisting = @"variation4";


@interface Optimizely(test)
- (OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId
                  attributes:(NSDictionary<NSString *,NSString *> *)attributes
                    callback:(void (^)(NSError *))callback;
- (OPTLYVariation *)sendImpressionEventFor:(OPTLYExperiment *)experiment
                                 variation:(OPTLYVariation *)variation
                                    userId:(NSString *)userId
                                attributes:(NSDictionary<NSString *,NSString *> *)attributes
                                  callback:(void (^)(NSError *))callback;
- (NSString *)getFeatureVariableValueForType:(NSString *)variableType
                                  featureKey:(nullable NSString *)featureKey
                                 variableKey:(nullable NSString *)variableKey
                                      userId:(nullable NSString *)userId
                                  attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;
@end

@interface OptimizelyTest : XCTestCase

@property (nonatomic, strong) NSData *datafile;
@property (nonatomic, strong) Optimizely *optimizely;
@property (nonatomic, strong) NSDictionary *attributes;

@end

@implementation OptimizelyTest

- (void)setUp {
    [super setUp];
    self.datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:@"test_data_10_experiments"];
    
    self.optimizely = [Optimizely init:^(OPTLYBuilder *builder) {
        builder.datafile = self.datafile;
        builder.logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelOff];;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }];
    
    XCTAssertNotNil(self.optimizely);
    
    self.attributes = @{@"browser_type": @"firefox"};
}

- (void)tearDown {
    [super tearDown];
    self.datafile = nil;
    self.optimizely = nil;
    [OHHTTPStubs removeAllStubs];
}

#pragma mark - Get Variation Tests

- (void)testBasicGetVariation {
    NSString *experimentKey = @"testExperiment1";
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:experimentKey];
    
    XCTAssertNotNil(experiment);
    OPTLYVariation *variation;
    
    // test just experiment key
    variation = [self.optimizely variation:experimentKey userId:kUserId];
    XCTAssertNotNil(variation);
    XCTAssertTrue([variation.variationKey isEqualToString:@"control"]);
    XCTAssertTrue([variation.variationId isEqualToString:@"6384330451"]);
    
    // test with bad experiment key
    variation = [self.optimizely variation:@"bad" userId:kUserId];
    XCTAssertNil(variation);
    
}

- (void)testVariationWithAudience {
    NSString *experimentKey = @"testExperimentWithFirefoxAudience";
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:experimentKey];
    XCTAssertNotNil(experiment);
    OPTLYVariation *variation;
    NSDictionary *attributesWithUserNotInAudience = @{@"browser_type" : @"chrome"};
    NSDictionary *attributesWithUserInAudience = @{@"browser_type" : @"firefox"};
    
    // test get experiment without attributes
    variation = [self.optimizely variation:experimentKey userId:kUserId];
    XCTAssertNil(variation);
    // test get experiment with bad attributes
    variation = [self.optimizely variation:experimentKey
                                    userId:kUserId
                                attributes:attributesWithUserNotInAudience];
    XCTAssertNil(variation);
    // test get experiment with good attributes
    variation = [self.optimizely variation:experimentKey
                                    userId:kUserId
                                attributes:attributesWithUserInAudience];
    XCTAssertNotNil(variation);
}

// Test whitelisting works with get variation
- (void)testVariationWhitelisting {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kBucketerTestDatafileName];
    
    Optimizely *optimizely = [Optimizely init:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
    }];
    XCTAssertNotNil(optimizely);
    
    // get variation
    OPTLYVariation *variation = [optimizely variation:kExperimentKeyForWhitelisting userId:kUserIdForWhitelisting];
    XCTAssertNotNil(variation);
    XCTAssertEqualObjects(variation.variationId, kVariationIDForWhitelisting);
    XCTAssertEqualObjects(variation.variationKey, kVariationKeyForWhitelisting);
}

# pragma mark - Integration Tests

- (void)testOptimizelyActivateWithInvalidExperiment {
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    NSString *invalidExperimentKey = @"invalid";
    OPTLYVariation *expectedVariation = [self.optimizely variation:kExperimentKey userId:kUserId attributes:self.attributes];
    
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OCMStub([optimizelyMock variation:invalidExperimentKey userId:kUserId attributes:self.attributes]).andReturn(expectedVariation);
    
    OPTLYVariation *variation = [optimizelyMock activate:invalidExperimentKey userId:kUserId attributes:self.attributes callback:^(NSError *error) {
        XCTAssertNotNil(error);
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationFailure, kUserId, invalidExperimentKey];
        XCTAssertEqualObjects(error.userInfo[NSLocalizedDescriptionKey], logMessage);
        [expectation fulfill];
    }];
    
    XCTAssertNil(variation, @"activate an invalid experiment should return nil: %@", variation);
    
    OCMVerify([optimizelyMock variation:invalidExperimentKey userId:kUserId attributes:self.attributes]);
    [optimizelyMock stopMocking];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testOptimizelyActivateWithNonTargetingAudience {
    
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    OPTLYVariation *variation = [self.optimizely activate:kExperimentKey
                                                   userId:kUserId
                                               attributes:nil callback:^(NSError *error) {
                                                   XCTAssertNotNil(error);
                                                   NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationFailure, kUserId, kExperimentKey];
                                                   XCTAssertEqualObjects(error.userInfo[NSLocalizedDescriptionKey], logMessage);
                                                   [expectation fulfill];
                                               }];
    XCTAssertNil(variation);
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testOptimizelyPostsActivateExperimentNotification {
    
    OPTLYExperiment *_experiment = [self.optimizely.config getExperimentForKey:kExperimentKeyForWhitelisting];
    OPTLYVariation *_variation = [self.optimizely variation:kExperimentKeyForWhitelisting userId:kUserId attributes:self.attributes];
    NSDictionary *_attributes = [NSDictionary new];
    
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getExperimentActivatedNotification"];
    [self.optimizely.notificationCenter addNotification:OPTLYNotificationTypeActivate activateListener:^(OPTLYExperiment *experiment, NSString *userId, NSDictionary<NSString *,NSString *> *attributes, OPTLYVariation *variation, NSDictionary<NSString *,NSString *> *event) {
        XCTAssertEqual(experiment, _experiment);
        XCTAssertEqual(userId, kUserId);
        XCTAssertEqual(attributes, _attributes);
        XCTAssertEqual(variation, _variation);
        [expectation fulfill];
    }];
    
    OPTLYVariation *variation = [self.optimizely activate:kExperimentKeyForWhitelisting
                                                   userId:kUserId];
    XCTAssertNotNil(variation);
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testOptimizelyTrackWithInvalidEvent {
    
    NSString *invalidEventKey = @"invalid";
    
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizely.logger);
    Optimizely *optimizely = [Optimizely init:^(OPTLYBuilder *builder) {
        builder.datafile = self.datafile;
        builder.logger = loggerMock;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }];
    [optimizely track:invalidEventKey userId:kUserId attributes:self.attributes];
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventNotTracked, invalidEventKey, kUserId];
    OCMVerify([loggerMock logMessage:logMessage withLevel:OptimizelyLogLevelError]);
    [loggerMock stopMocking];
}

- (void)testOptimizelyTrackWithEventOfNoExperiment {
    NSString *eventWithNoExerimentKey = @"testEventWithoutExperiments";
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizely.logger);
    Optimizely *optimizely = [Optimizely init:^(OPTLYBuilder *builder) {
        builder.datafile = self.datafile;
        builder.logger = loggerMock;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }];
    [optimizely track:eventWithNoExerimentKey userId:kUserId attributes:self.attributes];
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventNotTracked, eventWithNoExerimentKey, kUserId];
    OCMVerify([loggerMock logMessage:logMessage withLevel:OptimizelyLogLevelError]);
    [loggerMock stopMocking];
}

- (void)testOptimizelyPostsEventTrackedNotification {
    
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getExperimentActivatedNotification"];
    
    NSDictionary *_attributes = [NSDictionary new];
    
    [self.optimizely.notificationCenter addNotification:OPTLYNotificationTypeTrack trackListener:^(NSString *eventKey, NSString *userId, NSDictionary<NSString *,NSString *> *attributes, NSDictionary *eventTags, NSDictionary<NSString *,NSString *> *event) {
        XCTAssertEqual(eventKey, kEventNameWithMultipleExperiments);
        XCTAssertEqual(userId, kUserId);
        XCTAssertEqual(attributes, _attributes);
        [expectation fulfill];
    }];
    
    [self.optimizely track:kEventNameWithMultipleExperiments userId:kUserId];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

# pragma mark - IsFeatureEnabled Tests

// Should return false when arguments are nil or empty.
- (void)testIsFeatureEnabledWithEmptyOrNilArguments {
    NSString *featureFlagKey = @"featureKey";
    
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:nil attributes:nil], @"should return false for missing userId");
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:@"" attributes:nil], @"should return false for missing userId");
    
    XCTAssertFalse([self.optimizely isFeatureEnabled:nil userId:kUserId attributes:nil], @"should return false for missing featureKey");
    XCTAssertFalse([self.optimizely isFeatureEnabled:@"" userId:kUserId attributes:nil], @"should return false for missing featureKey");
}

// Should return false when feature flag key is invalid.
- (void)testIsFeatureEnabledWithInvalidFeatureFlagKey {
    NSString *featureFlagKey = @"featureNotFound";
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return false for invalid featureFlagKey");
}

// Should return false when feature flag does not belongs to an experiment.
- (void)testIsFeatureEnabledWithFeatureFlagContainsInvalidExperiment {
    NSString *featureFlagKey = @"invalidExperimentIdFeature";
    // Should return false when the experiment in feature flag does not get found in the datafile.
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return false for featureFlag does not belongs to experiment");
}

// Should return false when feature flag is not valid for non mutex group experiments.
- (void)testIsFeatureEnabledWithFeatureFlagContainsNonMutexGroupExperiments {
    NSString *featureFlagKey = @"multipleExperimentIdsFeature";
    // Should return false when experiments in feature flag does not belongs to same group.
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return false when experiments in feature flag does not belongs to same group");
}

// Should return true when feature flag is valid for mutex group experiments.
- (void)testIsFeatureEnabledWithFeatureFlagContainsMutexGroupExperiments {
    NSString *featureFlagKey = @"booleanFeature";
    // Should return true when experiments in feature flag does belongs to same group.
    XCTAssertTrue([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return true when experiments in feature flag does belongs to same group");
}

// Should return false when feature is not enabled for the user.
- (void)testIsFeatureEnabledWithFeatureFlagNotEnabled {
    NSString *featureFlagKey = @"multiVariateFeature";
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(nil);
    
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return false for featureFlag not enabled");
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    [decisionServiceMock stopMocking];
    
}

// Should return true but does not send an impression event when feature is enabled for the user
// but user does not get experimented.
- (void)testIsFeatureEnabledWithFeatureFlagEnabledAndUserIsNotBeingExperimented {
    NSString *featureFlagKey = @"booleanSingleVariableFeature";
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments[0];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSourceRollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    // SendImpressionEvent() does not get called.
    OCMReject([optimizelyMock sendImpressionEventFor:decision.experiment variation:decision.variation userId:kUserId attributes:nil callback:nil]);
    
    XCTAssertTrue([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return true for enabled featureFlag");
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    [decisionServiceMock stopMocking];
}

// Should return true and send an impression event when feature is enabled for the user
// and user is being experimented.
- (void)testIsFeatureEnabledWithFeatureFlagEnabledAndUserIsBeingExperimented {
    NSString *featureFlagKey = @"multiVariateFeature";
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:@"testExperimentMultivariate"];
    OPTLYVariation *variation = [experiment getVariationForVariationId:@"6358043287"];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSourceExperiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertTrue([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return true for enabled featureFlag");
    
    // SendImpressionEvent() does not get called.
    OCMVerify([optimizelyMock sendImpressionEventFor:decision.experiment variation:decision.variation userId:kUserId attributes:nil callback:nil]);
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    [decisionServiceMock stopMocking];
}

#pragma mark - GetFeatureVariable<Type> Tests

- (void)testGetFeatureVariableBooleanWithTrue {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyTrue = @"varTrue";
    NSString *featureVariableType = FeatureVariableTypeBoolean;
    
    // expectations
    NSString *expectedValueString = @"true";
    BOOL expectedValue = true;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyTrue expectedReturn:expectedValueString];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableBoolean:featureKey variableKey:variableKeyTrue userId:kUserId attributes:nil],
                   @"should return %@ for feature variable value %@", expectedValue ? @"true" : @"false", expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyTrue
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableBooleanWithFalse {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyFalse = @"varFalse";
    NSString *featureVariableType = FeatureVariableTypeBoolean;
    
    // expectations
    NSString *expectedValueString = @"false";
    BOOL expectedValue = false;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyFalse expectedReturn:expectedValueString];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableBoolean:featureKey variableKey:variableKeyFalse userId:kUserId attributes:nil],
                   @"should return %@ for feature variable value %@", expectedValue ? @"true" : @"false", expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyFalse
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableBooleanWithInvalidBoolean {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyNonBoolean = @"varNonBoolean";
    NSString *featureVariableType = FeatureVariableTypeBoolean;
    
    // expectations
    NSString *expectedValueString = @"nonBooleanValue";
    BOOL expectedValue = false;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyNonBoolean expectedReturn:expectedValueString];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableBoolean:featureKey variableKey:variableKeyNonBoolean userId:kUserId attributes:nil],
                   @"should return %@ for feature variable value %@", expectedValue ? @"true" : @"false", expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyNonBoolean
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableBooleanWithNil {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyNull = @"varNull";
    NSString *featureVariableType = FeatureVariableTypeBoolean;
    
    // expectations
    NSString *expectedValueString = @"nonBooleanValue";
    BOOL expectedValue = false;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyNull expectedReturn:expectedValueString];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableBoolean:featureKey variableKey:variableKeyNull userId:kUserId attributes:nil],
                   @"should return %@ for feature variable value %@", expectedValue ? @"true" : @"false", expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyNull
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableDoubleWithDouble {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyDouble = @"varDouble";
    NSString *featureVariableType = FeatureVariableTypeDouble;

    // expectations
    NSString *expectedValueString = @"100.54";
    double expectedValue = 100.54;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyDouble expectedReturn:expectedValueString];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableDouble:featureKey variableKey:variableKeyDouble userId:kUserId attributes:nil],
                   @"should return %f for feature variable value %@", expectedValue, expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyDouble
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableDoubleWithInt {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyInt = @"varInt";
    NSString *featureVariableType = FeatureVariableTypeDouble;

    NSString *expectedValueString = @"100";
    double expectedValue = 100;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyInt expectedReturn:expectedValueString];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableDouble:featureKey variableKey:variableKeyInt userId:kUserId attributes:nil],
                   @"should return %f for feature variable value %@", expectedValue, expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyInt
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableDoubleWithInvalidDouble {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyNonDouble = @"varNonDouble";
    NSString *featureVariableType = FeatureVariableTypeDouble;

    NSString *expectedValueString = @"nonDoubleValue";
    double expectedValue = 0.0;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyNonDouble expectedReturn:expectedValueString];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableDouble:featureKey variableKey:variableKeyNonDouble userId:kUserId attributes:nil],
                   @"should return %f for feature variable value %@", expectedValue, expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyNonDouble
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableDoubleWithNil {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyNull = @"varNull";
    NSString *featureVariableType = FeatureVariableTypeDouble;

    NSString *expectedValueString = nil;
    double expectedValue = 0.0;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyNull expectedReturn:expectedValueString];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableDouble:featureKey variableKey:variableKeyNull userId:kUserId attributes:nil],
                   @"should return %f for feature variable value %@", expectedValue, expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyNull
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableIntegerWithInt {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyInt = @"varInt";
    NSString *featureVariableType = FeatureVariableTypeInteger;
    
    // expectations
    NSString *expectedValueString = @"100";
    int expectedValue = 100;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyInt expectedReturn:expectedValueString];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableInteger:featureKey variableKey:variableKeyInt userId:kUserId attributes:nil],
                   @"should return %d for feature variable value %@", expectedValue, expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyInt
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableIntegerWithDouble {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyDouble = @"varDouble";
    NSString *featureVariableType = FeatureVariableTypeInteger;
    
    // expectations
    NSString *expectedValueString = @"100.45";
    int expectedValue = 100;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyDouble expectedReturn:expectedValueString];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableInteger:featureKey variableKey:variableKeyDouble userId:kUserId attributes:nil],
                   @"should return %d for feature variable value %@", expectedValue, expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyDouble
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableIntegerWithInvalidDouble {
    NSString *featureKey = @"featureKey";
    NSString *variableNonInt = @"varNonInt";
    NSString *featureVariableType = FeatureVariableTypeInteger;
    
    // expectations
    NSString *expectedValueString = @"nonIntegerValue";
    int expectedValue = 0;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableNonInt expectedReturn:expectedValueString];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableInteger:featureKey variableKey:variableNonInt userId:kUserId attributes:nil],
                   @"should return %d for feature variable value %@", expectedValue, expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableNonInt
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableIntegerWithNil {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyNull = @"varNull";
    NSString *featureVariableType = FeatureVariableTypeInteger;
    
    // expectations
    NSString *expectedValueString = nil;
    int expectedValue = 0;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyNull expectedReturn:expectedValueString];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableInteger:featureKey variableKey:variableKeyNull userId:kUserId attributes:nil],
                   @"should return %d for feature variable value %@", expectedValue, expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyNull
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableStringWithString {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyString = @"varString";
    NSString *featureVariableType = FeatureVariableTypeString;
    
    // expectations
    NSString *expectedValue = @"Test String";
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyString expectedReturn:expectedValue];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableString:featureKey variableKey:variableKeyString userId:kUserId attributes:nil],
                   @"should return %@ for feature variable value %@", expectedValue, expectedValue);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyString
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableStringWithIntString {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyIntString = @"123";
    NSString *featureVariableType = FeatureVariableTypeString;
    
    // expectations
    NSString *expectedValue = @"123";
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyIntString expectedReturn:expectedValue];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableString:featureKey variableKey:variableKeyIntString userId:kUserId attributes:nil],
                   @"should return %@ for feature variable value %@", expectedValue, expectedValue);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyIntString
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableStringWithNil {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyNull = @"varNull";
    NSString *featureVariableType = FeatureVariableTypeString;
    
    // expectations
    NSString *expectedValue = nil;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyNull expectedReturn:expectedValue];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableString:featureKey variableKey:variableKeyNull userId:kUserId attributes:nil],
                   @"should return %@ for feature variable value %@", expectedValue, expectedValue);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyNull
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

#pragma mark - GetFeatureVariableValueForType Tests

// Should return nil when arguments are nil or empty.
- (void)testGetFeatureVariableValueForTypeWithNilOrEmptyArguments {
    NSString *featureKey = @"featureKey";
    NSString *variableKey = @"variableKey";
    NSString *variableType = FeatureVariableTypeBoolean;
    
    // Passing nil and empty feature key.
    XCTAssertNil([self.optimizely getFeatureVariableValueForType:variableType
                                                     featureKey:nil
                                                    variableKey:variableKey
                                                         userId:kUserId
                                                     attributes:nil]);
    XCTAssertNil([self.optimizely getFeatureVariableValueForType:variableType
                                                      featureKey:@""
                                                     variableKey:variableKey
                                                          userId:kUserId
                                                      attributes:nil]);
    
    // Passing nil and empty variable key.
    XCTAssertNil([self.optimizely getFeatureVariableValueForType:variableType
                                                      featureKey:featureKey
                                                     variableKey:nil
                                                          userId:kUserId
                                                      attributes:nil]);
    XCTAssertNil([self.optimizely getFeatureVariableValueForType:variableType
                                                      featureKey:featureKey
                                                     variableKey:@""
                                                          userId:kUserId
                                                      attributes:nil]);
    
    // Passing nil and empty user Id.
    XCTAssertNil([self.optimizely getFeatureVariableValueForType:variableType
                                                      featureKey:featureKey
                                                     variableKey:variableKey
                                                          userId:nil
                                                      attributes:nil]);
    XCTAssertNil([self.optimizely getFeatureVariableValueForType:variableType
                                                      featureKey:featureKey
                                                     variableKey:variableKey
                                                          userId:@""
                                                      attributes:nil]);
}

// Should return nil when feature key or variable key does not get found.
- (void)testGetFeatureVariableValueForTypeWithInvalidFeatureAndVariableKey {
    NSString *featureKey = @"invalidFeature";
    NSString *variableKey = @"invalidVariable";
    NSString *variableType = FeatureVariableTypeBoolean;
    
    XCTAssertNil([self.optimizely getFeatureVariableValueForType:variableType
                                                      featureKey:featureKey
                                                     variableKey:variableKey
                                                          userId:kUserId
                                                      attributes:nil]);
    XCTAssertNil([self.optimizely getFeatureVariableValueForType:variableType
                                                      featureKey:@"booleanFeature"
                                                     variableKey:variableKey
                                                          userId:kUserId
                                                      attributes:nil]);
}

// Should return nil when variable type is invalid.
- (void)testGetFeatureVariableValueForTypeWithInvalidVariableType {
    NSString *variableTypeBool = FeatureVariableTypeBoolean;
    NSString *variableTypeInt = FeatureVariableTypeInteger;
    NSString *variableTypeDouble = FeatureVariableTypeDouble;
    NSString *variableTypeString = FeatureVariableTypeString;
    
    NSString *featureKeyBool = @"booleanSingleVariableFeature";
    NSString *featureKeyString = @"stringSingleVariableFeature";
    NSString *variableKeyBool = @"booleanVariable";
    NSString *variableKeyString = @"stringVariable";
    
    XCTAssertNil([self.optimizely getFeatureVariableValueForType:variableTypeBool
                                                      featureKey:featureKeyString
                                                     variableKey:variableKeyString
                                                          userId:kUserId
                                                      attributes:nil]);
    XCTAssertNil([self.optimizely getFeatureVariableValueForType:variableTypeInt
                                                      featureKey:featureKeyBool
                                                     variableKey:variableKeyBool
                                                          userId:kUserId
                                                      attributes:nil]);
    XCTAssertNil([self.optimizely getFeatureVariableValueForType:variableTypeDouble
                                                      featureKey:featureKeyString
                                                     variableKey:variableKeyString
                                                          userId:kUserId
                                                      attributes:nil]);
    XCTAssertNil([self.optimizely getFeatureVariableValueForType:variableTypeString
                                                      featureKey:featureKeyBool
                                                     variableKey:variableTypeBool
                                                          userId:kUserId
                                                      attributes:nil]);
}

// Should return default value when feature is not enabled for the user.
- (void)testGetFeatureVariableValueForTypeWithFeatureFlagNotEnabledForUser {
    NSString *featureKey = @"stringSingleVariableFeature";
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    NSString *variableKey = @"stringVariable";
    NSString *variableType = FeatureVariableTypeString;
    NSString *expectedValue = @"wingardium leviosa";
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(nil);
    
    NSString *value = [self.optimizely getFeatureVariableValueForType:variableType
                                                                   featureKey:featureKey
                                                                  variableKey:variableKey
                                                                       userId:kUserId
                                                                   attributes:nil];
    XCTAssertEqualObjects(expectedValue, value, @"should return %@ for featureFlag not enabled", expectedValue);
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    [decisionServiceMock stopMocking];
}

// Should return default value when feature is enabled for the user
// but variable usage does not get found for the variation.
- (void)testGetFeatureVariableValueForTypeWithVaribaleNotInVariation {
    NSString *featureKey = @"stringSingleVariableFeature";
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:@"testExperimentMultivariate"];
    OPTLYVariation *differentVariation = [experiment getVariationForVariationId:@"6358043287"];
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSourceExperiment];
    NSString *variableKey = @"stringVariable";
    NSString *variableType = FeatureVariableTypeString;
    NSString *expectedValue = @"wingardium leviosa";
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(expectedDecision);
    
    NSString *value = [self.optimizely getFeatureVariableValueForType:variableType
                                                           featureKey:featureKey
                                                          variableKey:variableKey
                                                               userId:kUserId
                                                           attributes:nil];
    XCTAssertEqualObjects(expectedValue, value, @"should return %@ for featureFlag enabled but dont used", expectedValue);
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    [decisionServiceMock stopMocking];
}

// Should return variable value from variation and log message when feature is enabled for the user
// and variable usage has been found for the variation.
- (void)testGetFeatureVariableValueForTypeWithFeatureFlagIsEnabledAndVaribaleUsed {
    NSString *featureKey = @"doubleSingleVariableFeature";
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    NSString *variableKey = @"doubleVariable";
    NSString *variableType = FeatureVariableTypeDouble;
    NSString *expectedValue = @"42.42";
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:@"testExperimentDoubleFeature"];
    OPTLYVariation *variation = [experiment getVariationForVariationId:@"122239"];
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSourceExperiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(expectedDecision);
    
    NSString *value = [self.optimizely getFeatureVariableValueForType:variableType
                                                           featureKey:featureKey
                                                          variableKey:variableKey
                                                               userId:kUserId
                                                           attributes:nil];
    XCTAssertEqualObjects(expectedValue, value, @"should return %@ for featureFlag enabled but dont used", expectedValue);
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    [decisionServiceMock stopMocking];
}

// Verify that GetFeatureVariableValueForType returns correct variable value for rollout rule.
- (void)testGetFeatureVariableValueForTypeWithRolloutRule {
    NSString *featureKey = @"booleanSingleVariableFeature";
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    NSString *variableKey = @"booleanVariable";
    BOOL expectedVariableValue = true;
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:@"177770"];
    OPTLYVariation *variation = [experiment getVariationForVariationId:@"177771"];
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSourceRollout];
        
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(expectedDecision);
                                   
   BOOL value = [self.optimizely getFeatureVariableBoolean:featureKey
                                                variableKey:variableKey
                                                     userId:kUserId
                                                 attributes:nil];
   XCTAssertEqual(expectedVariableValue, value, @"should return %@ for featureFlag enabled but dont used", expectedVariableValue ? @"true" : @"false");
                                   
   OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
   [decisionServiceMock stopMocking];
}

#pragma mark - Helper Methods

- (id)getOptimizelyMockForFeatureVariableType:(NSString *)featureVariableType variableKey:(NSString *)variableKey expectedReturn:(NSString *)expectedReturn {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    OCMStub([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                featureKey:[OCMArg any]
                                               variableKey:variableKey
                                                    userId:[OCMArg any]
                                                attributes:[OCMArg any]]).andReturn(expectedReturn);
    return optimizelyMock;
}

- (void)stubSuccessResponseForEventRequest {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"logx.optimizely.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[[NSData alloc] init]
                                          statusCode:200
                                             headers:@{@"Content-Type":@"application/json"}];
    }];
}

- (void)stubFailureResponseForEventRequest {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return YES; // Stub ALL requests without any condition
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:NSURLErrorTimedOut
                                         userInfo:nil];
        return [OHHTTPStubsResponse responseWithError:error];
    }];
}

@end
