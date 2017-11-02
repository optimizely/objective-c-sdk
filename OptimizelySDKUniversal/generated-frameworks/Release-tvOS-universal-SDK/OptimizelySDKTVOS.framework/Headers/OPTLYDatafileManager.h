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
#ifdef UNIVERSAL
    #import "OPTLYDatafileManager.h"
#else
    #import <OptimizelySDKShared/OPTLYDatafileManagerBasic.h>
#endif
#import "OPTLYDatafileManagerBuilder.h"

@protocol OPTLYDatafileManager, OPTLYErrorHandler, OPTLYLogger;

@interface OPTLYDatafileManagerDefault : NSObject<OPTLYDatafileManager>

/// The time interval to regularly fetch the datafile.
@property (nonatomic, readonly) NSTimeInterval datafileFetchInterval;
/// The project ID of the datafile this datafile manager will monitor
@property (nonatomic, readonly, strong, nonnull) NSString *projectId;
/// The error handler to be used for the manager, client, and all subcomponents
@property (nonatomic, readonly, strong, nullable) id<OPTLYErrorHandler> errorHandler;
/// A logger for the OPTLYDatafileManager to log messages.
@property (nonatomic, readonly, strong, nonnull) id<OPTLYLogger> logger;

/**
 * Init with builder block
 * @param builderBlock The builder block containing the datafile fetch interval.
 * @return an Optimizely Datafile Manager instance.
 */
+ (nullable instancetype)init:(nonnull OPTLYDatafileManagerBuilderBlock)builderBlock;

@end
