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

/*
 This class packages the parameters for impression and conversion events sent to the backend.
 */

#import <Foundation/Foundation.h>

@class OPTLYProjectConfig, OPTLYDecisionEventTicket;
@protocol OPTLYBucketer;

// --- Event URLs ----
NS_ASSUME_NONNULL_BEGIN
extern NSString * const OptimizelyBucketIdEventParam;
extern NSString * const OptimizelyActivateEventKey;
extern NSString * const OPTLYEventBuilderEventsTicketURL;
NS_ASSUME_NONNULL_END

@protocol OPTLYEventBuilder <NSObject>

/**
 * Create the parameters for an impression event.
 *
 * @param config The project config object.
 * @param userId The ID of the user.
 * @param experimentKey The experiment name.
 * @param variationId The variation ID.
 * @param attributes A map of attribute names to current user attribute values.
 * @return A map of parameters for an impression event. This value can be nil.
 *
 */
- (nullable NSDictionary *)buildImpressionEventTicket:(nonnull OPTLYProjectConfig *)config
                                         userId:(nonnull NSString *)userId
                                  experimentKey:(nonnull NSString *)experimentKey
                                    variationId:(nonnull NSString *)variationId
                                     attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;
   
/**
 * Create the parameters for a conversion event.
 *
 * @param config The project config object.
 * @param userId The ID of the user.
 * @param eventName The event name.
 * @param eventTags A map of event tag names to event tag values (NSString or NSNumber containing float, double, integer, or boolean).
 * @param attributes A map of attribute names to current user attribute values.
 * @return A map of parameters for a conversion event. This value can be nil.
 *
 */
- (nullable NSDictionary *)buildConversionTicket:(nonnull OPTLYProjectConfig *)config
                               bucketer:(nonnull id<OPTLYBucketer>)bucketer
                                 userId:(nonnull NSString *)userId
                              eventName:(nonnull NSString *)eventName
                              eventTags:(nullable NSDictionary *)eventTags
                             attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;
@end

@interface OPTLYEventBuilderDefault : NSObject<OPTLYEventBuilder>

@end
