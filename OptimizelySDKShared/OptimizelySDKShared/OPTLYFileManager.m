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

#import "OPTLYFileManager.h"

static NSString * const kOptimizelyDatafilePathSuffix = @"optimizely";

// file manager data types
static NSString * const kOPTLYFileManagerDataTypeDatafile = @"datafile";
static NSString * const kOPTLYFileManagerDataTypeUserProfile = @"user-profile";
static NSString * const kOPTLYFileManagerDataTypeEventDispatcher = @"event-dispatcher";
static NSString * const kOPTLYFileManagerDataTypePreview = @"preview";
static NSString * const kOPTLYFileManagerDataTypeEditor = @"editor";

@interface OPTLYFileManager()
@property (nonatomic, strong) NSString *baseDir;
@end

@implementation OPTLYFileManager

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        NSArray *libraryDirPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        _baseDir = [libraryDirPaths[0] stringByAppendingPathComponent:kOptimizelyDatafilePathSuffix];
    }
    return self;
}

- (void)saveFile:(nonnull NSString *)fileName
            data:(nonnull NSData *)data
            type:(OPTLYFileManagerDataType)fileType
           error:(NSError * _Nullable * _Nullable)error
{
    NSString *fileDir = [self.baseDir stringByAppendingPathComponent:[self stringForDataTypeEnum:fileType]];
    NSString *filePath = [self filePathFor:fileName type:fileType];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    bool isDir = true;
    if (![fileManager fileExistsAtPath:fileDir isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:error];
    }
    [fileManager createFileAtPath:filePath contents:data attributes:nil];
}


- (nullable NSData *)getFile:(nonnull NSString *)fileName
                        type:(OPTLYFileManagerDataType)fileType
                       error:(NSError * _Nullable * _Nullable)error
{
    NSString *filePath = [self filePathFor:fileName type:fileType];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath options:0 error:error];
    
    return fileData;
}


- (bool)fileExists:(nonnull NSString *)fileName
              type:(OPTLYFileManagerDataType)fileType
{
    NSString *filePath = [self filePathFor:fileName type:fileType];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    bool fileExists = [fileManager fileExistsAtPath:filePath];
    return fileExists;
}


- (void)removeFile:(nonnull NSString *)fileName
              type:(OPTLYFileManagerDataType)fileType
             error:(NSError * _Nullable * _Nullable)error
{
    NSString *filePath = [self filePathFor:fileName type:fileType];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:error];
}

- (void)removeAllFiles:(NSError * _Nullable * _Nullable)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:self.baseDir error:error];
}
# pragma mark - Helper Methods

- (NSString *)filePathFor:(NSString *)fileName
                     type:(OPTLYFileManagerDataType)fileType
{
    NSString *fileDir = [self.baseDir stringByAppendingPathComponent:[self stringForDataTypeEnum:fileType]];
    NSString *filePath = [fileDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", fileName]];
    return filePath;
}

- (NSString *)stringForDataTypeEnum:(OPTLYFileManagerDataType)dataType
{
    NSString *dataTypeString = @"";
    
    switch (dataType) {
        case OPTLYFileManagerDataTypeDatafile:
            dataTypeString = kOPTLYFileManagerDataTypeDatafile;
            break;
        case OPTLYFileManagerDataTypeUserProfile:
            dataTypeString = kOPTLYFileManagerDataTypeUserProfile;
            break;
        case OPTLYFileManagerDataTypeEventDispatcher:
            dataTypeString = kOPTLYFileManagerDataTypeEventDispatcher;
            break;
        case OPTLYFileManagerDataTypePreview:
            dataTypeString = kOPTLYFileManagerDataTypePreview;
            break;
        case OPTLYFileManagerDataTypeEditor:
            dataTypeString = kOPTLYFileManagerDataTypeEditor;
            break;
    }
    
    return dataTypeString;
}

@end
