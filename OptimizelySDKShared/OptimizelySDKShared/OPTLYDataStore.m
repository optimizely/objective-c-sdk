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

#import <OptimizelySDKCore/OPTLYLogger.h>
#import <OptimizelySDKCore/OPTLYQueue.h>
#import "OPTLYDataStore.h"
#import "OPTLYEventDataStore.h"
#import "OPTLYFileManager.h"

static NSString * const kOptimizelyDirectory = @"optimizely";

// data type names
static NSString * const kDatabase = @"database";
static NSString * const kDatafile = @"datafile";
static NSString * const kUserProfile = @"user-profile";
static NSString * const kEventDispatcher = @"event-dispatcher";

// table names
static NSString *const kOPTLYDataStoreEventTypeImpression = @"events_impression";
static NSString *const kOPTLYDataStoreEventTypeConversion = @"events_conversion";

@interface OPTLYDataStore()
@property (nonatomic, strong) OPTLYFileManager *fileManager;
@property (nonatomic, strong) id<OPTLYEventDataStore> eventDataStore;
@end

@implementation OPTLYDataStore

- (nullable instancetype)initWithLogger:(nullable id<OPTLYLogger>)logger
{
    self = [self init];
    if (self) {
        if (logger) {
            _logger = logger;
        }
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        NSString *filePath = @"";
        NSError *initError = nil;
#if TARGET_OS_IOS
        NSArray *libraryDirPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        filePath = libraryDirPaths[0];
        _baseDirectory = [filePath stringByAppendingPathComponent:kOptimizelyDirectory];
        _eventDataStore = [[OPTLYEventDataStoreiOS alloc] initWithBaseDir:_baseDirectory error:&initError];
#elif TARGET_OS_TV
        // tvOS only allows writing to a temporary file directory
        // a future enhancement would be save to iCloud
        filePath = NSTemporaryDirectory();
        _baseDirectory = [filePath stringByAppendingPathComponent:kOptimizelyDirectory];
        _eventDataStore = [[OPTLYEventDataStoreTVOS alloc] initWithBaseDir:_baseDirectory error:&initError];
#endif
        
        if (initError) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDataStoreDatabaseEventDataStoreError, initError];
            [_logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        }
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
    [self removeEventsStorage:error];
    [self removeAllFiles:error];
}

# pragma mark - NSUserDefault Data
- (void)saveUserData:(nonnull NSDictionary *)data type:(OPTLYDataStoreDataType)dataType
{
    NSString *key = [OPTLYDataStore stringForDataTypeEnum:dataType];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:key];
}

- (nullable NSDictionary *)getUserDataForType:(OPTLYDataStoreDataType)dataType
{
    NSString *key = [OPTLYDataStore stringForDataTypeEnum:dataType];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *data = [defaults objectForKey:key];
    return data;
}

- (void)removeUserDataForType:(OPTLYDataStoreDataType)dataType
{
    NSString *key = [OPTLYDataStore stringForDataTypeEnum:dataType];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:key];
}

- (void)removeObjectInUserData:(nonnull id)dataKey type:(OPTLYDataStoreDataType)dataType
{
    NSString *key = [OPTLYDataStore stringForDataTypeEnum:dataType];
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
           error:(NSError * _Nullable * _Nullable)error
{
    [self.fileManager saveFile:fileName data:data subDir:[OPTLYDataStore stringForDataTypeEnum:dataType] error:error];
    if (error && *error) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDataStoreFileManagerSaveFile, dataType, fileName, *error];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
}

- (nullable NSData *)getFile:(nonnull NSString *)fileName
                        type:(OPTLYDataStoreDataType)dataType
                       error:(NSError * _Nullable * _Nullable)error
{
    NSData *fileData = [self.fileManager getFile:fileName subDir:[OPTLYDataStore stringForDataTypeEnum:dataType] error:error];
    if (error && *error) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDataStoreFileManagerGetFile, dataType, fileName, *error];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return fileData;
}

- (bool)fileExists:(nonnull NSString *)fileName
              type:(OPTLYDataStoreDataType)dataType
{
    return [self.fileManager fileExists:fileName subDir:[OPTLYDataStore stringForDataTypeEnum:dataType]];
}

- (bool)dataTypeExists:(OPTLYDataStoreDataType)dataType
{
    return [self.fileManager subDirExists:[OPTLYDataStore stringForDataTypeEnum:dataType]];
}

- (void)removeFile:(nonnull NSString *)fileName
              type:(OPTLYDataStoreDataType)dataType
             error:(NSError * _Nullable * _Nullable)error
{
    [self.fileManager removeFile:fileName subDir:[OPTLYDataStore stringForDataTypeEnum:dataType] error:error];
    if (error && *error) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDataStoreFileManagerRemoveFileForDataTypeError, dataType, fileName, *error];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
}

- (void)removeFilesForDataType:(OPTLYDataStoreDataType)dataType
                         error:(NSError * _Nullable * _Nullable)error
{
    [self.fileManager removeDataSubDir:[OPTLYDataStore stringForDataTypeEnum:dataType] error:error];
    if (error && *error) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDataStoreFileManagerRemoveFilesForDataTypeError, dataType, *error];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
}

- (void)removeAllFiles:(NSError * _Nullable * _Nullable)error
{
    [self.fileManager removeAllFiles:error];
    self.fileManager = nil;
    if (error && *error) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDataStoreFileManagerRemoveAllFilesError, *error];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
}

# pragma mark - Event Storage Methods

- (void)saveEvent:(nonnull NSDictionary *)data
        eventType:(OPTLYDataStoreEventType)eventType
            error:(NSError * _Nullable * _Nullable)error
{
    NSString *eventTypeName = [OPTLYDataStore stringForDataEventEnum:eventType];
    [self.eventDataStore saveEvent:data eventType:eventTypeName error:error];
    if (error && *error) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDataStoreDatabaseSaveError, data, eventTypeName, *error];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
}

- (nullable NSArray *)getFirstNEvents:(NSInteger)numberOfEvents
                            eventType:(OPTLYDataStoreEventType)eventType
                                error:(NSError * _Nullable * _Nullable)error
{
    NSString *eventTypeName = [OPTLYDataStore stringForDataEventEnum:eventType];
    NSArray *firstNEvents = [self.eventDataStore getFirstNEvents:numberOfEvents eventType:eventTypeName error:error];
    
    if (error && *error) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDataStoreDatabaseGetError, numberOfEvents, eventTypeName, *error];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    
    return firstNEvents;
}

- (nullable NSDictionary *)getOldestEvent:(OPTLYDataStoreEventType)eventType
                                    error:(NSError * _Nullable * _Nullable)error
{
    NSDictionary *oldestEvent = nil;
    NSArray *oldestEvents = [self getFirstNEvents:1 eventType:eventType error:error];
    
    if ([oldestEvents count] <= 0) {
        NSString *eventTypeName = [OPTLYDataStore stringForDataEventEnum:eventType];
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDataStoreDatabaseGetNoEvents, eventTypeName];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
    } else {
        oldestEvent = oldestEvents[0];
    }
    
    return oldestEvent;
}

- (nullable NSArray *)getAllEvents:(OPTLYDataStoreEventType)eventType
                             error:(NSError * _Nullable * _Nullable)error
{
    NSInteger numberOfEvents = [self numberOfEvents:eventType error:error];
    NSArray *allEvents = [self getFirstNEvents:numberOfEvents eventType:eventType error:error];
    return allEvents;
}

- (void)removeFirstNEvents:(NSInteger)numberOfEvents
                 eventType:(OPTLYDataStoreEventType)eventType
                     error:(NSError * _Nullable * _Nullable)error
{
    NSString *eventTypeName = [OPTLYDataStore stringForDataEventEnum:eventType];
    [self.eventDataStore removeFirstNEvents:numberOfEvents eventType:eventTypeName error:error];
    
    if (error && *error) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDataStoreDatabaseRemoveError, numberOfEvents, eventTypeName, *error];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
}

- (void)removeOldestEvent:(OPTLYDataStoreEventType)eventType
                    error:(NSError * _Nullable * _Nullable)error
{
    [self removeFirstNEvents:1 eventType:eventType error:error];
}

- (void)removeAllEvents:(OPTLYDataStoreEventType)eventType
                  error:(NSError * _Nullable * _Nullable)error
{
    NSInteger numberOfEvents = [self numberOfEvents:eventType error:error];
    [self removeFirstNEvents:numberOfEvents eventType:eventType error:error];
}

- (void)removeEvent:(nonnull NSDictionary *)event
          eventType:(OPTLYDataStoreEventType)eventType
              error:(NSError * _Nullable * _Nullable)error
{
    NSString *eventTypeName = [OPTLYDataStore stringForDataEventEnum:eventType];
    [self.eventDataStore removeEvent:event eventType:eventTypeName error:error];
    
    if (error && *error) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDataStoreDatabaseRemoveEventError, *error, eventTypeName, event];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
}

- (NSInteger)numberOfEvents:(OPTLYDataStoreEventType)eventType
                      error:(NSError * _Nullable * _Nullable)error
{
    NSString *eventTypeName = [OPTLYDataStore stringForDataEventEnum:eventType];
    NSInteger numberOfEvents = [self.eventDataStore numberOfEvents:eventTypeName error:error];
    
    if (error && *error) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDataStoreDatabaseGetNumberEvents, eventTypeName, *error];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    
    return numberOfEvents;
}

- (void)removeAllEvents:(NSError * _Nullable * _Nullable)error {
    for (NSInteger i = 0; i <= OPTLYDataStoreEventTypeConversion; ++i ) {
        [self removeAllEvents:i error:error];
    }
    
    [self.logger logMessage:OPTLYLoggerMessagesDataStoreEventsRemoveAllWarning withLevel:OptimizelyLogLevelDebug];
}

// removes all events, including the data structures that store the events
- (void)removeEventsStorage:(NSError * _Nullable * _Nullable)error
{
    [self removeAllEvents:error];
    self.eventDataStore = nil;
}

# pragma mark - Helper Methods

+ (NSString *)stringForDataTypeEnum:(OPTLYDataStoreDataType)dataType
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

+ (NSString *)stringForDataEventEnum:(OPTLYDataStoreEventType)eventType
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
