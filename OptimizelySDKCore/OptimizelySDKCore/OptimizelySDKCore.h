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
#import "OPTLYErrorHandler.h"
#import "OPTLYErrorHandlerMessages.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYEventDispatcher.h"
#import "OPTLYExperiment.h"
#import "OPTLYHTTPRequestManager.h"
#import "OPTLYLogger.h"
#import "OPTLYLoggerMessages.h"
#import "OPTLYNetworkService.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYProjectConfigBuilder.h"
#import "OPTLYVariable.h"
#import "OPTLYVariation.h"
#import "OPTLYLog.h"
#import "OPTLYQueue.h"
#import "OPTLYUserProfile.h"

FOUNDATION_EXPORT double OptimizelySDKCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char OptimizelySDKCoreVersionString[];
