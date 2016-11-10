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

#import <OptimizelySDKCore/OPTLYLog.h>
#import <OptimizelySDKCore/OPTLYQueue.h>
#import "OPTLYDatabase.h"
#import "OPTLYDatabaseEntity.h"
#import "OPTLYDataStore.h"
#import "OPTLYFileManager.h"
#if TARGET_OS_IOS
#import "OPTLYDatabase.h"
#endif

static NSString * const kOptimizelyDirectory = @"optimizely";

// data type names
static NSString * const kDatabase = @"database";
static NSString * const kDatafile = @"datafile";
static NSString * const kUserProfile = @"user-profile";
static NSString * const kEventDispatcher = @"event-dispatcher";

// table names
static NSString *const kOPTLYDataStoreEventTypeImpression = @"EVENTS_IMPRESSION";
static NSString *const kOPTLYDataStoreEventTypeConversion = @"EVENTS_CONVERSION";

@interface OPTLYDataStore()
@property (nonatomic, strong) OPTLYFileManager *fileManager;
#if TARGET_OS_IOS
@property (nonatomic, strong) OPTLYDatabase *database;
#endif
@property (nonatomic, strong) NSDictionary *eventsCache;
@end

@implementation OPTLYDataStore

- (id)init {
    self = [super init];
    if (self) {
        NSString *filePath = @"";
#if TARGET_OS_TV
        // tvOS only allows writing to a temporary file directory
        // a future enhancement would be save to iCloud
        filePath = NSTemporaryDirectory();
#elif TARGET_OS_IOS
        NSArray *libraryDirPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        filePath = libraryDirPaths[0];
#endif
        // the base directory is the file directory for which all Optimizely-related data will be stored
        _baseDirectory = [filePath stringByAppendingPathComponent:kOptimizelyDirectory];
    }
    return self;
}

- (OPTLYFileManager *)fileManager {
    if (!_fileManager) {
        _fileManager = [[OPTLYFileManager alloc] initWithBaseDir:self.baseDirectory];
    }
    return _fileManager;
}

- (void)removeAll {
    [self removeAllData];
    [self removeAllFiles:nil];
}

#if TARGET_OS_IOS
- (OPTLYDatabase *)database
{
    if (!_database) {
        NSString *databaseDirectory = [self.baseDirectory stringByAppendingPathComponent:[self stringForDataTypeEnum:OPTLYDataStoreDataTypeDatabase]];
        _database = [[OPTLYDatabase alloc] initWithBaseDir:databaseDirectory];
        
        // create the events table
        NSError *error = nil;
        [self createTable:OPTLYDataStoreEventTypeImpression error:&error];
        if (error) {
            OPTLYLogError(@"Error creating impression event database table: %@", error);
        }
        [self createTable:OPTLYDataStoreEventTypeConversion error:&error];
        if (error) {
            OPTLYLogError(@"Error creating conversion event database table: %@", error);
        }
    }
    return _database;
}
#endif

- (NSDictionary *)eventsCache {
    if (!_eventsCache) {
        NSMutableDictionary *temp = [NSMutableDictionary new];
        // create cache of impression events
        temp[kOPTLYDataStoreEventTypeImpression] = [OPTLYQueue new];
        // create cache of conversin events
        temp[kOPTLYDataStoreEventTypeConversion] = [OPTLYQueue new];
        _eventsCache = [NSDictionary dictionaryWithDictionary:temp];
    }
    return _eventsCache;
}

# pragma mark - NSUserDefault Data
- (void)save:(nonnull NSDictionary *)data type:(OPTLYDataStoreDataType)dataType
{
    NSString *key = [self stringForDataTypeEnum:dataType];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:key];
}

- (nullable NSDictionary *)getDataForType:(OPTLYDataStoreDataType)dataType
{
    NSString *key = [self stringForDataTypeEnum:dataType];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *data = [defaults objectForKey:key];
    return data;
}

- (void)removeDataForType:(OPTLYDataStoreDataType)dataType
{
    NSString *key = [self stringForDataTypeEnum:dataType];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:key];
}

- (void)removeObjectInData:(nonnull id)dataKey type:(OPTLYDataStoreDataType)dataType
{
    NSString *key = [self stringForDataTypeEnum:dataType];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *data = [[defaults objectForKey:key] mutableCopy];
    [data removeObjectForKey:dataKey];
    [defaults setObject:data forKey:key];
}

- (void)removeAllData
{
    for (NSInteger i = 0; i <= OPTLYDataStoreDataTypeUserProfile; ++i) {
        [self removeDataForType:i];
    }
}

# pragma mark - File Manager Methods
- (void)saveFile:(nonnull NSString *)fileName
            data:(nonnull NSData *)data
            type:(OPTLYDataStoreDataType)dataType
           error:(NSError * _Nullable * _Nullable)error {
    [self.fileManager saveFile:fileName data:data subDir:[self stringForDataTypeEnum:dataType] error:error];
}

- (nullable NSData *)getFile:(nonnull NSString *)fileName
                        type:(OPTLYDataStoreDataType)dataType
                       error:(NSError * _Nullable * _Nullable)error {
    return [self.fileManager getFile:fileName subDir:[self stringForDataTypeEnum:dataType] error:error];
}

- (bool)fileExists:(nonnull NSString *)fileName
              type:(OPTLYDataStoreDataType)dataType {
    return [self.fileManager fileExists:fileName subDir:[self stringForDataTypeEnum:dataType]];
}

- (bool)dataTypeExists:(OPTLYDataStoreDataType)dataType
{
    return [self.fileManager subDirExists:[self stringForDataTypeEnum:dataType]];
}

- (void)removeFile:(nonnull NSString *)fileName
              type:(OPTLYDataStoreDataType)dataType
             error:(NSError * _Nullable * _Nullable)error {
    [self.fileManager removeFile:fileName subDir:[self stringForDataTypeEnum:dataType] error:error];
}

- (void)removeFilesForDataType:(OPTLYDataStoreDataType)dataType
                         error:(NSError * _Nullable * _Nullable)error {
    [self.fileManager removeDataSubDir:[self stringForDataTypeEnum:dataType] error:error];
}

- (void)removeAllFiles:(NSError * _Nullable * _Nullable)error {
    [self.fileManager removeAllFiles:error];
}

# pragma mark - Cached Data Methods
- (void)insertCachedData:(nonnull NSDictionary *)data
               eventType:(OPTLYDataStoreEventType)eventType
{
    NSString *eventTypeName = [self stringForDataEventEnum:eventType];
    OPTLYQueue *queue = self.eventsCache[eventTypeName];
    [queue enqueue:data];
}

- (nullable NSDictionary *)retrieveCachedItem:(OPTLYDataStoreEventType)eventType
{
    NSString *eventTypeName = [self stringForDataEventEnum:eventType];
    OPTLYQueue *queue = self.eventsCache[eventTypeName];
    return [queue front];
}

- (nullable NSArray *)retrieveNCachedItems:(NSInteger)numberOfItems
                                 eventType:(OPTLYDataStoreEventType)eventType
{
    NSString *eventTypeName = [self stringForDataEventEnum:eventType];
    OPTLYQueue *queue = self.eventsCache[eventTypeName];
    return [queue firstNItems:numberOfItems];
}

- (void)removeCachedItem:(OPTLYDataStoreEventType)eventType
{
    NSString *eventTypeName = [self stringForDataEventEnum:eventType];
    OPTLYQueue *queue = self.eventsCache[eventTypeName];
    [queue dequeue];
}

- (void)removeNCachedItem:(NSInteger)numberOfItems
                eventType:(OPTLYDataStoreEventType)eventType
{
    NSString *eventTypeName = [self stringForDataEventEnum:eventType];
    OPTLYQueue *queue = self.eventsCache[eventTypeName];
    [queue dequeueNItems:numberOfItems];
}

- (NSInteger)numberOfCachedItems:(OPTLYDataStoreEventType)eventType
{
    NSString *eventTypeName = [self stringForDataEventEnum:eventType];
    OPTLYQueue *queue = self.eventsCache[eventTypeName];
    return [queue size];
}

# pragma mark - Database Methods (only available on iOS)
#if TARGET_OS_IOS
- (void)createTable:(OPTLYDataStoreEventType)eventType
              error:(NSError * _Nullable * _Nullable)error
{
    NSString *tableName = [self stringForDataEventEnum:eventType];
    [self.database createTable:tableName error:error];
}

- (void)insertData:(nonnull NSDictionary *)data
         eventType:(OPTLYDataStoreEventType)eventType
             error:(NSError * _Nullable * _Nullable)error
{
    NSString *tableName = [self stringForDataEventEnum:eventType];
    [self.database insertData:data table:tableName error:error];
}

- (void)deleteEvent:(nonnull NSString *)entityId
          eventType:(OPTLYDataStoreEventType)eventType
              error:(NSError * _Nullable * _Nullable)error
{
    NSString *tableName = [self stringForDataEventEnum:eventType];
    [self.database deleteEntity:entityId table:tableName error:error];
}

- (void)deleteEvents:(nonnull NSArray *)entityIds
           eventType:(OPTLYDataStoreEventType)eventType
               error:(NSError * _Nullable * _Nullable)error
{
    NSString *tableName = [self stringForDataEventEnum:eventType];
    [self.database deleteEntities:entityIds table:tableName error:error];
}

- (nullable NSArray *)retrieveAllEvents:(OPTLYDataStoreEventType)eventType
                                  error:(NSError * _Nullable * _Nullable)error
{
    NSString *tableName = [self stringForDataEventEnum:eventType];
    return [self.database retrieveAllEntries:tableName error:error];
}

- (nullable NSArray *)retrieveFirstNEvents:(NSInteger)numberOfEntries
                                 eventType:(OPTLYDataStoreEventType)eventType
                                     error:(NSError * _Nullable * _Nullable)error
{
    NSString *tableName = [self stringForDataEventEnum:eventType];
    return [self.database retrieveFirstNEntries:numberOfEntries table:tableName error:error];
}

- (NSInteger)numberOfEvents:(OPTLYDataStoreEventType)eventType
                      error:(NSError * _Nullable * _Nullable)error
{
    NSString *tableName = [self stringForDataEventEnum:eventType];
    return [self.database numberOfRows:tableName error:error];
}
#endif

# pragma mark - Helper Methods
- (NSString *)stringForDataTypeEnum:(OPTLYDataStoreDataType)dataType
{
    NSString *dataTypeString = @"";
    
    switch (dataType) {
        case OPTLYDataStoreDataTypeDatabase:
            dataTypeString = kDatabase;
            break;
        case OPTLYDataStoreDataTypeDatafile:
            dataTypeString = kDatafile;
            break;
        case OPTLYDataStoreDataTypeEventDispatcher:
            dataTypeString = kEventDispatcher;
            break;
        case OPTLYDataStoreDataTypeUserProfile:
            dataTypeString = kUserProfile;
            break;
        default:
            break;
    }
    return dataTypeString;
}

- (NSString *)stringForDataEventEnum:(OPTLYDataStoreEventType)eventType
{
    NSString *eventTypeString = @"";
    
    switch (eventType) {
        case OPTLYDataStoreEventTypeImpression:
            eventTypeString = kOPTLYDataStoreEventTypeImpression;
            break;
        case OPTLYDataStoreEventTypeConversion:
            eventTypeString = kOPTLYDataStoreEventTypeConversion;
            break;
        default:
            break;
    }
    return eventTypeString;
}
@end
