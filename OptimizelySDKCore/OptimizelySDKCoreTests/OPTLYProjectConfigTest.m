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
#import "OPTLYAttribute.h"
#import "OPTLYAudience.h"
#import "OPTLYBucketer.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYEvent.h"
#import "OPTLYExperiment.h"
#import "OPTLYGroup.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYUserProfileServiceBasic.h"
#import "OPTLYTestHelper.h"
#import "OPTLYVariation.h"
#import "OPTLYFeatureFlag.h"
#import "OPTLYRollout.h"
#import "OPTLYFeatureVariable.h"
#import "OPTLYVariableUsage.h"
#import "OPTLYControlAttributes.h"
// Live Variables (DEPRECATED)
#import "OPTLYVariable.h"

// static data from datafile
static NSString * const kClientEngine = @"objective-c-sdk";
static NSString * const kDataModelDatafileName = @"optimizely_6372300739_v4";
static NSString * const kDataModelTypeAudienceDatafileName = @"typed_audience_datafile";
static NSString * const kDatafileNameAnonymizeIPFalse = @"test_data_25_experiments";
static NSString * const kRevision = @"58";
static NSString * const kProjectId = @"6372300739";
static NSString * const kAccountId = @"6365361536";
static NSString * const kDatafileVersion4 = @"4";
static NSUInteger const kNumberOfRolloutsObjects = 3;
static NSUInteger const kNumberOfFeatureFlagsObjects = 7;
static NSUInteger const kNumberOfEventObjects = 7;
static NSUInteger const kNumberOfGroupObjects = 1;
static NSUInteger const kNumberOfAttributeObjects = 1;
static NSUInteger const kNumberOfAudienceObjects = 8;
static NSUInteger const kNumberOfExperimentObjects = 48;
static NSString * const kAttributeKey = @"browser_type";
static NSString * const kAttributeId = @"6380961481";

static NSString * const kUnsupportedVersionDatafileName = @"UnsupportedVersionDatafile";

@interface OPTLYProjectConfigTest : XCTestCase
@property (nonatomic, strong) OPTLYProjectConfig *projectConfig;
@property (nonatomic, strong) OPTLYBucketer *bucketer;
@end

@implementation OPTLYProjectConfigTest

- (void)setUp {
    [super setUp];
    
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    self.projectConfig = [[OPTLYProjectConfig alloc] initWithBuilder:[OPTLYProjectConfigBuilder builderWithBlock:^(OPTLYProjectConfigBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.logger = [OPTLYLoggerDefault new];
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
        builder.userProfileService = [OPTLYUserProfileServiceNoOp new];
    }]];
    
    self.bucketer = [[OPTLYBucketer alloc] initWithConfig:self.projectConfig];
}


- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Test init:

- (void)testInitWithBuilderBlock
{
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithBuilder:[OPTLYProjectConfigBuilder builderWithBlock:^(OPTLYProjectConfigBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.logger = [OPTLYLoggerDefault new];
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
        builder.userProfileService = [OPTLYUserProfileServiceNoOp new];
    }]];
    
    XCTAssertNotNil(projectConfig, @"project config should not be nil.");
    XCTAssertNotNil(projectConfig.logger, @"logger should not be nil.");
    XCTAssertNotNil(projectConfig.errorHandler, @"error handler should not be nil.");
    XCTAssertNotNil(projectConfig.userProfileService, @"User profile should not be nil.");
    XCTAssertEqualObjects(projectConfig.clientEngine, kClientEngine, @"Invalid client engine: %@. Expected: %@.", projectConfig.clientEngine, kClientEngine);
    XCTAssertEqualObjects(projectConfig.clientVersion, OPTIMIZELY_SDK_VERSION, @"Invalid client version: %@. Expected: %@.", projectConfig.clientVersion, OPTIMIZELY_SDK_VERSION);
}
/**
 * Make sure we can pass in different values for client engine and client version to override the defaults.
 */
- (void)testClientEngineAndClientVersionAreConfigurable {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    NSString *clientEngine = @"clientEngine";
    NSString *clientVersion = @"clientVersion";
    
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithBuilder:[OPTLYProjectConfigBuilder builderWithBlock:^(OPTLYProjectConfigBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.clientEngine = clientEngine;
        builder.clientVersion = clientVersion;
    }]];
    XCTAssertNotNil(projectConfig);
    XCTAssertEqualObjects(projectConfig.clientEngine, clientEngine);
    XCTAssertEqualObjects(projectConfig.clientVersion, clientVersion);
}

- (void)testInitWithBuilderBlockNoDatafile
{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wnonnull"
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithBuilder:[OPTLYProjectConfigBuilder builderWithBlock:^(OPTLYProjectConfigBuilder * _Nullable builder) {
        builder.datafile = nil;
    }]];
#pragma GCC diagnostic pop // "-Wnonnull"
    XCTAssertNil(projectConfig, @"project config should be nil.");
}

- (void)testInitWithBuilderBlockInvalidModulesFails {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    
    id<OPTLYLogger> logger = (id<OPTLYLogger>)[NSObject new];
    id<OPTLYErrorHandler> errorHandler = (id<OPTLYErrorHandler>)[NSObject new];
    
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithBuilder:[OPTLYProjectConfigBuilder builderWithBlock:^(OPTLYProjectConfigBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.logger = logger;
        builder.errorHandler = errorHandler;
    }]];
    
    XCTAssertNil(projectConfig.userProfileService, @"Invalid user profile should not have been set.");
    XCTAssertNil(projectConfig, @"project config should not be able to be created with invalid modules.");
}

- (void)testInitWithBuilderBlockUnsupportedDatafile {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kUnsupportedVersionDatafileName];
    id errorHandlerMock = OCMPartialMock([OPTLYErrorHandlerNoOp new]);
    NSString *description = [NSString stringWithFormat:OPTLYErrorHandlerMessagesDataFileInvalid, @"5"];
    NSError *datafileError = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesDatafileInvalid
                                             userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(description, nil)}];
    
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithBuilder:[OPTLYProjectConfigBuilder builderWithBlock:^(OPTLYProjectConfigBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.logger = [OPTLYLoggerDefault new];
        builder.errorHandler = errorHandlerMock;
        builder.userProfileService = [OPTLYUserProfileServiceNoOp new];
    }]];
    
    XCTAssertNil(projectConfig, @"project config should be nil.");
    
    OCMVerify([errorHandlerMock handleError:datafileError]);
    [errorHandlerMock stopMocking];
}

#pragma mark - Test initWithDatafile:

- (void)testInitWithDatafile
{
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithDatafile:datafile];
    [self checkProjectConfigProperties:projectConfig];
}

- (void)testInitWithAnonymizeIPFalse {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatafileNameAnonymizeIPFalse];
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithDatafile:datafile];
    
    XCTAssertFalse(projectConfig.anonymizeIP.boolValue, @"IP anonymization should be set to false.");
}

- (void)testInitWithoutBotFiltering {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatafileNameAnonymizeIPFalse];
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithDatafile:datafile];
    XCTAssertNil(projectConfig.botFiltering, @"Shouldn't find Bot Filtering node in datafile");
}

#pragma mark - Test getExperimentForKey:

- (void)testGetExperimentForKey
{
    NSString* experimentKey = @"testExperiment31";
    OPTLYExperiment *experiment = [self.projectConfig getExperimentForKey:experimentKey];
    XCTAssertNotNil(experiment, @"Should find experiment for key: %@", experimentKey);
    XCTAssert([experiment isKindOfClass:[OPTLYExperiment class]], @"Expected to be an OPTLYExperiment: %@", experiment);
    XCTAssertEqualObjects(experiment.experimentKey, experimentKey,
                          @"Expecting experiment's experimentKey %@ to be: %@", experiment.experimentKey, experimentKey);
}

- (void)testGetExperimentForNonexistentKey
{
    NSString* experimentKey = @"testExperimentDoesntExist";
    OPTLYExperiment *experiment = [self.projectConfig getExperimentForKey:experimentKey];
    XCTAssertNil(experiment, @"Shouldn't find experiment for key: %@", experimentKey);
}

#pragma mark - Test getExperimentForId:

- (void)testGetExperimentForId
{
    NSString* experimentId = @"6313973431";
    OPTLYExperiment *experiment = [self.projectConfig getExperimentForId:experimentId];
    XCTAssertNotNil(experiment, @"Should find experiment for id: %@", experimentId);
    XCTAssert([experiment isKindOfClass:[OPTLYExperiment class]], @"Expected to be an OPTLYExperiment: %@", experiment);
    XCTAssertEqualObjects(experiment.experimentId, experimentId,
                          @"Expecting experiment's experimentId %@ to be: %@", experiment.experimentId, experimentId);
}

- (void)testGetExperimentForNonexistentId
{
    NSString* experimentId = @"66666666666";
    OPTLYExperiment *experiment = [self.projectConfig getExperimentForId:experimentId];
    XCTAssertNil(experiment, @"Shouldn't find experiment for id: %@", experimentId);
}

#pragma mark - Test getExperimentIdForKey:

- (void)testGetExperimentIdForKey
{
    NSString* experimentKey = @"testExperiment31";
    NSString* experimentId = [self.projectConfig getExperimentIdForKey:experimentKey];
    XCTAssertNotNil(experimentId, @"Should find experiment id for key: %@", experimentKey);
    XCTAssert([experimentId isKindOfClass:[NSString class]], @"Expected to be an NSString: %@", experimentId);
    XCTAssertEqualObjects(experimentId, @"6313973431",
                          @"Expecting experiment's experimentKey %@ to be: %@", experimentId, @"6313973431");
}

- (void)testGetExperimentIdForNonexistentKey
{
    NSString* experimentKey = @"testExperimentDoesntExist";
    NSString* experimentId = [self.projectConfig getExperimentIdForKey:experimentKey];
    XCTAssertNil(experimentId, @"Shouldn't find experiment id for key: %@", experimentKey);
}

#pragma mark - Test getGroupForGroupId:

- (void)testGetGroupForGroupId
{
    NSString* groupId = @"6455220163";
    OPTLYGroup* group = [self.projectConfig getGroupForGroupId:groupId];
    XCTAssertNotNil(group, @"Should find group for id: %@", groupId);
    XCTAssert([group isKindOfClass:[OPTLYGroup class]], @"Expected to be an OPTLYGroup: %@", group);
    XCTAssertEqualObjects(group.groupId, groupId,
                          @"Expecting group's groupId %@ to be: %@", group.groupId, groupId);
}

- (void)testGetGroupForNonexistentId
{
    NSString* groupId = @"66666666666";
    OPTLYGroup *group = [self.projectConfig getGroupForGroupId:groupId];
    XCTAssertNil(group, @"Shouldn't find group for id: %@", groupId);
}

#pragma mark - Test getEventIdForKey:

- (void)testGetEventIdForKey
{
    NSString* eventKey = @"testEvent";
    NSString* eventId = [self.projectConfig getEventIdForKey:eventKey];
    XCTAssertNotNil(eventId, @"Should find event id for key: %@", eventKey);
    XCTAssert([eventId isKindOfClass:[NSString class]], @"Expected to be an NSString: %@", eventId);
    XCTAssertEqualObjects(eventId, @"6370537431",
                          @"Expecting event's eventId %@ to be: %@", eventId, @"6370537431");
}

- (void)testGetEventIdForNonexistentKey
{
    NSString* eventKey = @"testEventDoesntExist";
    NSString* eventId = [self.projectConfig getEventIdForKey:eventKey];
    XCTAssertNil(eventId, @"Shouldn't find event id for key: %@", eventKey);
}

#pragma mark - Test getEventForKey:

- (void)testGetEventForKey
{
    NSString* eventKey = @"testEvent";
    OPTLYEvent *event = [self.projectConfig getEventForKey:eventKey];
    XCTAssertNotNil(event, @"Should find event for key: %@", eventKey);
    XCTAssert([event isKindOfClass:[OPTLYEvent class]], @"Expected to be an OPTLYEvent: %@", event);
    XCTAssertEqualObjects(event.eventKey, eventKey,
                          @"Expecting event's eventKey %@ to be: %@", event.eventKey, eventKey);
}

- (void)testGetEventForNonexistentKey
{
    NSString* eventKey = @"nonexistent_browser_type";
    OPTLYEvent *event = [self.projectConfig getEventForKey:eventKey];
    XCTAssertNil(event, @"Shouldn't find event for id: %@", eventKey);
}

#pragma mark - Test getAttributeForKey:

- (void)testGetAttributeForKey
{
    OPTLYAttribute *attribute = [self.projectConfig getAttributeForKey:kAttributeKey];
    XCTAssertNotNil(attribute, @"Should find attribute for key: %@", kAttributeKey);
    XCTAssert([attribute isKindOfClass:[OPTLYAttribute class]], @"Expected to be an OPTLYAttribute: %@", attribute);
    XCTAssertEqualObjects(attribute.attributeKey, kAttributeKey,
                          @"Expecting attribute's attributeKey %@ to be: %@", attribute.attributeKey, kAttributeKey);
}

- (void)testGetAttributeForNonexistentKey
{
    NSString* attributeKey = @"nonexistent_browser_type";
    OPTLYAttribute *attribute = [self.projectConfig getAttributeForKey:attributeKey];
    XCTAssertNil(attribute, @"Shouldn't find attribute for id: %@", attributeKey);
}

#pragma mark - Test getAttributeIdForKey:

- (void)testGetAttributeIdWhenAttributeKeyIsValid {
    NSString *attributeId = [self.projectConfig getAttributeIdForKey:kAttributeKey];
    XCTAssertEqualObjects(attributeId, kAttributeId, @"should retrieve attribute Id %@ for valid attribute key in datafile", kAttributeId);
}

- (void)testGetAttributeIdWhenAttributeKeyIsReserved {
    NSString *attributeId = [self.projectConfig getAttributeIdForKey:OptimizelyUserAgent];
    XCTAssertEqualObjects(attributeId, OptimizelyUserAgent, @"should retrieve attribute Id %@ for reserved attribute key", OptimizelyUserAgent);
}

- (void)testGetAttributeIdWhenAttributeKeyIsInvalid {
    NSString* attributeKey = @"nonexistent_browser_type";
    NSString *attributeId = [self.projectConfig getAttributeIdForKey:attributeKey];
    XCTAssertNil(attributeId, @"Shouldn't find an attribute id for key: %@", attributeKey);
}

- (void)testGetAttributeIdWhenAttributeKeyIsValidAndReserved {
    NSMutableDictionary *datafile = [[NSMutableDictionary alloc] initWithDictionary:[OPTLYTestHelper loadJSONDatafile:kDataModelDatafileName]];
    NSString *expectedAttributeKey = @"$opt_some_reserved_attribute";
    NSString *expectedAttributeId = @"555";
    [datafile setValue:@[ @{
                            @"id": expectedAttributeId,
                            @"key": expectedAttributeKey
                            }
                        ] forKey:@"attributes"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:datafile options:0 error:NULL];
    
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithBuilder:[OPTLYProjectConfigBuilder builderWithBlock:^(OPTLYProjectConfigBuilder * _Nullable builder) {
        builder.datafile = data;
        builder.logger = [OPTLYLoggerDefault new];
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
        builder.userProfileService = [OPTLYUserProfileServiceNoOp new];
    }]];
    NSString *attributeId = [projectConfig getAttributeIdForKey:expectedAttributeKey];
    XCTAssertEqualObjects(attributeId, expectedAttributeId, @"should retrieve attribute Id %@ for reserved attribute key in datafile", expectedAttributeId);
}

#pragma mark - Test getAudienceForId:

- (void)testGetAudienceForId
{
    NSString* audienceId = @"6373742627";
    OPTLYAudience *audience = [self.projectConfig getAudienceForId:audienceId];
    XCTAssertNotNil(audience, @"Should find audience for id: %@", audienceId);
    XCTAssert([audience isKindOfClass:[OPTLYAudience class]], @"Expected to be an OPTLYAudience: %@", audience);
    XCTAssertEqualObjects(audience.audienceId, audienceId,
                          @"Expecting audience's audienceId %@ to be: %@", audience.audienceId, audienceId);
}

- (void)testGetAudienceForNonexistentId
{
    NSString* audienceId = @"66666666666";
    OPTLYAudience *audience = [self.projectConfig getAudienceForId:audienceId];
    XCTAssertNil(audience, @"Shouldn't find audience for id: %@", audienceId);
}

- (void)testExperimentAudiencesRetrievedFromTypedAudiencesFirstThenFromAudiences
{
    NSString* experimentKey = @"feat_with_var_test";
    NSArray *audienceIds = @[@"3468206642", @"3988293898", @"3988293899", @"3468206646", @"3468206647", @"3468206644", @"3468206643"];
    
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelTypeAudienceDatafileName];
    OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithBuilder:[OPTLYProjectConfigBuilder builderWithBlock:^(OPTLYProjectConfigBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.logger = [OPTLYLoggerDefault new];
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
        builder.userProfileService = [OPTLYUserProfileServiceNoOp new];
    }]];
    
    OPTLYExperiment *experiment = [projectConfig getExperimentForKey:experimentKey];
    XCTAssertNotNil(experiment, @"Should find experiment for id: %@", experimentKey);
    XCTAssert([experiment isKindOfClass:[OPTLYExperiment class]], @"Expected to be an OPTLYExperiment: %@", experiment);
    XCTAssertEqualObjects(experiment.audienceIds, audienceIds);
}

#pragma mark - Test getVariableForVariableKey: (DEPRECATED)

- (void)testGetVariableForVariableKey
{
    NSString* variableKey = @"someString";
    OPTLYVariable *variable = [self.projectConfig getVariableForVariableKey:variableKey];
    XCTAssertNotNil(variable, @"Should find variable for key: %@", variableKey);
    XCTAssert([variable isKindOfClass:[OPTLYVariable class]], @"Expected to be an OPTLYVariable: %@", variable);
    XCTAssertEqualObjects(variable.variableKey, variableKey,
                          @"Expecting variable's variableKey %@ to be: %@", variable.variableKey, variableKey);
}

- (void)testGetVariableForVariableNonexistentKey
{
    NSString* variableKey = @"someBlob";
    OPTLYVariable *variable = [self.projectConfig getVariableForVariableKey:variableKey];
    XCTAssertNil(variable, @"Shouldn't find variable for key: %@", variableKey);
}

#pragma mark - Test setForcedVariation:userId:variationKey: and getForcedVariation:userId:

- (void)testSetForcedVariationAndGetForcedVariation
{
    NSString* experimentKey = @"testExperiment31";
    [self.projectConfig setForcedVariation:experimentKey
                                    userId:@"user_a"
                              variationKey:@"variation"];
    OPTLYVariation* variation = [self.projectConfig getForcedVariation:experimentKey
                                                                userId:@"user_a"];
    XCTAssertNotNil(variation, @"getForcedVariation should find forced variation");
    XCTAssert([variation isKindOfClass:[OPTLYVariation class]], @"Expected to be an OPTLYVariation: %@", variation);
    XCTAssertEqualObjects(variation.variationKey, @"variation",
                          @"Expecting variation's variationKey %@ to be: %@", variation.variationKey, @"variation");
}

- (void)testGetForcedVariationWhenNoVariationIsForced
{
    NSString* experimentKey = @"testExperiment31";
    OPTLYVariation* variation = [self.projectConfig getForcedVariation:experimentKey
                                                                userId:@"user_a"];
    XCTAssertNil(variation, @"getForcedVariation shouldn't find forced variation");
}

#pragma mark - Test getVariationForExperiment:userId:attributes:bucketer:

// "user_b": "b"
- (void)testGetVariationWhitelisted
{
    OPTLYVariation *variation = [self.projectConfig getVariationForExperiment:@"mutex_exp2"
                                                                       userId:@"user_b"
                                                                   attributes:@{@"abc":@"123"}
                                                                     bucketer:self.bucketer];
    
    XCTAssert([variation.variationKey isEqualToString:@"b"], @"Invalid variation for getVariation with whitelisted user: %@", variation.variationKey);
}

- (void)testGetVariationAudience
{
    // invalid audience
    OPTLYVariation *variationInvalidAudience = [self.projectConfig getVariationForExperiment:@"testExperimentWithFirefoxAudience"
                                                                                      userId:@"user_b"
                                                                                  attributes:@{kAttributeKey:@"chrome"}
                                                                                    bucketer:self.bucketer];
    
    XCTAssertNil(variationInvalidAudience, @"Variation should be nil for experiment that does not pass audience evaluation: %@", variationInvalidAudience);
    
    // valid audience
    OPTLYVariation *variationValidAudience = [self.projectConfig getVariationForExperiment:@"testExperimentWithFirefoxAudience"
                                                                                    userId:@"user_b"
                                                                                attributes:@{kAttributeKey:@"firefox"}
                                                                                  bucketer:self.bucketer];
    XCTAssert([variationValidAudience.variationKey isEqualToString:@"variation"], @"Invalid variation for getVariation with whitelisted user: %@", variationValidAudience.variationKey);
}

- (void)testGetVariationExperiment
{
    // experiment does not exist
    OPTLYVariation *variationExpNotExist = [self.projectConfig getVariationForExperiment:@"invalidExperiment"
                                                                                  userId:@"user_b"
                                                                              attributes:@{@"abc":@"123"}
                                                                                bucketer:self.bucketer];
    XCTAssertNil(variationExpNotExist, @"Variation should be nil for experiment that does not exist: %@", variationExpNotExist.variationKey);
    
    // experiment is paused
    OPTLYVariation *variationExpNotRunning = [self.projectConfig getVariationForExperiment:@"testExperimentNotRunning"
                                                                                    userId:@"user_b"
                                                                                attributes:nil
                                                                                  bucketer:self.bucketer];
    XCTAssertNil(variationExpNotRunning, @"Variation should be nil for experiment that is paused: %@", variationExpNotRunning.variationKey);
}

#pragma mark - Test v4 projectConfig:

#pragma mark - Test getFeatureFlagForKey:

- (void)testGetFeatureFlagForKey
{
    NSString* featureFlagKey = @"boolean_feature";
    OPTLYFeatureFlag *featureFlag = [self.projectConfig getFeatureFlagForKey:featureFlagKey];
    XCTAssertNotNil(featureFlag, @"Should find feature flag for key: %@", featureFlagKey);
    XCTAssert([featureFlag isKindOfClass:[OPTLYFeatureFlag class]], @"Expected to be an OPTLYFeatureFlag: %@", featureFlag);
    XCTAssertEqualObjects(featureFlag.key, featureFlagKey,
                          @"Expecting feature flag's key %@ to be: %@", featureFlag.key, featureFlagKey);
}

- (void)testGetFeatureFlagForNonexistentKey
{
    NSString* featureFlagKey = @"testFeatureFlagDoesntExist";
    OPTLYFeatureFlag *featureFlag = [self.projectConfig getFeatureFlagForKey:featureFlagKey];
    XCTAssertNil(featureFlag, @"Shouldn't find feature flag for key: %@", featureFlagKey);
}

#pragma mark - Test getRolloutForId:

- (void)testGetRolloutForId
{
    NSString* rolloutId = @"1058508303";
    OPTLYRollout *rollout = [self.projectConfig getRolloutForId:rolloutId];
    XCTAssertNotNil(rollout, @"Should find rollout for id: %@", rolloutId);
    XCTAssert([rollout isKindOfClass:[OPTLYRollout class]], @"Expected to be an OPTLYRollout: %@", rollout);
    XCTAssertEqualObjects(rollout.rolloutId, rolloutId,
                          @"Expecting rollout's rolloutId %@ to be: %@", rollout.rolloutId, rolloutId);
}

- (void)testGetRolloutForNonexistentId
{
    NSString* rolloutId = @"66666666666";
    OPTLYRollout *rollout = [self.projectConfig getRolloutForId:rolloutId];
    XCTAssertNil(rollout, @"Shouldn't find rollout for id: %@", rolloutId);
}

#pragma mark - Test [OPTLYVariation getVariableUsageForVariableId]:

- (void)testGetVariableUsageForVariableId {
    NSString *featureKey = @"double_single_variable_feature";
    OPTLYFeatureFlag *featureFlag = [self.projectConfig getFeatureFlagForKey:featureKey];
    OPTLYFeatureVariable *featureVariable = featureFlag.variables[0];
    OPTLYExperiment *experiment = [self.projectConfig getExperimentForId:featureFlag.experimentIds[0]];
    OPTLYVariation *variation = [experiment getVariationForVariationId:@"6363413697"];
    OPTLYVariableUsage *variableUsage = [variation getVariableUsageForVariableId:featureVariable.variableId];
    
    XCTAssertNotNil(variableUsage, @"Should find variable usage for id: %@", featureVariable.variableId);
    XCTAssert([variableUsage isKindOfClass:[OPTLYVariableUsage class]], @"Expected to be an OPTLYVariableUsage: %@", variableUsage);
    XCTAssertEqualObjects(featureVariable.variableId, variableUsage.variableId,
                          @"Expecting feature variable's id %@ to be: %@", featureVariable.variableId, variableUsage.variableId);
}

- (void)testGetVariableUsageForVariableIdInvalid {
    NSString *featureKey = @"multi_variate_feature";
    OPTLYFeatureFlag *featureFlag = [self.projectConfig getFeatureFlagForKey:featureKey];
    OPTLYFeatureVariable *featureVariable = featureFlag.variables[0];
    OPTLYExperiment *experiment = [self.projectConfig getExperimentForId:featureFlag.experimentIds[0]];
    OPTLYVariation *variation = [experiment getVariationForVariationId:@"6383523065"];
    OPTLYVariableUsage *variableUsage = [variation getVariableUsageForVariableId:featureVariable.variableId];
    
    XCTAssertNil(variableUsage, @"Should not find variable usage for id: %@", featureVariable.variableId);
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
    NSAssert([projectConfig.version isEqualToString:kDatafileVersion4], @"Invalid version number.");
    
    // validate revision number
    NSAssert([projectConfig.revision isEqualToString:kRevision], @"Invalid revision number.");
    
    // validate IP anonymization value
    XCTAssertTrue(projectConfig.anonymizeIP.boolValue, @"IP anonymization should be set to true.");
    
    // validate Bot Filtering value
    XCTAssertTrue(projectConfig.botFiltering.boolValue, @"Bot Filtering should be set to true.");
    
    // check experiments
    NSAssert([projectConfig.experiments count] == kNumberOfExperimentObjects, @"deserializeJSONArray failed to deserialize the right number of experiments objects in project config.");
    for (id experiment in projectConfig.experiments) {
        NSAssert([experiment isKindOfClass:[OPTLYExperiment class]], @"deserializeJSONArray failed to deserialize the experiment object in project config.");
    }
    
    // check audiences
    NSAssert([projectConfig.audiences count] == kNumberOfAudienceObjects, @"deserializeJSONArray failed to deserialize the right number of audience objects in project config.");
    for (id audience in projectConfig.audiences) {
        NSAssert([audience isKindOfClass:[OPTLYAudience class]], @"deserializeJSONArray failed to deserialize the audience object in project config.");
    }
    
    // check attributes
    NSAssert([projectConfig.attributes count] == kNumberOfAttributeObjects, @"deserializeJSONArray failed to deserialize the right number of attribute objects in project config.");
    for (id attribute in projectConfig.attributes) {
        NSAssert([attribute isKindOfClass:[OPTLYAttribute class]], @"deserializeJSONArray failed to deserialize the attribute object in project config.");
    }
    
    // check groups
    NSAssert([projectConfig.groups count] == kNumberOfGroupObjects, @"deserializeJSONArray failed to deserialize the right number of group objects in project config.");
    for (id group in projectConfig.groups) {
        NSAssert([group isKindOfClass:[OPTLYGroup class]], @"deserializeJSONArray failed to deserialize the group object in project config.");
    }
    
    // check events
    NSAssert([projectConfig.events count] == kNumberOfEventObjects, @"deserializeJSONArray failed to deserialize the right number of event objects in project config.");
    for (id event in projectConfig.events) {
        NSAssert([event isKindOfClass:[OPTLYEvent class]], @"deserializeJSONArray failed to deserialize the event object in project config.");
    }
    
    // check feature flags
    NSAssert([projectConfig.featureFlags count] == kNumberOfFeatureFlagsObjects, @"deserializeJSONArray failed to deserialize the right number of feature flags objects in project config.");
    for (id featureFlag in projectConfig.featureFlags) {
        NSAssert([featureFlag isKindOfClass:[OPTLYFeatureFlag class]], @"deserializeJSONArray failed to deserialize the feature flag object in project config.");
        for (NSString *expId in ((OPTLYFeatureFlag *)featureFlag).experimentIds) {
            OPTLYExperiment *exp = [_projectConfig getExperimentForId:expId];
            [self checkFeatureEnabledProperty:exp];
        }
    }
    
    // check rollouts
    NSAssert([projectConfig.rollouts count] == kNumberOfRolloutsObjects, @"deserializeJSONArray failed to deserialize the right number of rollouts objects in project config.");
    for (id rollout in projectConfig.rollouts) {
        NSAssert([rollout isKindOfClass:[OPTLYRollout class]], @"deserializeJSONArray failed to deserialize the rollout object in project config.");
        for (OPTLYExperiment *experiment in ((OPTLYRollout *)rollout).experiments) {
            [self checkFeatureEnabledProperty:experiment];
        }
    }
}

// Check all properties in an ProjectConfig object
- (void)checkFeatureEnabledProperty:(OPTLYExperiment *)experiment {
    for (OPTLYVariation *variation in experiment.variations) {
        NSString *key = @"featureEnabled";
        NSString *setterStr = [NSString stringWithFormat:@"set%@%@:",
                               [[key substringToIndex:1] capitalizedString],
                               [key substringFromIndex:1]];
        NSAssert([variation respondsToSelector:NSSelectorFromString(setterStr)],
                 @"Experiment variations should have %@ field.", key);
    }
}

@end
