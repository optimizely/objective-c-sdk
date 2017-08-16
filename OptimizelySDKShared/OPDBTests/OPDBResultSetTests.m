//
//  OPDBResultSetTests.m
//  opdb
//
//  Created by Muralidharan,Roshan on 10/6/14.
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

#import "OPDBTempDBTests.h"
#import "OPDBDatabase.h"
#import "OPDBResultSet.h"

#if OPDB_SQLITE_STANDALONE
#import <sqlite3/sqlite3.h>
#else
#import <sqlite3.h>
#endif

@interface OPDBResultSetTests : OPDBTempDBTests

@end

@implementation OPDBResultSetTests

+ (void)populateDatabase:(OPDBDatabase *)db
{
    [db executeUpdate:@"create table test (a text, b text, c integer, d double, e double)"];
    
    [db beginTransaction];
    int i = 0;
    while (i++ < 20) {
        [db executeUpdate:@"insert into test (a, b, c, d, e) values (?, ?, ?, ?, ?)" ,
         @"hi'",
         [NSString stringWithFormat:@"number %d", i],
         [NSNumber numberWithInt:i],
         [NSDate date],
         [NSNumber numberWithFloat:2.2f]];
    }
    [db commit];
}

- (void)testNextWithError_WithoutError
{
    [self.db executeUpdate:@"CREATE TABLE testTable(key INTEGER PRIMARY KEY, value INTEGER)"];
    [self.db executeUpdate:@"INSERT INTO testTable (key, value) VALUES (1, 2)"];
    [self.db executeUpdate:@"INSERT INTO testTable (key, value) VALUES (2, 4)"];
    
    OPDBResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM testTable WHERE key=1"];
    XCTAssertNotNil(resultSet);
    NSError *error;
    XCTAssertTrue([resultSet nextWithError:&error]);
    XCTAssertNil(error);
    
    XCTAssertFalse([resultSet nextWithError:&error]);
    XCTAssertNil(error);
    
    [resultSet close];
}

- (void)testNextWithError_WithBusyError
{
    [self.db executeUpdate:@"CREATE TABLE testTable(key INTEGER PRIMARY KEY, value INTEGER)"];
    [self.db executeUpdate:@"INSERT INTO testTable (key, value) VALUES (1, 2)"];
    [self.db executeUpdate:@"INSERT INTO testTable (key, value) VALUES (2, 4)"];
    
    OPDBResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM testTable WHERE key=1"];
    XCTAssertNotNil(resultSet);
    
    OPDBDatabase *newDB = [OPDBDatabase databaseWithPath:self.databasePath];
    [newDB open];
    
    [newDB beginTransaction];
    NSError *error;
    XCTAssertFalse([resultSet nextWithError:&error]);
    [newDB commit];
    
    
    XCTAssertEqual(error.code, SQLITE_BUSY, @"SQLITE_BUSY should be the last error");
    [resultSet close];
}

- (void)testNextWithError_WithMisuseError
{
    [self.db executeUpdate:@"CREATE TABLE testTable(key INTEGER PRIMARY KEY, value INTEGER)"];
    [self.db executeUpdate:@"INSERT INTO testTable (key, value) VALUES (1, 2)"];
    [self.db executeUpdate:@"INSERT INTO testTable (key, value) VALUES (2, 4)"];
    
    OPDBResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM testTable WHERE key=9"];
    XCTAssertNotNil(resultSet);
    XCTAssertFalse([resultSet next]);
    NSError *error;
    XCTAssertFalse([resultSet nextWithError:&error]);

    XCTAssertEqual(error.code, SQLITE_MISUSE, @"SQLITE_MISUSE should be the last error");
}

@end
