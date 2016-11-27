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
<<<<<<< HEAD
#import "OPTLYClientBuilder.h"
#import "OPTLYDataStore.h"
=======
>>>>>>> Added a timer to the datafile manager to periodically download the datafile. Also moved the datafile manager protocol to core as the core should have a basic datafile downloader (the network classes will be moved to core as well in another commit.). Cleaned up the headers and was being more deligent about alphabetizing imports and initializing modules.
#if TARGET_OS_IOS
#import "OPTLYDatabase.h"
#import "OPTLYDatabaseEntity.h"
#endif
<<<<<<< HEAD
#import "OPTLYFileManager.h"
#import "OPTLYHTTPRequestManager.h"
#import "OPTLYManager.h"
#import "OPTLYManagerBuilder.h"
#import "OPTLYNetworkService.h"



=======
#import "OPTLYDataStore.h"
#import "OPTLYFileManager.h"
#import "OPTLYHTTPRequestManager.h"
#import "OPTLYManager.h"
#import "OPTLYNetworkService.h"
>>>>>>> Added a timer to the datafile manager to periodically download the datafile. Also moved the datafile manager protocol to core as the core should have a basic datafile downloader (the network classes will be moved to core as well in another commit.). Cleaned up the headers and was being more deligent about alphabetizing imports and initializing modules.

//! Project version number for OptimizelySDKShared.
FOUNDATION_EXPORT double OptimizelySDKSharedVersionNumber;

//! Project version string for OptimizelySDKShared.
FOUNDATION_EXPORT const unsigned char OptimizelySDKSharedVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <OptimizelySDKShared/PublicHeader.h>


