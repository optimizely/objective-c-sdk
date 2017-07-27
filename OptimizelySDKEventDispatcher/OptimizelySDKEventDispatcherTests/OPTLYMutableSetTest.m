//
//  OPTLYMutableSetTest.m
//  OptimizelySDKEventDispatcher
//
//  Created by Kelly Roach on 7/25/17.
//  Copyright © 2017 Optimizely. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OPTLYMutableSet.h"

@interface OPTLYMutableSetTest : XCTestCase

@end

@implementation OPTLYMutableSetTest

- (void)testOPTLYMutableSetAPI {
    // Confirm OPTLYMutableSet behaves like NSMutableSet wrt declared API methods.
    // Begin with empty set.
    OPTLYMutableSet *mutableSet=[OPTLYMutableSet new];
    NSString *x=@"x";
    NSString *y=@"y";
    NSString *z=@"z";
    XCTAssertEqual(mutableSet.count, 0, @"mutableSet should be empty");
    XCTAssertEqual([mutableSet count], 0, @"mutableSet should be empty");
    XCTAssertFalse([mutableSet containsObject:x], @"mutableSet shouldn't contain x");
    XCTAssertFalse([mutableSet containsObject:y], @"mutableSet shouldn't contain y");
    XCTAssertFalse([mutableSet containsObject:z], @"mutableSet shouldn't contain z");
    // Add element x .
    [mutableSet addObject:x];
    XCTAssertEqual(mutableSet.count, 1, @"mutableSet should be {x}");
    XCTAssertEqual([mutableSet count], 1, @"mutableSet should be {x}");
    XCTAssert([mutableSet containsObject:x], @"mutableSet should contain x");
    XCTAssertFalse([mutableSet containsObject:y], @"mutableSet shouldn't contain y");
    XCTAssertFalse([mutableSet containsObject:z], @"mutableSet shouldn't contain z");
    // Add element x again .
    [mutableSet addObject:x];
    XCTAssertEqual(mutableSet.count, 1, @"mutableSet should be {x}");
    XCTAssertEqual([mutableSet count], 1, @"mutableSet should be {x}");
    XCTAssert([mutableSet containsObject:x], @"mutableSet should contain x");
    XCTAssertFalse([mutableSet containsObject:y], @"mutableSet shouldn't contain y");
    XCTAssertFalse([mutableSet containsObject:z], @"mutableSet shouldn't contain z");
    // Add element y .
    [mutableSet addObject:y];
    XCTAssertEqual(mutableSet.count, 2, @"mutableSet should be {x, y}");
    XCTAssertEqual([mutableSet count], 2, @"mutableSet should be {x, y}");
    XCTAssert([mutableSet containsObject:x], @"mutableSet should contain x");
    XCTAssert([mutableSet containsObject:y], @"mutableSet should contain y");
    XCTAssertFalse([mutableSet containsObject:z], @"mutableSet shouldn't contain z");
    // Add element z .
    [mutableSet addObject:z];
    XCTAssertEqual(mutableSet.count, 3, @"mutableSet should be {x, y}");
    XCTAssertEqual([mutableSet count], 3, @"mutableSet should be {x, y}");
    XCTAssert([mutableSet containsObject:x], @"mutableSet should contain x");
    XCTAssert([mutableSet containsObject:y], @"mutableSet should contain y");
    XCTAssert([mutableSet containsObject:z], @"mutableSet should contain z");
    // Add element z again .
    [mutableSet addObject:z];
    XCTAssertEqual(mutableSet.count, 3, @"mutableSet should be {x, y}");
    XCTAssertEqual([mutableSet count], 3, @"mutableSet should be {x, y}");
    XCTAssert([mutableSet containsObject:x], @"mutableSet should contain x");
    XCTAssert([mutableSet containsObject:y], @"mutableSet should contain y");
    XCTAssert([mutableSet containsObject:z], @"mutableSet should contain z");
    // Remove element x . State should be two element set {y, z} .
    [mutableSet removeObject:x];
    XCTAssertEqual(mutableSet.count, 2, @"mutableSet should be {y, z}");
    XCTAssertEqual([mutableSet count], 2, @"mutableSet should be {y, z}");
    XCTAssertFalse([mutableSet containsObject:x], @"mutableSet shouldn't contain x");
    XCTAssert([mutableSet containsObject:y], @"mutableSet should contain y");
    XCTAssert([mutableSet containsObject:z], @"mutableSet should contain z");
    // Remove element x when not present acts like a NOP .
    [mutableSet removeObject:x];
    XCTAssertEqual(mutableSet.count, 2, @"mutableSet should be {y, z}");
    XCTAssertEqual([mutableSet count], 2, @"mutableSet should be {y, z}");
    // Remove all elements . State should be empty set {} .
    [mutableSet removeAllObjects];
    XCTAssertEqual(mutableSet.count, 0, @"mutableSet should be empty");
    XCTAssertEqual([mutableSet count], 0, @"mutableSet should be empty");
    XCTAssertFalse([mutableSet containsObject:x], @"mutableSet shouldn't contain x");
    XCTAssertFalse([mutableSet containsObject:y], @"mutableSet shouldn't contain y");
    XCTAssertFalse([mutableSet containsObject:z], @"mutableSet shouldn't contain z");
    // Add element x .
    [mutableSet addObject:x];
    XCTAssertEqual(mutableSet.count, 1, @"mutableSet should be {x}");
    XCTAssertEqual([mutableSet count], 1, @"mutableSet should be {x}");
    XCTAssert([mutableSet containsObject:x], @"mutableSet should contain x");
    XCTAssertFalse([mutableSet containsObject:y], @"mutableSet shouldn't contain y");
    XCTAssertFalse([mutableSet containsObject:z], @"mutableSet shouldn't contain z");
}

- (void)testOPTLYMutableSetStress {
    // Hammer an OPTLYMutableSet with multiple threads for a brief spell.
    // The first goal is to not crash.  The second goal is to end in predicted state.
    // Create a mutableSet
    __block OPTLYMutableSet *mutableSet=[OPTLYMutableSet new];
    __block int imax=100;
    {
        // Populate mutableSet with even numbers.
        for (int i=0;i<imax;i++) {
            [mutableSet addObject:@(2*i)];
        }
        XCTAssertEqual(mutableSet.count, imax, @"mutableSet has wrong cardinality");
        XCTAssertEqual([mutableSet count], imax, @"mutableSet has wrong cardinality");
        for (int i=0;i<imax;i++) {
            XCTAssert([mutableSet containsObject:@(2*i)], @"mutableSet should contain %@", @(2*i));
            XCTAssertFalse([mutableSet containsObject:@(2*i+1)], @"mutableSet shouldn't contain %@", @(2*i+1));
        }
    }
    // Hammer mutableSet with multiple threads for a brief spell.
    {
        // Create simultaneously executing block's that access mutableSet .
        // Begin by creating a GCD "group" and GCD "queue" .
        dispatch_group_t group = dispatch_group_create();
        // NOTE: DISPATCH_QUEUE_CONCURRENT
        // "A dispatch queue that executes blocks concurrently. Although they
        // execute blocks concurrently, you can use barrier blocks to create
        // synchronization points within the queue."
        // https://developer.apple.com/documentation/dispatch/dispatch_queue_concurrent
        dispatch_queue_t queue = dispatch_queue_create("com.optimizely.testOPTLYMutableSetStress", DISPATCH_QUEUE_CONCURRENT);
        // Create simultaneously executing block's that access mutableSet .
        for (int i=0;i<imax;i++) {
            // Each block removes an even number from and adds an odd number to mutableSet .
            // A couple OPTLYMutableSet methods are called here just to they are exercised,
            // and not so much to be useful.
            dispatch_group_async(group, queue, ^(){
                XCTAssert([mutableSet containsObject:@(2*i)], @"mutableSet should contain %@", @(2*i));
                XCTAssertFalse([mutableSet containsObject:@(2*i+1)], @"mutableSet shouldn't contain %@", @(2*i+1));
                if ([mutableSet containsObject:@(2*i)]) {
                    [mutableSet removeObject:@(2*i)];
                    [mutableSet addObject:@(2*i+1)];
                    XCTAssertFalse([mutableSet containsObject:@(2*i)], @"mutableSet shouldn't contain %@", @(2*i));
                    XCTAssert([mutableSet containsObject:@(2*i+1)], @"mutableSet should contain %@", @(2*i+1));
                } else {
                    XCTAssert(NO, @"mutableSet should contain %@", @(2*i));
                };
                NSUInteger count = mutableSet.count;
                XCTAssert(count<=(2*imax), @"count unexpectedly greater than %@", @(2*imax));
            });
        }
        // NOTE: dispatch_group_wait "Returns zero on success (all blocks
        // associated with the group completed before the specified timeout)"
        // https://developer.apple.com/documentation/dispatch/1452794-dispatch_group_wait?language=objc
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.0 * NSEC_PER_SEC));
        XCTAssertEqual(dispatch_group_wait(group, timeout), 0, @"Test not expected to time out.");
    }
    // Check the final state of the mutableSet matches predicted state.
    XCTAssertEqual(mutableSet.count, imax, @"mutableSet has wrong cardinality");
    XCTAssertEqual([mutableSet count], imax, @"mutableSet has wrong cardinality");
    for (int i=0;i<imax;i++) {
        XCTAssertFalse([mutableSet containsObject:@(2*i)], @"mutableSet shouldn't contain %@", @(2*i));
        XCTAssert([mutableSet containsObject:@(2*i+1)], @"mutableSet should contain %@", @(2*i+1));
    }
    // Remove all elements . State should be empty set {} .
    [mutableSet removeAllObjects];
    XCTAssertEqual(mutableSet.count, 0, @"mutableSet should be empty");
    XCTAssertEqual([mutableSet count], 0, @"mutableSet should be empty");
}

@end
