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

#import "OPTLYUserProfileBasic.h"

@implementation OPTLYUserProfileUtility

+ (BOOL)conformsToOPTLYUserProfileProtocol:(nonnull Class)instanceClass {
    // compile-time check
    BOOL isValidProtocolDeclaration = [instanceClass conformsToProtocol:@protocol(OPTLYUserProfile)];
    
    // runtime checks
    BOOL implementsHandleSaveVariationMethod = [instanceClass instancesRespondToSelector:@selector(saveUserId:experimentId:variationId:)];
    BOOL implementsHandleGetVariationMethod = [instanceClass instancesRespondToSelector:@selector(getVariationIdForUserId:experimentId:)];
    BOOL implementsHandleRemoveVariationMethod = [instanceClass instancesRespondToSelector:@selector(removeUserId:experimentId:)];
    
    return isValidProtocolDeclaration && implementsHandleSaveVariationMethod && implementsHandleGetVariationMethod && implementsHandleRemoveVariationMethod;
}

@end

@implementation OPTLYUserProfileNoOp

- (void)saveUserId:(nonnull NSString *)userId
      experimentId:(nonnull NSString *)experimentId
       variationId:(nonnull NSString *)variationId {
    return;
}

- (nullable NSString *)getVariationIdForUserId:(nonnull NSString *)userId
                                  experimentId:(nonnull NSString *)experimentId {
    return nil;
}

- (void)removeUserId:(nonnull NSString *)userId
        experimentId:(nonnull NSString *)experimentId {
    return;
}

@end
