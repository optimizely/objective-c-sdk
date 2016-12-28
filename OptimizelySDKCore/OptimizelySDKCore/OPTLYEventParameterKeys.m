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

#import "OPTLYEventParameterKeys.h"

// --- Common Event Parameters ----
NSString * const OPTLYEventParameterKeysTimestamp                       = @"timestamp";         // nonnull
NSString * const OPTLYEventParameterKeysRevision                        = @"revision";
NSString * const OPTLYEventParameterKeysActivationId                    = @"activationId";
NSString * const OPTLYEventParameterKeysSessionId                       = @"sessionId";
NSString * const OPTLYEventParameterKeysVisitorId                       = @"visitorId";         // nonnull
NSString * const OPTLYEventParameterKeysVisitorUUID                     = @"visitorUUID";
NSString * const OPTLYEventParameterKeysProjectId                       = @"projectId";         // nonnull
NSString * const OPTLYEventParameterKeysAccountId                       = @"accountId";         // nonnull
NSString * const OPTLYEventParameterKeysClientEngine                    = @"clientEngine";
NSString * const OPTLYEventParameterKeysClientVersion                   = @"clientVersion";
NSString * const OPTLYEventParameterKeysHeader                          = @"header";
NSString * const OPTLYEventParameterKeysUserFeatures                    = @"userFeatures";      // nonnull
NSString * const OPTLYEventParameterKeysIsGlobalHoldback                = @"isGlobalHoldback";  // nonnull
NSString * const OPTLYEventParameterKeysAnonymizeIP                     = @"anonymizeIP";

// --- Decision Ticket Event Parameters ("Impression Event") ----
NSString * const OPTLYEventParameterKeysDecisionId                      = @"decisionId";
NSString * const OPTLYEventParameterKeysLayerId                         = @"layerId";           // nonnull
NSString * const OPTLYEventParameterKeysDecisionTicket                  = @"decisionTicket";
NSString * const OPTLYEventParameterKeysDecision                        = @"decision";          // nonnull

// --- Event Ticket Parameters ("Conversion Event") ----
NSString * const OPTLYEventParameterKeysEventId                         = @"eventId";
NSString * const OPTLYEventParameterKeysEventEntityId                   = @"eventEntityId";
NSString * const OPTLYEventParameterKeysEventType                       = @"eventType";
NSString * const OPTLYEventParameterKeysEventName                       = @"eventName";
NSString * const OPTLYEventParameterKeysEventFeatures                   = @"eventFeatures";     // nonnull
NSString * const OPTLYEventParameterKeysEventMetrics                    = @"eventMetrics";      // nonnull
NSString * const OPTLYEventParameterKeysRelatedEvents                   = @"relatedEvents";
NSString * const OPTLYEventParameterKeysLayerStates                     = @"layerStates";       // nonnull
NSString * const OPTLYEventParameterKeysActiveViews                     = @"activeViews";

// ---- Header Parameters ----
NSString * const OPTLYEventParameterKeysHeaderClientIp                  = @"clientIp";
NSString * const OPTLYEventParameterKeysHeaderUserAgent                 = @"userAgent";
NSString * const OPTLYEventParameterKeysHeaderReferer                   = @"referer";

// ---- Feature Parameters ----
NSString * const OPTLYEventParameterKeysFeaturesId                      = @"id";
NSString * const OPTLYEventParameterKeysFeaturesName                    = @"name";
NSString * const OPTLYEventParameterKeysFeaturesType                    = @"type";
NSString * const OPTLYEventParameterKeysFeaturesValue                   = @"value";
NSString * const OPTLYEventParameterKeysFeaturesShouldIndex             = @"shouldIndex";

// ---- Metric Parameters ----
NSString * const OPTLYEventParameterKeysMetricName                      = @"name";
NSString * const OPTLYEventParameterKeysMetricValue                     = @"value";

// ---- Related Event Parameters ----
NSString * const OPTLYEventParameterKeysRelatedEventsEventId            = @"eventId";
NSString * const OPTLYEventParameterKeysRelatedEventsRelationship       = @"relationship";

// ---- Audience Parameters ----
NSString * const OPTLYEventParameterKeysAudienceId                      = @"id";
NSString * const OPTLYEventParameterKeysAudienceName                    = @"name";

// ---- Decision Ticket Parameters ----
NSString * const OPTLYEventParameterKeysDecisionTicketAudiences         = @"audiences";
NSString * const OPTLYEventParameterKeysDecisionTicketBucketingId       = @"bucketingId";

// ---- Decision Parameters ----
NSString * const OPTLYEventParameterKeysDecisionExperimentId            = @"experimentId";
NSString * const OPTLYEventParameterKeysDecisionVariationId             = @"variationId";
NSString * const OPTLYEventParameterKeysDecisionIsLayerHoldback         = @"isLayerHoldback";

// ---- Layer State Parameters ----
NSString * const OPTLYEventParameterKeysLayerStateLayerId               = @"layerId";
NSString * const OPTLYEventParameterKeysLayerStateDecisionTicket        = @"decisionTicket";
NSString * const OPTLYEventParameterKeysLayerStateDecision              = @"decision";
NSString * const OPTLYEventParameterKeysLayerStateActivationId          = @"decisionActivationId";
NSString * const OPTLYEventParameterKeysLayerStateDecisionSessionId     = @"decisionSessionId";
NSString * const OPTLYEventParameterKeysLayerStateDecisionTimestamp     = @"decisionTimestamp";
NSString * const OPTLYEventParameterKeysLayerStateDecisionEventId       = @"decisionEventId";
NSString * const OPTLYEventParameterKeysLayerStateActionTriggered       = @"actionTriggered";
NSString * const OPTLYEventParameterKeysLayerStateActionActivationId    = @"actionActivationId";
NSString * const OPTLYEventParameterKeysLayerStateActionSessionId       = @"actionSessionId";
NSString * const OPTLYEventParameterKeysLayerStateActionTimestamp       = @"actionTimestamp";
NSString * const OPTLYEventParameterKeysLayerStateRevision              = @"revision";

// ----View Parameters ----
NSString * const OPTLYEventParameterKeysViewViewId                      = @"viewId";
NSString * const OPTLYEventParameterKeysViewViewActivatedTimestamp      = @"activatedTimestamp";
NSString * const OPTLYEventParameterKeysViewViewFeatures                = @"viewFeatures";


@implementation OPTLYEventParameterKeys

@end
