//
//  OPTLYVariable.m
//  OptimizelySDKCore
//
//  Created by Haley Bash on 11/17/16.
//  Copyright © 2016 Optimizely. All rights reserved.
//

#import "OPTLYVariable.h"
#import "OPTLYDatafileKeys.h"

@implementation OPTLYVariable

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{ OPTLYDatafileKeysVariableId     : @"variableId",
                                                        OPTLYDatafileKeysVariableKey    : @"variableKey"
                                                        }];
}

@end
