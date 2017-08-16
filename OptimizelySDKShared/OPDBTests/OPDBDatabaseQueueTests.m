//
//  OPDBDatabaseQueueTests.m
//  opdb
//
//  Created by Graham Dennis on 24/11/2013.
//
//
/****************************************************************************
 * Modifications to FMDB by Optimizely, Inc.                                *
 * Copyright 2017, Optimizely, Inc. and contributors                        *
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
#import "OPDBDatabaseQueue.h"

#if OPDB_SQLITE_STANDALONE
#import <sqlite3/sqlite3.h>
#else
#import <sqlite3.h>
#endif

@interface OPDBDatabaseQueueTests : OPDBTempDBTests

@property OPDBDatabaseQueue *queue;

@end

@implementation OPDBDatabaseQueueTests

+ (void)populateDatabase:(OPDBDatabase *)db
{
    [db executeUpdate:@"create table easy (a text)"];
    
    [db executeUpdate:@"create table qfoo (foo text)"];
    [db executeUpdate:@"insert into qfoo values ('hi')"];
    [db executeUpdate:@"insert into qfoo values ('hello')"];
    [db executeUpdate:@"insert into qfoo values ('not')"];
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.queue = [OPDBDatabaseQueue databaseQueueWithPath:self.databasePath];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testURLOpenNoPath {
    OPDBDatabaseQueue *queue = [[OPDBDatabaseQueue alloc] init];
    XCTAssert(queue, @"Database queue should be returned");
    queue = nil;
}

- (void)testURLOpenNoURL {
    OPDBDatabaseQueue *queue = [[OPDBDatabaseQueue alloc] initWithURL:nil];
    XCTAssert(queue, @"Database queue should be returned");
    queue = nil;
}

- (void)testURLOpen {
    NSURL *tempFolder = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *fileURL = [tempFolder URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    
    OPDBDatabaseQueue *queue = [OPDBDatabaseQueue databaseQueueWithURL:fileURL];
    XCTAssert(queue, @"Database queue should be returned");
    queue = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
}

- (void)testURLOpenInit {
    NSURL *tempFolder = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *fileURL = [tempFolder URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    
    OPDBDatabaseQueue *queue = [[OPDBDatabaseQueue alloc] initWithURL:fileURL];
    XCTAssert(queue, @"Database queue should be returned");
    queue = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
}

- (void)testURLOpenWithOptions {
    NSURL *tempFolder = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *fileURL = [tempFolder URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    
    OPDBDatabaseQueue *queue = [OPDBDatabaseQueue databaseQueueWithURL:fileURL flags:SQLITE_OPEN_READWRITE];
    XCTAssertNil(queue, @"Database queue should not have been created");
}

- (void)testURLOpenInitWithOptions {
    NSURL *tempFolder = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *fileURL = [tempFolder URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    
    OPDBDatabaseQueue *queue = [[OPDBDatabaseQueue alloc] initWithURL:fileURL flags:SQLITE_OPEN_READWRITE];
    XCTAssertNil(queue, @"Database queue should not have been created");

    queue = [[OPDBDatabaseQueue alloc] initWithURL:fileURL flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE];
    XCTAssert(queue, @"Database queue should have been created");
    
    [queue inDatabase:^(OPDBDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:@"CREATE TABLE foo (bar INT)"];
        XCTAssert(success, @"Create failed");
        success = [db executeUpdate:@"INSERT INTO foo (bar) VALUES (?)", @42];
        XCTAssert(success, @"Insert failed");
    }];
    queue = nil;

    queue = [[OPDBDatabaseQueue alloc] initWithURL:fileURL flags:SQLITE_OPEN_READONLY];
    XCTAssert(queue, @"Now database queue should open have been created");
    [queue inDatabase:^(OPDBDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:@"CREATE TABLE baz (qux INT)"];
        XCTAssertFalse(success, @"But updates should fail on read only database");
    }];    
    queue = nil;
    
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
}

- (void)testURLOpenWithOptionsVfs {
    sqlite3_vfs vfs = *sqlite3_vfs_find(NULL);
    vfs.zName = "MyCustomVFS";
    XCTAssertEqual(SQLITE_OK, sqlite3_vfs_register(&vfs, 0));

    NSURL *tempFolder = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *fileURL = [tempFolder URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    
    OPDBDatabaseQueue *queue = [[OPDBDatabaseQueue alloc] initWithURL:fileURL flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE vfs:@"MyCustomVFS"];
    XCTAssert(queue, @"Database queue should not have been created");
    queue = nil;

    XCTAssertEqual(SQLITE_OK, sqlite3_vfs_unregister(&vfs));
}

- (void)testQueueSelect
{
    [self.queue inDatabase:^(OPDBDatabase *adb) {
        int count = 0;
        OPDBResultSet *rsl = [adb executeQuery:@"select * from qfoo where foo like 'h%'"];
        while ([rsl next]) {
            count++;
        }
        
        XCTAssertEqual(count, 2);
        
        count = 0;
        rsl = [adb executeQuery:@"select * from qfoo where foo like ?", @"h%"];
        while ([rsl next]) {
            count++;
        }
        
        XCTAssertEqual(count, 2);
    }];
}

- (void)testReadOnlyQueue
{
    OPDBDatabaseQueue *queue2 = [OPDBDatabaseQueue databaseQueueWithPath:self.databasePath flags:SQLITE_OPEN_READONLY];
    XCTAssertNotNil(queue2);

    {
        [queue2 inDatabase:^(OPDBDatabase *db2) {
            OPDBResultSet *rs1 = [db2 executeQuery:@"SELECT * FROM qfoo"];
            XCTAssertNotNil(rs1);

            [rs1 close];
            
            XCTAssertFalse(([db2 executeUpdate:@"insert into easy values (?)", [NSNumber numberWithInt:3]]), @"Insert should fail because this is a read-only database");
        }];
        
        [queue2 close];
        
        // Check that when we re-open the database, it's still read-only
        [queue2 inDatabase:^(OPDBDatabase *db2) {
            OPDBResultSet *rs1 = [db2 executeQuery:@"SELECT * FROM qfoo"];
            XCTAssertNotNil(rs1);
            
            [rs1 close];
            
            XCTAssertFalse(([db2 executeUpdate:@"insert into easy values (?)", [NSNumber numberWithInt:3]]), @"Insert should fail because this is a read-only database");
        }];
    }
}

- (void)testStressTest
{
    size_t ops = 16;
    
    dispatch_queue_t dqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply(ops, dqueue, ^(size_t nby) {
        
        // just mix things up a bit for demonstration purposes.
        if (nby % 2 == 1) {
            [NSThread sleepForTimeInterval:.01];
            
            [self.queue inTransaction:^(OPDBDatabase *adb, BOOL *rollback) {
                OPDBResultSet *rsl = [adb executeQuery:@"select * from qfoo where foo like 'h%'"];
                while ([rsl next]) {
                    ;// whatever.
                }
            }];
            
        }
        
        if (nby % 3 == 1) {
            [NSThread sleepForTimeInterval:.01];
        }
        
        [self.queue inTransaction:^(OPDBDatabase *adb, BOOL *rollback) {
            XCTAssertTrue([adb executeUpdate:@"insert into qfoo values ('1')"]);
            XCTAssertTrue([adb executeUpdate:@"insert into qfoo values ('2')"]);
            XCTAssertTrue([adb executeUpdate:@"insert into qfoo values ('3')"]);
        }];
    });
    
    [self.queue close];
    
    [self.queue inDatabase:^(OPDBDatabase *adb) {
        XCTAssertTrue([adb executeUpdate:@"insert into qfoo values ('1')"]);
    }];
}

- (void)testTransaction
{
    [self.queue inDatabase:^(OPDBDatabase *adb) {
        [adb executeUpdate:@"create table transtest (a integer)"];
        XCTAssertTrue([adb executeUpdate:@"insert into transtest values (1)"]);
        XCTAssertTrue([adb executeUpdate:@"insert into transtest values (2)"]);
        
        int rowCount = 0;
        OPDBResultSet *ars = [adb executeQuery:@"select * from transtest"];
        while ([ars next]) {
            rowCount++;
        }
        
        XCTAssertEqual(rowCount, 2);
    }];
    
    [self.queue inTransaction:^(OPDBDatabase *adb, BOOL *rollback) {
        XCTAssertTrue([adb executeUpdate:@"insert into transtest values (3)"]);
        
        if (YES) {
            // uh oh!, something went wrong (not really, this is just a test
            *rollback = YES;
            return;
        }
        
        XCTFail(@"This shouldn't be reached");
    }];
    
    [self.queue inDatabase:^(OPDBDatabase *adb) {
        
        int rowCount = 0;
        OPDBResultSet *ars = [adb executeQuery:@"select * from transtest"];
        while ([ars next]) {
            rowCount++;
        }
        
        XCTAssertFalse([adb hasOpenResultSets]);
        
        XCTAssertEqual(rowCount, 2);
    }];

}

@end
