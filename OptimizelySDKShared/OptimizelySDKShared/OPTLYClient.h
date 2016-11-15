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
#import <OptimizelySDKCore/Optimizely.h>
#import "OPTLYClientBuilder.h"

/**
 * This class wraps the Optimizely class from the Core SDK.
 * Optimizely Client Instance
 */
@interface OPTLYClient : NSObject <Optimizely>

/// Reference to the Optimizely Core instance
@property (nonatomic, strong, readonly, nullable) Optimizely *optimizely;
/// The Optimizely Core's logger, or if no logger a default logger
@property (nonatomic, strong, readonly, nonnull) id<OPTLYLogger> logger;

+ (nonnull instancetype)initWithBuilderBlock:(nonnull OPTLYClientBuilderBlock)block;

@end
