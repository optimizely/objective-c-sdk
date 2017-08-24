//
//  OPTLYJSONValueTransformer+UIColor.h
//  OPTLYJSONModel_Demo
//
//  Created by Marin Todorov on 26/11/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//
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

@import Foundation;
@import OptimizelySDKCore;
@import UIKit;

@interface OPTLYJSONValueTransformer (UIColor)

#pragma mark - uicolor <-> hex color
/* uicolor <-> hex color for converting text hex representations to actual color objects */

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(UIColor*)UIColorFromNSString:(NSString*)string;
-(id)JSONObjectFromUIColor:(UIColor*)color;
#else
-(NSColor*)UIColorFromNSString:(NSString*)string;
-(id)JSONObjectFromUIColor:(NSColor*)color;
#endif

@end
