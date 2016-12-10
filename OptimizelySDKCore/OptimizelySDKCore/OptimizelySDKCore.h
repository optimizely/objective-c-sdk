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

#import "Optimizely.h"
#import "OPTLYBucketer.h"
#import "OPTLYBuilder.h"
#import "OPTLYErrorHandlerMessages.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYEventDispatcher.h"
#import "OPTLYEventTicket.h"
#import "OPTLYExperiment.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYHTTPRequestManager.h"
#import "OPTLYLog.h"
#import "OPTLYLogger.h"
#import "OPTLYLoggerMessages.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYProjectConfigBuilder.h"
#import "OPTLYTrafficAllocation.h"
#import "OPTLYQueue.h"
#import "OPTLYVariable.h"
#import "OPTLYVariation.h"
#import "OPTLYUserProfile.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYEventAudience.h"
#import "OPTLYAttribute.h"
#import "OPTLYValidator.h"
#import "OPTLYEventParameterKeys.h"
#import "OPTLYEventLayerState.h"
#import "OPTLYEventRelatedEvent.h"
#import "OPTLYEvent.h"
#import "OPTLYEventFeature.h"
#import "OPTLYVariationVariable.h"
#import "OPTLYEventDecision.h"
#import "OPTLYDecisionEventTicket.h"
#import "OPTLYEventDecisionTicket.h"
#import "OPTLYGroup.h"
#import "OPTLYEventView.h"
#import "OPTLYEventHeader.h"
#import "OPTLYBaseCondition.h"
#import "OPTLYEventMetric.h"
#import "OPTLYAudience.h"
#import "OPTLYCondition.h"
#import "OPTLYNetworkService.h"

FOUNDATION_EXPORT double OptimizelySDKCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char OptimizelySDKCoreVersionString[];
