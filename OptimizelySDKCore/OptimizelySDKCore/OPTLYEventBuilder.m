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

#import "OPTLYAttribute.h"
#import "OPTLYBucketer.h"
#import "OPTLYDecisionEventTicket.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYEvent.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYEventFeature.h"
#import "OPTLYEventDecision.h"
#import "OPTLYEventDecisionTicket.h"
#import "OPTLYEventHeader.h"
#import "OPTLYEventLayerState.h"
#import "OPTLYEventMetric.h"
#import "OPTLYEventParameterKeys.h"
#import "OPTLYEventTicket.h"
#import "OPTLYExperiment.h"
#import "OPTLYLogger.h"
#import "OPTLYMacros.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYValidator.h"
#import "OPTLYVariation.h"

// --- Event URLs ----
NSString * const OPTLYEventBuilderDecisionTicketEventURL   = @"https://p13nlog.dz.optimizely.com/log/decision";
NSString * const OPTLYEventBuilderEventTicketURL           = @"https://p13nlog.dz.optimizely.com/log/event";

@implementation OPTLYEventBuilderDefault : NSObject 

// NOTE: A dictionary is used to build the decision event ticket object instead of
// OPTLYDecisionEventTicket object to simplify the logic. The OPTLYEventFeature value can be a
// string, double, float, int, or boolean.
// The JSONModel cannot support a generic primitive/object type, so each event tag
// value would have to be manually checked and converted to the appropriate OPTLYEventFeature type.
- (NSDictionary *)buildDecisionEventTicket:(OPTLYProjectConfig *)config
                                    userId:(NSString *)userId
                             experimentKey:(NSString *)experimentKey
                               variationId:(NSString *)variationId
                                attributes:(NSDictionary<NSString *, NSString *> *)attributes
{
    if (!config) {
        return nil;
    }
    
    if ([userId length] == 0) {
        [config.logger logMessage:OPTLYLoggerMessagesUserIdInvalid withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    
    if ([experimentKey length] == 0) {
        [config.logger logMessage:OPTLYLoggerMessagesExperimentKeyInvalid withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    
    if ([variationId length] == 0) {
        [config.logger logMessage:OPTLYLoggerMessagesVariationIdInvalid withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSDictionary *commonParams = [self createCommonParams:config
                                                   userId:userId
                                               attributes:attributes];
    [params addEntriesFromDictionary:commonParams];
    
    OPTLYExperiment *experiment = [config getExperimentForKey:experimentKey];
    
    if (!experiment) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesNotBuildingDecisionEventTicket, experimentKey];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    
    params[OPTLYEventParameterKeysLayerId] = StringOrEmpty(experiment.layerId);
    params[OPTLYEventParameterKeysDecision] = [self createDecisionWithExperimentId:experiment.experimentId variationId:variationId];
    
    return [params copy];
}

- (NSDictionary *)buildEventTicket:(OPTLYProjectConfig *)config
                          bucketer:(id<OPTLYBucketer>)bucketer
                            userId:(NSString *)userId
                         eventName:(NSString *)eventName
                         eventTags:(NSDictionary *)eventTags
                        attributes:(NSDictionary<NSString *, NSString *> *)attributes
{
    if (!config) {
        return nil;
    }
    
    if (!bucketer) {
        [config.logger logMessage:OPTLYLoggerMessagesBucketerInvalid withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    
    if ([userId length] == 0) {
        [config.logger logMessage:OPTLYLoggerMessagesUserIdInvalid withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    
    if ([eventName length] == 0) {
        [config.logger logMessage:OPTLYLoggerMessagesEventKeyInvalid withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    
    // Allow only 'revenue' eventTags with integer values (max long long); otherwise the value will be cast to an integer
    NSMutableDictionary *mutableEventTags = [[NSMutableDictionary alloc] initWithDictionary:eventTags];
    if ([[eventTags allKeys] containsObject:OPTLYEventMetricNameRevenue]) {
        if (!(strcmp([eventTags[OPTLYEventMetricNameRevenue] objCType], @encode(short)) == 0 ||
              strcmp([eventTags[OPTLYEventMetricNameRevenue] objCType], @encode(int)) == 0 ||
              strcmp([eventTags[OPTLYEventMetricNameRevenue] objCType], @encode(long)) == 0 ||
              strcmp([eventTags[OPTLYEventMetricNameRevenue] objCType], @encode(long long)) == 0 ||
              strcmp([eventTags[OPTLYEventMetricNameRevenue] objCType], @encode(unsigned short)) == 0 ||
              strcmp([eventTags[OPTLYEventMetricNameRevenue] objCType], @encode(unsigned int)) == 0 ||
              strcmp([eventTags[OPTLYEventMetricNameRevenue] objCType], @encode(unsigned long)) == 0 ||
              strcmp([eventTags[OPTLYEventMetricNameRevenue] objCType], @encode(unsigned long long)) == 0)) {
            [config.logger logMessage:OPTLYLoggerMessagesRevenueValueInvalid withLevel:OptimizelyLogLevelWarning];
            NSNumber *revenueValue = eventTags[OPTLYEventMetricNameRevenue];
            long long revenueValueCast = revenueValue.longLongValue;
            mutableEventTags[OPTLYEventMetricNameRevenue] = [NSNumber numberWithLongLong:revenueValueCast];
        }
    }
    
    NSArray *layerStates = [self createLayerStates:config
                                          bucketer:bucketer
                                          eventKey:eventName
                                            userId:userId
                                        attributes:attributes];
    
    // if layer states is empty, then none of the experiments passed the audience evaluation
    if ([layerStates count] == 0) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventNotPassAudienceEvaluation, eventName];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSDictionary *commonParams = [self createCommonParams:config
                                                   userId:userId
                                               attributes:attributes];
    [params addEntriesFromDictionary:commonParams];
    params[OPTLYEventParameterKeysEventEntityId] = StringOrEmpty([config getEventIdForKey:eventName]);
    params[OPTLYEventParameterKeysEventName] = StringOrEmpty(eventName);
    params[OPTLYEventParameterKeysEventFeatures] = [self createEventFeatures:config eventTags:mutableEventTags];
    params[OPTLYEventParameterKeysEventMetrics] = [self createEventMetric:config eventTags:mutableEventTags];
    params[OPTLYEventParameterKeysLayerStates] = layerStates;
   
    return [params copy];
}

- (NSDictionary *)createDecisionWithExperimentId:(NSString *)experimentId
                                     variationId:(NSString *)variationId
{
    NSDictionary *decisionParams = @{ OPTLYEventParameterKeysDecisionExperimentId       : experimentId,
                                      OPTLYEventParameterKeysDecisionVariationId        : variationId,
                                      OPTLYEventParameterKeysDecisionIsLayerHoldback    : @NO};
    
    return decisionParams;
}

- (NSArray *)createEventMetric:(OPTLYProjectConfig *)config
                     eventTags:(NSDictionary *)eventTags
{
    NSMutableArray *metrics = [NSMutableArray new];
    
    if ([[eventTags allKeys] containsObject:OPTLYEventMetricNameRevenue]) {
        NSDictionary *metricParam = @{ OPTLYEventParameterKeysMetricName  : OPTLYEventMetricNameRevenue,
                                       OPTLYEventParameterKeysMetricValue : eventTags[OPTLYEventMetricNameRevenue] };
        [metrics addObject:metricParam];
    }
    
    return [metrics copy];
}

- (NSDictionary *)createCommonParams:(OPTLYProjectConfig *)config
                              userId:(NSString *)userId
                          attributes:(NSDictionary<NSString *, NSString *> *)attributes
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[OPTLYEventParameterKeysTimestamp] = [self time] ? : @0;
    params[OPTLYEventParameterKeysRevision] = StringOrEmpty(config.revision);
    params[OPTLYEventParameterKeysVisitorId] = StringOrEmpty(userId);
    params[OPTLYEventParameterKeysProjectId] = StringOrEmpty(config.projectId);
    params[OPTLYEventParameterKeysAccountId] = StringOrEmpty(config.accountId);
    params[OPTLYEventParameterKeysClientEngine] = StringOrEmpty([config clientEngine]);
    params[OPTLYEventParameterKeysClientVersion] = StringOrEmpty([config clientVersion]);
    params[OPTLYEventParameterKeysUserFeatures] = [self createUserFeatures:config attributes:attributes];
    // This may be removed (https://optimizely.atlassian.net/browse/NB-1493)
    params[OPTLYEventParameterKeysIsGlobalHoldback] = @NO;
    params[OPTLYEventParameterKeysAnonymizeIP] = config.anonymizeIP ? @YES : @NO;
    
    return [params copy];
    
}

- (NSArray *)createEventFeatures:(OPTLYProjectConfig *)config
                       eventTags:(NSDictionary *)eventTags
{
    NSMutableArray *features = [NSMutableArray new];
    NSArray *eventTagKeys = [eventTags allKeys];

    if ([eventTags count] == 0) {
        return features;
    }

    for (NSString *key in eventTagKeys) {
        id eventTagValue = eventTags[key];
        
        // only string, long, int, double, float, and booleans are supported
        if ([eventTagValue isKindOfClass:[NSString class]] || [eventTagValue isKindOfClass:[NSNumber class]]) {
            NSDictionary *eventFeatureParams = @{ OPTLYEventParameterKeysFeaturesName        : key,
                                                  OPTLYEventParameterKeysFeaturesType        : OPTLYEventFeatureFeatureTypeCustomAttribute,
                                                  OPTLYEventParameterKeysFeaturesValue       : eventTagValue,
                                                  OPTLYEventParameterKeysFeaturesShouldIndex : @NO };
            
            [features addObject:eventFeatureParams];
        } else {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventTagValueInvalid, key];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        }
    }
    
    return [[NSArray alloc] initWithArray:features];
}


- (NSArray *)createUserFeatures:(OPTLYProjectConfig *)config
                     attributes:(NSDictionary *)attributes
{
    NSMutableArray *features = [NSMutableArray new];
    NSArray *attributeKeys = [attributes allKeys];
    
    for (NSString *attributeKey in attributeKeys) {
        OPTLYAttribute *attribute = [config getAttributeForKey:attributeKey];
        NSString *attributeValue = attributes[attributeKey];
        NSString *attributeId = attribute.attributeId;
        
        if ([attributeId length] == 0) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAttributeInvalidFormat, attributeKey];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            continue;
        }
        
        if ([attributeValue length] == 0) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAttributeValueInvalidFormat, attributeKey];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            continue;
        }
        
        NSDictionary *featureParams = @{ OPTLYEventParameterKeysFeaturesId           : attributeId,
                                         OPTLYEventParameterKeysFeaturesName         : attributeKey,
                                         OPTLYEventParameterKeysFeaturesType         : OPTLYEventFeatureFeatureTypeCustomAttribute,
                                         OPTLYEventParameterKeysFeaturesValue        : attributeValue,
                                         OPTLYEventParameterKeysFeaturesShouldIndex  : @YES };
        
        if (featureParams) {
            [features addObject:featureParams];
        }
    }
    return [features copy];
}

- (NSArray *)createLayerStates:(OPTLYProjectConfig *)config
                      bucketer:(id<OPTLYBucketer>)bucketer
                      eventKey:(NSString *)eventKey
                        userId:(NSString *)userId
                    attributes:(NSDictionary *)attributes
{
    NSMutableArray *layerStates = [NSMutableArray new];
    
    OPTLYEvent *event = [config getEventForKey:eventKey];
    NSArray *eventExperimentIds = event.experimentIds;
    
    if ([eventExperimentIds count] == 0) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventNotAssociatedWithExperiment, eventKey];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return nil;
    }
    
    for (NSString *eventExperimentId in eventExperimentIds)
    {
        OPTLYExperiment *experiment = [config getExperimentForId:eventExperimentId];
        
        // if the experiment is nil, then it is not part of the project's list of experiments
        if (!experiment) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesExperimentNotPartOfEvent, experiment.experimentKey, event.eventKey];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            continue;
        }
        
        // bucket user into a variation
        OPTLYVariation *bucketedVariation = [config getVariationForExperiment:experiment.experimentKey
                                                                       userId:userId
                                                                   attributes:attributes
                                                                     bucketer:bucketer];
    
        if (bucketedVariation) {
            NSDictionary *eventDecisionParams = [self createDecisionWithExperimentId:experiment.experimentId
                                                                         variationId:bucketedVariation.variationId];
            
            NSDictionary *layerStateParams = @{ OPTLYEventParameterKeysLayerStateLayerId            : experiment.layerId,
                                                OPTLYEventParameterKeysLayerStateDecision           : eventDecisionParams,
                                                OPTLYEventParameterKeysLayerStateRevision           : config.revision,
                                                OPTLYEventParameterKeysLayerStateActionTriggered    : @NO};
         
            if (layerStateParams) {
                [layerStates addObject:layerStateParams];
            }
        }
    }
    

    
    return [layerStates copy];
}

// time in milliseconds
- (NSNumber *)time
{
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970] * 1000;
    // need to cast this since the event class expects a long long (results will reject this value otherwise)
    long long currentTimeIntervalCast = currentTimeInterval;
    NSNumber *timestamp = [NSNumber numberWithLongLong:currentTimeIntervalCast];

    return timestamp;
}
@end
