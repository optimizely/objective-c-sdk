/*************************************************************************** 
 * Copyright 2016 Optimizely                                                *
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
#import "OPTLYAttribute.h"
#import "OPTLYAudience.h"
#import "OPTLYBucketer.h"
#import "OPTLYBuilder.h"
#import "OPTLYCondition.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYErrorHandlerMessages.h"
#import "OPTLYEvent.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYEventDispatcher.h"
#import "OPTLYExperiment.h"
#import "OPTLYGroup.h"
#import "OPTLYHTTPRequestManager.h"
#import "OPTLYLogger.h"
#import "OPTLYLoggerMessages.h"
#import "OPTLYNetworkService.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYTrafficAllocation.h"
#import "OPTLYEventTicket.h"
#import "OPTLYDecisionEventTicket.h"


FOUNDATION_EXPORT double OptimizelySDKCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char OptimizelySDKCoreVersionString[];
