//
//  OPTLYMutableSet.h
//  OptimizelySDKEventDispatcher
//
//  Created by Kelly Roach on 7/25/17.
//  Copyright © 2017 Optimizely. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPTLYMutableSet<ObjectType> : NSObject
@property(readonly) NSUInteger count;
- (BOOL)containsObject:(ObjectType)anObject;
- (void)addObject:(ObjectType)object;
- (void)removeObject:(ObjectType)object;
- (void)removeAllObjects;
@end
