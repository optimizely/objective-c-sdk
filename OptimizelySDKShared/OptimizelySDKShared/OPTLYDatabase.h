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

/*
 This class manages all the database reads and writes and will primiarly be used to store events or logs.
 Each row entry contains three columns [OPTLYDatabaseEntity]:
 1. id [int]
 2. json [text]
 3. timestamp [int]
 The table is stored in the Library directory: .../optimizely/database/optly-database.sqlite
 This feature is not available for tvOS as storage is limited.
 */

#import <Foundation/Foundation.h>

@interface OPTLYDatabase : NSObject
/**
 * File manager initializer.
 *
 * @param baseDir The base directory where the database will be stored.
 * @return an instance of OPTLYDatabase.
 **/
- (nullable instancetype)initWithBaseDir:(nonnull NSString *)baseDir;

/**
 * Creates a new table.
 *
 * @param tableName The database table name.
 * @param error An error object is returned if an error occurs.
 **/
- (void)createTable:(nonnull NSString *)tableName
              error:(NSError * _Nullable * _Nullable)error;

/**
 * File manager initializer.
 *
 * @param baseDir The base directory where the database will be stored.
 * @return an instance of OPTLYDatabase.
 **/
- (nullable instancetype)initWithBaseDir:(nonnull NSString *)baseDir;

/**
 * Inserts data into a database table.
 *
 * @param data The data to be written into the table.
 * @param tableName The database table name.
 * @param error An error object is returned if an error occurs.
 */
- (void)saveData:(nonnull NSDictionary *)data
             table:(nonnull NSString *)tableName
             error:(NSError * _Nullable * _Nullable)error;

/**
 * Deletes data from a database table.
 *
 * @param entityId The entity id to remove from the table.
 * @param tableName The database table name.
 * @param error An error object is returned if an error occurs.
 */
- (void)deleteEntity:(nonnull NSString *)entityId
               table:(nonnull NSString *)tableName
               error:(NSError * _Nullable * _Nullable)error;

/**
 * Deletes data from a database table.
 *
 * @param entityIds The entity ids to remove from the table.
 * @param tableName The database table name.
 * @param error An error object is returned if an error occurs.
 */
- (void)deleteEntities:(nonnull NSArray *)entityIds
                 table:(nonnull NSString *)tableName
                 error:(NSError * _Nullable * _Nullable)error;

/**
 * Retrieve all entries from the table.
 *
 * @param tableName The database table name.
 * @param error An error object is returned if an error occurs.
 * @return The return value is an array of OPTLYDatabaseEntity.
 */
- (nullable NSArray *)retrieveAllEntries:(nonnull NSString *)tableName
                                   error:(NSError * _Nullable * _Nullable)error;

/**
 * Retrieves a set of N entries from the table.
 *
 * @param numberOfEntries The number of entries to read from the table
 * @param tableName The database table name.
 * @param error An error object is returned if an error occurs.
 * @return The return value is an array of OPTLYDatabaseEntity.
 */
- (nullable NSArray *)retrieveFirstNEntries:(NSInteger)numberOfEntries
                                      table:(nonnull NSString *)tableName
                                      error:(NSError * _Nullable * _Nullable)error;

/**
 * Returns the number of rows of a table.
 *
 * @param tableName The database table name.
 * @param error An error object is returned if an error occurs.
 * @return The number of rows in a table.
 */
- (NSInteger)numberOfRows:(nonnull NSString *)tableName
                    error:(NSError * _Nullable * _Nullable)error;

/**
 * Deletes the database.
 *
 * @param error An error object is returned if an error occurs.
 */
- (void)deleteDatabase:(NSError * _Nullable * _Nullable)error;
@end

