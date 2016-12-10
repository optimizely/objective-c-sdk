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

#import <OptimizelySDKCore/OptimizelySDKCore.h>
#import "OPTLYClient.h"
#import "OPTLYClientBuilder.h"
#if TARGET_OS_IOS
#import "OPTLYDatabase.h"
#import "OPTLYDatabaseEntity.h"
#endif
#import "OPTLYDataStore.h"
#import "OPTLYDatafileManager.h"
#import "OPTLYFileManager.h"
#import "OPTLYManager.h"
#import "OPTLYManagerBuilder.h"

//! Project version number for OptimizelySDKShared.
FOUNDATION_EXPORT double OptimizelySDKSharedVersionNumber;

//! Project version string for OptimizelySDKShared.
FOUNDATION_EXPORT const unsigned char OptimizelySDKSharedVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <OptimizelySDKShared/PublicHeader.h>


