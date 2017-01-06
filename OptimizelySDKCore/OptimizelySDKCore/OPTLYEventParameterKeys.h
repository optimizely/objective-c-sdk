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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// --- Common Event Parameters ----
extern NSString * const OPTLYEventParameterKeysTimestamp;
extern NSString * const OPTLYEventParameterKeysRevision;
extern NSString * const OPTLYEventParameterKeysActivationId;
extern NSString * const OPTLYEventParameterKeysSessionId;
extern NSString * const OPTLYEventParameterKeysVisitorId;
extern NSString * const OPTLYEventParameterKeysVisitorUUID;
extern NSString * const OPTLYEventParameterKeysProjectId;
extern NSString * const OPTLYEventParameterKeysAccountId;
extern NSString * const OPTLYEventParameterKeysClientEngine;
extern NSString * const OPTLYEventParameterKeysClientVersion;
extern NSString * const OPTLYEventParameterKeysHeader;
extern NSString * const OPTLYEventParameterKeysUserFeatures;
extern NSString * const OPTLYEventParameterKeysIsGlobalHoldback;
extern NSString * const OPTLYEventParameterKeysAnonymizeIP;

// --- Decision Ticket Event Parameters ("Impression Event") ----
extern NSString * const OPTLYEventParameterKeysDecisionId;
extern NSString * const OPTLYEventParameterKeysLayerId;
extern NSString * const OPTLYEventParameterKeysDecisionTicket;
extern NSString * const OPTLYEventParameterKeysDecision;

// --- Event Ticket Parameters ("Conversion Event") ----
extern NSString * const OPTLYEventParameterKeysEventId;
extern NSString * const OPTLYEventParameterKeysEventEntityId;
extern NSString * const OPTLYEventParameterKeysEventType;
extern NSString * const OPTLYEventParameterKeysEventName;
extern NSString * const OPTLYEventParameterKeysEventFeatures;
extern NSString * const OPTLYEventParameterKeysEventMetrics;
extern NSString * const OPTLYEventParameterKeysRelatedEvents;
extern NSString * const OPTLYEventParameterKeysLayerStates;
extern NSString * const OPTLYEventParameterKeysActiveViews;

// ---- Header Parameters ----
extern NSString * const OPTLYEventParameterKeysHeaderClientIp;
extern NSString * const OPTLYEventParameterKeysHeaderUserAgent;
extern NSString * const OPTLYEventParameterKeysHeaderReferer;

// ---- Feature Parameters ----
extern NSString * const OPTLYEventParameterKeysFeaturesId;
extern NSString * const OPTLYEventParameterKeysFeaturesName;
extern NSString * const OPTLYEventParameterKeysFeaturesType;
extern NSString * const OPTLYEventParameterKeysFeaturesValue;
extern NSString * const OPTLYEventParameterKeysFeaturesShouldIndex;

// ---- Metric Parameters ----
extern NSString * const OPTLYEventParameterKeysMetricName;
extern NSString * const OPTLYEventParameterKeysMetricValue;

// ---- Related Event Parameters ----
extern NSString * const OPTLYEventParameterKeysRelatedEventsEventId;
extern NSString * const OPTLYEventParameterKeysRelatedEventsRelationship;

// ---- Audience Parameters ----
extern NSString * const OPTLYEventParameterKeysAudienceId;
extern NSString * const OPTLYEventParameterKeysAudienceName;

// ---- Decision Ticket Parameters ----
extern NSString * const OPTLYEventParameterKeysDecisionTicketAudiences;
extern NSString * const OPTLYEventParameterKeysDecisionTicketBucketingId;

// ---- Decision Parameters ----
extern NSString * const OPTLYEventParameterKeysDecisionExperimentId;
extern NSString * const OPTLYEventParameterKeysDecisionVariationId;
extern NSString * const OPTLYEventParameterKeysDecisionIsLayerHoldback;

// ---- Layer State Parameters ----
extern NSString * const OPTLYEventParameterKeysLayerStateLayerId;
extern NSString * const OPTLYEventParameterKeysLayerStateDecisionTicket;
extern NSString * const OPTLYEventParameterKeysLayerStateDecision;
extern NSString * const OPTLYEventParameterKeysLayerStateActivationId;
extern NSString * const OPTLYEventParameterKeysLayerStateDecisionSessionId;
extern NSString * const OPTLYEventParameterKeysLayerStateDecisionTimestamp;
extern NSString * const OPTLYEventParameterKeysLayerStateDecisionEventId;
extern NSString * const OPTLYEventParameterKeysLayerStateActionTriggered;
extern NSString * const OPTLYEventParameterKeysLayerStateActionActivationId;
extern NSString * const OPTLYEventParameterKeysLayerStateActionSessionId;
extern NSString * const OPTLYEventParameterKeysLayerStateActionTimestamp;
extern NSString * const OPTLYEventParameterKeysLayerStateRevision;

// ----View Parameters ----
extern NSString * const OPTLYEventParameterKeysViewViewId;
extern NSString * const OPTLYEventParameterKeysViewViewActivatedTimestamp;
extern NSString * const OPTLYEventParameterKeysViewViewFeatures;
extern NS_ASSUME_NONNULL_END

@interface OPTLYEventParameterKeys : NSObject

@end
