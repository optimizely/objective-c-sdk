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

#pragma mark - Helper Methods

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
