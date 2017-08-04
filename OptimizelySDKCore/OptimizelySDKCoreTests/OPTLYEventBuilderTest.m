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
#import "OPTLYDecisionService.h"
#import "OPTLYBucketer.h"
#import "OPTLYMacros.h"
#import "OPTLYEventFeature.h"
#import "OPTLYExperiment.h"
#import "OPTLYEventMetric.h"
#import "OPTLYVariation.h"

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
@property (nonatomic, strong) NSDate *begTimestamp;

@end

@implementation OPTLYEventBuilderTest

- (void)setUp {
    [super setUp];
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatafileName];
    self.config = [[OPTLYProjectConfig alloc] initWithDatafile:datafile];
    self.eventBuilder = [OPTLYEventBuilderDefault new];
    self.bucketer = [[OPTLYBucketer alloc] initWithConfig:self.config];
    
    // need to do this cast because this is what happens when we get the event time stamp
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    long long currentTimeIntervalCast = currentTimeInterval;
    self.begTimestamp = [NSDate dateWithTimeIntervalSince1970:currentTimeIntervalCast];
}

- (void)tearDown {
    [super tearDown];
    self.config = nil;
    self.eventBuilder = nil;
    self.bucketer = nil;
}

#pragma mark - Test buildEventTicket:...

- (void)testBuildEventTicketWithNoAudience
{
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithoutAudienceName
                                                     eventTags:nil
                                                    attributes:nil];
    [self checkCommonParams:params
             withAttributes:nil];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithoutAudienceId
                 eventName:kEventWithoutAudienceName
                 eventTags:nil
                attributes:nil
                    userId:kUserId
             experimentIds:@[kExperimentWithoutAudienceId]];
    
}

- (void)testBuildEventTicketWithValidAudience
{
    // check without attributes that satisfy audience requirement
    NSDictionary *attributes = @{@"browser_type":@"firefox"};
    
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithAudienceName
                                                     eventTags:nil
                                                    attributes:attributes];
    [self checkCommonParams:params withAttributes:attributes];
    
    // check with attributes
    attributes = @{ kAttributeKeyBrowserType : kAttributeValueFirefox };
    params = [self.eventBuilder buildEventTicket:self.config
                                        bucketer:self.bucketer
                                          userId:kUserId
                                       eventName:kEventWithAudienceName
                                       eventTags:nil
                                      attributes:attributes];
    [self checkCommonParams:params withAttributes:attributes];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithAudienceId
                 eventName:kEventWithAudienceName
                 eventTags:nil
                attributes:attributes
                    userId:kUserId
             experimentIds:@[kExperimentWithAudienceId]];
}

- (void)testBuildEventTicketWithInvalidAudience
{
    // check without attributes that satisfy audience requirement
    NSDictionary *attributes = @{@"browser_type":@"chrome"};
    
    NSDictionary *eventTicket = [self.eventBuilder buildEventTicket:self.config
                                                           bucketer:self.bucketer
                                                             userId:kUserId
                                                          eventName:kEventWithAudienceName
                                                          eventTags:nil
                                                         attributes:attributes];
    XCTAssertNil(eventTicket, @"Event ticket should be nil.");
}

- (void)testBuildEventTicketWithExperimentNotRunning
{
    NSDictionary *eventTicket = [self.eventBuilder buildEventTicket:self.config
                                                           bucketer:self.bucketer
                                                             userId:kUserId
                                                          eventName:kEventWithExperimentNotRunningName
                                                          eventTags:nil
                                                         attributes:nil];
    XCTAssertNil(eventTicket, @"Event ticket should be nil.");
}

- (void)testBuildEventTicketWithoutExperiment
{
    NSDictionary *eventTicket = [self.eventBuilder buildEventTicket:self.config
                                                           bucketer:self.bucketer
                                                             userId:kUserId
                                                          eventName:kEventWithoutExperimentName
                                                          eventTags:nil
                                                         attributes:nil];
    XCTAssertNil(eventTicket, @"Event ticket should be nil.");
}

- (void)testBuildEventTicketWithRevenue
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithAudienceName
                                                     eventTags:@{ OPTLYEventMetricNameRevenue : [NSNumber numberWithInteger:kEventValue]}
                                                    attributes:attributes];
    [self checkCommonParams:params withAttributes:attributes];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithAudienceId
                 eventName:kEventWithAudienceName
                 eventTags:@{ OPTLYEventMetricNameRevenue : [NSNumber numberWithInteger:kEventValue]}
                attributes:attributes
                    userId:kUserId
             experimentIds:@[kExperimentWithAudienceId]];
}

- (void)testBuildEventTicketWithInvalidDoubleRevenue
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    double doubleRevenueValue = 888.88;
    long long doubleRevenueValueCast = doubleRevenueValue;
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithAudienceName
                                                     eventTags:@{ OPTLYEventMetricNameRevenue : [NSNumber numberWithDouble:doubleRevenueValue]}
                                                    attributes:attributes];
    [self checkCommonParams:params withAttributes:attributes];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithAudienceId
                 eventName:kEventWithAudienceName
                 eventTags:@{ OPTLYEventMetricNameRevenue : [NSNumber numberWithLongLong:doubleRevenueValueCast]}
                attributes:attributes
                    userId:kUserId
             experimentIds:@[kExperimentWithAudienceId]];
}

- (void)testBuildEventTicketWithInvalidBooleanRevenue
{
    NSDictionary *attributes = @{ kAttributeKeyBrowserType : kAttributeValueFirefox };
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithAudienceName
                                                     eventTags:@{ OPTLYEventMetricNameRevenue : @YES }
                                                    attributes:attributes];
    [self checkCommonParams:params withAttributes:attributes];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithAudienceId
                 eventName:kEventWithAudienceName
                 eventTags:@{ OPTLYEventMetricNameRevenue : [NSNumber numberWithBool:YES] }
                attributes:attributes
                    userId:kUserId
             experimentIds:@[kExperimentWithAudienceId]];
}

- (void)testBuildEventTicketWithEventTags
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithAudienceName
                                                     eventTags:@{ kAttributeKeyBrowserType : kAttributeValueChrome,
                                                                  @"IntegerTag" : [NSNumber numberWithInteger:15],
                                                                  @"BooleanTag" : @YES,
                                                                  @"FloatTag" : [NSNumber numberWithFloat:1.23],
                                                                  @"InvalidArrayTag" : [NSArray new]}
                                                    attributes:attributes];
    [self checkCommonParams:params withAttributes:attributes];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithAudienceId
                 eventName:kEventWithAudienceName
                 eventTags:@{ kAttributeKeyBrowserType : kAttributeValueChrome,
                              @"IntegerTag" : [NSNumber numberWithInteger:15],
                              @"FloatTag" : [NSNumber numberWithFloat:1.23],
                              @"BooleanTag" : @YES}
                attributes:attributes
                    userId:kUserId
             experimentIds:@[kExperimentWithAudienceId]];
}

- (void)testBuildEventTicketWithRevenueAndEventTags
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithAudienceName
                                                     eventTags:@{ OPTLYEventMetricNameRevenue : [NSNumber numberWithInteger:kEventValue],
                                                                  kAttributeKeyBrowserType : kAttributeValueChrome }
                                                    attributes:attributes];
    [self checkCommonParams:params withAttributes:attributes];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithAudienceId
                 eventName:kEventWithAudienceName
                 eventTags:@{ OPTLYEventMetricNameRevenue : [NSNumber numberWithInteger:kEventValue],
                              kAttributeKeyBrowserType : kAttributeValueChrome}
                attributes:attributes
                    userId:kUserId
             experimentIds:@[kExperimentWithAudienceId]];
}

- (void)testBuildEventTicketWithAllArguments
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithAudienceName
                                                     eventTags:@{ OPTLYEventMetricNameRevenue : [NSNumber numberWithInteger:kEventValue]}
                                                    attributes:attributes];
    [self checkCommonParams:params withAttributes:attributes];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithAudienceId
                 eventName:kEventWithAudienceName
                 eventTags:@{ OPTLYEventMetricNameRevenue : [NSNumber numberWithInteger:kEventValue] }
                attributes:attributes
                    userId:kUserId
             experimentIds:@[kExperimentWithAudienceId]];
}

- (void)testBuildEventTicketWithEventMultipleExperiments
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueChrome};
    
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithMultipleExperimentsName
                                                     eventTags:@{ OPTLYEventMetricNameRevenue : [NSNumber numberWithInteger:kEventValue] }
                                                    attributes:attributes];
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
    
    NSDictionary *params = [eventBuilder buildEventTicket:config
                                                 bucketer:bucketer
                                                   userId:kUserId
                                                eventName:kEventWithoutAudienceName
                                                eventTags:nil
                                               attributes:nil];
    
    NSNumber *anonymizeIP = params[OPTLYEventParameterKeysAnonymizeIP];
    NSAssert([anonymizeIP boolValue] == false, @"Incorrect value for IP anonymization.");
}

- (void)testCreateImpressionEventWithBucketingIDAttribute
{
    NSDictionary *attributes = @{OptimizelyBucketId : kAttributeValueFirefox};
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithoutAudienceName
                                                     eventTags:nil
                                                    attributes:@{OptimizelyBucketId:kAttributeValueFirefox}];
    [self checkCommonParams:params
             withAttributes:attributes];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithoutAudienceId
                 eventName:kEventWithoutAudienceName
                 eventTags:nil
                attributes:attributes
                    userId:kUserId
             experimentIds:@[kExperimentWithoutAudienceId]];
}

- (void)testCreateConversionEventWithBucketingIDAttribute
{
    NSDictionary *attributes = @{OptimizelyBucketId : kAttributeValueFirefox};
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithoutAudienceName
                                                     eventTags:nil
                                                    attributes:@{OptimizelyBucketId:kAttributeValueFirefox}];
    [self checkCommonParams:params
             withAttributes:attributes];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithoutAudienceId
                 eventName:kEventWithoutAudienceName
                 eventTags:nil
                attributes:attributes
                    userId:kUserId
             experimentIds:@[kExperimentWithoutAudienceId]];
}

#pragma mark - Test buildDecisionEventTicket:...

- (void)testBuildDecisionEventTicketWithAllArguments
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:kExperimentWithAudienceKey
                                                                        userId:kUserId
                                                                    attributes:attributes
                                                                      bucketer:self.bucketer];
    
    
    NSDictionary *decisionEventTicketParams = [self.eventBuilder buildDecisionEventTicket:self.config
                                                                                   userId:kUserId
                                                                            experimentKey:kExperimentWithAudienceKey
                                                                              variationId:bucketedVariation.variationId
                                                                               attributes:attributes];
    [self checkCommonParams:decisionEventTicketParams withAttributes:attributes];
    [self checkDecisionTicketParams:decisionEventTicketParams
                             config:self.config
                           bucketer:self.bucketer
                         attributes:attributes
                      experimentKey:kExperimentWithAudienceKey
                             userId:kUserId];
    
}

- (void)testBuildDecisionEventTicketWithNoAudience
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    NSDictionary *decisionEventTicketParams = [self.eventBuilder buildDecisionEventTicket:self.config
                                                                                   userId:kUserId
                                                                            experimentKey:kExperimentWithoutAudienceKey
                                                                              variationId:kVariationWithoutAudienceId
                                                                               attributes:attributes];
    [self checkCommonParams:decisionEventTicketParams withAttributes:attributes];
    [self checkDecisionTicketParams:decisionEventTicketParams
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
    
    NSDictionary *decisionEventTicketParams = [self.eventBuilder buildDecisionEventTicket:self.config
                                                                                   userId:kUserId
                                                                            experimentKey:invalidExperimentKey
                                                                              variationId:invalidVariationId
                                                                               attributes:attributes];
    NSAssert([decisionEventTicketParams count] == 0, @"parameters should not be created with unknown experiment.");
}

- (void)testBuildDecisionTicketWithAnonymizeIPFalse {
    OPTLYProjectConfig *config = [self setUpForAnonymizeIPFalse];
    OPTLYEventBuilderDefault *eventBuilder = [OPTLYEventBuilderDefault new];
    
    NSDictionary *decisionEventTicketParams = [eventBuilder buildDecisionEventTicket:config
                                                                              userId:kUserId
                                                                       experimentKey:kExperimentWithoutAudienceKey
                                                                         variationId:kVariationWithoutAudienceId
                                                                          attributes:nil];
    NSNumber *anonymizeIP = decisionEventTicketParams[OPTLYEventParameterKeysAnonymizeIP];
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

- (void)checkEventTicket:(NSDictionary *)params
                  config:(OPTLYProjectConfig *)config
                 eventId:(NSString *)eventId
               eventName:(NSString *)eventName
               eventTags:(NSDictionary *)eventTags
              attributes:(NSDictionary *)attributes
                  userId:(NSString *)userId
           experimentIds:(NSArray *)experimentIds

{
    NSAssert([params[OPTLYEventParameterKeysEventEntityId] isEqualToString:eventId], @"Invalid entityId.");
    
    NSAssert([params[OPTLYEventParameterKeysEventName] isEqualToString:eventName], @"Invalid event name: %@. Should be: %@.", params[OPTLYEventParameterKeysEventName], eventName);
    
    NSArray *eventFeatures = params[OPTLYEventParameterKeysEventFeatures];
    if ([eventTags count] > 0)
    {
        [self checkEventFeatures:eventFeatures eventTags:eventTags];
    }
    
    NSArray *eventMetrics = params[OPTLYEventParameterKeysEventMetrics];
    if ([eventMetrics count] > 0)
    {
        [self checkEventMetric:eventMetrics[0]
                     eventTags:eventTags];
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
    NSDate *currentTimestamp = [NSDate date];
    
    // check timestamp is within the correct range
    NSNumber *timestamp = params[OPTLYEventParameterKeysTimestamp];
    double time = [timestamp doubleValue]/1000;
    NSDate *eventTimestamp = [NSDate dateWithTimeIntervalSince1970:time];
    NSAssert([self date:eventTimestamp isBetweenDate:self.begTimestamp andDate:currentTimestamp], @"Invalid timestamp: %@.", eventTimestamp);
    
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
        
        NSString *featureName = params[OPTLYEventParameterKeysFeaturesName];
        NSString *featureID = params[OPTLYEventParameterKeysFeaturesId];
        if ([featureName isEqualToString:OptimizelyBucketIdEventParam]) {
            // check id
            XCTAssertNil(featureID, @"There should be no id here.");
        } else {
            // check name
            XCTAssert([featureName isEqualToString:anAttributeKey ], @"Incorrect feature name.");
            // check id
            XCTAssert([featureID isEqualToString:kAttributeId], @"Incorrect feature id: %@.", featureID);
        }
        
        // check type
        NSString *featureType = params[OPTLYEventParameterKeysFeaturesType];
        XCTAssert([featureType isEqualToString:OPTLYEventFeatureFeatureTypeCustomAttribute], @"Incorrect feature type.");
        
        // check value
        NSString *featureValue = params[OPTLYEventParameterKeysFeaturesValue];
        XCTAssert([featureValue isEqualToString:anAttributeValue], @"Incorrect feature value.");
        
        // check should index
        BOOL shouldIndex = [params[OPTLYEventParameterKeysFeaturesShouldIndex] boolValue];
        XCTAssert(shouldIndex == true, @"Incorrect shouldIndex value.");
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
               eventTags:(NSDictionary *)eventTags
{
    NSAssert([params[OPTLYEventParameterKeysMetricName] isEqualToString:OPTLYEventMetricNameRevenue], @"Invalid event metric name: %@.", params[OPTLYEventParameterKeysMetricName]);
    NSAssert([params[OPTLYEventParameterKeysMetricValue] isEqualToNumber:eventTags[OPTLYEventMetricNameRevenue]], @"Invalid event metric value: %@.", params[OPTLYEventParameterKeysMetricValue]);
}

- (void)checkEventFeatures:(NSArray *)eventFeatures
                 eventTags:(NSDictionary *)eventTags
{
    XCTAssert([eventFeatures count] == [eventTags count], @"Invalid number of event feature.");
    
    for (NSDictionary *eventFeature in eventFeatures) {
        
        XCTAssert([eventFeature count] == 4, @"Invalid number of keys in event feature.");
        
        NSString *eventFeatureName = eventFeature[OPTLYEventParameterKeysFeaturesName];
        XCTAssertNotNil(eventFeatureName, @"Event feature name is missing from event feature.");
        XCTAssertNotNil(eventTags[eventFeatureName], @"Invalid event feature name.");
        
        NSNumber *eventFeatureValue = eventFeature[OPTLYEventParameterKeysFeaturesValue];
        XCTAssertNotNil(eventFeatureValue, @"Event feature value is missing from event feature.");
        XCTAssert([eventFeatureValue isEqual: eventTags[eventFeatureName]], @"Invalid event feature value.");
        
        XCTAssertEqual(eventFeature[OPTLYEventParameterKeysFeaturesShouldIndex], @NO, @"Invalid should index value for event feature.");
        
        XCTAssertEqual(eventFeature[OPTLYEventParameterKeysFeaturesType], OPTLYEventFeatureFeatureTypeCustomAttribute, @"Invalid feature type for event feature.");
    }
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

- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
}

@end
