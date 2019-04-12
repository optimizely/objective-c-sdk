/****************************************************************************
 * Copyright 2016-2019, Optimizely, Inc. and contributors                   *
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
#import "OPTLYEventMetric.h"
#import "OPTLYEventParameterKeys.h"
#import "OPTLYEventBuilder.h"

static NSString *const kUserId = @"userId";
static NSString *const kExperimentKey = @"testExperimentWithFirefoxAudience";
static NSString *const kEventNameWithMultipleExperiments = @"testEventWithMultipleExperiments";

// datafiles
static NSString *const kV2TestDatafileName = @"V2TestDatafile";
static NSString *const kBucketerTestDatafileName = @"BucketerTestsDatafile";

// user IDs
static NSString * const kUserIdForWhitelisting = @"userId";
static NSString * const kUserIdForFV = @"userId";

// experiment Keys
static NSString * const kExperimentKeyForWhitelisting = @"whiteListExperiment";
static NSString * const kExperimentKeyForFV = @"whiteListExperiment";

// variation Keys
static NSString * const kVariationKeyForWhitelisting = @"whiteListedVariation";
static NSString * const kVariationKeyForFV = @"whiteListedVariation";

// variation IDs
static NSString * const kVariationIDForWhitelisting = @"variation4";

// attribute keys
static NSString * const kAttributeKeyBrowserType = @"browser_type";
static NSString * const kAttributeKeyBrowserVersion = @"browser_version";
static NSString * const kAttributeKeyBrowserBuildNumber = @"browser_build_number";
static NSString * const kAttributeKeyBrowserIsDefault = @"browser_is_default";

@interface OPTLYNotificationCenter(Testing)
- (void)notifyDecisionListener:(DecisionListener)listener args:(NSDictionary *)args;
@end

@interface Optimizely(Testing)
- (BOOL)validateStringInputs:(NSMutableDictionary<NSString *, NSString *> *)inputs logs:(NSDictionary<NSString *, NSString *> *)logs;
- (id)ObjectOrNull:(id)object;
@end

@interface OPTLYNotificationTest : NSObject
@end

@implementation OPTLYNotificationTest
- (void)onActivate:(OPTLYExperiment *)experiment userId:(NSString *)userId attributes:(NSDictionary<NSString *,id> *)attributes variation:(OPTLYVariation *)variation event:(NSDictionary<NSString *,NSString *> *)event {
    
}

- (void)onTrack:(NSString *)eventKey userId:(NSString *)userId attributes:(NSDictionary<NSString *, id> *)attributes eventTags:(NSDictionary *)eventTags event:(NSDictionary<NSString *,NSString *> *)event {
    
}
@end

@interface Optimizely(test)
- (OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId
                  attributes:(NSDictionary<NSString *, id> *)attributes
                    callback:(void (^)(NSError *))callback;
- (OPTLYVariation *)sendImpressionEventFor:(OPTLYExperiment *)experiment
                                 variation:(OPTLYVariation *)variation
                                    userId:(NSString *)userId
                                attributes:(NSDictionary<NSString *, id> *)attributes
                                  callback:(void (^)(NSError *))callback;
- (id)getFeatureVariableValueForType:(NSString *)variableType
                          featureKey:(nullable NSString *)featureKey
                         variableKey:(nullable NSString *)variableKey
                              userId:(nullable NSString *)userId
                          attributes:(nullable NSDictionary<NSString *, id> *)attributes;
@end

@interface OPTLYEventBuilderDefault(Tests)
@end

@interface OptimizelyTest : XCTestCase

@property (nonatomic, strong) NSData *datafile;
@property (nonatomic, strong) NSData *typedAudienceDatafile;
@property (nonatomic, strong) Optimizely *optimizely;
@property (nonatomic, strong) Optimizely *optimizelyTypedAudience;
@property (nonatomic, strong) NSDictionary *attributes;

@end

@implementation OptimizelyTest

- (void)setUp {
    [super setUp];
    self.datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:@"test_data_10_experiments"];
    self.typedAudienceDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:@"typed_audience_datafile"];
    
    self.optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.datafile;
        builder.logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelOff];;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    self.optimizelyTypedAudience = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.typedAudienceDatafile;
        builder.logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelOff];;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    
    XCTAssertNotNil(self.optimizely);
    XCTAssertNotNil(self.optimizelyTypedAudience);
    
    self.attributes = @{
                        kAttributeKeyBrowserType : @"firefox",
                        kAttributeKeyBrowserVersion : @(68.1),
                        kAttributeKeyBrowserBuildNumber : @(106),
                        kAttributeKeyBrowserIsDefault : @YES
                        };
}

- (void)tearDown {
    [super tearDown];
    self.datafile = nil;
    self.optimizely = nil;
    self.typedAudienceDatafile = nil;
    self.optimizelyTypedAudience = nil;
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

- (void)testVariationWithAudienceTypeInteger {
    NSString *experimentKey = @"testExperimentWithFirefoxAudience";
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:experimentKey];
    XCTAssertNotNil(experiment);
    OPTLYVariation *variation;
    NSDictionary *attributesWithUserNotInAudience = @{kAttributeKeyBrowserBuildNumber : @(601)};
    NSDictionary *attributesWithUserInAudience = @{kAttributeKeyBrowserBuildNumber : @(106)};
    
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


// Test initializing with older V2 datafile
- (void)testOlderV2Datafile {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kV2TestDatafileName];
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
    }]];
    XCTAssertNotNil(optimizely);
}

// Test whitelisting works with get variation
- (void)testVariationWhitelisting {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kBucketerTestDatafileName];
    
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
    }]];
    XCTAssertNotNil(optimizely);
    
    // get variation
    OPTLYVariation *variation = [optimizely variation:kExperimentKeyForWhitelisting userId:kUserIdForWhitelisting];
    XCTAssertNotNil(variation);
    XCTAssertEqualObjects(variation.variationId, kVariationIDForWhitelisting);
    XCTAssertEqualObjects(variation.variationKey, kVariationKeyForWhitelisting);
}

#pragma mark - Get Variation <DECISION NOTIFICATION> Tests

- (void)testDecisionNotificationForBasicGetVariation {
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
    
    __block NSString *decisionNotificationExperimentKey = nil;
    __block NSString *decisionNotificationVariationKey = nil;
    
    [self.optimizely.notificationCenter addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        decisionNotificationExperimentKey = decisionInfo[OPTLYNotificationExperimentKey];
        decisionNotificationVariationKey = decisionInfo[OPTLYNotificationVariationKey];
    }];
    
    variation = [self.optimizely variation:@"bad" userId:kUserId];
    XCTAssertNil(variation);
    XCTAssertEqualObjects(decisionNotificationExperimentKey, [NSNull null]);
    XCTAssertEqualObjects(decisionNotificationVariationKey, [NSNull null]);
}

// Test whitelisting works with get variation
- (void)testDecisionNotificationForVariationWhitelisting {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kBucketerTestDatafileName];
    __block NSString *decisionNotificationExperimentKey = nil;
    __block NSString *decisionNotificationVariationKey = nil;
    
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
    }]];
    XCTAssertNotNil(optimizely);
    
    [optimizely.notificationCenter addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        decisionNotificationExperimentKey = decisionInfo[OPTLYNotificationExperimentKey];
        decisionNotificationVariationKey = decisionInfo[OPTLYNotificationVariationKey];
    }];
    
    // get variation
    OPTLYVariation *variation = [optimizely variation:kExperimentKeyForWhitelisting userId:kUserIdForWhitelisting];
    XCTAssertNotNil(variation);
    XCTAssertEqualObjects(variation.variationId, kVariationIDForWhitelisting);
    XCTAssertEqualObjects(variation.variationKey, kVariationKeyForWhitelisting);
    XCTAssertEqualObjects(decisionNotificationExperimentKey, kExperimentKeyForWhitelisting);
    XCTAssertEqualObjects(decisionNotificationVariationKey, variation.variationKey);
}

# pragma mark - Integration Tests

- (void)testOptimizelyActivateWithEmptyUserId {
    OPTLYVariation *_variation = [self.optimizely activate:@"testExperimentMultivariate"
                                                    userId:@""];
    XCTAssertNotNil(_variation);
    XCTAssertEqualObjects(@"Feorge", _variation.variationKey);
}


- (void)testOptimizelyActivateWithNoExperiment {
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    OPTLYVariation *variation = [self.optimizely activate:nil userId:kUserId attributes:self.attributes callback:^(NSError *error) {
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.userInfo[NSLocalizedDescriptionKey], OPTLYLoggerMessagesActivateExperimentKeyEmpty);
        [expectation fulfill];
    }];
    
    XCTAssertNil(variation, @"activate without experiment should return nil: %@", variation);
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testOptimizelyActivateWithNoUser {
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    OPTLYVariation *variation = [self.optimizely activate:kExperimentKeyForWhitelisting userId:nil attributes:self.attributes callback:^(NSError *error) {
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.userInfo[NSLocalizedDescriptionKey], OPTLYLoggerMessagesUserIdInvalid);
        [expectation fulfill];
    }];
    
    XCTAssertNil(variation, @"activate without user should return nil: %@", variation);
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testOptimizelyActivateWithInvalidExperiment {
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    NSString *invalidExperimentKey = @"invalid";
    
    OPTLYVariation *variation = [self.optimizely activate:invalidExperimentKey userId:kUserId attributes:self.attributes callback:^(NSError *error) {
        XCTAssertNotNil(error);
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesActivateExperimentKeyInvalid, invalidExperimentKey];
        XCTAssertEqualObjects(error.userInfo[NSLocalizedDescriptionKey], logMessage);
        [expectation fulfill];
    }];
    
    XCTAssertNil(variation, @"activate an invalid experiment should return nil: %@", variation);
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testOptimizelyActivateWithNoImpressionTicket {
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:kExperimentKey];
    OPTLYVariation *variation = [self.optimizely variation:kExperimentKey userId:kUserId attributes:self.attributes];
    
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OCMStub([optimizelyMock sendImpressionEventFor:experiment
                                         variation:variation
                                            userId:kUserId
                                        attributes:self.attributes
                                          callback:[OCMArg any]]).andReturn(nil);
    
    OPTLYVariation *sentVariation = [optimizelyMock activate:kExperimentKey userId:kUserId attributes:self.attributes callback:^(NSError *error) {
        XCTAssertNotNil(error);
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationFailure, kUserId, kExperimentKey];
        XCTAssertEqualObjects(error.userInfo[NSLocalizedDescriptionKey], logMessage);
        [expectation fulfill];
    }];
    
    XCTAssertNil(sentVariation, @"activate an experiment with no impresion event should return nil");
    
    OCMVerify([optimizelyMock sendImpressionEventFor:experiment
                                           variation:variation
                                              userId:kUserId
                                          attributes:self.attributes
                                            callback:[OCMArg any]]);
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
    
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:kExperimentKeyForWhitelisting];
    __block NSString *notificationExperimentKey = nil;
    
    [self.optimizely.notificationCenter addActivateNotificationListener:^(OPTLYExperiment *experiment, NSString *userId, NSDictionary<NSString *, id> *attributes, OPTLYVariation *variation, NSDictionary<NSString *,NSString *> *event) {
        notificationExperimentKey = experiment.experimentId;
    }];
    
    OPTLYVariation *_variation = [self.optimizely activate:kExperimentKeyForWhitelisting
                                                    userId:kUserId];
    XCTAssertNotNil(_variation);
    XCTAssertEqual(experiment.experimentId, notificationExperimentKey);
}

- (void)testOptimizelyPostsActivateExperimentNotificationAllAttributes {
    
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:kExperimentKeyForWhitelisting];
    __block NSString *notificationExperimentKey = nil;
    
    NSDictionary<NSString *, id> *expectedAttributes = @{
                                                                 @"browser_name": @"chrome",
                                                                 @"buildno": @(10),
                                                                 @"buildversion": @(0.13)
                                                                 };
    __block NSDictionary<NSString *, id> *actualAttributes;
    
    [self.optimizely.notificationCenter addActivateNotificationListener:^(OPTLYExperiment *experiment, NSString *userId, NSDictionary<NSString *, id> *attributes, OPTLYVariation *variation, NSDictionary<NSString *,NSString *> *event) {
        notificationExperimentKey = experiment.experimentId;
        actualAttributes = attributes;
    }];
    
    OPTLYVariation *_variation = [self.optimizely activate:kExperimentKeyForWhitelisting
                                                    userId:kUserId attributes:expectedAttributes];
    XCTAssertEqualObjects(expectedAttributes, actualAttributes);
    XCTAssertNotNil(_variation);
    XCTAssertEqual(experiment.experimentId, notificationExperimentKey);
}

- (void)testOptimizelyPostsActivateExperimentNotificationEmptyAttributes {
    
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:kExperimentKeyForWhitelisting];
    __block NSString *notificationExperimentKey = nil;
    __block NSDictionary<NSString *, id> *actualAttributes;
    
    [self.optimizely.notificationCenter addActivateNotificationListener:^(OPTLYExperiment *experiment, NSString *userId, NSDictionary<NSString *, id> *attributes, OPTLYVariation *variation, NSDictionary<NSString *,NSString *> *event) {
        notificationExperimentKey = experiment.experimentId;
        actualAttributes = attributes;
    }];
    
    OPTLYVariation *_variation = [self.optimizely activate:kExperimentKeyForWhitelisting
                                                    userId:kUserId attributes:nil];
    XCTAssertNotNil(_variation);
    XCTAssertEqual(experiment.experimentId, notificationExperimentKey);
}

- (void)testOptimizelyTrackWithNoEvent {
    
    NSString *eventKey;
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizely.logger);
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.datafile;
        builder.logger = loggerMock;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    [optimizely track:eventKey userId:kUserId attributes:self.attributes];
    
    OCMVerify([loggerMock logMessage:OPTLYLoggerMessagesTrackEventKeyEmpty withLevel:OptimizelyLogLevelError]);
    [loggerMock stopMocking];
}

- (void)testOptimizelyTrackWithNoUser {
    
    NSString *eventKey = @"testEvent";
    NSString *userId;
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizely.logger);
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.datafile;
        builder.logger = loggerMock;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    [optimizely track:eventKey userId:userId attributes:self.attributes];
    
    OCMVerify([loggerMock logMessage:OPTLYLoggerMessagesUserIdInvalid withLevel:OptimizelyLogLevelError]);
    [loggerMock stopMocking];
}

- (void)testOptimizelyTrackWithEmptyUserId {
    
    NSString *eventKey = @"testEvent";
    __block NSString *_userId = nil;
    __block NSString *notificationEventKey = nil;
    __block NSDictionary<NSString *, id> *actualAttributes;
    __block NSDictionary<NSString *, id> *actualEventTags;
    
    [self.optimizely.notificationCenter addTrackNotificationListener:^(NSString * _Nonnull eventKey, NSString * _Nonnull userId, NSDictionary<NSString *, id> * _Nonnull attributes, NSDictionary * _Nonnull eventTags, NSDictionary<NSString *,NSString *> * _Nonnull event) {
        _userId = userId;
        notificationEventKey = eventKey;
        actualAttributes = attributes;
        actualEventTags = eventTags;
    }];
    
    [self.optimizely track:eventKey userId:@""];
    XCTAssertEqualObjects(@"", _userId);
    XCTAssertEqual(eventKey, notificationEventKey);
    XCTAssertNil(actualAttributes);
    XCTAssertEqualObjects(nil, actualEventTags);
}

- (void)testOptimizelyTrackWithInvalidEvent {
    
    NSString *invalidEventKey = @"invalid";
    
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizely.logger);
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.datafile;
        builder.logger = loggerMock;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    [optimizely track:invalidEventKey userId:kUserId attributes:self.attributes];
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventNotTracked, invalidEventKey, kUserId];
    OCMVerify([loggerMock logMessage:logMessage withLevel:OptimizelyLogLevelInfo]);
    [loggerMock stopMocking];
}

- (void)testOptimizelyTrackWithEventOfNoExperiment {
    NSString *eventWithNoExerimentKey = @"testEventWithoutExperiments";
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizely.logger);
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.datafile;
        builder.logger = loggerMock;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    [optimizely track:eventWithNoExerimentKey userId:kUserId attributes:self.attributes];
    
    [loggerMock verify];
    [loggerMock stopMocking];
}

- (void)testOptimizelyPostEventTrackNotification {
    
    NSString *eventKey = @"testEvent";
    __block NSString *notificationEventKey = nil;
    
    [self.optimizely.notificationCenter addTrackNotificationListener:^(NSString * _Nonnull eventKey, NSString * _Nonnull userId, NSDictionary<NSString *, id> * _Nonnull attributes, NSDictionary * _Nonnull eventTags, NSDictionary<NSString *,NSObject *> * _Nonnull event) {
        notificationEventKey = eventKey;
    }];
    
    [self.optimizely track:eventKey userId:kUserId attributes:self.attributes];
    XCTAssertEqual(eventKey, notificationEventKey);
}

- (void)testOptimizelyPostEventTrackNotificationWithAllAttributesEventTags {
    
    NSString *eventKey = @"testEvent";
    __block NSString *notificationEventKey = nil;
    __block NSDictionary<NSString *, id> *actualAttributes;
    __block NSDictionary<NSString *, id> *actualEventTags;
    
    NSDictionary<NSString *, id> *expectedEventTags = @{
                                                                OPTLYEventMetricNameRevenue: OPTLYEventMetricNameValue,
                                                                @"event_int": @(11),
                                                                @"event_version": @(1.3),
                                                                @"event_bool": @(YES)
                                                                };
    
    [self.optimizely.notificationCenter addTrackNotificationListener:^(NSString * _Nonnull eventKey, NSString * _Nonnull userId, NSDictionary<NSString *, id> * _Nonnull attributes, NSDictionary * _Nonnull eventTags, NSDictionary<NSString *,NSObject *> * _Nonnull event) {
        actualAttributes = attributes;
        actualEventTags = eventTags;
        notificationEventKey = eventKey;
    }];
    
    [self.optimizely track:eventKey userId:kUserId attributes:self.attributes eventTags:expectedEventTags];
    XCTAssertEqualObjects(self.attributes, actualAttributes);
    XCTAssertEqualObjects(expectedEventTags, actualEventTags);
    XCTAssertEqual(eventKey, notificationEventKey);
}

- (void)testOptimizelyPostEventTrackNotificationWithNilAttributesEventTags {
    
    NSString *eventKey = @"testEvent";
    __block NSString *notificationEventKey = nil;
    __block NSDictionary<NSString *, id> *actualAttributes;
    __block NSDictionary<NSString *, id> *actualEventTags;
    
    [self.optimizely.notificationCenter addTrackNotificationListener:^(NSString * _Nonnull eventKey, NSString * _Nonnull userId, NSDictionary<NSString *, id> * _Nonnull attributes, NSDictionary * _Nonnull eventTags, NSDictionary<NSString *,NSObject *> * _Nonnull event) {
        actualAttributes = attributes;
        actualEventTags = eventTags;
        notificationEventKey = eventKey;
    }];
    
    [self.optimizely track:eventKey userId:kUserId attributes:nil eventTags:nil];
    
    XCTAssertNil(actualAttributes);
    XCTAssertNil(actualEventTags);
    XCTAssertEqual(eventKey, notificationEventKey);
}

- (void)testOptimizelyPostEventTrackNotificationWithEventTags {
    
    NSString *eventKey = @"testEvent";
    NSDictionary *eventTags = @{ OPTLYEventMetricNameRevenue: @(2.5)};
    __block NSString *notificationEventKey = nil;
    __block NSDictionary *notificationEventTags = nil;
    
    [self.optimizely.notificationCenter addTrackNotificationListener:^(NSString * _Nonnull eventKey, NSString * _Nonnull userId, NSDictionary<NSString *, id> * _Nonnull attributes, NSDictionary * _Nonnull eventTags, NSDictionary<NSString *,NSObject *> * _Nonnull event) {
        notificationEventKey = eventKey;
        notificationEventTags = eventTags;
    }];
    [self.optimizely track:eventKey userId:kUserId eventTags:eventTags];
    XCTAssertEqual(eventKey, notificationEventKey);
    XCTAssertEqual(eventTags, notificationEventTags);
}

#pragma mark - Activate <DECISION NOTIFICATION> Tests

- (void)testDecisionNotificationForActivateWithNonTargetingAudience {
    
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    __block NSString *decisionNotificationVariationKey = nil;
    
    [self.optimizely.notificationCenter addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        decisionNotificationVariationKey = decisionInfo[OPTLYNotificationVariationKey];
    }];
    
    OPTLYVariation *variation = [self.optimizely activate:kExperimentKey
                                                   userId:kUserId
                                               attributes:nil callback:^(NSError *error) {
                                                   XCTAssertNotNil(error);
                                                   NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationFailure, kUserId, kExperimentKey];
                                                   XCTAssertEqualObjects(error.userInfo[NSLocalizedDescriptionKey], logMessage);
                                                   [expectation fulfill];
                                               }];
    XCTAssertNil(variation);
    XCTAssertEqualObjects(decisionNotificationVariationKey, [NSNull null]);
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testOptimizelyPostsOnDecisionActivateNotification {
    
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:kExperimentKeyForWhitelisting];
    __block NSString *decisionNotificationExperimentKey = nil;
    __block NSString *decisionNotificationVariationKey = nil;
    
    [self.optimizely.notificationCenter addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        decisionNotificationExperimentKey = decisionInfo[OPTLYNotificationExperimentKey];
        decisionNotificationVariationKey = decisionInfo[OPTLYNotificationVariationKey];
    }];
    
    OPTLYVariation *_variation = [self.optimizely activate:kExperimentKeyForWhitelisting
                                                    userId:kUserId];
    XCTAssertNotNil(_variation);
    XCTAssertEqualObjects(experiment.experimentKey, decisionNotificationExperimentKey);
    XCTAssertEqualObjects(_variation.variationKey, decisionNotificationVariationKey);
}

- (void)testOptimizelyPostsOnDecisionActivateNotificationAllAttributes {
    
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:kExperimentKeyForWhitelisting];
    __block NSString *decisionNotificationExperimentKey = nil;
    
    NSDictionary<NSString *, id> *expectedAttributes = @{
                                                         @"browser_name": @"chrome",
                                                         @"buildno": @(10),
                                                         @"buildversion": @(0.13)
                                                         };
    __block NSDictionary<NSString *, id> *decisionActualAttributes;
    
    [self.optimizely.notificationCenter addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        decisionNotificationExperimentKey = decisionInfo[OPTLYNotificationExperimentKey];
        decisionActualAttributes = attributes;
    }];
    
    OPTLYVariation *_variation = [self.optimizely activate:kExperimentKeyForWhitelisting
                                                    userId:kUserId attributes:expectedAttributes];
    XCTAssertEqualObjects(expectedAttributes, decisionActualAttributes);
    XCTAssertNotNil(_variation);
    XCTAssertEqualObjects(experiment.experimentKey, decisionNotificationExperimentKey);
}

- (void)testOptimizelyPostsPostsOnDecisionActivateNotificationEmptyAttributes {
    
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:kExperimentKeyForWhitelisting];
    __block NSString *decisionNotificationExperimentKey = nil;
    __block NSDictionary<NSString *, id> *decisionActualAttributes;
    
    [self.optimizely.notificationCenter addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        decisionNotificationExperimentKey = decisionInfo[OPTLYNotificationExperimentKey];
        decisionActualAttributes = attributes;
    }];
    
    OPTLYVariation *_variation = [self.optimizely activate:kExperimentKeyForWhitelisting
                                                    userId:kUserId attributes:nil];
    XCTAssertEqualObjects(decisionActualAttributes, @{});
    XCTAssertNotNil(_variation);
    XCTAssertEqualObjects(experiment.experimentKey, decisionNotificationExperimentKey);
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
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    // SendImpressionEvent() does not get called.
    OCMReject([optimizelyMock sendImpressionEventFor:decision.experiment
                                           variation:decision.variation
                                              userId:kUserId
                                          attributes:nil
                                            callback:nil]);
    
    XCTAssertTrue([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return true for enabled featureFlag");
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    [decisionServiceMock stopMocking];
}

// Should return true and send an impression event when feature is enabled for the user
// and user is being experimented.
- (void)testIsFeatureEnabledWithFeatureFlagEnabledAndUserIsBeingExperimented {
    NSString *featureFlagKey = @"multiVariateFeature";
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:@"testExperimentMultivariate"];
    OPTLYVariation *variation = [experiment getVariationForVariationId:@"6373141147"];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertTrue([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return true for enabled featureFlag");
    
    // SendImpressionEvent() does get called.
    OCMVerify([optimizelyMock sendImpressionEventFor:decision.experiment
                                           variation:decision.variation
                                              userId:kUserId
                                          attributes:nil
                                            callback:nil]);
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    [decisionServiceMock stopMocking];
}

// Should return false if the feature experiment variation’s `featureEnabled` property is false
- (void)testIsFeatureEnabledWithVariationsFeatureEnabledFalse {
    NSString *featureFlagKey = @"booleanFeature";
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds[0]];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return false for disabled featureFlag");
    
    // SendImpressionEvent() does get called.
    OCMVerify([optimizelyMock sendImpressionEventFor:decision.experiment
                                           variation:decision.variation
                                              userId:kUserId
                                          attributes:nil
                                            callback:nil]);
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    [decisionServiceMock stopMocking];
}

// Should return true if the feature experiment variation’s `featureEnabled` property is true
- (void)testIsFeatureEnabledWithVariationsFeatureEnabledTrue {
    NSString *featureFlagKey = @"booleanFeature";
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds[1]];
    OPTLYVariation *variation = experiment.variations[1];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertTrue([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return true for enabled featureFlag");
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    [decisionServiceMock stopMocking];
}

// Should return true if the user is bucketed into rollout experiment’s variation
// and variation's featureEnabled is also true
- (void)testIsFeatureEnabledWithVariationsFeatureEnabledTrueForRollout {
    NSString *featureFlagKey = @"booleanSingleVariableFeature";
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments[0];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertTrue([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return true for enabled featureFlag");
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    [decisionServiceMock stopMocking];
}

// Should return false if the user is bucketed into rollout experiment’s variation
// but variation's featureEnabled is false
- (void)testIsFeatureEnabledWithVariationsFeatureEnabledForRollout {
    NSString *featureFlagKey = @"booleanSingleVariableFeature";
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = rollout.experiments[1];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return false for disabled featureFlag");
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    [decisionServiceMock stopMocking];
}

#pragma mark - IsFeatureEnabled <Decision Notification> Tests

// Should return false when arguments are nil or empty.
- (void)testDecisionListenerForIsFeatureEnabledWithEmptyOrNilArguments {
    NSString *featureFlagKey = @"featureKey";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
    }];
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:nil attributes:nil], @"should return false for missing userId");
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:@"" attributes:nil], @"should return false for missing userId");
    
    XCTAssertFalse([self.optimizely isFeatureEnabled:nil userId:kUserId attributes:nil], @"should return false for missing featureKey");
    XCTAssertFalse([self.optimizely isFeatureEnabled:@"" userId:kUserId attributes:nil], @"should return false for missing featureKey");
    OCMReject([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

// Should return false when feature flag key is invalid.
- (void)testDecisionListenerForIsFeatureEnabledWithInvalidFeatureFlagKey {
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
    }];
    NSString *featureFlagKey = @"featureNotFound";
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return false for invalid featureFlagKey");
    OCMReject([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

// Should return false when feature flag does not belongs to an experiment.
- (void)testDecisionListenerForIsFeatureEnabledWithFeatureFlagContainsInvalidExperiment {
    NSString *featureFlagKey = @"invalidExperimentIdFeature";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(featureFlagKey, decisionInfo[DecisionInfo.FeatureKey]);
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(DecisionSource.Rollout, decisionInfo[DecisionInfo.SourceKey]);
    }];
    // Should return false when the experiment in feature flag does not get found in the datafile.
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return false for featureFlag does not belongs to experiment");
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

// Should return false when feature flag is not valid for non mutex group experiments.
- (void)testDecisionListenerForIsFeatureEnabledWithFeatureFlagContainsNonMutexGroupExperiments {
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    NSString *featureFlagKey = @"multipleExperimentIdsFeature";
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
    }];
    // Should return false when experiments in feature flag does not belongs to same group.
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return false when experiments in feature flag does not belongs to same group");
    OCMReject([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

// Should return true when feature flag is valid for mutex group experiments.
- (void)testDecisionListenerForIsFeatureEnabledWithFeatureFlagContainsMutexGroupExperiments {
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    NSString *featureFlagKey = @"booleanFeature";
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(featureFlagKey, decisionInfo[DecisionInfo.FeatureKey]);
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(true, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqualObjects(@"mutex_exp2", decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects(@"b", decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqualObjects(DecisionSource.Experiment, decisionInfo[DecisionInfo.SourceKey]);
    }];
    // Should return true when experiments in feature flag does belongs to same group.
    XCTAssertTrue([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return true when experiments in feature flag does belongs to same group");
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

// Should return false when feature is not enabled for the user.
- (void)testDecisionListenerForIsFeatureEnabledWithFeatureFlagNotEnabled {
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    NSString *featureFlagKey = @"multiVariateFeature";
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(featureFlagKey, decisionInfo[DecisionInfo.FeatureKey]);
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(DecisionSource.Rollout, decisionInfo[DecisionInfo.SourceKey]);
    }];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn([[OPTLYFeatureDecision alloc] initWithExperiment:nil variation:nil source:DecisionSource.Rollout]);
    
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return false for featureFlag not enabled");
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [decisionServiceMock stopMocking];
    [(id)notificationCenterMock stopMocking];
}

// Should return true but does not send an impression event when feature is enabled for the user
// but user does not get experimented.
- (void)testDecisionListenerForIsFeatureEnabledWithFeatureFlagEnabledAndUserIsNotBeingExperimented {
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    NSString *featureFlagKey = @"booleanSingleVariableFeature";
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(featureFlagKey, decisionInfo[DecisionInfo.FeatureKey]);
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(true, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(DecisionSource.Rollout, decisionInfo[DecisionInfo.SourceKey]);
    }];
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments[0];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    // SendImpressionEvent() does not get called.
    OCMReject([optimizelyMock sendImpressionEventFor:decision.experiment
                                           variation:decision.variation
                                              userId:kUserId
                                          attributes:nil
                                            callback:nil]);
    
    XCTAssertTrue([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return true for enabled featureFlag");
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [decisionServiceMock stopMocking];
    [(id)notificationCenterMock stopMocking];
}

// Should return true and send an impression event when feature is enabled for the user
// and user is being experimented.
- (void)testDecisionListenerForIsFeatureEnabledWithFeatureFlagEnabledAndUserIsBeingExperimented {
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    NSString *featureFlagKey = @"multiVariateFeature";
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(featureFlagKey, decisionInfo[DecisionInfo.FeatureKey]);
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(true, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqualObjects(@"testExperimentMultivariate", decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects(@"Fred", decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqualObjects(DecisionSource.Experiment, decisionInfo[DecisionInfo.SourceKey]);
    }];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:@"testExperimentMultivariate"];
    OPTLYVariation *variation = [experiment getVariationForVariationId:@"6373141147"];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertTrue([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return true for enabled featureFlag");
    
    // SendImpressionEvent() does get called.
    OCMVerify([optimizelyMock sendImpressionEventFor:decision.experiment
                                           variation:decision.variation
                                              userId:kUserId
                                          attributes:nil
                                            callback:nil]);
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [decisionServiceMock stopMocking];
    [(id)notificationCenterMock stopMocking];
}

// Should return false if the feature experiment variation’s `featureEnabled` property is false
- (void)testDecisionListenerForIsFeatureEnabledWithVariationsFeatureEnabledFalse {
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    NSString *featureFlagKey = @"booleanFeature";
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(featureFlagKey, decisionInfo[DecisionInfo.FeatureKey]);
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqualObjects(@"mutex_exp1", decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects(@"a", decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqualObjects(DecisionSource.Experiment, decisionInfo[DecisionInfo.SourceKey]);
    }];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds[0]];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return false for disabled featureFlag");
    
    // SendImpressionEvent() does get called.
    OCMVerify([optimizelyMock sendImpressionEventFor:decision.experiment
                                           variation:decision.variation
                                              userId:kUserId
                                          attributes:nil
                                            callback:nil]);
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [decisionServiceMock stopMocking];
    [(id)notificationCenterMock stopMocking];
}

// Should return true if the feature experiment variation’s `featureEnabled` property is true
- (void)testDecisionListenerForIsFeatureEnabledWithVariationsFeatureEnabledTrue {
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    NSString *featureFlagKey = @"booleanFeature";
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(featureFlagKey, decisionInfo[DecisionInfo.FeatureKey]);
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(true, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqualObjects(@"mutex_exp2", decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects(@"b", decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqualObjects(DecisionSource.Experiment, decisionInfo[DecisionInfo.SourceKey]);
    }];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds[1]];
    OPTLYVariation *variation = experiment.variations[1];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertTrue([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return true for enabled featureFlag");
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [decisionServiceMock stopMocking];
    [(id)notificationCenterMock stopMocking];
}

// Should return true if the user is bucketed into rollout experiment’s variation
// and variation's featureEnabled is also true
- (void)testDecisionListenerForIsFeatureEnabledWithVariationsFeatureEnabledTrueForRollout {
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    NSString *featureFlagKey = @"booleanSingleVariableFeature";
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(featureFlagKey, decisionInfo[DecisionInfo.FeatureKey]);
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(true, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(DecisionSource.Rollout, decisionInfo[DecisionInfo.SourceKey]);
    }];
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments[0];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertTrue([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return true for enabled featureFlag");
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [decisionServiceMock stopMocking];
    [(id)notificationCenterMock stopMocking];
}

// Should return false if the user is bucketed into rollout experiment’s variation
// but variation's featureEnabled is false
- (void)testDecisionListenerForIsFeatureEnabledWithVariationsFeatureEnabledForRollout {
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    NSString *featureFlagKey = @"booleanSingleVariableFeature";
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(featureFlagKey, decisionInfo[DecisionInfo.FeatureKey]);
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(DecisionSource.Rollout, decisionInfo[DecisionInfo.SourceKey]);
    }];
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = rollout.experiments[1];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertFalse([self.optimizely isFeatureEnabled:featureFlagKey userId:kUserId attributes:nil], @"should return false for disabled featureFlag");
    
    OCMVerify([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [decisionServiceMock stopMocking];
    [(id)notificationCenterMock stopMocking];
}

#pragma mark - GetFeatureVariable<Type> Tests

- (void)testGetFeatureVariableBooleanNotBucketedInFeatureExperimentAndRollout {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyTrue = @"booleanVariable";
    
    NSString *expectedValueString = @"false";
    BOOL expectedValue = false;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:nil variation:nil source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableBoolean:featureKey variableKey:variableKeyTrue userId:kUserId attributes:nil] boolValue],
                   @"should return %@ for feature variable value %@", expectedValue ? @"true" : @"false", expectedValueString);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableBooleanInExperimentWithFeatureEnabledFalse {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyTrue = @"booleanVariable";
    
    NSString *expectedValueString = @"false";
    BOOL expectedValue = false;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:@"6358043287"];
    OPTLYVariation *variation = experiment.variations[2];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableBoolean:featureKey variableKey:variableKeyTrue userId:kUserId attributes:nil] boolValue],
                   @"should return %@ for feature variable value %@", expectedValue ? @"true" : @"false", expectedValueString);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableBooleanInRolloutWithFeatureEnabledFalse {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyTrue = @"booleanVariable";
    
    NSString *expectedValueString = @"false";
    BOOL expectedValue = false;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments[1];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableBoolean:featureKey variableKey:variableKeyTrue userId:kUserId attributes:nil] boolValue],
                   @"should return %@ for feature variable value %@", expectedValue ? @"true" : @"false", expectedValueString);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableBooleanInExperimentWithFeatureEnabledTrue {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyTrue = @"booleanVariable";
    
    NSString *expectedValueString = @"true";
    BOOL expectedValue = true;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:@"6358043287"];
    OPTLYVariation *variation = experiment.variations[3];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableBoolean:featureKey variableKey:variableKeyTrue userId:kUserId attributes:nil] boolValue],
                   @"should return %@ for feature variable value %@", expectedValue ? @"true" : @"false", expectedValueString);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableBooleanInRolloutWithFeatureEnabledTrue {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyTrue = @"booleanVariable";
    
    NSString *expectedValueString = @"true";
    BOOL expectedValue = true;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments[0];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableBoolean:featureKey variableKey:variableKeyTrue userId:kUserId attributes:nil] boolValue],
                   @"should return %@ for feature variable value %@", expectedValue ? @"true" : @"false", expectedValueString);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableBooleanWithTrue {
    NSString *featureKey = @"featureKey";
    NSString *variableKeyTrue = @"varTrue";
    NSString *featureVariableType = FeatureVariableTypeBoolean;
    
    // expectations
    NSString *expectedValueString = @"true";
    BOOL expectedValue = true;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyTrue expectedReturn:expectedValueString];
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableBoolean:featureKey variableKey:variableKeyTrue userId:kUserId attributes:nil] boolValue],
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
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableBoolean:featureKey variableKey:variableKeyFalse userId:kUserId attributes:nil] boolValue],
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
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableBoolean:featureKey variableKey:variableKeyNonBoolean userId:kUserId attributes:nil] boolValue],
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
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableBoolean:featureKey variableKey:variableKeyNull userId:kUserId attributes:nil] boolValue],
                   @"should return %@ for feature variable value %@", expectedValue ? @"true" : @"false", expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyNull
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableDoubleNotBucketedInFeatureExperimentAndRollout {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyDouble = @"doubleVariable";
    NSString *expectedValueString = @"14.99";
    double expectedValue = 14.99;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:nil variation:nil source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableDouble:featureKey variableKey:variableKeyDouble userId:kUserId attributes:nil] doubleValue],
                   @"should return %f for feature variable value %@", expectedValue, expectedValueString);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableDoubleInExperimentWithFeatureEnabledFalse {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyDouble = @"doubleVariable";
    NSString *expectedValueString = @"14.99";
    double expectedValue = 14.99;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:@"6358043287"];
    OPTLYVariation *variation = experiment.variations[2];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableDouble:featureKey variableKey:variableKeyDouble userId:kUserId attributes:nil] doubleValue],
                   @"should return %f for feature variable value %@", expectedValue, expectedValueString);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableDoubleInRolloutWithFeatureEnabledFalse {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyDouble = @"doubleVariable";
    NSString *expectedValueString = @"14.99";
    double expectedValue = 14.99;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments[1];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableDouble:featureKey variableKey:variableKeyDouble userId:kUserId attributes:nil] doubleValue],
                   @"should return %f for feature variable value %@", expectedValue, expectedValueString);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableDoubleInExperimentWithFeatureEnabledTrue {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyDouble = @"doubleVariable";
    NSString *expectedValueString = @"42.42";
    double expectedValue = 42.42;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:@"6358043287"];
    OPTLYVariation *variation = experiment.variations[3];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableDouble:featureKey variableKey:variableKeyDouble userId:kUserId attributes:nil] doubleValue],
                   @"should return %f for feature variable value %@", expectedValue, expectedValueString);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableDoubleInRolloutWithFeatureEnabledTrue{
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyDouble = @"doubleVariable";
    NSString *expectedValueString = @"42.42";
    double expectedValue = 42.42;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments[0];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableDouble:featureKey variableKey:variableKeyDouble userId:kUserId attributes:nil] doubleValue],
                   @"should return %f for feature variable value %@", expectedValue, expectedValueString);
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
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableDouble:featureKey variableKey:variableKeyDouble userId:kUserId attributes:nil] doubleValue],
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
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableDouble:featureKey variableKey:variableKeyInt userId:kUserId attributes:nil] doubleValue],
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
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableDouble:featureKey variableKey:variableKeyNonDouble userId:kUserId attributes:nil] doubleValue],
                   @"should return nil for feature variable value %@", expectedValueString);
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
    NSNumber* expectedValue = nil;
    id optimizelyMock = [self getOptimizelyMockForFeatureVariableType:featureVariableType variableKey:variableKeyNull expectedReturn:expectedValueString];
    XCTAssertEqual(expectedValue, [optimizelyMock getFeatureVariableDouble:featureKey variableKey:variableKeyNull userId:kUserId attributes:nil],
                   @"should return nil for feature variable value %@", expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyNull
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableIntegerNotBucketedInFeatureExperimentAndRollout {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyDouble = @"someInteger";
    NSString *expectedValueString = @"1";
    int expectedValue = 1;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:nil variation:nil source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableInteger:featureKey variableKey:variableKeyDouble userId:kUserId attributes:nil] integerValue],
                   @"should return %d for feature variable value %@", expectedValue, expectedValueString);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableIntegerInExperimentWithFeatureEnabledFalse {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyDouble = @"someInteger";
    NSString *expectedValueString = @"1";
    int expectedValue = 1;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:@"6358043287"];
    OPTLYVariation *variation = experiment.variations[2];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableInteger:featureKey variableKey:variableKeyDouble userId:kUserId attributes:nil] integerValue],
                   @"should return %d for feature variable value %@", expectedValue, expectedValueString);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableIntegerInRolloutWithFeatureEnabledFalse {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyDouble = @"someInteger";
    NSString *expectedValueString = @"1";
    int expectedValue = 1;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments[1];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableInteger:featureKey variableKey:variableKeyDouble userId:kUserId attributes:nil] integerValue],
                   @"should return %d for feature variable value %@", expectedValue, expectedValueString);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableIntegerInExperimentWithFeatureEnabledTrue {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyDouble = @"someInteger";
    NSString *expectedValueString = @"2";
    int expectedValue = 2;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:@"6358043287"];
    OPTLYVariation *variation = experiment.variations[3];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableInteger:featureKey variableKey:variableKeyDouble userId:kUserId attributes:nil] integerValue],
                   @"should return %d for feature variable value %@", expectedValue, expectedValueString);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableIntegerInRolloutWithFeatureEnabledTrue {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyDouble = @"someInteger";
    NSString *expectedValueString = @"2";
    int expectedValue = 2;
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments[0];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableInteger:featureKey variableKey:variableKeyDouble userId:kUserId attributes:nil] integerValue],
                   @"should return %d for feature variable value %@", expectedValue, expectedValueString);
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
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableInteger:featureKey variableKey:variableKeyInt userId:kUserId attributes:nil] integerValue],
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
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableInteger:featureKey variableKey:variableKeyDouble userId:kUserId attributes:nil] integerValue],
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
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableInteger:featureKey variableKey:variableNonInt userId:kUserId attributes:nil] integerValue],
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
    XCTAssertEqual(expectedValue, [[optimizelyMock getFeatureVariableInteger:featureKey variableKey:variableKeyNull userId:kUserId attributes:nil] integerValue],
                   @"should return %d for feature variable value %@", expectedValue, expectedValueString);
    OCMVerify([optimizelyMock getFeatureVariableValueForType:featureVariableType
                                                  featureKey:featureKey
                                                 variableKey:variableKeyNull
                                                      userId:kUserId
                                                  attributes:nil]);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableStringNotBucketedInFeatureExperimentAndRollout {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyString = @"stringVariable";
    NSString *expectedValue = @"wingardium leviosa";
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:nil variation:nil source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqualObjects(expectedValue, [optimizelyMock getFeatureVariableString:featureKey variableKey:variableKeyString userId:kUserId attributes:nil],
                          @"should return %@ for feature variable value %@", expectedValue, expectedValue);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableStringInExperimentWithFeatureEnabledFalse {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyString = @"stringVariable";
    NSString *expectedValue = @"wingardium leviosa";
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:@"6358043287"];
    OPTLYVariation *variation = experiment.variations[2];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqualObjects(expectedValue, [optimizelyMock getFeatureVariableString:featureKey variableKey:variableKeyString userId:kUserId attributes:nil],
                          @"should return %@ for feature variable value %@", expectedValue, expectedValue);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableStringInRolloutWithFeatureEnabledFalse {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyString = @"stringVariable";
    NSString *expectedValue = @"wingardium leviosa";
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments[1];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqualObjects(expectedValue, [optimizelyMock getFeatureVariableString:featureKey variableKey:variableKeyString userId:kUserId attributes:nil],
                   @"should return %@ for feature variable value %@", expectedValue, expectedValue);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableStringInExperimentWithFeatureEnabledTrue {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyString = @"stringVariable";
    NSString *expectedValue = @"wing";
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:@"6358043287"];
    OPTLYVariation *variation = experiment.variations[3];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqualObjects(expectedValue, [optimizelyMock getFeatureVariableString:featureKey variableKey:variableKeyString userId:kUserId attributes:nil],
                          @"should return %@ for feature variable value %@", expectedValue, expectedValue);
    [optimizelyMock stopMocking];
}

- (void)testGetFeatureVariableStringInRolloutWithFeatureEnabledTrue {
    NSString *featureKey = @"featureEnabledFalse";
    NSString *variableKeyString = @"stringVariable";
    NSString *expectedValue = @"wing";
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments[0];
    OPTLYVariation *variation = experiment.variations[0];
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    OPTLYFeatureDecision *decision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(decision);
    
    // expectations
    XCTAssertEqualObjects(expectedValue, [optimizelyMock getFeatureVariableString:featureKey variableKey:variableKeyString userId:kUserId attributes:nil],
                          @"should return %@ for feature variable value %@", expectedValue, expectedValue);
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

#pragma mark - GetFeatureVariable<Type> Notification Tests

- (void)testGetFeatureVariableBooleanNotificationWithFeatureDisabledAndUserInExperiment {
    
    NSString *featureFlagKey = @"booleanSingleVariableFeature";
    NSString *variableKey = @"booleanVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments.firstObject;
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = false;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Experiment];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block BOOL expectedValue = false;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeBoolean, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects(@"177770", decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects(@"177771", decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(true, [decisionInfo[DecisionInfo.VariableValueKey] boolValue]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] boolValue];
    }];
    
    BOOL actualValue = [(NSNumber *)[self.optimizely getFeatureVariableBoolean:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] boolValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableBooleanNotificationWithFeatureEnabledAndUserInExperiment {
    
    NSString *featureFlagKey = @"booleanSingleVariableFeature";
    NSString *variableKey = @"booleanVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments.firstObject;
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = true;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Experiment];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block BOOL expectedValue = false;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(true, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeBoolean, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects(@"177770", decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects(@"177771", decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(true, [decisionInfo[DecisionInfo.VariableValueKey] boolValue]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] boolValue];
    }];
    
    BOOL actualValue = [(NSNumber *)[self.optimizely getFeatureVariableBoolean:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] boolValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableBooleanNotificationWithFeatureDisabledAndUserInRollout {
    
    NSString *featureFlagKey = @"booleanSingleVariableFeature";
    NSString *variableKey = @"booleanVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments.firstObject;
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = false;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Rollout];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block BOOL expectedValue = false;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(FeatureVariableTypeBoolean, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqual(true, [decisionInfo[DecisionInfo.VariableValueKey] boolValue]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] boolValue];
    }];
    
    BOOL actualValue = [(NSNumber *)[self.optimizely getFeatureVariableBoolean:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] boolValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableBooleanNotificationWithFeatureEnabledAndUserInRollout {
    
    NSString *featureFlagKey = @"booleanSingleVariableFeature";
    NSString *variableKey = @"booleanVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYRollout *rollout = [self.optimizely.config getRolloutForId:@"166660"];
    OPTLYExperiment *experiment = rollout.experiments.firstObject;
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = true;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Rollout];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block BOOL expectedValue = false;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(true, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeBoolean, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(true, [decisionInfo[DecisionInfo.VariableValueKey] boolValue]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] boolValue];
    }];
    
    BOOL actualValue = [(NSNumber *)[self.optimizely getFeatureVariableBoolean:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] boolValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableBooleanNotificationWithDecisionContainingNilVariationAndExperiment {
    
    NSString *featureFlagKey = @"booleanSingleVariableFeature";
    NSString *variableKey = @"booleanVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn([[OPTLYFeatureDecision alloc] initWithExperiment:nil variation:nil source:DecisionSource.Rollout]);
    
    __block BOOL expectedValue = false;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeBoolean, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(true, [decisionInfo[DecisionInfo.VariableValueKey] boolValue]);
        XCTAssertEqual(DecisionSource.Rollout, decisionInfo[DecisionInfo.SourceKey]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] boolValue];
    }];
    
    BOOL actualValue = [(NSNumber *)[self.optimizely getFeatureVariableBoolean:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] boolValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableDoubleNotificationWithFeatureDisabledAndUserInExperiment {
    
    NSString *featureFlagKey = @"doubleSingleVariableFeature";
    NSString *variableKey = @"doubleVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds.firstObject];
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = false;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Experiment];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block double expectedValue = 0;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeDouble, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects(@"testExperimentDoubleFeature", decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects(@"control", decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(14.99, [decisionInfo[DecisionInfo.VariableValueKey] doubleValue]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] doubleValue];
    }];
    
    double actualValue = [(NSNumber *)[self.optimizely getFeatureVariableDouble:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] doubleValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableDoubleNotificationWithFeatureEnabledAndUserInExperiment {
    
    NSString *featureFlagKey = @"doubleSingleVariableFeature";
    NSString *variableKey = @"doubleVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds.firstObject];
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = true;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Experiment];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block double expectedValue = 0;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(true, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeDouble, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects(@"testExperimentDoubleFeature", decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects(@"control", decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(42.42, [decisionInfo[DecisionInfo.VariableValueKey] doubleValue]);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] doubleValue];
    }];
    
    double actualValue = [(NSNumber *)[self.optimizely getFeatureVariableDouble:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] doubleValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableDoubleNotificationWithFeatureDisabledAndUserInRollout {
    
    NSString *featureFlagKey = @"doubleSingleVariableFeature";
    NSString *variableKey = @"doubleVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds.firstObject];
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = false;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Rollout];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block double expectedValue = 0;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeDouble, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(14.99, [decisionInfo[DecisionInfo.VariableValueKey] doubleValue]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] doubleValue];
    }];
    
    double actualValue = [(NSNumber *)[self.optimizely getFeatureVariableDouble:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] doubleValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableDoubleNotificationWithFeatureEnabledAndUserInRollout {
    
    NSString *featureFlagKey = @"doubleSingleVariableFeature";
    NSString *variableKey = @"doubleVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds.firstObject];
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = true;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Rollout];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block double expectedValue = 0;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(true, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeDouble, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(42.42, [decisionInfo[DecisionInfo.VariableValueKey] doubleValue]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] doubleValue];
    }];
    
    double actualValue = [(NSNumber *)[self.optimizely getFeatureVariableDouble:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] doubleValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableDoubleNotificationWithDecisionContainingNilVariationAndExperiment {
    
    NSString *featureFlagKey = @"doubleSingleVariableFeature";
    NSString *variableKey = @"doubleVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn([[OPTLYFeatureDecision alloc] initWithExperiment:nil variation:nil source:DecisionSource.Rollout]);
    
    __block double expectedValue = 0;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeDouble, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqual(14.99, [decisionInfo[DecisionInfo.VariableValueKey] doubleValue]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(DecisionSource.Rollout, decisionInfo[DecisionInfo.SourceKey]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] doubleValue];
    }];
    
    double actualValue = [(NSNumber *)[self.optimizely getFeatureVariableDouble:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] doubleValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableIntegerNotificationWithFeatureDisabledAndUserInExperiment {
    
    NSString *featureFlagKey = @"integerSingleVariableFeature";
    NSString *variableKey = @"integerVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds.firstObject];
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = false;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Experiment];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block int expectedValue = 0;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeInteger, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects(@"testExperimentDoubleFeature", decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects(@"control", decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(42, [decisionInfo[DecisionInfo.VariableValueKey] intValue]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] intValue];
    }];
    
    int actualValue = [(NSNumber *)[self.optimizely getFeatureVariableInteger:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] intValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableIntegerNotificationWithFeatureEnabledAndUserInExperiment {
    
    NSString *featureFlagKey = @"integerSingleVariableFeature";
    NSString *variableKey = @"integerVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds.firstObject];
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = true;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Experiment];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block int expectedValue = 0;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(true, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeInteger, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects(@"testExperimentDoubleFeature", decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects(@"control", decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(42, [decisionInfo[DecisionInfo.VariableValueKey] intValue]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] intValue];
    }];
    
    int actualValue = [(NSNumber *)[self.optimizely getFeatureVariableInteger:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] intValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableIntegerNotificationWithFeatureDisabledAndUserInRollout {
    
    NSString *featureFlagKey = @"integerSingleVariableFeature";
    NSString *variableKey = @"integerVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds.firstObject];
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = false;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Rollout];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block int expectedValue = 0;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeInteger, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(42, [decisionInfo[DecisionInfo.VariableValueKey] intValue]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] intValue];
    }];
    
    int actualValue = [(NSNumber *)[self.optimizely getFeatureVariableInteger:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] intValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableIntegerNotificationWithFeatureEnabledAndUserInRollout {
    
    NSString *featureFlagKey = @"integerSingleVariableFeature";
    NSString *variableKey = @"integerVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds.firstObject];
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = true;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Rollout];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block int expectedValue = 0;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(true, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeInteger, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(42, [decisionInfo[DecisionInfo.VariableValueKey] intValue]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] intValue];
    }];
    
    int actualValue = [(NSNumber *)[self.optimizely getFeatureVariableInteger:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] intValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableIntegerNotificationWithDecisionContainingNilVariationAndExperiment {
    
    NSString *featureFlagKey = @"integerSingleVariableFeature";
    NSString *variableKey = @"integerVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn([[OPTLYFeatureDecision alloc] initWithExperiment:nil variation:nil source:DecisionSource.Rollout]);
    
    __block int expectedValue = 0;
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeInteger, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqual(42, [decisionInfo[DecisionInfo.VariableValueKey] intValue]);
        XCTAssertEqual(DecisionSource.Rollout, decisionInfo[DecisionInfo.SourceKey]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = [decisionInfo[DecisionInfo.VariableValueKey] intValue];
    }];
    
    int actualValue = [(NSNumber *)[self.optimizely getFeatureVariableInteger:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}] intValue];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableStringNotificationWithFeatureDisabledAndUserInExperiment {
    
    NSString *featureFlagKey = @"stringSingleVariableFeature";
    NSString *variableKey = @"stringVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds.firstObject];
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = false;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Experiment];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block NSString *expectedValue = @"";
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeString, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects(@"testExperimentDoubleFeature", decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects(@"control", decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqualObjects(@"wingardium leviosa", decisionInfo[DecisionInfo.VariableValueKey]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = decisionInfo[DecisionInfo.VariableValueKey];
    }];
    
    NSString *actualValue = [self.optimizely getFeatureVariableString:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableStringNotificationWithFeatureEnabledAndUserInExperiment {
    
    NSString *featureFlagKey = @"stringSingleVariableFeature";
    NSString *variableKey = @"stringVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds.firstObject];
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = true;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Experiment];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block NSString *expectedValue = @"";
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(true, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeString, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects(@"testExperimentDoubleFeature", decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects(@"control", decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqualObjects(@"wingardium leviosa", decisionInfo[DecisionInfo.VariableValueKey]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = decisionInfo[DecisionInfo.VariableValueKey];
    }];
    
    NSString *actualValue = [self.optimizely getFeatureVariableString:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableStringNotificationWithFeatureDisabledAndUserInRollout {
    
    NSString *featureFlagKey = @"stringSingleVariableFeature";
    NSString *variableKey = @"stringVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds.firstObject];
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = false;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Rollout];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block NSString *expectedValue = @"";
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeString, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqualObjects(@"wingardium leviosa", decisionInfo[DecisionInfo.VariableValueKey]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = decisionInfo[DecisionInfo.VariableValueKey];
    }];
    
    NSString *actualValue = [self.optimizely getFeatureVariableString:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableStringNotificationWithFeatureEnabledAndUserInRollout {
    
    NSString *featureFlagKey = @"stringSingleVariableFeature";
    NSString *variableKey = @"stringVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureFlagKey];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForId:featureFlag.experimentIds.firstObject];
    OPTLYVariation *differentVariation = experiment.variations.firstObject;
    differentVariation.featureEnabled = true;
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Rollout];
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn(expectedDecision);
    
    __block NSString *expectedValue = @"";
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(true, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeString, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqualObjects(@"wingardium leviosa", decisionInfo[DecisionInfo.VariableValueKey]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = decisionInfo[DecisionInfo.VariableValueKey];
    }];
    
    NSString *actualValue = [self.optimizely getFeatureVariableString:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
}

- (void)testGetFeatureVariableStringNotificationWithDecisionContainingNilVariationAndExperiment {
    
    NSString *featureFlagKey = @"stringSingleVariableFeature";
    NSString *variableKey = @"stringVariable";
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    id decisionService = OCMPartialMock(self.optimizely.decisionService);
    OCMStub([decisionService getVariationForFeature:[OCMArg any] userId:[OCMArg any] attributes:[OCMArg any]]).andReturn([[OPTLYFeatureDecision alloc] initWithExperiment:nil variation:nil source:DecisionSource.Rollout]);
    
    __block NSString *expectedValue = @"";
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        XCTAssertEqual(FeatureVariableTypeString, decisionInfo[DecisionInfo.VariableTypeKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceVariationKey]);
        XCTAssertEqualObjects(@"wingardium leviosa", decisionInfo[DecisionInfo.VariableValueKey]);
        XCTAssertEqual(DecisionSource.Rollout, decisionInfo[DecisionInfo.SourceKey]);
        XCTAssertEqual(@{}, attributes);
        expectedValue = decisionInfo[DecisionInfo.VariableValueKey];
    }];
    
    NSString *actualValue = [self.optimizely getFeatureVariableString:featureFlagKey variableKey:variableKey userId:kUserId attributes:@{}];
    XCTAssertEqual(actualValue, expectedValue);
    OCMVerify([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]);
    [(id)notificationCenterMock stopMocking];
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
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:differentVariation source:DecisionSource.Experiment];
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
- (void)testGetFeatureVariableValueForTypeWithFeatureFlagIsEnabledAndVariableUsed {
    NSString *featureKey = @"doubleSingleVariableFeature";
    OPTLYFeatureFlag *featureFlag = [self.optimizely.config getFeatureFlagForKey:featureKey];
    NSString *variableKey = @"doubleVariable";
    NSString *variableType = FeatureVariableTypeDouble;
    NSNumber *expectedValue = [NSNumber numberWithDouble:14.99];
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:@"testExperimentDoubleFeature"];
    OPTLYVariation *variation = [experiment getVariationForVariationId:@"122239"];
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Experiment];
    
    id decisionServiceMock = OCMPartialMock(self.optimizely.decisionService);
    OCMStub([decisionServiceMock getVariationForFeature:featureFlag userId:kUserId attributes:nil]).andReturn(expectedDecision);
    
    NSNumber *value = [self.optimizely getFeatureVariableValueForType:variableType
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
    OPTLYFeatureDecision *expectedDecision = [[OPTLYFeatureDecision alloc] initWithExperiment:experiment variation:variation source:DecisionSource.Rollout];
    
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

#pragma mark - GetEnabledFeatures Tests

// should return empty feature array as no feature is enabled for user
- (void)testGetEnabledFeaturesWithNoFeatureEnabledForUser {
    id optimizelyMock = OCMPartialMock(self.optimizely.decisionService);
    OCMStub([optimizelyMock getVariationForFeature:[OCMArg any] userId:kUserId attributes:self.attributes]).andReturn(nil);
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    __block int callCount = 0;
    OCMStub([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]).andDo(^(NSInvocation *invocation)
                                                                                                        {
                                                                                                            ++callCount;
                                                                                                        });
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(self.attributes, attributes);
        XCTAssertEqualObjects(kUserId, userId);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
    }];
    
    XCTAssertEqual([self.optimizely getEnabledFeatures:kUserId attributes:self.attributes].count, 0);
    OCMVerify([optimizelyMock getVariationForFeature:[OCMArg any] userId:kUserId attributes:self.attributes]);
    int expectedNumberOfCalls = 12;
    [optimizelyMock stopMocking];
    XCTAssertEqual(callCount, expectedNumberOfCalls);
    [(id)notificationCenterMock stopMocking];
}

// should return feature array as some feature is enabled for user
- (void)testGetEnabledFeaturesWithSomeFeaturesEnabledForUser {
    OPTLYNotificationCenter *notificationCenterMock = OCMPartialMock(self.optimizely.notificationCenter);
    NSArray<NSString *> *enabledFeatures = @[@"booleanFeature", @"booleanSingleVariableFeature", @"multiVariateFeature", @"featureEnabledFalse"];
    
    __block int callCount = 0;
    OCMStub([(id)notificationCenterMock notifyDecisionListener:[OCMArg any] args:[OCMArg any]]).andDo(^(NSInvocation *invocation)
                                                                                                        {
                                                                                                            ++callCount;
                                                                                                        });
    [notificationCenterMock addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqualObjects(self.attributes, attributes);
        XCTAssertEqualObjects(kUserId, userId);
        if ([enabledFeatures containsObject:decisionInfo[DecisionInfo.FeatureKey]]) {
            XCTAssertEqual(true, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        }
        else {
            XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.FeatureEnabledKey] boolValue]);
        }
    }];
    
    int expectedNumberOfCalls = 12;
    NSArray<NSString *> *features = [self.optimizely getEnabledFeatures:kUserId attributes:self.attributes];
    XCTAssertEqualObjects(features, enabledFeatures);
    XCTAssertEqual(callCount, expectedNumberOfCalls);
    [(id)notificationCenterMock stopMocking];
}

#pragma mark - TypedAudiences Tests

- (void)testActivateWithTypedAudiencesWithExactMatchType {
    // Should be included via exact match string audience with id '3468206642'
    NSDictionary<NSString *, id> *expectedAttributes = @{
                                                                 @"house": @"Gryffindor"
                                                                 };
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    OPTLYVariation *variation = [self.optimizelyTypedAudience activate:@"typed_audience_experiment" userId:@"user1" attributes:expectedAttributes callback:^(NSError *error) {
    }];
    XCTAssertEqualObjects(@"A", variation.variationKey);
    [expectation fulfill];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
    
    // Should be included via exact match number audience with id '3468206646'
    expectedAttributes = @{
                           @"lasers": @45.5
                           };
    expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    variation = [self.optimizelyTypedAudience activate:@"typed_audience_experiment" userId:@"user1" attributes:expectedAttributes callback:^(NSError *error) {
    }];
    XCTAssertEqualObjects(@"A", variation.variationKey);
    [expectation fulfill];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
    
    // Should be included via exact match bool audience with id '3468206643'
    expectedAttributes = @{
                           @"should_do_it": @YES
                           };
    expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    variation = [self.optimizelyTypedAudience activate:@"typed_audience_experiment" userId:@"user1" attributes:expectedAttributes callback:^(NSError *error) {
    }];
    XCTAssertEqualObjects(@"A", variation.variationKey);
    [expectation fulfill];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testActivateWithTypedAudiencesWithSubstringMatchType {
    // Should be included via substring match string audience with id '3988293898'
    NSDictionary<NSString *, id> *expectedAttributes = @{
                                                                 @"house": @"222Slytherin"
                                                                 };
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    OPTLYVariation *variation = [self.optimizelyTypedAudience activate:@"typed_audience_experiment" userId:@"user1" attributes:expectedAttributes callback:^(NSError *error) {
    }];
    XCTAssertEqualObjects(@"A", variation.variationKey);
    [expectation fulfill];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testActivateWithTypedAudiencesWithExistsMatchType {
    // Should be included via exists match string audience with id '3988293899'
    NSDictionary<NSString *, id> *expectedAttributes = @{
                                                                 @"favorite_ice_cream": @1
                                                                 };
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    OPTLYVariation *variation = [self.optimizelyTypedAudience activate:@"typed_audience_experiment" userId:@"user1" attributes:expectedAttributes callback:^(NSError *error) {
    }];
    XCTAssertEqualObjects(@"A", variation.variationKey);
    [expectation fulfill];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testActivateWithTypedAudiencesWithLtMatchType {
    // Should be included via lt match number audience with id '3468206644'
    NSDictionary<NSString *, id> *expectedAttributes = @{
                                                                 @"lasers": @0.8
                                                                 };
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    OPTLYVariation *variation = [self.optimizelyTypedAudience activate:@"typed_audience_experiment" userId:@"user1" attributes:expectedAttributes callback:^(NSError *error) {
    }];
    XCTAssertEqualObjects(@"A", variation.variationKey);
    [expectation fulfill];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testActivateWithTypedAudiencesWithGtMatchType {
    // Should be included via gt match number audience with id '3468206647'
    NSDictionary<NSString *, id> *expectedAttributes = @{
                                                                 @"lasers": @71
                                                                 };
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    OPTLYVariation *variation = [self.optimizelyTypedAudience activate:@"typed_audience_experiment" userId:@"user1" attributes:expectedAttributes callback:^(NSError *error) {
    }];
    XCTAssertEqualObjects(@"A", variation.variationKey);
    [expectation fulfill];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testActivateExcludesUserFromExperimentWithTypedAudiences {
    NSDictionary<NSString *, id> *expectedAttributes = @{
                                                                 @"house": @"Hufflepuff"
                                                                 };
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    OPTLYVariation *variation = [self.optimizelyTypedAudience activate:@"typed_audience_experiment" userId:@"user1" attributes:expectedAttributes callback:^(NSError *error) {
    }];
    XCTAssertNil(variation);
    [expectation fulfill];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testTrackWithTypedAudiences {
    NSString *eventId = @"item_bought";
    NSString *userId = @"user1";
    NSDictionary<NSString *, id> *attributes = @{
                                                         @"house": @"Welcome to Slytherin!"
                                                         };
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizely.logger);
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.typedAudienceDatafile;
        builder.logger = loggerMock;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    [optimizely track:eventId userId:userId attributes:attributes];
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherAttemptingToSendConversionEvent, eventId, userId];
    OCMVerify([loggerMock logMessage:logMessage withLevel:OptimizelyLogLevelInfo]);
    [loggerMock stopMocking];
}

- (void)testTrackExcludesUserFromExperimentWithTypedAudiences {
    NSString *eventId = @"item_bought";
    NSString *userId = @"user1";
    NSDictionary<NSString *, id> *attributes = @{
                                                         @"house": @"Hufflepuff"
                                                         };
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizely.logger);
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.typedAudienceDatafile;
        builder.logger = loggerMock;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    [optimizely track:eventId userId:userId attributes:attributes];
    [loggerMock verify];
    [loggerMock stopMocking];
}

- (void)testIsFeatureEnabledWithTypedAudiences {
    NSString *featureFlagKey = @"feat";
    NSString *userId = @"user1";
    NSDictionary<NSString *, id> *attributes = @{
                                                         @"favorite_ice_cream": @"chocolate"
                                                         };
    XCTAssertTrue([self.optimizelyTypedAudience isFeatureEnabled:featureFlagKey userId:userId attributes:attributes]);
    
    attributes = @{
                   @"lasers": @45.5
                   };
    XCTAssertTrue([self.optimizelyTypedAudience isFeatureEnabled:featureFlagKey userId:userId attributes:attributes]);
}

- (void)testIsFeatureEnabledExcludesUserFromExperimentWithTypedAudiences {
    NSString *featureFlagKey = @"feat";
    NSString *userId = @"user1";
    NSDictionary<NSString *, id> *attributes = @{
                                                         };
    XCTAssertFalse([self.optimizelyTypedAudience isFeatureEnabled:featureFlagKey userId:userId attributes:attributes]);
}

- (void)testGetFeatureVariableStringReturnsVariableValueWithTypedAudiences {
    NSString *featureKey = @"feat_with_var";
    NSString *variableKey = @"x";
    NSString *userId = @"user1";
    NSDictionary<NSString *, id> *attributes = @{
                                                         @"lasers": @71
                                                         };
    NSString *featureVariable = [self.optimizelyTypedAudience getFeatureVariableValueForType:FeatureVariableTypeString featureKey:featureKey variableKey:variableKey userId:userId attributes:attributes];
    XCTAssertEqualObjects(featureVariable, @"xyz");
    
    attributes = @{
                   @"should_do_it": @YES
                   };
    featureVariable = [self.optimizelyTypedAudience getFeatureVariableValueForType:FeatureVariableTypeString featureKey:featureKey variableKey:variableKey userId:userId attributes:attributes];
    XCTAssertEqualObjects(featureVariable, @"xyz");
}

- (void)testGetFeatureVariableStringReturnsDefaultVariableValueWithTypedAudiences {
    NSString *featureKey = @"feat_with_var";
    NSString *variableKey = @"x";
    NSString *userId = @"user1";
    NSDictionary<NSString *, id> *attributes = @{
                                                         @"lasers": @50
                                                         };
    NSString *featureVariable = [self.optimizelyTypedAudience getFeatureVariableValueForType:FeatureVariableTypeString featureKey:featureKey variableKey:variableKey userId:userId attributes:attributes];
    XCTAssertEqualObjects(featureVariable, @"x");
}

#pragma mark - Audience Combination Tests

//Test that activate calls dispatch_event with right params and returns expected
//variation when attributes are provided and complex audience conditions are met.

- (void)testActivateWithAttributesComplexAudienceAndMatchingAttributes {
    
     Optimizely *_optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:@"audience_targeting"];
        builder.logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelOff];;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    
    NSDictionary<NSString *, id> *userAttributes = @{
                                                             @"s_foo": @"foo",
                                                             @"b_true": @"N/A",
                                                             @"i_42": @43,
                                                             @"d_4_2": @4.2
                                                             };
    
    OPTLYVariation *variation = [_optimizely activate:@"ab_running_exp_audience_combo_exact_foo_and__42_or_4_2" userId:@"test_user_1" attributes:userAttributes callback:^(NSError *error) {
    }];
    XCTAssertEqualObjects(@"all_traffic_variation", variation.variationKey);
    
    userAttributes = @{
                       @"s_foo": @"foo",
                       @"b_true": @"N/A",
                       @"i_42": @42,
                       @"d_4_2": @4.3
                       };
    
    variation = [_optimizely activate:@"ab_running_exp_audience_combo_exact_foo_and__42_or_4_2" userId:@"test_user_1" attributes:userAttributes callback:^(NSError *error) {
    }];
    XCTAssertEqualObjects(@"all_traffic_variation", variation.variationKey);
}

- (void)testActivateWithAttributesComplexAudienceAndNoMatchingAttributes {
    
    Optimizely *_optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:@"audience_targeting"];
        builder.logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelOff];;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    
    NSDictionary<NSString *, id> *userAttributes = @{
                                                             @"s_foo": [NSNull null],
                                                             @"b_true": @"N/A",
                                                             @"i_42": @"N/A",
                                                             @"d_4_2": @"N/A"
                                                             };
    
    OPTLYVariation *variation = [_optimizely activate:@"ab_running_exp_audience_combo_not_foo" userId:@"test_user_1" attributes:userAttributes callback:^(NSError *error) {
    }];
    XCTAssertEqualObjects(nil, variation.variationKey);
    
    userAttributes = @{
                       @"s_foo": @"not_foo",
                       @"b_true": @"N/A",
                       @"i_42": [NSNull null],
                       @"d_4_2": @"N/A"
                       };
    
    variation = [_optimizely activate:@"ab_running_exp_audience_combo_not_foo__and__not_42" userId:@"test_user_1" attributes:userAttributes callback:^(NSError *error) {
    }];
    XCTAssertEqualObjects(nil, variation.variationKey);
}

- (void)testActivateWithAttributesComplexAudienceMatch {
    
    NSDictionary<NSString *, id> *userAttributes = @{
                                                             @"house": @"Welcome to Slytherin!",
                                                             @"lasers": @45.5
                                                             };
    NSDictionary<NSString *, id> *expectedAttributes1 = @{
                                                                  @"shouldIndex": @1,
                                                                  @"type": @"custom",
                                                                  @"value": @45.5,
                                                                  @"entity_id": @"594016",
                                                                  @"key": @"lasers"
                                                                  };
    NSDictionary<NSString *, id> *expectedAttributes2 = @{
                                                                  @"shouldIndex": @1,
                                                                  @"type": @"custom",
                                                                  @"value": @"Welcome to Slytherin!",
                                                                  @"entity_id": @"594015",
                                                                  @"key": @"house"
                                                                  };
    
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    
    __weak id weakSelf = self;
    [self.optimizelyTypedAudience.notificationCenter addActivateNotificationListener:^(OPTLYExperiment *experiment, NSString *userId, NSDictionary<NSString *, id> *attributes, OPTLYVariation *variation, NSDictionary<NSString *,NSString *> *event) {
        id self = weakSelf;
        NSDictionary *visitors = [(NSArray *)event[@"visitors"] firstObject];
        NSArray *_attributes = (NSArray *)visitors[@"attributes"];
        XCTAssertTrue([_attributes containsObject:expectedAttributes1]);
        XCTAssertTrue([_attributes containsObject:expectedAttributes2]);
        [expectation fulfill];
    }];
    
    OPTLYVariation *variation = [self.optimizelyTypedAudience activate:@"audience_combinations_experiment" userId:@"test_user" attributes:userAttributes callback:^(NSError *error) {
    }];
    XCTAssertEqualObjects(@"A", variation.variationKey);
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

//Test that activate returns None when complex audience conditions do not match.
- (void)testActivateWithAttributesComplexAudienceMismatch {
    
    NSDictionary<NSString *, id> *userAttributes = @{
                                                             @"house": @"Hufflepuff",
                                                             @"lasers": @45.5
                                                             };
    
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getActivatedVariation"];
    OPTLYExperiment *experiment = [self.optimizelyTypedAudience.config getExperimentForKey:@"audience_combinations_experiment"];
    OPTLYVariation *variation = [self.optimizelyTypedAudience variation:@"audience_combinations_experiment" userId:@"test_user" attributes:self.attributes];
    id optimizelyMock = OCMPartialMock(self.optimizelyTypedAudience);
    
    OPTLYVariation *_variation = [self.optimizelyTypedAudience activate:@"audience_combinations_experiment" userId:@"test_user" attributes:userAttributes callback:^(NSError *error) {
        [expectation fulfill];
    }];
    
    // SendImpressionEvent() does not get called.
    OCMReject([optimizelyMock sendImpressionEventFor:experiment variation:variation userId:@"test_user" attributes:userAttributes callback:[OCMArg any]]);
    [optimizelyMock stopMocking];
    
    XCTAssertNil(_variation);
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

//Test that track calls Notification Listener with right params when attributes are provided
//and it's a complex audience match.
- (void)testTrackWithAttributesComplexAudienceMatch {
    
    NSDictionary<NSString *, id> *userAttributes = @{
                                                             @"house": @"Gryffindor",
                                                             @"should_do_it": @YES
                                                             };
    NSDictionary<NSString *, id> *expectedAttributes1 = @{
                                                                  @"shouldIndex": @1,
                                                                  @"type": @"custom",
                                                                  @"value": @"Gryffindor",
                                                                  @"entity_id": @"594015",
                                                                  @"key": @"house"
                                                                  };
    NSDictionary<NSString *, id> *expectedAttributes2 = @{
                                                                  @"shouldIndex": @1,
                                                                  @"type": @"custom",
                                                                  @"value": @YES,
                                                                  @"entity_id": @"594017",
                                                                  @"key": @"should_do_it"
                                                                  };
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"trackedSuccessfuly"];
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizelyTypedAudience.logger);
    
    __weak id weakSelf = self;
    [self.optimizelyTypedAudience.notificationCenter addTrackNotificationListener:^(NSString * _Nonnull eventKey, NSString * _Nonnull userId, NSDictionary<NSString *, id> * _Nonnull attributes, NSDictionary * _Nonnull eventTags, NSDictionary<NSString *,NSObject *> * _Nonnull event) {
        id self = weakSelf;
        NSDictionary *visitors = [(NSArray *)event[@"visitors"] firstObject];
        NSArray *_attributes = (NSArray *)visitors[@"attributes"];
        XCTAssertTrue([_attributes containsObject:expectedAttributes1]);
        XCTAssertTrue([_attributes containsObject:expectedAttributes2]);
        [expectation fulfill];
    }];
    
    [self.optimizelyTypedAudience track:@"user_signed_up" userId:@"test_user" attributes:userAttributes];
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherAttemptingToSendConversionEvent, @"user_signed_up", @"test_user"];
    OCMVerify([loggerMock logMessage:logMessage withLevel:OptimizelyLogLevelInfo]);
    [loggerMock stopMocking];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

//Test that track does not call dispatch_event when complex audience conditions do not match.
- (void)testTrackWithAttributesComplexAudienceMismatch {
    
    NSDictionary<NSString *, id> *userAttributes = @{
                                                             @"house": @"Gryffindor",
                                                             @"should_do_it": @false
                                                             };
    
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizelyTypedAudience.logger);
    
    [self.optimizelyTypedAudience track:@"user_signed_up" userId:@"test_user" attributes:userAttributes];
    [loggerMock verify];
    [loggerMock stopMocking];
}

//Test that isFeatureEnabled returns True for feature rollout with complex audience match.
- (void)testIsFeatureEnabledInRolloutComplexAudienceMatch {
    NSDictionary<NSString *, id> *userAttributes = @{
                                                             @"house": @"...Slytherinnn...sss.",
                                                             @"favorite_ice_cream": @"matcha"
                                                             };
    NSString *featureFlagKey = @"feat2";
    XCTAssertTrue([self.optimizelyTypedAudience isFeatureEnabled:featureFlagKey userId:@"test_user" attributes:userAttributes]);
}

//Test that isFeatureEnabled returns False for feature rollout with complex audience mismatch.
- (void)testIsFeatureEnabledInRolloutComplexAudienceMismatch {
    NSDictionary<NSString *, id> *userAttributes = @{
                                                             @"house": @"Lannister"
                                                             };
    NSString *featureFlagKey = @"feat2";
    XCTAssertFalse([self.optimizelyTypedAudience isFeatureEnabled:featureFlagKey userId:@"test_user" attributes:userAttributes]);
}

//Test that getFeatureVariableInteger return variable value with complex audience match.
- (void)testGetFeatureVariableReturnsVariableValueComplexAudienceMatch {
    NSDictionary<NSString *, id> *userAttributes = @{
                                                             @"house": @"Gryffindor",
                                                             @"lasers": @700
                                                             };
    XCTAssertEqual([[self.optimizelyTypedAudience getFeatureVariableInteger:@"feat2_with_var" variableKey:@"z" userId:@"user1" attributes:userAttributes] integerValue], 150);
}

//Test that getFeatureVariableInteger return default value with complex audience mismatch.
- (void)testGetFeatureVariableReturnsDefaultValueComplexAudienceMatch {
    XCTAssertEqual([[self.optimizelyTypedAudience getFeatureVariableInteger:@"feat2_with_var" variableKey:@"z" userId:@"user1" attributes:@{}] integerValue], 10);
}

#pragma mark - setForcedVariation

- (void)testSetForcedVariationWithNullAndEmptyUserId
{
    XCTAssertFalse([self.optimizely setForcedVariation:kExperimentKeyForFV
                                                userId:[NSNull null]
                                          variationKey:kVariationKeyForFV]);
    XCTAssertTrue([self.optimizely setForcedVariation:kExperimentKeyForFV
                                               userId:@""
                                         variationKey:kVariationKeyForFV]);
    OPTLYVariation *variation = [self.optimizely getForcedVariation:kExperimentKeyForFV userId:@""];
    XCTAssertEqualObjects(variation.variationKey, kVariationKeyForFV);
}

- (void)testSetForcedVariationWithInvalidExperimentKey
{
    XCTAssertFalse([self.optimizely setForcedVariation:@"invalid"
                                                userId:kUserIdForFV
                                          variationKey:kVariationKeyForFV]);
    XCTAssertFalse([self.optimizely setForcedVariation:@""
                                                userId:kUserIdForFV
                                          variationKey:kVariationKeyForFV]);
    XCTAssertFalse([self.optimizely setForcedVariation:[NSNull null]
                                                userId:kUserIdForFV
                                          variationKey:kVariationKeyForFV]);
}

- (void)testSetForcedVariationWithInvalidVariationKey
{
    XCTAssertFalse([self.optimizely setForcedVariation:kExperimentKeyForFV
                                                userId:kUserIdForFV
                                          variationKey:@"invalid"]);
    XCTAssertFalse([self.optimizely setForcedVariation:kExperimentKeyForFV
                                                userId:kUserIdForFV
                                          variationKey:@""]);
}

- (void)testGetForcedVariationWithInvalidUserID
{
    XCTAssertTrue([self.optimizely setForcedVariation:kExperimentKeyForFV
                                                userId:kUserIdForFV
                                          variationKey:kVariationKeyForFV]);
    XCTAssertNil([self.optimizely getForcedVariation:kExperimentKeyForFV userId:[NSNull null]]);
    XCTAssertNil([self.optimizely getForcedVariation:kExperimentKeyForFV userId:@"invalid"]);
}

- (void)testGetForcedVariationWithInvalidExperimentKey
{
    XCTAssertTrue([self.optimizely setForcedVariation:kExperimentKeyForFV
                                               userId:kUserIdForFV
                                         variationKey:kVariationKeyForFV]);
    XCTAssertNil([self.optimizely getForcedVariation:@"invalid" userId:kUserIdForFV]);
    XCTAssertNil([self.optimizely getForcedVariation:[NSNull null] userId:kUserIdForFV]);
    XCTAssertNil([self.optimizely getForcedVariation:@"" userId:kUserIdForFV]);
}

#pragma mark - Test ValidateStringInputs

- (void)testValidateStringInputsWithValidValuesReturnTrue
{
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizely.logger);
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.datafile;
        builder.logger = loggerMock;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    NSMutableDictionary<NSString *, NSString *> *logs = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                          OPTLYNotificationExperimentKey:@"testMessage"}];
    NSMutableDictionary<NSString *, NSString *> *dictionary = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                OPTLYNotificationExperimentKey:@"test_experiment"}];
    XCTAssertTrue([optimizely validateStringInputs:dictionary logs:logs]);
    OCMReject([loggerMock logMessage:@"testMessage" withLevel:OptimizelyLogLevelError]);
    [loggerMock stopMocking];
}

- (void)testValidateStringInputsWithEmptyValueReturnFalse
{
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizely.logger);
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.datafile;
        builder.logger = loggerMock;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    
    NSMutableDictionary<NSString *, NSString *> *logs = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                          OPTLYNotificationEventKey:@"testMessage"}];
    NSMutableDictionary<NSString *, NSString *> *dictionary = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                OPTLYNotificationEventKey:@""}];
    XCTAssertFalse([optimizely validateStringInputs:dictionary logs:logs]);
    OCMVerify([loggerMock logMessage:@"testMessage" withLevel:OptimizelyLogLevelError]);
    [loggerMock stopMocking];
}

- (void)testValidateStringInputsWithNullValueReturnFalse
{
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizely.logger);
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.datafile;
        builder.logger = loggerMock;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    
    NSMutableDictionary<NSString *, NSString *> *logs = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                          OPTLYNotificationEventKey:@"testMessage"}];
    NSMutableDictionary<NSString *, NSString *> *dictionary = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                OPTLYNotificationEventKey:[NSNull null]}];
    XCTAssertFalse([optimizely validateStringInputs:dictionary logs:logs]);
    OCMVerify([loggerMock logMessage:@"testMessage" withLevel:OptimizelyLogLevelError]);
    [loggerMock stopMocking];
}

- (void)testValidateStringInputsWithValidUserIdReturnTrue
{
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizely.logger);
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.datafile;
        builder.logger = loggerMock;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    
    NSMutableDictionary<NSString *, NSString *> *logs = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                          OPTLYNotificationUserIdKey:@"testMessage"}];
    NSMutableDictionary<NSString *, NSString *> *dictionary = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                          OPTLYNotificationUserIdKey:@"testUser"}];
    XCTAssertTrue([optimizely validateStringInputs:dictionary logs:logs]);
    OCMReject([loggerMock logMessage:@"testMessage" withLevel:OptimizelyLogLevelError]);
    [loggerMock stopMocking];
}

- (void)testValidateStringInputsWithEmptyUserIdReturnTrue
{
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizely.logger);
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.datafile;
        builder.logger = loggerMock;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    
    NSMutableDictionary<NSString *, NSString *> *logs = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                          OPTLYNotificationUserIdKey:@"testMessage"}];
    NSMutableDictionary<NSString *, NSString *> *dictionary = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                OPTLYNotificationUserIdKey:@""}];
    XCTAssertTrue([optimizely validateStringInputs:dictionary logs:logs]);
    OCMReject([loggerMock logMessage:@"testMessage" withLevel:OptimizelyLogLevelError]);
    [loggerMock stopMocking];
}

- (void)testValidateStringInputsWithNullUserIdReturnFalse
{
    id loggerMock = OCMPartialMock((OPTLYLoggerDefault *)self.optimizely.logger);
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.datafile;
        builder.logger = loggerMock;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    
    NSMutableDictionary<NSString *, NSString *> *logs = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                          OPTLYNotificationUserIdKey:@"testMessage"}];
    NSMutableDictionary<NSString *, NSString *> *dictionary = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                 OPTLYNotificationUserIdKey:[NSNull null]}];
    XCTAssertFalse([optimizely validateStringInputs:dictionary logs:logs]);
    OCMVerify([loggerMock logMessage:@"testMessage" withLevel:OptimizelyLogLevelError]);
    [loggerMock stopMocking];
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

