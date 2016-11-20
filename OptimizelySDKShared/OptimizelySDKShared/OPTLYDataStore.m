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
@property (nonatomic, strong) NSCache *eventsCache;
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

- (void)removeAll:(NSError * _Nullable * _Nullable)error {
    [self removeAllUserData];
    [self removeAllEvents:error];
    [self removeAllFiles:error];
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

- (NSCache *)eventsCache {
    if (!_eventsCache) {
        _eventsCache = [NSCache new];
        [_eventsCache setObject:[OPTLYQueue new] forKey:kOPTLYDataStoreEventTypeImpression];
        [_eventsCache setObject:[OPTLYQueue new] forKey:kOPTLYDataStoreEventTypeConversion];
    }
    return _eventsCache;
}

# pragma mark - NSUserDefault Data
- (void)saveUserData:(nonnull NSDictionary *)data type:(OPTLYDataStoreDataType)dataType
{
    NSString *key = [self stringForDataTypeEnum:dataType];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:key];
}

- (nullable NSDictionary *)getUserDataForType:(OPTLYDataStoreDataType)dataType
{
    NSString *key = [self stringForDataTypeEnum:dataType];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *data = [defaults objectForKey:key];
    return data;
}

- (void)removeUserDataForType:(OPTLYDataStoreDataType)dataType
{
    NSString *key = [self stringForDataTypeEnum:dataType];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:key];
}

- (void)removeObjectInUserData:(nonnull id)dataKey type:(OPTLYDataStoreDataType)dataType
{
    NSString *key = [self stringForDataTypeEnum:dataType];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *data = [[defaults objectForKey:key] mutableCopy];
    [data removeObjectForKey:dataKey];
    [defaults setObject:data forKey:key];
}

- (void)removeAllUserData
{
    for (NSInteger i = 0; i <= OPTLYDataStoreDataTypeUserProfile; ++i) {
        [self removeUserDataForType:i];
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
    self.fileManager = nil;
}

# pragma mark - Event Storage Methods

// SQLite tables are only available for iOS
#if TARGET_OS_IOS
- (void)createTable:(OPTLYDataStoreEventType)eventType
              error:(NSError * _Nullable * _Nullable)error
{
    NSString *tableName = [self stringForDataEventEnum:eventType];
    [self.database createTable:tableName error:error];
}
#endif

- (void)saveData:(nonnull NSDictionary *)data
       eventType:(OPTLYDataStoreEventType)eventType
      cachedData:(bool)cachedData
           error:(NSError * _Nullable * _Nullable)error
{
    // tvOS can only save to cached data
#if TARGET_OS_TV
    if (!cachedData) {
        NSString *usageWarning = @"tvOS can only save to cached data.";
        OPTLYLogInfo(usageWarning);
    }
#endif
    
    NSString *eventTypeName = [self stringForDataEventEnum:eventType];
    if (cachedData) {
        OPTLYQueue *queue = [self.eventsCache objectForKey:eventTypeName];
        [queue enqueue:data];
    } else {
#if TARGET_OS_IOS
        [self.database saveData:data table:eventTypeName error:error];
#endif
    }
}

- (nullable NSArray *)getFirstNEvents:(NSInteger)numberOfEvents
                            eventType:(OPTLYDataStoreEventType)eventType
                           cachedData:(bool)cachedData
                                error:(NSError * _Nullable * _Nullable)error
{
    // tvOS can only read from cached data
#if TARGET_OS_TV
    if (!cachedData) {
        NSString *usageWarning = @"tvOS can only read from cached data.";
        OPTLYLogInfo(usageWarning);
    }
#endif
    
    NSMutableArray *firstNEvents = [NSMutableArray new];
    NSString *eventTypeName = [self stringForDataEventEnum:eventType];
    if (cachedData) {
        OPTLYQueue *queue = [self.eventsCache objectForKey:eventTypeName];
        [firstNEvents addObjectsFromArray:[queue firstNItems:numberOfEvents]];
    } else {
#if TARGET_OS_IOS
        NSArray *firstNEntities = [self.database retrieveFirstNEntries:numberOfEvents table:eventTypeName error:error];
        for (OPTLYDatabaseEntity *entity in firstNEntities) {
            NSString *entityValue = entity.entityValue;
            NSDictionary *event = [NSJSONSerialization JSONObjectWithData:[entityValue dataUsingEncoding:NSUTF8StringEncoding] options:0 error:error];
            [firstNEvents addObject:event];
        }
#endif
    }
    return firstNEvents;
}

- (nullable NSDictionary *)getOldestEvent:(OPTLYDataStoreEventType)eventType
                               cachedData:(bool)cachedData
                                    error:(NSError * _Nullable * _Nullable)error
{
    NSDictionary *oldestEvent = nil;
    NSArray *oldestEvents = [self getFirstNEvents:1 eventType:eventType cachedData:cachedData error:error];
    
    if ([oldestEvents count] <= 0) {
        OPTLYLogInfo(@"No event(s).");
    } else {
        oldestEvent = oldestEvents[0];
    }
    
    return oldestEvent;
}

- (nullable NSArray *)getAllEvents:(OPTLYDataStoreEventType)eventType
                        cachedData:(bool)cachedData
                             error:(NSError * _Nullable * _Nullable)error
{
    NSInteger numberOfEvents = [self numberOfEvents:eventType cachedData:cachedData error:error];
    NSArray *allEvents = [self getFirstNEvents:numberOfEvents eventType:eventType cachedData:cachedData error:error];
    return allEvents;
}

- (void)removeFirstNEvents:(NSInteger)numberOfEvents
                 eventType:(OPTLYDataStoreEventType)eventType
                cachedData:(bool)cachedData
                     error:(NSError * _Nullable * _Nullable)error
{
    // tvOS can only delete from cached data
#if TARGET_OS_TV
    if (!cachedData) {
        NSString *usageWarning = @"tvOS can only read from cached data.";
        OPTLYLogInfo(usageWarning);
    }
#endif
    
    NSString *eventTypeName = [self stringForDataEventEnum:eventType];
    if (cachedData) {
        OPTLYQueue *queue = [self.eventsCache objectForKey:eventTypeName];
        [queue dequeueNItems:numberOfEvents];
    } else {
        // only iOS can delete from the database table
#if TARGET_OS_IOS
        NSArray *firstNEvents = [self.database retrieveFirstNEntries:numberOfEvents table:eventTypeName error:error];
        if ([firstNEvents count] <= 0) {
            OPTLYLogInfo(@"No event(s) to delete.");
            return;
        }
        
        NSMutableArray *entityIds = [NSMutableArray new];
        for (OPTLYDatabaseEntity *entity in firstNEvents) {
            NSString *entityId = [entity.entityId stringValue];
            [entityIds addObject:entityId];
        }
        [self.database deleteEntities:entityIds table:eventTypeName error:error];
#endif
    }
}

- (void)removeOldestEvent:(OPTLYDataStoreEventType)eventType
               cachedData:(bool)cachedData
                    error:(NSError * _Nullable * _Nullable)error
{
    [self removeFirstNEvents:1 eventType:eventType cachedData:cachedData error:error];
}

- (void)removeAllEvents:(OPTLYDataStoreEventType)eventType
             cachedData:(bool)cachedData
                  error:(NSError * _Nullable * _Nullable)error
{
    NSInteger numberOfEvents = [self numberOfEvents:eventType cachedData:cachedData error:error];
    [self removeFirstNEvents:numberOfEvents eventType:eventType cachedData:cachedData error:error];
}


- (NSInteger)numberOfEvents:(OPTLYDataStoreEventType)eventType
                 cachedData:(bool)cachedData
                      error:(NSError * _Nullable * _Nullable)error
{
    NSInteger numberOfEvents = 0;
    // tvOS can only read from cached data
#if TARGET_OS_TV
    if (!cachedData) {
        OPTLYLogInfo(@"tvOS can only read from cached data.");
    }
#endif
    
    NSString *eventTypeName = [self stringForDataEventEnum:eventType];
    if (cachedData) {
        OPTLYQueue *queue = [self.eventsCache objectForKey:eventTypeName];
        numberOfEvents = [queue size];
    } else {
        // only iOS can read from the database table
#if TARGET_OS_IOS
        numberOfEvents = [self.database numberOfRows:eventTypeName error:error];
#endif
    }
    return numberOfEvents;
}

- (void)removeSavedEvents:(BOOL)cachedData
                    error:(NSError * _Nullable * _Nullable)error {
    for (NSInteger i = 0; i <= OPTLYDataStoreEventTypeConversion; ++i ) {
        [self removeAllEvents:i cachedData:cachedData error:error];
    }
}

- (void)removeAllEvents:(NSError * _Nullable * _Nullable)error {
    [self removeSavedEvents:YES error:error];
    [self removeSavedEvents:NO error:error];
#if TARGET_OS_IOS
    [self.database deleteDatabase:error];
    self.database = nil;
#endif
}

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
