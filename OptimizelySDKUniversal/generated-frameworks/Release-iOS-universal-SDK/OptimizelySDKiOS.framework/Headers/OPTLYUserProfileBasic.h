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

@protocol OPTLYUserProfile <NSObject>

/**
 * Saves a user ID's project-to-experiment-to-variation mapping.
 *
 * @param userId The user id that was used to generate the bucket value.
 * @param experimentId An active experiment for which the user should be bucketed into.
 * @param variationId The bucketed variation key.
 *
 **/
- (void)saveUserId:(nonnull NSString *)userId
      experimentId:(nonnull NSString *)experimentId
       variationId:(nonnull NSString *)variationId;

/**
 * Gets the saved variation for a given user ID, project ID, and experiment key.
 *
 * @param userId The user ID that was used to generate the bucket value.
 * @param experimentId An active experiment which the user was bucketed into.
 * @returns The variation ID that the user was bucketed into for the given project id and experiment key.
 *
 **/
- (nullable NSString *)getVariationIdForUserId:(nonnull NSString *)userId
                                  experimentId:(nonnull NSString *)experimentId;

/**
 * Removes a user ID's project-to-experiment-to-variation mapping.
 *
 * @param userId The user ID that was used to generate the bucket value.
 * @param experimentId An active experiment for which the user should be bucketed into.
 *
 **/
- (void)removeUserId:(nonnull NSString *)userId
        experimentId:(nonnull NSString *)experimentId;

@end

@interface OPTLYUserProfileUtility : NSObject
/**
 * Utility method to check if a class conforms to the OPTLYUserProfile protocol
 * This method uses compile and run time checks
 */
+ (BOOL)conformsToOPTLYUserProfileProtocol:(nonnull Class)instanceClass;
@end

/**
 * OPTLYUserProfileNoOp comforms to the OPTLYUserProfile protocol,
 * but all methods perform a no op.
 */
@interface OPTLYUserProfileNoOp : NSObject <OPTLYUserProfile>
@end
