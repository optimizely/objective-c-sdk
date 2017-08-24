//
//  EnumModel.m
//  OPTLYJSONModelDemo_iOS
//
//  Created by Marin Todorov on 6/17/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
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

#import "EnumModel.h"

@implementation EnumModel

-(void)setStatusWithNSString:(NSString*)statusString
{
	_status = [statusString isEqualToString:@"open"]?StatusOpen:StatusClosed;
}

-(void)setNsStatusWithNSString:(NSString*)statusString
{
	_nsStatus = [statusString isEqualToString:@"open"]?NSE_StatusOpen:NSE_StatusClosed;
}

-(void)setNsuStatusWithNSString:(NSString*)statusString
{
	_nsuStatus = [statusString isEqualToString:@"open"]?NSEU_StatusOpen:NSEU_StatusClosed;
}

-(void)setNestedStatusWithNSString:(NSString*)statusString
{
	_status = [statusString isEqualToString:@"open"]?StatusOpen:StatusClosed;
}

-(void)setNestedStatusWithNSNumber:(NSNumber*)statusNumber
{
	_status = statusNumber.boolValue?StatusOpen:StatusClosed;
}

- (void)setNestedStatusWithJSONObject:(id <NSObject>)object
{
	if ([object isKindOfClass:[NSArray class]])
		_status = [((NSArray *)object).firstObject isEqualToString:@"open"] ? StatusOpen : StatusClosed;
	else
		_status = StatusClosed;
}

-(id)JSONObjectForStatus
{
	return (self.status==StatusOpen)?@"open":@"closed";
}

-(id)JSONObjectForNsStatus
{
	return (self.nsStatus==NSE_StatusOpen)?@"open":@"closed";
}

-(id)JSONObjectForNsuStatus
{
	return (self.nsuStatus==NSEU_StatusOpen)?@"open":@"closed";
}

-(id)JSONObjectForNestedStatus
{
	return (self.status==StatusOpen)?@"open":@"closed";
}

+(OPTLYJSONKeyMapper*)keyMapper
{
	return [[OPTLYJSONKeyMapper alloc] initWithModelToJSONDictionary:@
	{
		@"status":@"statusString",
		@"nestedStatus":@"nested.status"
	}];
}

@end
