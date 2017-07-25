//
//  OPTLYMutableSet.m
//  OptimizelySDKEventDispatcher
//
//  Created by Kelly Roach on 7/25/17.
//  Copyright © 2017 Optimizely. All rights reserved.
//

#import "OPTLYMutableSet.h"

/*
 * This class implements a thread-safe wrapper around NSMutableSet that
 * is used by OPTLYEventDispatcher.m .  We only implement the NSMutableSet
 * methods OPTLYEventDispatcher.m needs, but more could be added later if
 * there is demand.
 */

@interface OPTLYMutableSet<ObjectType> ()
@property (nonatomic,strong) NSObject *lockObject;
@property (nonatomic,strong) NSMutableSet *mutableSet;
@end

@implementation OPTLYMutableSet
- (instancetype)init {
    self = [super init];
    if (self) {
        _lockObject = [[NSObject alloc] init];
        _mutableSet = [[NSMutableSet alloc] init];
    }
    return self;
}
- (NSUInteger)count {
    @synchronized (_lockObject) {
        return [_mutableSet count];
    }
}
- (BOOL)containsObject:(id)anObject {
    BOOL answer=NO;
    @synchronized (_lockObject) {
        answer=[_mutableSet containsObject:anObject];
    }
    return answer;
}
- (void)addObject:(id)object {
    @synchronized (_lockObject) {
        [_mutableSet addObject:object];
    }
}
- (void)removeObject:(id)object {
    @synchronized (_lockObject) {
        [_mutableSet removeObject:object];
    }
}
- (void)removeAllObjects {
    @synchronized (_lockObject) {
        [_mutableSet removeAllObjects];
    }
}
@end
