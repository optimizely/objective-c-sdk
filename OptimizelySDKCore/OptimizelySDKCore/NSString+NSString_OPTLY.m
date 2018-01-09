//
//  NSString+NSString_OPTLY.m
//  OptimizelySDKCore
//
//  Created by Abdur Rafay on 08/01/2018.
//  Copyright © 2018 Optimizely. All rights reserved.
//

#import "NSString+NSString_OPTLY.h"

@implementation NSString (NSString_OPTLY)

- (BOOL)isEmpty {
    BOOL isEmpty = [self isEqualToString:@""];
    return isEmpty;
}

@end
