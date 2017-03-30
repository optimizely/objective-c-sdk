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
    #import "JSONModelLib.h"
#else
    #import <JSONModel/JSONModelLib.h>
#endif

/**
 * This class is a representation of an Optimizely variation.
 */
@protocol OPTLYVariationVariable;
@protocol OPTLYVariation
@end

@interface OPTLYVariation : JSONModel

/// The variation's ID.
@property (nonatomic, strong) NSString *variationId;
/// The variation's Key.
@property (nonatomic, strong) NSString *variationKey;
/// The array containing the variation's live variable information -- variable ID and variable value.
/// TODO: Make variables required and add in NSDictionary * back into NSArray
@property (nonatomic, strong) NSArray<OPTLYVariationVariable, Optional> *variables;

@end
