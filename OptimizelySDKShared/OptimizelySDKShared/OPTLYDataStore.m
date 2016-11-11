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

@interface OPTLYDataStore()
@property (nonatomic, strong) OPTLYFileManager *fileManager;
#if TARGET_OS_IOS
@property (nonatomic, strong) OPTLYDatabase *database;
#endif
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

#if TARGET_OS_IOS
- (OPTLYDatabase *)database
{
    if (!_database) {
        NSString *databaseDirectory = [self.baseDirectory stringByAppendingPathComponent:[self stringForDataTypeEnum:OPTLYDataStoreDataTypeDatabase]];
        _database = [[OPTLYDatabase alloc] initWithBaseDir:databaseDirectory];
    }
    return _database;
}
#endif

# pragma mark - File Manager Methods
- (void)saveFile:(nonnull NSString *)fileName
            data:(nonnull NSData *)data
            type:(OPTLYDataStoreDataType)fileType
           error:(NSError * _Nullable * _Nullable)error {
    [self.fileManager saveFile:fileName data:data subDir:[self stringForDataTypeEnum:fileType] error:error];
}

- (nullable NSData *)getFile:(nonnull NSString *)fileName
                        type:(OPTLYDataStoreDataType)fileType
                       error:(NSError * _Nullable * _Nullable)error {
    return [self.fileManager getFile:fileName subDir:[self stringForDataTypeEnum:fileType] error:error];
}

- (bool)fileExists:(nonnull NSString *)fileName
              type:(OPTLYDataStoreDataType)fileType {
    return [self.fileManager fileExists:fileName subDir:[self stringForDataTypeEnum:fileType]];
}

- (void)removeFile:(nonnull NSString *)fileName
              type:(OPTLYDataStoreDataType)fileType
             error:(NSError * _Nullable * _Nullable)error {
    [self.fileManager removeFile:fileName subDir:[self stringForDataTypeEnum:fileType] error:error];
}

- (void)removeDataType:(OPTLYDataStoreDataType)fileType
                 error:(NSError * _Nullable * _Nullable)error {
    [self.fileManager removeDataSubDir:[self stringForDataTypeEnum:fileType] error:error];
}

- (void)removeAllData:(NSError * _Nullable * _Nullable)error {
    [self.fileManager removeAllData:error];
}

# pragma mark - Database Methods (only available on iOS)
#if TARGET_OS_IOS
- (void)insertData:(nonnull NSDictionary *)data
             table:(nonnull NSString *)tableName
             error:(NSError * _Nullable * _Nullable)error
{
    [self.database insertData:data table:tableName error:error];
}

- (void)deleteEntity:(nonnull NSString *)entityId
               table:(nonnull NSString *)tableName
               error:(NSError * _Nullable * _Nullable)error
{
    [self.database deleteEntity:entityId table:tableName error:error];
}

- (void)deleteEntities:(nonnull NSArray *)entityIds
                 table:(nonnull NSString *)tableName
                 error:(NSError * _Nullable * _Nullable)error
{
    [self.database deleteEntities:entityIds table:tableName error:error];
}

- (nullable NSArray *)retrieveAllEntries:(nonnull NSString *)tableName
                                   error:(NSError * _Nullable * _Nullable)error
{
    return [self.database retrieveAllEntries:tableName error:error];
}

- (nullable NSArray *)retrieveFirstNEntries:(NSInteger)numberOfEntries
                                      table:(nonnull NSString *)tableName
                                      error:(NSError * _Nullable * _Nullable)error
{
    return [self.database retrieveFirstNEntries:numberOfEntries table:tableName error:error];
}

- (NSInteger)numberOfRows:(nonnull NSString *)tableName
                    error:(NSError * _Nullable * _Nullable)error
{
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
            dataTypeString = kUserProfile;
            break;
        case OPTLYDataStoreDataTypeUserProfile:
            dataTypeString = kEventDispatcher;
            break;
        default:
            break;
    }
    
    return dataTypeString;
}
@end
