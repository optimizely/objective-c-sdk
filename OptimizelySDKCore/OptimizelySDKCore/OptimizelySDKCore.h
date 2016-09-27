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

#import <OptimizelySDKCore/Optimizely.h>
#import <OptimizelySDKCore/OptimizelySDKCore.h>
#import <OptimizelySDKCore/OPTLYAttribute.h>
#import <OptimizelySDKCore/OPTLYAudience.h>
#import <OptimizelySDKCore/OPTLYBucketer.h>
#import <OptimizelySDKCore/OPTLYBuilder.h>
#import <OptimizelySDKCore/OPTLYCondition.h>
#import <OptimizelySDKCore/OPTLYDatafileKeys.h>
#import <OptimizelySDKCore/OPTLYErrorHandler.h>
#import <OptimizelySDKCore/OPTLYErrorHandlerMessages.h>
#import <OptimizelySDKCore/OPTLYEvent.h>
#import <OptimizelySDKCore/OPTLYEventBuilder.h>
#import <OptimizelySDKCore/OPTLYEventDispatcher.h>
#import <OptimizelySDKCore/OPTLYExperiment.h>
#import <OptimizelySDKCore/OPTLYGroup.h>
#import <OptimizelySDKCore/OPTLYHTTPRequestManager.h>
#import <OptimizelySDKCore/OPTLYLogger.h>
#import <OptimizelySDKCore/OPTLYLoggerMessages.h>
#import <OptimizelySDKCore/OPTLYNetworkService.h>
#import <OptimizelySDKCore/OPTLYProjectConfig.h>
#import <OptimizelySDKCore/OPTLYTrafficAllocation.h>
#import <OptimizelySDKCore/OPTLYEventTicket.h>
#import <OptimizelySDKCore/OPTLYDecisionEventTicket.h>


FOUNDATION_EXPORT double OptimizelySDKCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char OptimizelySDKCoreVersionString[];
