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

#import "OPTLYUserProfile.h"

@implementation OPTLYUserProfileUtility

+ (BOOL)conformsToOPTLYUserProfileProtocol:(nonnull Class)instanceClass {
    // compile-time check
    BOOL isValidProtocolDeclaration = [instanceClass conformsToProtocol:@protocol(OPTLYUserProfile)];
    
    // runtime checks
    BOOL implementsHandleSaveVariationMethod = [instanceClass instancesRespondToSelector:@selector(saveUser:experiment:variation:)];
    BOOL implementsHandleGetVariationMethod = [instanceClass instancesRespondToSelector:@selector(getVariationForUser:experiment:)];
    BOOL implementsHandleRemoveVariationMethod = [instanceClass instancesRespondToSelector:@selector(removeUser:experiment:)];
    
    return isValidProtocolDeclaration && implementsHandleSaveVariationMethod && implementsHandleGetVariationMethod && implementsHandleRemoveVariationMethod;
}

@end

@implementation OPTLYUserProfileNoOp

- (void)saveUser:(nonnull NSString *)userId
      experiment:(nonnull NSString *)experimentKey
       variation:(nonnull NSString *)variationKey {
    return;
}

- (nullable NSString *)getVariationForUser:(nonnull NSString *)userId
                                experiment:(nonnull NSString *)experimentKey {
    return nil;
}

- (void)removeUser:(nonnull NSString *)userId
        experiment:(nonnull NSString *)experimentKey {
    return;
}

@end
