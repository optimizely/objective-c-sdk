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
#import "OPTLYEventBuilder.h"
#import "OPTLYEventTicket.h"
#import "OPTLYEventParameterKeys.h"
#import "OPTLYDecisionEventTicket.h"
#import "OPTLYBucketer.h"
#import "OPTLYMacros.h"
#import "OPTLYEventFeature.h"
#import "OPTLYExperiment.h"
#import "OPTLYEventMetric.h"

static NSString * const kDatafileName = @"test_data_10_experiments";
static NSString * const kDatafileNameAnonymizeIPFalse = @"test_data_25_experiments";
static NSString * const kUserId = @"6369992312";
static NSString * const kAccountId = @"6365361536";
static NSString * const kProjectId = @"6377970066";
static NSString * const kRevision = @"83";
static NSString * const kLayerId = @"1234";
static NSInteger kEventValue = 88;
static NSString * const kTotalRevenueId = @"6316734272";
static NSString * const kAttributeId = @"6359881003";
static NSString * const kAttributeKeyBrowserType = @"browser_type";
static NSString * const kAttributeValueFirefox = @"firefox";
static NSString * const kAttributeValueChrome = @"chrome";

// events with experiment, but no audiences
static NSString * const kEventWithoutAudienceName = @"testEvent";
static NSString * const kEventWithoutAudienceId = @"6372590948";
static NSString * const kExperimentWithoutAudienceKey = @"testExperiment1";
static NSString * const kExperimentWithoutAudienceId = @"6367863211";
static NSString * const kVariationWithoutAudienceId = @"6384330452";

// events with experiment and audiences
static NSString * const kEventWithAudienceName = @"testEventWithAudiences";
static NSString * const kEventWithAudienceId = @"6384781388";
static NSString * const kExperimentWithAudienceKey = @"testExperimentWithFirefoxAudience";
static NSString * const kExperimentWithAudienceId = @"6383811281";
static NSString * const kVariationWithAudienceId = @"6333082303";

// experiment not running parameters
static NSString * const kEventWithExperimentNotRunningName = @"testEventWithExperimentNotRunning";
static NSString * const kEventWithExperimentNotRunningId = @"6380961307";
static NSString * const kExperimentNotRunningKey = @"testExperimentNotRunning";
static NSString * const kExperimentNotRunningId = @"6367444440";

// events without experiments
static NSString * const kEventWithoutExperimentName = @"testEventWithoutExperiments";
static NSString * const kEventWithoutExperimentId = @"6386521015";

// events with multiple experiments
static NSString * const kEventWithMultipleExperimentsName = @"testEventWithMultipleExperiments";
static NSString * const kEventWithMultipleExperimentsId = @"6372952486";

@interface OPTLYEventBuilderDefault(Tests)
- (NSString *)sdkVersion;
- (NSArray *)createUserFeatures:(OPTLYProjectConfig *)config
                     attributes:(NSDictionary *)attributes;
@end

@interface OPTLYEventBuilderTest : XCTestCase
@property (nonatomic, strong) OPTLYProjectConfig *config;
@property (nonatomic, strong) OPTLYEventBuilderDefault *eventBuilder;
@property (nonatomic, strong) OPTLYBucketer *bucketer;

@end

@implementation OPTLYEventBuilderTest

- (void)setUp {
    [super setUp];
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatafileName];
    self.config = [[OPTLYProjectConfig alloc] initWithDatafile:datafile];
    self.eventBuilder = [OPTLYEventBuilderDefault new];
    self.bucketer = [[OPTLYBucketer alloc] initWithConfig:self.config];
}

- (void)tearDown {
    [super tearDown];
    self.config = nil;
    self.eventBuilder = nil;
    self.bucketer = nil;
}

- (void)testBuildEventTicketWithNoAudience
{
    OPTLYEventTicket *eventTicket = [self.eventBuilder buildEventTicket:self.config
                                                               bucketer:self.bucketer
                                                                 userId:kUserId
                                                              eventName:kEventWithoutAudienceName
                                                             eventValue:nil
                                                             attributes:nil];
    NSDictionary *eventTicketParams = [eventTicket toDictionary];
    [self checkCommonParams:eventTicketParams
             withAttributes:nil];
    [self checkEventTicketParams:eventTicketParams
                          config:self.config
                         eventId:kEventWithoutAudienceId
                       eventName:kEventWithoutAudienceName
                      eventValue:nil
                      attributes:nil
                          userId:kUserId
                   experimentIds:@[kExperimentWithoutAudienceId]];
    
}

- (void)testBuildEventTicketWithAudience
{
    // check without attributes
    NSDictionary *attributes = @{};
    OPTLYEventTicket *eventTicket = [self.eventBuilder buildEventTicket:self.config
                                                               bucketer:self.bucketer
                                                                 userId:kUserId
                                                              eventName:kEventWithAudienceName
                                                             eventValue:nil
                                                             attributes:attributes];
    NSDictionary *params = [eventTicket toDictionary];
    [self checkCommonParams:params withAttributes:attributes];
    NSArray *userFeatures = params[OPTLYEventParameterKeysUserFeatures];
    NSAssert([userFeatures count] == 0, @"User features params should not be generated with nil attributes.");
    
    // check with attributes
    attributes = @{ kAttributeKeyBrowserType : kAttributeValueFirefox };
    eventTicket = [self.eventBuilder buildEventTicket:self.config
                                             bucketer:self.bucketer
                                               userId:kUserId
                                            eventName:kEventWithAudienceName
                                           eventValue:nil
                                           attributes:attributes];
    params = [eventTicket toDictionary];
    [self checkCommonParams:params withAttributes:attributes];
    [self checkEventTicketParams:params
                          config:self.config
                         eventId:kEventWithAudienceId
                       eventName:kEventWithAudienceName
                      eventValue:nil
                      attributes:attributes
                          userId:kUserId
                   experimentIds:@[kExperimentWithAudienceId]];
}

- (void)testBuildEventTicketWithExperimentNotRunning
{
    OPTLYEventTicket *eventTicket = [self.eventBuilder buildEventTicket:self.config
                                                               bucketer:self.bucketer
                                                                 userId:kUserId
                                                              eventName:kEventWithExperimentNotRunningName
                                                             eventValue:nil
                                                             attributes:nil];
    
    NSDictionary *params = [eventTicket toDictionary];
    [self checkCommonParams:params withAttributes:nil];
    
    NSArray *layerStates = params[OPTLYEventParameterKeysLayerStates];
    NSUInteger numberOfLayers = [layerStates count];
    NSAssert(numberOfLayers == 0, @"Layers should not be created.");
}

- (void)testBuildEventTicketWithoutExperiment
{
    OPTLYEventTicket *eventTicket = [self.eventBuilder buildEventTicket:self.config
                                                               bucketer:self.bucketer
                                                                 userId:kUserId
                                                              eventName:kEventWithoutExperimentName
                                                             eventValue:nil
                                                             attributes:nil];
    
    NSDictionary *params = [eventTicket toDictionary];
    [self checkCommonParams:params withAttributes:nil];
    
    NSArray *layerStates = params[OPTLYEventParameterKeysLayerStates];
    NSUInteger numberOfLayers = [layerStates count];
    NSAssert(numberOfLayers == 0, @"Layers should not be created.");
}


- (void)testBuildEventTicketWithAllArguments
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    OPTLYEventTicket *eventTicket = [self.eventBuilder buildEventTicket:self.config
                                                               bucketer:self.bucketer
                                                                 userId:kUserId
                                                              eventName:kEventWithAudienceName
                                                             eventValue:[NSNumber numberWithInteger:kEventValue]
                                                             attributes:attributes];
    NSDictionary *params = [eventTicket toDictionary];
    [self checkCommonParams:params withAttributes:attributes];
    [self checkEventTicketParams:params
                          config:self.config
                         eventId:kEventWithAudienceId
                       eventName:kEventWithAudienceName
                      eventValue:[NSNumber numberWithInteger:kEventValue]
                      attributes:attributes
                          userId:kUserId
                   experimentIds:@[kExperimentWithAudienceId]];
}

- (void)testBuildEventTicketWithEventMultipleExperiments
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueChrome};
    
    OPTLYEventTicket *eventTicket = [self.eventBuilder buildEventTicket:self.config
                                                               bucketer:self.bucketer
                                                                 userId:kUserId
                                                              eventName:kEventWithMultipleExperimentsName
                                                             eventValue:[NSNumber numberWithInteger:kEventValue]
                                                             attributes:attributes];
    NSDictionary *params = [eventTicket toDictionary];
    [self checkCommonParams:params withAttributes:attributes];
    
    NSArray *experimentIds = @[@"6364835526", @"6450630664", @"6367863211", @"6376870125", @"6383811281", @"6358043286", @"6370392407", @"6367444440", @"6370821515", @"6447021179"];
    NSArray *layerStates = params[OPTLYEventParameterKeysLayerStates];
    
    NSUInteger numberOfLayers = [layerStates count];
    NSUInteger numberOfExperiments = [experimentIds count];
    
    // 6383811281 (testExperimentWithFirefoxAudience) is excluded because the attributes do not match
    // 6367444440 (testExperimentNotRunning) is excluded because the experiment is not running
    // 6450630664 should be exlucded becuase it is mutually excluded.
    NSAssert(numberOfLayers == (numberOfExperiments - 3), @"Incorrect number of layers.");
}

- (void)testBuildEventTicketWithAnonymizeIPFalse {
    OPTLYProjectConfig *config = [self setUpForAnonymizeIPFalse];
    OPTLYEventBuilderDefault *eventBuilder = [OPTLYEventBuilderDefault new];
    OPTLYBucketer *bucketer = [[OPTLYBucketer alloc] initWithConfig:config];
    
    OPTLYEventTicket *eventTicket = [eventBuilder buildEventTicket:config
                                                          bucketer:bucketer
                                                            userId:kUserId
                                                         eventName:kEventWithoutAudienceName
                                                        eventValue:nil
                                                        attributes:nil];
    
    NSDictionary *params = [eventTicket toDictionary];
    NSNumber *anonymizeIP = params[OPTLYEventParameterKeysAnonymizeIP];
    NSAssert([anonymizeIP boolValue] == false, @"Incorrect value for IP anonymization.");
}

- (void)testBuildDecisionEventTicketWithAllArguments
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:kExperimentWithAudienceKey
                                                                        userId:kUserId
                                                                    attributes:attributes
                                                                      bucketer:self.bucketer];
    
    
    OPTLYDecisionEventTicket *decisionEventTicket = [self.eventBuilder buildDecisionEventTicket:self.config
                                                                                         userId:kUserId
                                                                                  experimentKey:kExperimentWithAudienceKey
                                                                                    variationId:bucketedVariation.variationId
                                                                                     attributes:attributes];
    NSDictionary *params = [decisionEventTicket toDictionary];
    [self checkCommonParams:params withAttributes:attributes];
    [self checkDecisionTicketParams:params
                             config:self.config
                           bucketer:self.bucketer
                         attributes:attributes
                      experimentKey:kExperimentWithAudienceKey
                             userId:kUserId];
    
}

- (void)testBuildDecisionEventTicketWithNoAudience
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    OPTLYDecisionEventTicket *decisionEventTicket = [self.eventBuilder buildDecisionEventTicket:self.config
                                                                                         userId:kUserId
                                                                                  experimentKey:kExperimentWithoutAudienceKey
                                                                                    variationId:kVariationWithoutAudienceId
                                                                                     attributes:attributes];
    NSDictionary *params = [decisionEventTicket toDictionary];
    [self checkCommonParams:params withAttributes:attributes];
    [self checkDecisionTicketParams:params
                             config:self.config
                           bucketer:self.bucketer
                         attributes:attributes
                      experimentKey:kExperimentWithoutAudienceKey
                             userId:kUserId];
}

- (void)testBuildDecisionEventTicketWithUnknownExperiment
{
    NSString *invalidExperimentKey = @"InvalidExperiment";
    NSString *invalidVariationId = @"5678";
    
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    OPTLYDecisionEventTicket *decisionEventTicket = [self.eventBuilder buildDecisionEventTicket:self.config
                                                                                         userId:kUserId
                                                                                  experimentKey:invalidExperimentKey
                                                                                    variationId:invalidVariationId
                                                                                     attributes:attributes];
    NSDictionary *params = [decisionEventTicket toDictionary];
    NSAssert(params == nil, @"parameters should not be created with unknown experiment.");
}

- (void)testBuildDecisionTicketWithAnonymizeIPFalse {
    OPTLYProjectConfig *config = [self setUpForAnonymizeIPFalse];
    OPTLYEventBuilderDefault *eventBuilder = [OPTLYEventBuilderDefault new];
    
    OPTLYDecisionEventTicket *decisionEventTicket = [eventBuilder buildDecisionEventTicket:config
                                                                                    userId:kUserId
                                                                             experimentKey:kExperimentWithoutAudienceKey
                                                                               variationId:kVariationWithoutAudienceId
                                                                                attributes:nil];
    NSDictionary *params = [decisionEventTicket toDictionary];
    NSNumber *anonymizeIP = params[OPTLYEventParameterKeysAnonymizeIP];
    NSAssert([anonymizeIP boolValue] == false, @"Incorrect value for IP anonymization.");
}

#pragma mark - Helper Methods

- (void)checkDecisionTicketParams:(NSDictionary *)params
                           config:(OPTLYProjectConfig *)config
                         bucketer:(OPTLYBucketer *)bucketer
                       attributes:(NSDictionary *)attributes
                    experimentKey:(NSString *)experimentKey
                           userId:(NSString *)userId
{
    // check layer id
    NSAssert([params[OPTLYEventParameterKeysLayerId] isEqualToString:kLayerId], @"Layer id is invalid.");
    
    // check decision
    NSDictionary *decision = params[OPTLYEventParameterKeysDecision];
    OPTLYVariation *bucketedVariation = [config getVariationForExperiment:experimentKey
                                                                   userId:userId
                                                               attributes:attributes
                                                                 bucketer:bucketer];
    NSString *experimentId = [config getExperimentIdForKey:experimentKey];
    [self checkDecision:decision experimentId:experimentId bucketedVariationId:bucketedVariation.variationId];
}

- (void)checkEventTicketParams:(NSDictionary *)params
                        config:(OPTLYProjectConfig *)config
                       eventId:(NSString *)eventId
                     eventName:(NSString *)eventName
                    eventValue:(NSNumber *)eventValue
                    attributes:(NSDictionary *)attributes
                        userId:(NSString *)userId
                 experimentIds:(NSArray *)experimentIds

{
    NSAssert([params[OPTLYEventParameterKeysEventEntityId] isEqualToString:eventId], @"Invalid entityId.");
    
    NSAssert([params[OPTLYEventParameterKeysEventName] isEqualToString:eventName], @"Invalid event name.");
    
    NSArray *eventFeatures = params[OPTLYEventParameterKeysEventFeatures];
    NSAssert([eventFeatures count] == 0, @"Event features should be empty.");
    
    NSArray *eventMetrics = params[OPTLYEventParameterKeysEventMetrics];
    if ([eventMetrics count] > 0)
    {
        [self checkEventMetric:eventMetrics[0]
                    eventValue:eventValue];
    }
    
    NSArray *layerStates = params[OPTLYEventParameterKeysLayerStates];
    [self checkLayerStates:config
               layerStates:layerStates
             experimentIds:experimentIds
                    userId:userId
                attributes:attributes];
    
}


- (void)checkCommonParams:(NSDictionary *)params
           withAttributes:(NSDictionary *)attributes
{
    // check timestamp exists
    NSNumber *timestamp = params[OPTLYEventParameterKeysTimestamp];
    NSAssert(timestamp > 0, @"No timestamp.");
    
    // check revision
    NSString *revision = params[OPTLYEventParameterKeysRevision];
    NSAssert([revision isEqualToString:kRevision], @"Incorrect revision number.");
    
    // check visitor id
    NSString *visitorId = params[OPTLYEventParameterKeysVisitorId];
    NSAssert([visitorId isEqualToString:kUserId], @"Incorrect visitor id.");
    
    // check project id
    NSString *projectId = params[OPTLYEventParameterKeysProjectId];
    NSAssert([projectId isEqualToString:kProjectId], @"Incorrect project id.");
    
    // check account id
    NSString *accountId = params[OPTLYEventParameterKeysAccountId];
    NSAssert([accountId isEqualToString:kAccountId], @"Incorrect accound id");
    
    // check clientEngine
    NSString *clientEngine = params[OPTLYEventParameterKeysClientEngine];
    NSAssert([clientEngine isEqualToString:[self.config clientEngine]], @"Incorrect client engine.");
    
    // check clientVersion
    NSString *clientVersion = params[OPTLYEventParameterKeysClientVersion];
    NSAssert([clientVersion isEqualToString:[self.config clientVersion]], @"Incorrect client version.");
    
    // check anonymizeIP
    NSNumber *anonymizeIP = params[OPTLYEventParameterKeysAnonymizeIP];
    NSAssert([anonymizeIP boolValue] == true, @"Incorrect value for IP anonymization.");
    
    // check global holdback
    NSNumber *isGlobalHoldback = params[OPTLYEventParameterKeysIsGlobalHoldback];
    NSAssert([isGlobalHoldback boolValue] == false, @"Incorrect value for global holdback.");
    
    NSArray *userFeatures = params[OPTLYEventParameterKeysUserFeatures];
    [self checkUserFeatures:userFeatures
             withAttributes:attributes];
}

- (void)checkUserFeatures:(NSArray *)userFeatures
           withAttributes:(NSDictionary *)attributes
{
    NSUInteger numberOfFeatures = [userFeatures count];
    NSUInteger numberOfAttributes = [attributes count];
    
    NSAssert(numberOfFeatures == numberOfAttributes, @"Incorrect number of user features.");
    
    NSSortDescriptor *featureNameDescriptor = [[NSSortDescriptor alloc] initWithKey:OPTLYEventParameterKeysFeaturesName ascending:YES];
    NSArray *sortedUserFeaturesByName = [userFeatures sortedArrayUsingDescriptors:@[featureNameDescriptor]];
    
    NSSortDescriptor *attributeKeyDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray *sortedAttributeKeys = [[attributes allKeys] sortedArrayUsingDescriptors:@[attributeKeyDescriptor]];
    
    for (NSUInteger i = 0; i < numberOfAttributes; i++)
    {
        NSDictionary *params = sortedUserFeaturesByName[i];
        
        NSString *anAttributeKey = sortedAttributeKeys[i];
        NSString *anAttributeValue = [attributes objectForKey:anAttributeKey];
        
        // check name
        NSString *featureName = params[OPTLYEventParameterKeysFeaturesName];
        NSAssert([featureName isEqualToString:anAttributeKey ], @"Incorrect feature name.");
        
        // check type
        NSString *featureType = params[OPTLYEventParameterKeysFeaturesType];
        NSAssert([featureType isEqualToString:OPTLYEventFeatureFeatureTypeCustomAttribute], @"Incorrect feature type.");
        
        // check value
        NSString *featureValue = params[OPTLYEventParameterKeysFeaturesValue];
        NSAssert([featureValue isEqualToString:anAttributeValue], @"Incorrect feature value.");
        
        // check should index
        BOOL shouldIndex = [params[OPTLYEventParameterKeysFeaturesShouldIndex] boolValue];
        NSAssert(shouldIndex == true, @"Incorrect shouldIndex value.");
    }
}

- (void)checkLayerStates:(OPTLYProjectConfig *)config
             layerStates:(NSArray *)layerStates
           experimentIds:(NSArray *)experimentIds
                  userId:(NSString *)userId
              attributes:(NSDictionary *)attributes
{
    NSUInteger numberOfLayers = [layerStates count];
    NSUInteger numberOfExperiments = [experimentIds count];
    
    NSAssert(numberOfLayers == numberOfExperiments, @"Incorrect number of layers.");
    
    // sort layer states
    NSSortDescriptor *layerStatesDecisionExperimentIdDescriptor = [[NSSortDescriptor alloc] initWithKey:@"decision.experimentId" ascending:YES];
    NSArray *sortedLayerStatesByDecisionExperimentId = [layerStates sortedArrayUsingDescriptors:@[layerStatesDecisionExperimentIdDescriptor]];
    
    // sort experiment ids
    NSSortDescriptor *experimentIdDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray *sortedExperimentIds = [experimentIds sortedArrayUsingDescriptors:@[experimentIdDescriptor]];
    
    for (NSUInteger i = 0; i < numberOfLayers; i++)
    {
        NSString *experimentId = sortedExperimentIds[i];
        NSDictionary *layerState = sortedLayerStatesByDecisionExperimentId[i];
        
        OPTLYExperiment *experiment = [config getExperimentForId:experimentId];
        NSAssert(experiment != nil, @"Experiment should be part of the datafile.");
        OPTLYVariation *bucketedVariation = [config getVariationForExperiment:experiment.experimentKey
                                                                       userId:userId
                                                                   attributes:attributes
                                                                     bucketer:self.bucketer];
        
        NSDictionary *decisionParams = layerState[OPTLYEventParameterKeysLayerStateDecision];
        if ([decisionParams count] > 0) {
            [self checkDecision:decisionParams
                   experimentId:experimentId
            bucketedVariationId:bucketedVariation.variationId];
        }
        
        NSNumber *actionTriggered = layerState[OPTLYEventParameterKeysLayerStateActionTriggered];
        NSAssert([actionTriggered boolValue] == false, @"Invalid actionTriggered value.");
        NSString *layerId = layerState[OPTLYEventParameterKeysLayerStateLayerId];
        NSAssert([layerId isEqualToString:kLayerId], @"Invalid layerId value.");
        NSString *revision = layerState[OPTLYEventParameterKeysLayerStateRevision];
        NSAssert([revision isEqualToString:kRevision], @"Invalid revision.");
    }
}

- (void)checkEventMetric:(NSDictionary *)params
              eventValue:(NSNumber *)eventValue
{
    NSAssert([params[OPTLYEventParameterKeysMetricName] isEqualToString:OPTLYEventMetricNameRevenue], @"Invalid event name.");
    NSAssert([params[OPTLYEventParameterKeysMetricValue] isEqualToValue:eventValue], @"Invalid event name.");
}

- (void)checkEventFeatures:(NSArray *)eventFeatures
{
    NSAssert([eventFeatures count] == 0, @"Event features should be empty.");
}

- (void)checkDecision:(NSDictionary *)params
         experimentId:(NSString *)experimentId
  bucketedVariationId:(NSString *)variationId
{
    NSAssert([experimentId isEqualToString:params[OPTLYEventParameterKeysDecisionExperimentId]], @"Invalid experimentId.");
    NSAssert([variationId isEqualToString: params[OPTLYEventParameterKeysDecisionVariationId]], @"Invalid variationId.");
    NSNumber *isLayerHoldback = params[OPTLYEventParameterKeysDecisionIsLayerHoldback];
    NSAssert([isLayerHoldback boolValue] == false, @"Invalid isLayerHoldback value.");
}

- (OPTLYProjectConfig *)setUpForAnonymizeIPFalse
{
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatafileNameAnonymizeIPFalse];
    return [[OPTLYProjectConfig alloc] initWithDatafile:datafile];
}

@end
