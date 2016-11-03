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

@class Optimizely;

/**
 * This class contains the informaation on how your Optimizely Client instance will be built.
 */
@class OPTLYClientBuilder;

/// This is a block that takes the builder values.
typedef void (^OPTLYClientBuilderBlock)(OPTLYClientBuilder * _Nullable builder);

@interface OPTLYClientBuilder : NSObject

/// Reference to the Optimizely Core instance
@property (nonatomic, readwrite, strong, nullable) Optimizely *optimizely;

/// Create an Optimizely Client object.
+ (nonnull instancetype)builderWithBlock:(nonnull OPTLYClientBuilderBlock)block;

@end
