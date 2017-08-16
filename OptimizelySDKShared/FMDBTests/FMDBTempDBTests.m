//
//  FMDBTempDBTests.m
//  fmdb
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

#import "FMDBTempDBTests.h"

static NSString *const testDatabasePath = @"/tmp/tmp.db";
static NSString *const populatedDatabasePath = @"/tmp/tmp-populated.db";

@implementation FMDBTempDBTests

+ (void)setUp
{
    [super setUp];
    
    // Delete old populated database
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:populatedDatabasePath error:NULL];
    
    if ([self respondsToSelector:@selector(populateDatabase:)]) {
        FMDatabase *db = [FMDatabase databaseWithPath:populatedDatabasePath];
        
        [db open];
        [self populateDatabase:db];
        [db close];
    }
}

- (void)setUp
{
    [super setUp];
    
    // Delete the old database
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:testDatabasePath error:NULL];
    
    if ([[self class] respondsToSelector:@selector(populateDatabase:)]) {
        [fileManager copyItemAtPath:populatedDatabasePath toPath:testDatabasePath error:NULL];
    }
    
    self.db = [FMDatabase databaseWithPath:testDatabasePath];
    
    XCTAssertTrue([self.db open], @"Wasn't able to open database");
    [self.db setShouldCacheStatements:YES];
}

- (void)tearDown
{
    [super tearDown];
    
    [self.db close];
}

- (NSString *)databasePath
{
    return testDatabasePath;
}

- (void)testTempDBTests {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
