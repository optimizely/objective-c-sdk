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

/** This describes the type of file
 */
typedef NS_ENUM (NSUInteger, OPTLYFileManagerDataType) {
    OPTLYFileManagerDataTypeDatafile,
    OPTLYFileManagerDataTypeUserProfile,
    OPTLYFileManagerDataTypeEventDispatcher,
    OPTLYFileManagerDataTypePreview,
    OPTLYFileManagerDataTypeEditor,
};

@interface OPTLYFileManager : NSObject
/**
 * Saves a document file.
 * If a file of the same name type exists already, then that file will be overwritten.
 *
 * @param fileName A string that represents the name of the file to save.
 * @param data The data to dave to file.
 * @param fileType The type of file (e.g., datafile, user profile, event dispatcher, preview, editor)
 * @param error An error object which will store any errors if the file save fails.
 *  If error is nil, than the file save was successful.
 *
 **/
- (void)saveFile:(nonnull NSString *)fileName
            data:(nonnull NSData *)data
            type:(OPTLYFileManagerDataType)fileType
           error:(NSError * _Nullable * _Nullable)error;

/**
 * Gets a document file.
 *
 * @param fileName A string that represents the name of the file to retrieve.
 * @param fileType The type of file (e.g., datafile, user profile, event dispatcher, preview, editor)
 * @return The file in NSData format.
 * @param error An error object which will store any errors if the file save fails.
 *  If error is nil, than the file save was successful.
 *
 **/
- (nullable NSData *)getFile:(nonnull NSString *)fileName
                        type:(OPTLYFileManagerDataType)fileType
                       error:(NSError * _Nullable * _Nullable)error;

/**
 * Deterimes if a file exists in the documents directory.
 *
 * @param fileName A string that represents the name of the file to check.
 * @param fileType The type of file (e.g., datafile, user profile, event dispatcher, preview, editor)
 * @return A boolean value that states if a file exists or not (or could not be determined).
 *
 **/
- (bool)fileExists:(nonnull NSString *)fileName
              type:(OPTLYFileManagerDataType)fileType;

/**
 * Deletes a document file.
 *
 * @param fileName A string that represents the name of the file to delete.
 * @param fileType The type of file (e.g., datafile, user profile, event dispatcher, preview, editor)
 * @param error An error object which will store any errors if the file deletion fails.
 *  If error is nil, than the file deletion was successful.
 *
 **/
- (void)removeFile:(nonnull NSString *)fileName
              type:(OPTLYFileManagerDataType)fileType
             error:(NSError * _Nullable * _Nullable)error;

@end
