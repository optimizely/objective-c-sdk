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

#import <UIKit/UIKit.h>
#import <FMDB/FMDB.h>
#import <OptimizelySDKCore/OptimizelySDKCore.h>
#import "OPTLYDatabase.h"
#import "OPTLYFileManager.h"
#import "OPTLYDatabaseEntity.h"

// table names
NSString *const OPTLYDatabaseEventsTable = @"EVENTS";

// table file name
static NSString * const kdatabaseFileName = @"optly-database.sqlite";

// database queries
static NSString * const kCreateTableQuery = @"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT, json TEXT,timestamp INTEGER)";
static NSString * const kInsertEntityQuery = @"INSERT INTO %@ (json,timestamp) VALUES(?,?)";
static NSString * const kDeleteEntityQuery = @"DELETE FROM %@ where id IN %@";
static NSString * const kRetrieveEntityQuery = @"SELECT * from %@";
static NSString * const kRetrieveEntityQueryLimit = @" LIMIT %ld";
static NSString * const kEntitiesCountQuery = @"SELECT count(*) FROM %@";

// column names
static NSString * const kColumnKeyId = @"id";
static NSString * const kColumnKeyJSON = @"json";
static NSString * const kColumnKeyTimestamp = @"timestamp";

@interface OPTLYDatabase()
@property (nonatomic, strong) NSString *databaseFileDirectory;
@property (nonatomic, strong) NSString *databaseFilePath;
@property (nonatomic, strong) FMDatabaseQueue *fmDatabaseQueue;
@end

#define LOG_FLAG_INFO 1

@implementation OPTLYDatabase

- (id)init
{
    self = [super init];
    if (self) {
        OPTLYFileManager *optlyFileManager = [OPTLYFileManager new];
        _databaseFileDirectory = [optlyFileManager directoryPathForFileType:OPTLYFileManagerDataTypeDatabase];
        _databaseFilePath = [_databaseFileDirectory stringByAppendingPathComponent:kdatabaseFileName];
        
        // create directory for the database if it does not exist
        NSFileManager *fileManager = [NSFileManager new];
        bool isDir = true;
        if (![fileManager fileExistsAtPath:self.databaseFileDirectory isDirectory:&isDir]) {
            [fileManager createDirectoryAtPath:self.databaseFileDirectory
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        }
        
        // set the database queue
        _fmDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:_databaseFilePath];
        
        // create the events table
        NSError *error = nil;
        [self createTable:OPTLYDatabaseEventsTable error:&error];
        if (error) {
            OPTLYLogError(@"Error creating database table: %@", error);
        }
    }
    return self;
}

- (void)createTable:(NSString *)tableName
              error:(NSError **)error
{
    [self.fmDatabaseQueue inDatabase:^(FMDatabase *db) {
        NSString *query = [NSString stringWithFormat:kCreateTableQuery, tableName];
        if (![db executeUpdate:query]) {
            if (error) {
                *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                  code:OPTLYErrorTypesDatabase
                                              userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString([db lastErrorMessage], nil)}];
            }
            OPTLYLogError(@"Unable to create Optimizely table: %@ %@", tableName, [db lastErrorMessage]);
        }
    }];
}


- (void)insertData:(NSDictionary *)data
             table:(NSString *)tableName
             error:(NSError **)error
{
    [self.fmDatabaseQueue inDatabase:^(FMDatabase *db){
        NSString *json = [self jsonStringFromDictionary:data];
        NSNumber *timeStamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        NSMutableString *query = [NSMutableString stringWithFormat:kInsertEntityQuery, tableName];
        if (![db executeUpdate:query, json, timeStamp]) {
            if (error) {
                *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesDatabase
                                         userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString([db lastErrorMessage], nil)}];
            }
            OPTLYLogError(@"Unable to store data to Optimizely table: %@ %@ %@", tableName, json, [db lastErrorMessage]);
        } 
    }];
}

- (void)deleteEntity:(NSString *)entityId
               table:(NSString *)tableName
               error:(NSError **)error
{
    [self deleteEntities:@[entityId] table:tableName error:error];
}

- (void)deleteEntities:(NSArray *)entityIds
                 table:(NSString *)tableName
                 error:(NSError **)error
{
    [self.fmDatabaseQueue inDatabase:^(FMDatabase *db){
        NSString *commaSeperatedIds = [NSString stringWithFormat:@"(%@)", [entityIds componentsJoinedByString:@","]];
        NSString *query = [NSString stringWithFormat:kDeleteEntityQuery, tableName, commaSeperatedIds];
        if (![db executeUpdate:query]) {
            if (error) {
                *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                            code:OPTLYErrorTypesDatabase
                                        userInfo:@{NSLocalizedDescriptionKey :
                                                       NSLocalizedString([db lastErrorMessage], nil)}];
            }
            OPTLYLogError(@"Unable to remove rows of Optimizely table: %@ %@", tableName, [db lastErrorMessage]);
        }
    }];
}

- (NSArray *)retrieveAllEntries:(NSString *)tableName
                          error:(NSError **)error
{
    NSArray *allEntries = [self retrieveFirstNEntries:0 table:tableName error:error];
    return allEntries;
}

- (NSArray *)retrieveFirstNEntries:(NSInteger)numberOfEntries
                             table:(NSString *)tableName
                             error:(NSError **)error
{
    NSMutableArray *results = [NSMutableArray new];
    
    [self.fmDatabaseQueue inDatabase:^(FMDatabase *db){
        NSMutableString *query = [NSMutableString stringWithFormat:kRetrieveEntityQuery, tableName];
        if (numberOfEntries) {
            [query appendFormat:kRetrieveEntityQueryLimit, (long)numberOfEntries];
        }
        FMResultSet *resultSet = [db executeQuery:query];
        if (!resultSet) {
            if (error) {
                *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesDatabase
                                         userInfo:@{NSLocalizedDescriptionKey :
                                                        NSLocalizedString([db lastErrorMessage], nil)}];
            }
            OPTLYLogError(@"Unable to retrieve rows of Optimizely table: %@ %@", tableName, [db lastErrorMessage]);
        }
        
        while ([resultSet next]) {
            OPTLYDatabaseEntity *entity = [OPTLYDatabaseEntity new];
            entity.entityId = [NSNumber numberWithLongLong:[resultSet intForColumn:kColumnKeyId]];
            entity.entityValue = [resultSet stringForColumn:kColumnKeyJSON];
            entity.timestamp = [NSNumber numberWithLongLong:[resultSet intForColumn:kColumnKeyTimestamp]];
            [results addObject:entity];
        }
        [resultSet close];
    }];
    
    return results;
}

- (NSInteger)numberOfRows:(NSString *)tableName
                    error:(NSError **)error
{
    __block NSInteger rows = 0;
    
    [self.fmDatabaseQueue inDatabase:^(FMDatabase *db){
        NSString *query = [NSString stringWithFormat:kEntitiesCountQuery, tableName];
        FMResultSet *resultSet = [db executeQuery:query];
        if (!resultSet) {
            if (error) {
                *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesDatabase
                                         userInfo:@{NSLocalizedDescriptionKey :
                                                        NSLocalizedString([db lastErrorMessage], nil)}];
            }
            OPTLYLogError(@"Unable to fetch number of rows in Optimizely table: %@ %@", tableName, [db lastErrorMessage]);
        }
        if ([resultSet next]) {
            rows = [resultSet intForColumnIndex:0];
        }
        
        [resultSet close];
    }];
    
    return rows;
}

# pragma mark -- Helper Methods

- (NSString *)jsonStringFromDictionary:(NSDictionary *)dictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

- (NSDictionary *)dictionaryFromJSON:(NSString *)JSON {
    return [NSJSONSerialization JSONObjectWithData:[JSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}

@end
