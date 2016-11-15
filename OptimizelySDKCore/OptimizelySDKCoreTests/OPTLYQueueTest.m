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

#import <XCTest/XCTest.h>
#import "OPTLYQueue.h"

static const NSInteger kMaxQueueSize = 3;

@interface OPTLYQueueTest : XCTestCase
@property (nonatomic, strong) OPTLYQueue *queue;
@property (nonatomic, strong) NSString *testData1;
@property (nonatomic, strong) NSString *testData2;
@property (nonatomic, strong) NSString *testData3;
@property (nonatomic, strong) NSString *testData4;
@end

@implementation OPTLYQueueTest

- (void)setUp {
    [super setUp];
    self.queue =  [[OPTLYQueue alloc] initWithQueueSize:kMaxQueueSize];
    self.testData1 = @"testData1";
    self.testData2 = @"testData2";
    self.testData3 = @"testData3";
    self.testData4 = @"testData4";
    
    [self.queue enqueue:self.testData1];
    [self.queue enqueue:self.testData2];
    [self.queue enqueue:self.testData3];
    [self.queue enqueue:self.testData4];
}

- (void)tearDown {
    self.queue = nil;
    [super tearDown];
}

- (void)testQueueInitWithQueueSize {
    XCTAssertNotNil(self.queue);
    NSInteger queueCapacity = [self.queue maxQueueSize];
    XCTAssert(queueCapacity == kMaxQueueSize, @"incorrect max queue size");
}

// queue insertion should cap off at max size
- (void)testEnqueueAndSize
{
    NSInteger size = [self.queue size];
    XCTAssert(size == kMaxQueueSize, @"Invalid queue size. Data was not successfully enqueued.");
}

// dequeue'd value should be the oldest
// queue size shoudl decrease
- (void)testDequeue
{
    NSString *dequeuedData = [self.queue dequeue];
    XCTAssert([dequeuedData isEqualToString:self.testData1], @"Invalid data dequeued.");
    NSInteger size = [self.queue size];
    XCTAssert(size == kMaxQueueSize-1, @"Invalid queue size after dequeue.");
}

- (void)testDequeueNItems
{
    NSInteger numberOfItems = 3;
    NSArray *firstNItems = [self.queue dequeueNItems:numberOfItems];
    XCTAssert([firstNItems count] == numberOfItems, @"Invalid number of items retrieved.");
    XCTAssert([firstNItems[0] isEqualToString:self.testData1], @"Invalid data dequeued.");
    XCTAssert([firstNItems[1] isEqualToString:self.testData2], @"Invalid data dequeued.");
    XCTAssert([firstNItems[2] isEqualToString:self.testData3], @"Invalid data dequeued.");
    NSInteger size = [self.queue size];
    XCTAssert(size == 0, @"Invalid queue size.");
}

// the front value should be the oldest
- (void)testFront
{
    NSString *front = [self.queue front];
    XCTAssert([front isEqualToString:self.testData1], @"Invalid data dequeued.");
    NSInteger size = [self.queue size];
    XCTAssert(size == kMaxQueueSize, @"Invalid queue size.");
}

- (void)testFirstNItems
{
    NSInteger numberOfItems = 3;
    NSArray *firstNItems = [self.queue firstNItems:numberOfItems];
    XCTAssert([firstNItems count] == numberOfItems, @"Invalid number of items retrieved.");
    XCTAssert([firstNItems[0] isEqualToString:self.testData1], @"Invalid data dequeued.");
    XCTAssert([firstNItems[1] isEqualToString:self.testData2], @"Invalid data dequeued.");
    XCTAssert([firstNItems[2] isEqualToString:self.testData3], @"Invalid data dequeued.");
    NSInteger size = [self.queue size];
    XCTAssert(size == kMaxQueueSize, @"Invalid queue size.");
}

- (void)testIsFull
{
    bool isFull = [self.queue isFull];
    XCTAssertTrue(isFull, @"isFull is invalid. Queue should be full.");
    
    [self.queue dequeue];
    isFull = [self.queue isFull];
    XCTAssertFalse(isFull, @"isFull is invalid. Queue should not be full.");
}

- (void)testIsEmpty
{
    bool isEmpty = [self.queue isEmpty];
    XCTAssertFalse(isEmpty, @"isEmpty is invalid. The queue should not be empty.");
    
    for (int i = 0; i < kMaxQueueSize; i++) {
        [self.queue dequeue];
    }
    isEmpty = [self.queue isEmpty];
    XCTAssertTrue(isEmpty, @"isEmpty is invalid. The queue should be empty.");
}

@end
