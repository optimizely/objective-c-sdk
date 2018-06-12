//
//  NSString+OPTLYCategory.m
//  OptimizelySDKShared
//
//  Created by Thomas Zurkan on 6/12/18.
//  Copyright © 2018 Optimizely. All rights reserved.
//

#import "NSString+OPTLYCategory.h"

@implementation NSString(OPTLYCategory)

- (BOOL)isValidKeyString {
    return (self != nil && ![self isEqualToString:@""] && ![self containsString:@" "]);
}
@end
