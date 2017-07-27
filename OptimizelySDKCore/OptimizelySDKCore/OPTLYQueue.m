/****************************************************************************
 * Copyright 2016, Optimizely, Inc. and contributors                        *
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

#import "OPTLYQueue.h"

const NSInteger OPTLYQueueDefaultMaxSize = 1000;

@interface OPTLYQueue()
@property (nonatomic, strong) NSArray *queue;
@property (nonatomic, assign) NSInteger maxQueueSize;
@property (nonatomic, strong) NSMutableArray *mutableQueue;
@property (nonatomic, strong) NSObject *lockObject;
@end

@implementation OPTLYQueue

#pragma mark - Properties
// Thread-safe getters and setters for mutable public properties

- (NSArray *)queue {
    // queue is reaadonly property
    @synchronized (_lockObject) {
        return [self.mutableQueue copy];
    }
}

// maxQueueSize is immutable reaadonly property

// mutableQueue is hidden encapsulated property

#pragma mark - Life Cycle

- (id)init {
    return [self initWithQueueSize:OPTLYQueueDefaultMaxSize];
}

- (instancetype)initWithQueueSize:(NSInteger)maxQueueSize {
    // Designated Initializer
    self = [super init];
    if (self) {
        _maxQueueSize = maxQueueSize;
        _mutableQueue = [[NSMutableArray alloc] initWithCapacity:_maxQueueSize];
        _lockObject = [[NSObject alloc] init];
    }
    return self;
}

#pragma mark - Operations

- (bool)enqueue:(id)data {
    @synchronized (_lockObject) {
        if (!self.isFull) {
            if (data) {
                [self.mutableQueue addObject:data];
                return true;
            }
        }
    }
    return false;
}

- (id)front {
    id item = nil;
    @synchronized (_lockObject) {
        if (!self.isEmpty) {
            item = [self.mutableQueue objectAtIndex:0];
        }
    }
    return item;
}

- (NSArray *)firstNItems:(NSInteger)numberOfItems {
    NSArray *items;
    @synchronized (_lockObject) {
        if (!self.isEmpty) {
            NSInteger endOfRange = numberOfItems > [self size] ? [self size] : numberOfItems;
            NSRange range = NSMakeRange(0, endOfRange);
            items = [self.mutableQueue subarrayWithRange:range];
        }
    }
    return items;
}

- (id)dequeue {
    id item = nil;
    @synchronized (_lockObject) {
        if (!self.isEmpty) {
            item = [self.mutableQueue objectAtIndex:0];
            [self.mutableQueue removeObject:item];
        }
    }
    return item;
}

- (NSArray *)dequeueNItems:(NSInteger)numberOfItems {
    NSArray *items;
    @synchronized (_lockObject) {
        if (!self.isEmpty) {
            NSInteger endOfRange = numberOfItems > [self size] ? [self size] : numberOfItems;
            NSRange range = NSMakeRange(0, endOfRange);
            items = [self.mutableQueue subarrayWithRange:range];
            [self.mutableQueue removeObjectsInRange:range];
        }
    }
    return items;
}

- (void)removeItem:(id)item {
    @synchronized (_lockObject) {
        for (NSInteger i = [self size]-1; i >= 0; i--) {
            if ([item isEqual:self.mutableQueue[i]]) {
                [self.mutableQueue removeObjectAtIndex:i];
            }
        }
    }
}

- (NSInteger)size {
    @synchronized (_lockObject) {
        return [self.mutableQueue count];
    }
}

- (bool)isFull {
    @synchronized (_lockObject) {
        return ([self.mutableQueue count] >= self.maxQueueSize);
    }
}

- (bool)isEmpty {
    @synchronized (_lockObject) {
        return [self.mutableQueue count] == 0;
    }
}

@end
