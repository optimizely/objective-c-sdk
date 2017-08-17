/****************************************************************************
 * Modifications to JSONModel by Optimizely, Inc.                           *
 * Copyright 2017, Optimizely, Inc. and contributors                        *
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
//
//  OPJMModelLib.h
//  OPJMModel
//

#import <Foundation/Foundation.h>

// core
#import "OPJMModel.h"
#import "OPJMModelError.h"

// transformations
#import "OPJMValueTransformer.h"
#import "OPJMKeyMapper.h"

// networking (deprecated)
#import "OPJMHTTPClient.h"
#import "OPJMModel+networking.h"
#import "OPJMAPI.h"
