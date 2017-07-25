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

@end
