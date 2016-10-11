//
//  OPTLYVariable.m
//  OptimizelySDKCore
//
//  Created by Haley Bash on 10/10/16.
//  Copyright © 2016 Optimizely. All rights reserved.
//

#import "OPTLYVariable.h"
#import "OPTLYDatafileKeys.h"

@implementation OPTLYVariable

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{ OPTLYDatafileKeysVariableId     : @"variableId",
                                                        OPTLYDatafileKeysVariableKey    : @"variableKey",
                                                        OPTLYDatafileKeysVariableType   : @"type",
                                                        OPTLYDatafileKeysVariableValue  : @"value",
                                                        OPTLYDatafileKeysVariableStatus : @"status"
                                                       }];
}
    
@end
