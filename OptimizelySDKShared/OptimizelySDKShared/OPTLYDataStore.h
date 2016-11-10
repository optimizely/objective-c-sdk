<<<<<<< ce6f3747e73962c7c281bf400714e00bdf7e32d6
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

typedef NS_ENUM(NSUInteger, OPTLYDataStoreDataType)
{
    OPTLYDataStoreDataTypeDatabase,
    OPTLYDataStoreDataTypeDatafile,
    OPTLYDataStoreDataTypeEventDispatcher,
    OPTLYDataStoreDataTypeUserProfile,
};

typedef NS_ENUM(NSUInteger, OPTLYDataStoreEventType)
{
    OPTLYDataStoreEventTypeImpression,
    OPTLYDataStoreEventTypeConversion,
};

@class OPTLYFileManager;

/*
 * This class handles all things related to persistence and serves as a wrapper class for
 * OPTLYFileManager and OPTLYDatabase.
 */

@interface OPTLYDataStore : NSObject

/// base directory where Optimizely-related data will persist
@property (nonatomic, strong, readonly, nonnull) NSString *baseDirectory;

/**
 * Removes all data persisted by Optimizely
 **/
- (void)removeAll;

// ---- NSFileManager ----
/**
 * Saves a file.
 * If a file of the same name type exists already, then that file will be overwritten.
 *
 * @param fileName A string that represents the name of the file to save.
 *  Can include a file suffix if desired (e.g., .txt or .json).
 * @param data The data to save to the file.
 * @param dataType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @param error An error object which will store any errors if the file save fails.
 *  If error is nil, than the file save was successful.
 *
 **/
- (void)saveFile:(nonnull NSString *)fileName
            data:(nonnull NSData *)data
            type:(OPTLYDataStoreDataType)dataType
           error:(NSError * _Nullable * _Nullable)error;

/**
 * Gets a file.
 *
 * @param fileName A string that represents the name of the file to retrieve.
 * @param dataType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @return The file in NSData format.
 * @param error An error object which will store any errors if the file save fails.
 *  If error is nil, than the file save was successful.
 *
 **/
- (nullable NSData *)getFile:(nonnull NSString *)fileName
                        type:(OPTLYDataStoreDataType)dataType
                       error:(NSError * _Nullable * _Nullable)error;

/**
 * Determines if a file exists.
 *
 * @param fileName A string that represents the name of the file to check.
 * @param dataType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @return A boolean value that states if a file exists or not (or could not be determined).
 *
 **/
- (bool)fileExists:(nonnull NSString *)fileName
              type:(OPTLYDataStoreDataType)dataType;

/**
 * Determines if a data type exists.
 *
 * @param dataType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @return A boolean value that states if a data type exists or not (or could not be determined).
 *
 **/
- (bool)dataTypeExists:(OPTLYDataStoreDataType)dataType;

/**
 * Deletes a file.
 *
 * @param fileName A string that represents the name of the file to delete.
 * @param dataType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @param error An error object which will store any errors if the file removal fails.
 *  If error is nil, than the file deletion was successful.
 *
 **/
- (void)removeFile:(nonnull NSString *)fileName
              type:(OPTLYDataStoreDataType)dataType
             error:(NSError * _Nullable * _Nullable)error;

/**
 * Removes all document files.
 *
 * @param error An error object which will store any errors if the file removal fails.
 *
 **/
- (void)removeAllFiles:(NSError * _Nullable * _Nullable)error;

/**
 * Removes a particular data type.
 *
 * @param dataType The type of file (e.g., datafile, user profile, event dispatcher, etc.)
 * @param error An error object which will store any errors if the directory removal fails.
 *
 **/
- (void)removeFilesForDataType:(OPTLYDataStoreDataType)dataType
                         error:(NSError * _Nullable * _Nullable)error;


// ---- SQLite Table ----
// Used for event storage
#if TARGET_OS_IOS
/**
 * Creates a new table.
 *
 * @param eventType The event type of the data to be stored in the new table.
 * @param error An error object is returned if an error occurs.
 **/
- (void)createTable:(OPTLYDataStoreEventType)eventType
              error:(NSError * _Nullable * _Nullable)error;

/**
 * Inserts data into a database table.
 *
 * @param data The data to be written into the table.
 * @param eventType The event type of the data that needs to be saved.
 * @param error An error object is returned if an error occurs.
 */
- (void)insertData:(nonnull NSDictionary *)data
         eventType:(OPTLYDataStoreEventType)eventType
             error:(NSError * _Nullable * _Nullable)error;

/**
 * Deletes data from a database table.
 *
 * @param entityId The entity id to remove from the table.
 * @param eventType The event type of the data that needs to be removed.
 * @param error An error object is returned if an error occurs.
 */
- (void)deleteEvent:(nonnull NSString *)entityId
          eventType:(OPTLYDataStoreEventType)eventType
              error:(NSError * _Nullable * _Nullable)error;

/**
 * Deletes data from a database table.
 *
 * @param entityIds The entity ids to remove from the table.
 * @param eventType The event type of the data that needs to be removed.
 * @param error An error object is returned if an error occurs.
 */
- (void)deleteEvents:(nonnull NSArray *)entityIds
           eventType:(OPTLYDataStoreEventType)eventType
               error:(NSError * _Nullable * _Nullable)error;

/**
 * Retrieve all entries from the table.
 *
 * @param eventType The event type of the data that needs to be retrieved.
 * @param error An error object is returned if an error occurs.
 * @return The return value is an array of OPTLYDatabaseEntity.
 */
- (nullable NSArray *)retrieveAllEvents:(OPTLYDataStoreEventType)eventType
                                  error:(NSError * _Nullable * _Nullable)error;

/**
 * Retrieves a set of N entries from the table.
 *
 * @param numberOfEntries The number of entries to read from the table
 * @param eventType The event type of the data that needs to be retrieved.
 * @param error An error object is returned if an error occurs.
 * @return The return value is an array of OPTLYDatabaseEntity.
 */
- (nullable NSArray *)retrieveFirstNEvents:(NSInteger)numberOfEntries
                                 eventType:(OPTLYDataStoreEventType)eventType
                                     error:(NSError * _Nullable * _Nullable)error;

/**
 * Returns the number of saved events.
 *
 * @param eventType The event type of the data.
 * @param error An error object is returned if an error occurs.
 * @return The number of rows in a table.
 */
- (NSInteger)numberOfEvents:(OPTLYDataStoreEventType)eventType
                      error:(NSError * _Nullable * _Nullable)error;
#endif

// ---- NSUserDefault ----
/**
 * Saves data in dictionary format in NSUserDefault
 *
 * @param data The dictionary data to save.
 * @param dataType The type of data (e.g., datafile, user profile, event dispatcher, etc.)
 */
- (void)save:(nonnull NSDictionary *)data type:(OPTLYDataStoreDataType)dataType;

/**
 * Gets saved data from NSUserDefault.
 *
 * @param dataType The type of data (e.g., datafile, user profile, event dispatcher, etc.)
 * @return data retrieved.
 */
- (nullable NSDictionary *)getDataForType:(OPTLYDataStoreDataType)dataType;

/**
 * Removes data for a particular type of data in NSUserDefault.
 *
 * @param dataType The type of data (e.g., datafile, user profile, event dispatcher, etc.)
 */
- (void)removeDataForType:(OPTLYDataStoreDataType)dataType;

/**
 * Removes all Optimizely-related data in NSUserDefault.
 */
- (void)removeAllData;

/**
 * Removes an object from the dictionary data saved in NSUserDefault.
 *
 * @param dataKey The key for the dictionary data to remove.
 * @param dataType The type of data (e.g., datafile, user profile, event dispatcher, etc.)
 */
- (void)removeObjectInData:(nonnull id)dataKey type:(OPTLYDataStoreDataType)dataType;

// ---- Cached Data ----
- (void)insertCachedData:(nonnull NSDictionary *)data
               eventType:(OPTLYDataStoreEventType)eventType;

- (nullable NSDictionary *)retrieveCachedItem:(OPTLYDataStoreEventType)eventType;

- (nullable NSArray *)retrieveNCachedItems:(NSInteger)numberOfItems
                                 eventType:(OPTLYDataStoreEventType)eventType;

- (void)removeCachedItem:(OPTLYDataStoreEventType)eventType;

- (void)removeNCachedItem:(NSInteger)numberOfItems
                eventType:(OPTLYDataStoreEventType)eventType;

- (NSInteger)numberOfCachedItems:(OPTLYDataStoreEventType)eventType;
@end
