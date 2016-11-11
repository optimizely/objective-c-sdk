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

#import <Foundation/Foundation.h>

typedef enum {
    OPTLYDataStoreDataTypeDatabase,
    OPTLYDataStoreDataTypeDatafile,
    OPTLYDataStoreDataTypeEventDispatcher,
    OPTLYDataStoreDataTypeUserProfile,
} OPTLYDataStoreDataType;

@class OPTLYFileManager;

/*
 * This class handles all things related to persistence and serves as a wrapper class for
 * OPTLYFileManager and OPTLYDatabase.
 */

@interface OPTLYDataStore : NSObject

/// base directory where Optimizely-related data will persist
@property (nonatomic, strong, readonly, nonnull) NSString *baseDirectory;

/**
 * Saves a file.
 * If a file of the same name type exists already, then that file will be overwritten.
 *
 * @param fileName A string that represents the name of the file to save.
 *  Can include a file suffix if desired (e.g., .txt or .json).
 * @param data The data to save to the file.
 * @param fileType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @param error An error object which will store any errors if the file save fails.
 *  If error is nil, than the file save was successful.
 *
 **/
- (void)saveFile:(nonnull NSString *)fileName
            data:(nonnull NSData *)data
            type:(OPTLYDataStoreDataType)fileType
           error:(NSError * _Nullable * _Nullable)error;

/**
 * Gets a file.
 *
 * @param fileName A string that represents the name of the file to retrieve.
 * @param fileType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @return The file in NSData format.
 * @param error An error object which will store any errors if the file save fails.
 *  If error is nil, than the file save was successful.
 *
 **/
- (nullable NSData *)getFile:(nonnull NSString *)fileName
                        type:(OPTLYDataStoreDataType)fileType
                       error:(NSError * _Nullable * _Nullable)error;

/**
 * Determines if a file exists.
 *
 * @param fileName A string that represents the name of the file to check.
 * @param fileType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @return A boolean value that states if a file exists or not (or could not be determined).
 *
 **/
- (bool)fileExists:(nonnull NSString *)fileName
              type:(OPTLYDataStoreDataType)fileType;

/**
 * Deletes a file.
 *
 * @param fileName A string that represents the name of the file to delete.
 * @param fileType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @param error An error object which will store any errors if the file removal fails.
 *  If error is nil, than the file deletion was successful.
 *
 **/
- (void)removeFile:(nonnull NSString *)fileName
              type:(OPTLYDataStoreDataType)fileType
             error:(NSError * _Nullable * _Nullable)error;

/**
 * Removes all document files.
 *
 * @param error An error object which will store any errors if the file removal fails.
 *
 **/
- (void)removeAllData:(NSError * _Nullable * _Nullable)error;

/**
 * Removes a particular data type.
 *
 * @param fileType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @param error An error object which will store any errors if the directory removal fails.
 *
 **/
- (void)removeDataType:(OPTLYDataStoreDataType)fileType
                 error:(NSError * _Nullable * _Nullable)error;

#if TARGET_OS_IOS
/**
 * Inserts data into a database table.
 *
 * @param data The data to be written into the table.
 * @param tableName The database table name.
 * @param error An error object is returned if an error occurs.
 */
- (void)insertData:(nonnull NSDictionary *)data
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
#endif
@end
