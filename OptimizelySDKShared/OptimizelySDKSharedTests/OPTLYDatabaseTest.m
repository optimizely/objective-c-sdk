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
#import "OPTLYDatabase.h"
#import "OPTLYFileManager.h"
#import "OPTLYDatabaseEntity.h"

@interface OPTLYDatabaseTest : XCTestCase
@property (nonatomic, strong) OPTLYDatabase *db;
@end

@implementation OPTLYDatabaseTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    OPTLYFileManager *fm = [OPTLYFileManager new];
    [fm removeAllFiles:nil];
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDatabaseAPIs {
    NSError *error = nil;
    OPTLYDatabase *db = [OPTLYDatabase new];
    
    NSDictionary *testData =
        @{
        @"userFeatures": @[@{
            @"value": @"alda",
            @"shouldIndex": @true,
            @"name": @"nameOfPerson",
            @"type": @"custom"
        }],
        @"timestamp": @1478510071576,
        @"clientVersion": @"0.2.0-debug",
        @"eventEntityId": @"7723870635",
        @"revision": @"7",
        @"isGlobalHoldback": @false,
        @"accountId": @"4902200114",
        @"layerStates": @[],
        @"projectId": @"7738070017",
        @"eventMetrics": @[@{
            @"name": @"revenue",
            @"value": @88
        }],
        @"visitorId": @"1234",
        @"eventName": @"people",
        @"clientEngine": @"objective-c-sdk-core",
        @"eventFeatures": @[]
        };
    
    // test insert
    [db insertData:testData table:OPTLYDatabaseEventsTable error:&error];
    [db insertData:testData table:OPTLYDatabaseEventsTable error:&error];
    [db insertData:testData table:OPTLYDatabaseEventsTable error:&error];
    [db insertData:testData table:OPTLYDatabaseEventsTable error:&error];
    [db insertData:testData table:OPTLYDatabaseEventsTable error:&error];
    [db insertData:testData table:OPTLYDatabaseEventsTable error:&error];
    
    // test retrieveFirstNEntries
    NSInteger n = 3;
    NSArray *results = [db retrieveFirstNEntries:n table:OPTLYDatabaseEventsTable error:&error];
    XCTAssert([results count] == n, @"Data insertion failed or invalid number of results retrieved from retrieveFirstNEntries.");
    
    // test retrieveAllEntries
    NSInteger totalEntity = 6;
    results = [db retrieveAllEntries:OPTLYDatabaseEventsTable error:&error];
    NSInteger numberOfRows = [db numberOfRows:OPTLYDatabaseEventsTable error:&error];
    XCTAssert([results count] == totalEntity, @"Data insertion failed or invalid number of results retrieved from retrieveAllEntries");
    
    // test numberOfRows
    XCTAssert(numberOfRows == totalEntity, @"Invalid count from numberOfRows.");
    
    // test contents of retrieveAllEntries
    OPTLYDatabaseEntity *entity = results[0];
    NSString *entityString = entity.entityValue;
    NSDictionary *resultData = [NSJSONSerialization JSONObjectWithData:[entityString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    XCTAssert([resultData isEqualToDictionary:testData], @"Invalid result data retrieved.");
    
    // test deleteEntities
    NSMutableArray *entityIds = [NSMutableArray new];
    for (OPTLYDatabaseEntity *entity in results) {
        NSNumber *resultId = entity.entityId;
        [entityIds addObject:resultId];
    }
    [db deleteEntities:entityIds table:OPTLYDatabaseEventsTable error:&error];
    
    numberOfRows = [db numberOfRows:OPTLYDatabaseEventsTable error:&error];
    XCTAssert(numberOfRows == 0, @"Deletion failed. Invalid number of results retrieved from database");
}



@end
