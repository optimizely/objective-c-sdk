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

// --- Event URLs ----
NSString * const OPTLYEventBuilderDecisionTicketEventURL   = @"https://p13nlog.dz.optimizely.com/log/decision";
NSString * const OPTLYEventBuilderEventTicketURL           = @"https://p13nlog.dz.optimizely.com/log/event";

@implementation OPTLYEventBuilderDefault : NSObject 

- (OPTLYDecisionEventTicket *)buildDecisionEventTicket:(OPTLYProjectConfig *)config
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

    NSError *error;
    OPTLYDecisionEventTicket *decision = [[OPTLYDecisionEventTicket alloc] initWithDictionary:params error:&error];
    
    return decision;
}

- (OPTLYEventTicket *)buildEventTicket:(OPTLYProjectConfig *)config
                              bucketer:(id<OPTLYBucketer>)bucketer
                                userId:(NSString *)userId
                             eventName:(NSString *)eventName
                            eventValue:(NSNumber *)eventValue
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
    params[OPTLYEventParameterKeysEventFeatures] = @[];
    params[OPTLYEventParameterKeysEventMetrics] = eventValue? @[[self createEventMetric:eventValue]] : @[];
    params[OPTLYEventParameterKeysLayerStates] = layerStates;
   
    NSError *error;
    OPTLYEventTicket *eventTicket = [[OPTLYEventTicket alloc] initWithDictionary:params error:&error];
    return eventTicket;
}

- (NSDictionary *)createDecisionWithExperimentId:(NSString *)experimentId
                                     variationId:(NSString *)variationId
{
    NSDictionary *decisionParams = @{ OPTLYEventParameterKeysDecisionExperimentId       : experimentId,
                                      OPTLYEventParameterKeysDecisionVariationId        : variationId,
                                      OPTLYEventParameterKeysDecisionIsLayerHoldback    : @0 };
    
    return decisionParams;
}

- (NSDictionary *)createEventMetric:(NSNumber *)eventValue
{
    NSDictionary *metricParams = [NSDictionary new];
    
    if (!eventValue) {
        return metricParams;
    }
    
    metricParams = @{ OPTLYEventParameterKeysMetricName  : OPTLYEventMetricNameRevenue,
                      OPTLYEventParameterKeysMetricValue : eventValue };
    return metricParams;
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
    params[OPTLYEventParameterKeysIsGlobalHoldback] = @false;
    params[OPTLYEventParameterKeysAnonymizeIP] = [NSNumber numberWithBool:config.anonymizeIP];
    
    return [params copy];
    
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
                                         OPTLYEventParameterKeysFeaturesShouldIndex  : @1 };
        
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
                                                OPTLYEventParameterKeysLayerStateActionTriggered    : @0 };
         
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
    NSNumber *timestamp = [NSNumber numberWithDouble:currentTimeInterval];

    return timestamp;
}
@end
