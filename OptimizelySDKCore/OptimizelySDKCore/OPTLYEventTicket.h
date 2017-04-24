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

#ifdef UNIVERSAL
    #import "JSONModelLib.h"
#else
    #import <JSONModel/JSONModelLib.h>
#endif

// Model object representing an Event Ticket sent when an event triggers in the client.

@class OPTLYEventHeader;
@protocol OPTLYEventFeature, OPTLYEventMetric, OPTLYEventRelatedEvent, OPTLYEventLayerState, OPTLYEventView;

@interface OPTLYEventTicket : JSONModel

// The time the event triggered
@property (nonatomic, assign) long long timestamp;
// Revision of client DATA, corresponding to a stored snapshot
@property (nonatomic, strong, nullable) NSString<Optional> *revision;
// Unique ID shared by all events in the current activation cycle
@property (nonatomic, strong, nullable) NSString<Optional> *activationId;
// GUID ID uniquely identifying the instance of the event triggering
@property (nonatomic, strong, nullable) NSString<Optional> *eventId;
// GUID ID uniquely identifying the user’s current session
@property (nonatomic, strong, nullable) NSString<Optional> *sessionId;
// The ID of the user
@property (nonatomic, strong, nonnull) NSString *visitorId;
// The unique user ID of the user (if available)
@property (nonatomic, strong, nullable) NSString<Optional> *visitorUUID;
// Project ID of the event.
@property (nonatomic, strong, nonnull) NSString *projectId;
// Account ID of the event
@property (nonatomic, strong, nonnull) NSString *accountId;
// The type of client engine sending this event: ‘ios’, ‘android’, ‘js’.
@property (nonatomic, strong, nullable) NSString<Optional> *clientEngine;
// The version of the client engine sending this event.
@property (nonatomic, strong, nullable) NSString<Optional> *clientVersion;
// Event information taken from the http header instead of the payload
@property (nonatomic, strong, nullable) OPTLYEventHeader<Optional> *header;
// The ID of the GAE entity corresponding to this event if it exists
@property (nonatomic, strong, nullable) NSString<Optional> *eventEntityId;
// The type of the event being logged
@property (nonatomic, strong, nullable) NSString<Optional> *eventType;
// The name of the event being logged
@property (nonatomic, strong, nullable) NSString<Optional> *eventName;
// Features attached to this event
@property (nonatomic, strong, nonnull) NSArray<OPTLYEventFeature> *eventFeatures;
// The metrics associated with this event
@property (nonatomic, strong, nullable) NSArray<OPTLYEventMetric, Optional> *eventMetrics;
// Features attached to the user as chosen through customer config.
@property (nonatomic, strong, nonnull) NSArray<OPTLYEventFeature> *userFeatures;
// Other events related to this event. E.g. impression and conversion events.
@property (nonatomic, strong, nullable) NSArray<OPTLYEventRelatedEvent, Optional> *relatedEvents;
// The most recent LayerState for every layer. All layers active when the event happened.
@property (nonatomic, strong, nonnull) NSArray<OPTLYEventLayerState> *layerStates;
// The views active at the time of the event.
@property (nonatomic, strong, nullable) NSArray<OPTLYEventView, Optional> *activeViews;
// If true, all experiences were held back at the global level
@property (nonatomic, assign) BOOL isGlobalHoldback;
// If true, then anonymize IP.
@property (nonatomic, assign) BOOL anonymizeIP;

@end
