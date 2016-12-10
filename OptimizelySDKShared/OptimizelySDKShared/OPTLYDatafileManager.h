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
#import <OptimizelySDKCore/OPTLYHTTPRequestManager.h>

@protocol OPTLYErrorHandler, OPTLYLogger;
@protocol OPTLYDatafileManager <NSObject>

/**
 * Retrieve the datafile that is currently saved on the device.
 * @return NSData object that should be the most recently downloaded datafile.
 *      Will be nil if no datafile has been successfully downloaded.
 */
- (NSData * _Nullable)getSavedDatafile;

/**
 * Download the datafile for the project ID
 * @param projectId The project ID of the datafile to request.
 * @param completion Completion handler.
 */
- (void)downloadDatafile:(nonnull NSString *)projectId
       completionHandler:(nullable void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion;

@end

@interface OPTLYDatafileManagerUtility : NSObject

/**
 * Utility method to check if a class conforms to the OPTLYDatafileManager protocol
 * This method uses compile and run time checks
 */
+ (BOOL)conformsToOPTLYDatafileManagerProtocol:(nonnull Class)instanceClass;

@end

@interface OPTLYDatafileManagerBasic : NSObject<OPTLYDatafileManager>

@end

@interface OPTLYDatafileManagerNoOp : NSObject<OPTLYDatafileManager>

@end
