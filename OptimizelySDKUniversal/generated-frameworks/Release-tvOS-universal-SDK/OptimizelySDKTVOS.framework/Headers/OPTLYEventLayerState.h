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

// Model object storing the state of a layer

#import <Foundation/Foundation.h>
#ifdef UNIVERSAL
    #import "OPTLYJSONModelLib.h"
#else
    #import <OptimizelySDKCore/OPTLYJSONModelLib.h>
#endif

@class OPTLYEventDecisionTicket, OPTLYEventDecision;

@protocol OPTLYEventLayerState
@end

@interface OPTLYEventLayerState : OPTLYJSONModel

// The id of the layer state
@property (nonatomic, strong, nonnull) NSString *layerId;
// Visitor-specific input to Client Decision Engine
@property (nonatomic, strong, nullable) OPTLYEventDecisionTicket<Optional> *decisionTicket;
// Output of the Client Decision Engine
@property (nonatomic, strong, nullable) OPTLYEventDecision<Optional> *decision;
// The activationId when the decision was made
@property (nonatomic, strong, nullable) NSString<Optional> *decisionActivationId;
// The sessionId when the decision was made
@property (nonatomic, strong, nullable) NSString<Optional> *decisionSessionId;
// The timestamp when the decision was made
@property (nonatomic, strong, nullable) NSNumber<Optional> *decisionTimestamp;
// The generated UID for the DecisionEventTicketAvro logged when this decision was made.
@property (nonatomic, strong, nullable) NSString<Optional> *decisionEventId;
// Indicates whether any actions for this layer have trigged
@property (nonatomic, assign) BOOL actionTriggered;
// The activation ID when the action was last triggered
@property (nonatomic, strong, nullable) NSString<Optional> *actionActivationId;
// The session Id when the action was last triggered
@property (nonatomic, strong, nullable) NSString<Optional> *actionSessionId;
// The timestamp when the action was last triggered
@property (nonatomic, strong, nullable) NSNumber<Optional> *actionTimestamp;
// The DATA revision of the layer definition in use when this layer was processed
@property (nonatomic, strong, nullable) NSString<Optional> *revision;


@end
