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
#import "OPTLYDecisionService.h"
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
#import "OPTLYExperiment.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYVariation.h"

NSString * const OptimizelyBucketIdEventParam = @"optimizely_bucketing_id";
NSString * const OptimizelyActivateEventKey = @"campaign_activated";

// --- Event URLs ----
NSString * const OPTLYEventBuilderEventsTicketURL   = @"https://logx.optimizely.com/v1/events";

@implementation OPTLYEventBuilderDefault : NSObject 

// NOTE: A dictionary is used to build the decision event ticket object instead of
// OPTLYDecisionEventTicket object to simplify the logic. The OPTLYEventFeature value can be a
// string, double, float, int, or boolean.
// The OPTLYJSONModel cannot support a generic primitive/object type, so each event tag
// value would have to be manually checked and converted to the appropriate OPTLYEventFeature type.
-(NSDictionary *)buildImpressionEventTicket:(OPTLYProjectConfig *)config
                                     userId:(NSString *)userId
                              experimentKey:(NSString *)experimentKey
                                variationId:(NSString *)variationId
                                 attributes:(NSDictionary<NSString *,NSString *> *)attributes {
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
    
    OPTLYExperiment *experiment = [config getExperimentForKey:experimentKey];
    
    if (!experiment) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesNotBuildingDecisionEventTicket, experimentKey];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    NSDictionary *commonParams = [self createCommonParams:config userId:userId attributes:attributes];
    NSDictionary *impressionOnlyParams = [self createImpressionParams:experiment variationId:variationId];
    NSDictionary *impressionParams = [self createImpressionOrConversionParamsWithCommonParams:commonParams conversionOrImpressionOnlyParams:@[impressionOnlyParams]];
    
    return impressionParams;
}
    
-(NSDictionary *)buildConversionTicket:(OPTLYProjectConfig *)config
                              bucketer:(id<OPTLYBucketer>)bucketer
                                userId:(NSString *)userId
                             eventName:(NSString *)eventName
                             eventTags:(NSDictionary *)eventTags
                            attributes:(NSDictionary<NSString *,NSString *> *)attributes {
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
    
    NSDictionary *commonParams = [self createCommonParams:config userId:userId attributes:attributes];
    NSArray *conversionOnlyParams = [self createConversionParams:config bucketer:bucketer eventKey:eventName userId:userId eventTags:eventTags attributes:attributes];
    if ([conversionOnlyParams count] == 0) {
        [config.logger logMessage:OPTLYLoggerMessagesVariationIdInvalid withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    NSDictionary *conversionParams = [self createImpressionOrConversionParamsWithCommonParams:commonParams conversionOrImpressionOnlyParams:conversionOnlyParams];
    
    return conversionParams;
}


- (NSNumber *)revenueValue:(OPTLYProjectConfig *)config value:(NSObject *)value {
    // Convert value to NSNumber of type "long long" or nil (failure) if impossible.
    NSNumber *answer = nil;
    // If the object is an in range NSNumber, then char, floats, and boolean values will be cast to a "long long".
    if ([value isKindOfClass:[NSNumber class]]) {
        answer = (NSNumber*)value;
        const char *objCType = [answer objCType];
        // Dispatch objCType according to one of "Type Encodings" listed here:
        // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        if ((strcmp(objCType, @encode(bool)) == 0)
            || [value isEqual:@YES]
            || [value isEqual:@NO]) {
            // NSNumber's generated by "+ (NSNumber *)numberWithBool:(BOOL)value;"
            // serialize to JSON booleans "true" and "false" via NSJSONSerialization .
            // The @YES and @NO compile to __NSCFBoolean's which (strangely enough)
            // are ((strcmp(objCType, @encode(char)) == 0) but these serialize as
            // JSON booleans "true" and "false" instead of JSON numbers.
            // These aren't integers, so shouldn't be sent.
            answer = nil;
            [config.logger logMessage:OPTLYLoggerMessagesRevenueValueInvalidBoolean withLevel:OptimizelyLogLevelWarning];
        } else if ((strcmp(objCType, @encode(char)) == 0)
            || (strcmp(objCType, @encode(unsigned char)) == 0)
            || (strcmp(objCType, @encode(short)) == 0)
            || (strcmp(objCType, @encode(unsigned short)) == 0)
            || (strcmp(objCType, @encode(int)) == 0)
            || (strcmp(objCType, @encode(unsigned int)) == 0)
            || (strcmp(objCType, @encode(long)) == 0)
            || (strcmp(objCType, @encode(long long)) == 0)) {
            // These objCType's all fit inside "long long"
        } else if (((strcmp(objCType, @encode(unsigned long)) == 0)
                    || (strcmp(objCType, @encode(unsigned long long)) == 0))) {
            // Cast in range "unsigned long" and "unsigned long long" to "long long".
            // NOTE: Above uses all 64 bits of precision available and that "unsigned long"
            // and "unsigned long long" are same size on 64 bit Apple platforms.
            // https://developer.apple.com/library/content/documentation/General/Conceptual/CocoaTouch64BitGuide/Major64-BitChanges/Major64-BitChanges.html
            if ([answer unsignedLongLongValue]<=((unsigned long long)LLONG_MAX)) {
                long long longLongValue = [answer longLongValue];
                answer = [NSNumber numberWithLongLong:longLongValue];
            } else {
                // The unsignedLongLongValue is outside of [LLONG_MIN,LLONG_MAX], so
                // can't be properly cast to "long long" nor will be sent.
                answer = nil;
                [config.logger logMessage:OPTLYLoggerMessagesRevenueValueIntegerOverflow withLevel:OptimizelyLogLevelWarning];
            }
        } else if ((LLONG_MIN<=[answer doubleValue])&&([answer doubleValue]<=LLONG_MAX)) {
            // Cast in range floats etc. to long long, rounding or trunctating fraction parts.
            // NOTE: Mantissas of Objective-C doubles have 53 bits of precision which is
            // less than the 64 bits of precision of a "long long" or "unsigned long".
            // OTOH, floats have expts which can put the value of float outside the range
            // of a "long long" or "unsigned long".  Therefore, we test doubleValue
            // -- the highest precision floating format made available by NSNumber --
            // against [LLONG_MIN,LLONG_MAX] only after we're guaranteed we've already
            // considered all possible NSNumber integer formats (the previous two "if"
            // conditions).
            // https://en.wikipedia.org/wiki/IEEE_754
            // Intel "Floating-point Formats"
            // https://software.intel.com/en-us/node/523338
            // ARM "IEEE 754 arithmetic"
            // https://developer.arm.com/docs/dui0808/g/floating-point-support/ieee-754-arithmetic
            answer = @([answer longLongValue]);
            // Appropriate warning since conversion to integer generally will lose
            // some non-zero fraction after the decimal point.  Even if the fraction is zero,
            // the warning could alert user of SDK to a coding issue that should be remedied.
            [config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesRevenueValueFloatOverflow, value, answer] withLevel:OptimizelyLogLevelWarning];
        } else {
            // all other NSNumber's can't be reasonably cast to long long
            answer = nil;
            [config.logger logMessage:OPTLYLoggerMessagesRevenueValueInvalid withLevel:OptimizelyLogLevelWarning];
        }
    } else if ([value isKindOfClass:[NSString class]]) {
        // cast strings to long long
        answer = @([(NSString*)value longLongValue]);
        [config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesRevenueValueString, value] withLevel:OptimizelyLogLevelWarning];
    } else {
        // all other objects can't be cast to long long
        [config.logger logMessage:OPTLYLoggerMessagesRevenueValueInvalid withLevel:OptimizelyLogLevelWarning];
    };
    return answer;
}

- (NSNumber *)numericValue:(OPTLYProjectConfig *)config value:(NSObject *)value {
    // Convert value to NSNumber of type "double" or nil (failure) if impossible.
    NSNumber *answer = nil;
    // if the object is an NSNumber, then char, floats, and boolean values will be cast to a double int
    if ([value isKindOfClass:[NSNumber class]]) {
        answer = (NSNumber*)value;
        const char *objCType = [answer objCType];
        // Dispatch objCType according to one of "Type Encodings" listed here:
        // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        if ((strcmp(objCType, @encode(bool)) == 0)
            || [value isEqual:@YES]
            || [value isEqual:@NO]) {
            // NSNumber's generated by "+ (NSNumber *)numberWithBool:(BOOL)value;"
            // serialize to JSON booleans "true" and "false" via NSJSONSerialization .
            // The @YES and @NO compile to __NSCFBoolean's which (strangely enough)
            // are ((strcmp(objCType, @encode(char)) == 0) but these serialize as
            // JSON booleans "true" and "false" instead of JSON numbers.
            // These aren't integers, so shouldn't be sent.
            answer = nil;
            [config.logger logMessage:OPTLYLoggerMessagesNumericValueInvalidBoolean withLevel:OptimizelyLogLevelWarning];
        } else {
            // Require real numbers (not infinite or NaN).
            double doubleValue = [(NSNumber*)value doubleValue];
            if (isfinite(doubleValue)) {
                answer = (NSNumber*)value;
            } else {
                answer = nil;
                [config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesNumericValueInvalidFloat, value] withLevel:OptimizelyLogLevelWarning];
            }
        }
    } else if ([value isKindOfClass:[NSString class]]) {
        // cast strings to double
        double doubleValue = [(NSString*)value doubleValue];
        if (isfinite(doubleValue)) {
            [config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesNumericValueString, value] withLevel:OptimizelyLogLevelWarning];
            answer = [NSNumber numberWithDouble:doubleValue];
        } else {
            [config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesNumericValueInvalidString, value] withLevel:OptimizelyLogLevelWarning];
        }
    } else {
        // all other objects can't be cast to double
        [config.logger logMessage:OPTLYLoggerMessagesNumericValueInvalid withLevel:OptimizelyLogLevelWarning];
    };
    return answer;
}

- (NSDictionary *)createCommonParams:(OPTLYProjectConfig *)config userId:(NSString *)userId
                          attributes:(NSDictionary<NSString *, NSString *> *)attributes {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    NSMutableDictionary *visitor = [NSMutableDictionary new];
    visitor[OPTLYEventParameterKeysSnapshots] =  [NSMutableArray new];
    visitor[OPTLYEventParameterKeysVisitorId] = [OPTLYEventBuilderDefault stringOrEmpty:userId];
    visitor[OPTLYEventParameterKeysAttributes] = [self createUserFeatures:config attributes:attributes];
    
    params[OPTLYEventParameterKeysVisitors] = @[visitor];
    params[OPTLYEventParameterKeysProjectId] = [OPTLYEventBuilderDefault stringOrEmpty:config.projectId ];
    params[OPTLYEventParameterKeysAccountId] = [OPTLYEventBuilderDefault stringOrEmpty:config.accountId];
    params[OPTLYEventParameterKeysClientEngine] = [OPTLYEventBuilderDefault stringOrEmpty:[config clientEngine]];
    params[OPTLYEventParameterKeysClientVersion] = [OPTLYEventBuilderDefault stringOrEmpty:[config clientVersion]];
    params[OPTLYEventParameterKeysRevision] = [OPTLYEventBuilderDefault stringOrEmpty:config.revision];
    params[OPTLYEventParameterKeysAnonymizeIP] = @(config.anonymizeIP.boolValue);
    
    return [params copy];
}
    
- (NSDictionary *)createImpressionParams:(OPTLYExperiment *)experiment variationId:(NSString *)variationId {
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    NSMutableDictionary *decision = [NSMutableDictionary new];
    decision[OPTLYEventParameterKeysDecisionCampaignId]                 =[OPTLYEventBuilderDefault stringOrEmpty:experiment.layerId];
    decision[OPTLYEventParameterKeysDecisionExperimentId]       =experiment.experimentId;
    decision[OPTLYEventParameterKeysDecisionVariationId]        =variationId;
    decision[OPTLYEventParameterKeysDecisionIsLayerHoldback]    = @NO;
    NSArray *decisions = @[decision];
    
    NSMutableDictionary *event = [NSMutableDictionary new];
    event[OPTLYEventParameterKeysEntityId]      =[OPTLYEventBuilderDefault stringOrEmpty:experiment.layerId];
    event[OPTLYEventParameterKeysTimestamp]     =[self time] ? : @0;
    event[OPTLYEventParameterKeysKey]           =OptimizelyActivateEventKey;
    event[OPTLYEventParameterKeysUUID]          =[[NSUUID UUID] UUIDString];
    NSArray *events = @[event];
    
    params[OPTLYEventParameterKeysDecisions] = decisions;
    params[OPTLYEventParameterKeysEvents] = events;
    
    return params;
}

- (NSDictionary *)createImpressionOrConversionParamsWithCommonParams:(NSDictionary *)commonParams
                                 conversionOrImpressionOnlyParams:(NSArray *)conversionOrImpressionOnlyParams {
    
    NSMutableArray *visitors = commonParams[OPTLYEventParameterKeysVisitors];
    
    if(visitors.count > 0) {
        NSMutableDictionary *visitor = visitors[0];
        visitor[OPTLYEventParameterKeysSnapshots] = conversionOrImpressionOnlyParams;
    }
    
    return commonParams;
}

- (NSArray *)createConversionParams:(OPTLYProjectConfig *)config
                                bucketer:(id<OPTLYBucketer>)bucketer
                                eventKey:(NSString *)eventKey
                                  userId:(NSString *)userId
                               eventTags:(NSDictionary *)eventTags
                              attributes:(NSDictionary *)attributes {
    
    OPTLYEvent *eventEntity = [config getEventForKey:eventKey];
    NSArray *eventExperimentIds = eventEntity.experimentIds;
    
    if ([eventExperimentIds count] == 0) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventNotAssociatedWithExperiment, eventKey];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return nil;
    }
    
    NSMutableArray *conversionEventParams = [NSMutableArray new];
    for (NSString *eventExperimentId in eventExperimentIds) {
        OPTLYExperiment *experiment = [config getExperimentForId:eventExperimentId];
        
        // if the experiment is nil, then it is not part of the project's list of experiments
        if (!experiment) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesExperimentNotPartOfEvent, experiment.experimentKey, eventEntity.eventKey];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            continue;
        }
        
        // bucket user into a variation
        OPTLYVariation *bucketedVariation = [config getVariationForExperiment:experiment.experimentKey
                                                                       userId:userId
                                                                   attributes:attributes
                                                                     bucketer:bucketer];
        
        if (bucketedVariation) {
            
            NSMutableDictionary *params = [NSMutableDictionary new];
            
            NSMutableDictionary *decision = [NSMutableDictionary new];
            decision[OPTLYEventParameterKeysDecisionCampaignId]         =[OPTLYEventBuilderDefault stringOrEmpty:experiment.layerId];
            decision[OPTLYEventParameterKeysDecisionExperimentId]       =experiment.experimentId;
            decision[OPTLYEventParameterKeysDecisionVariationId]        =bucketedVariation.variationId;
            decision[OPTLYEventParameterKeysDecisionIsLayerHoldback]    = @NO;
            NSArray *decisions = @[decision];
            
            NSMutableDictionary *event = [NSMutableDictionary new];
            event[OPTLYEventParameterKeysEntityId]      =[OPTLYEventBuilderDefault stringOrEmpty:eventEntity.eventId];
            event[OPTLYEventParameterKeysTimestamp]     =[self time] ? : @0;
            event[OPTLYEventParameterKeysKey]           =eventKey;
            event[OPTLYEventParameterKeysUUID]          =[[NSUUID UUID] UUIDString];
            
            NSMutableDictionary *mutableEventTags = [[NSMutableDictionary alloc] initWithDictionary:eventTags];
            
            for (NSString *key in [eventTags allKeys]) {
                id eventTagValue = eventTags[key];
                
                // only string, long, int, double, float, and booleans are supported
                if ([eventTagValue isKindOfClass:[NSString class]] || [eventTagValue isKindOfClass:[NSNumber class]]) {
                    if ([key isEqualToString:OPTLYEventMetricNameRevenue]) {
                        // Allow only 'revenue' eventTags with integer values (max long long); otherwise the value will be cast to an integer
                        NSNumber *revenueValue = [self revenueValue:config value:eventTags[OPTLYEventMetricNameRevenue]];
                        if (revenueValue != nil) {
                            event[OPTLYEventMetricNameRevenue] = revenueValue;
                        } else {
                            [mutableEventTags removeObjectForKey:OPTLYEventMetricNameRevenue];
                        }
                    }
                    if ([key isEqualToString:OPTLYEventMetricNameValue]) {
                        // Allow only 'value' eventTags with double values; otherwise the value will be cast to a double
                        NSNumber *numericValue = [self numericValue:config value:eventTags[OPTLYEventMetricNameValue]];
                        if (numericValue != nil) {
                            event[OPTLYEventMetricNameValue] = numericValue;
                        } else {
                            [mutableEventTags removeObjectForKey:OPTLYEventMetricNameValue];
                        }
                    }
                } else {
                    [mutableEventTags removeObjectForKey:key];
                    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventTagValueInvalid, key];
                    [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
                }
            }
            event[OPTLYEventParameterKeysTags] = mutableEventTags;

            NSArray *events = @[event];
            
            params[OPTLYEventParameterKeysDecisions] = decisions;
            params[OPTLYEventParameterKeysEvents] = events;
            
            [conversionEventParams addObject:params];
        }
    }
    
    return [conversionEventParams copy];
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
        
        if ([attributeValue length] == 0) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAttributeValueInvalidFormat, attributeKey];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
            continue;
        }
        
        NSDictionary *featureParams;
        if ([attributeKey isEqualToString:OptimizelyBucketId]) {
            // check for reserved attribute OptimizelyBucketId
            featureParams = @{ OPTLYEventParameterKeysFeaturesId           : OptimizelyBucketId,
                               OPTLYEventParameterKeysFeaturesKey          : OptimizelyBucketIdEventParam,
                               OPTLYEventParameterKeysFeaturesType         : OPTLYEventFeatureFeatureTypeCustomAttribute,
                               OPTLYEventParameterKeysFeaturesValue        : attributeValue,
                               OPTLYEventParameterKeysFeaturesShouldIndex  : @YES };
        } else {
            if ([attributeId length] == 0) {
                NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAttributeInvalidFormat, attributeKey];
                [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
                continue;
            }
            featureParams = @{ OPTLYEventParameterKeysFeaturesId           : attributeId,
                               OPTLYEventParameterKeysFeaturesKey          : attributeKey,
                               OPTLYEventParameterKeysFeaturesType         : OPTLYEventFeatureFeatureTypeCustomAttribute,
                               OPTLYEventParameterKeysFeaturesValue        : attributeValue,
                               OPTLYEventParameterKeysFeaturesShouldIndex  : @YES };
        }
        if (featureParams) {
            [features addObject:featureParams];
        }
    }
    return [features copy];
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

+ (NSString *)stringOrEmpty:(NSString *)str {
    NSString *string = str != nil ? str : @"";
    return string;
}

@end
