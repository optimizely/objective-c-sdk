//
//  OPTLYJSONValueTransformer+UIColor.m
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

#import "OPTLYJSONValueTransformer+UIColor.h"

@implementation OPTLYJSONValueTransformer (UIColor)

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(UIColor*)UIColorFromNSString:(NSString *)string
#else
-(NSColor*)NSColorFromNSString:(NSString *)string
#endif
{
	//
	// http://stackoverflow.com/a/13648705
	//

	NSString *noHashString = [string stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
	NSScanner *scanner = [NSScanner scannerWithString:noHashString];
	[scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $

	unsigned hex;
	if (![scanner scanHexInt:&hex]) return nil;
	int r = (hex >> 16) & 0xFF;
	int g = (hex >> 8) & 0xFF;
	int b = (hex) & 0xFF;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
#else
	return [NSColor colorWithCalibratedRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
#endif
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(id)JSONObjectFromUIColor:(UIColor*)color
#else
-(id)JSONObjectFromNSColor:(NSColor*)color
#endif
{
	//
	// http://softteco.blogspot.de/2011/06/extract-hex-rgb-color-from-uicolor.mtml
	//

	return [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(color.CGColor))[0]*255.0), (int)((CGColorGetComponents(color.CGColor))[1]*255.0), (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
}

@end
