//
//  NSArray+NSArray_OPTLY.m
//  OptimizelySDKCore
//
//  Created by Abdur Rafay on 08/01/2018.
//  Copyright © 2018 Optimizely. All rights reserved.
//

#import "NSArray+NSArray_OPTLY.h"

@implementation NSArray (NSArray_OPTLY)

- (BOOL)isEmpty {
    BOOL isEmpty = self.count == 0;
    return isEmpty;
}

@end
