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

#import <objc/runtime.h>
#import "OPTLYProjectConfig+tvOS.h"

NSString * const kClientEngine = @"objective-c-sdk-tvOS";

@implementation OPTLYProjectConfig (OptimizelySDKTVOS)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL clientEngineSelector = @selector(clientEngine);
        SEL clientVersionSelector = @selector(clientVersion);
        SEL iOSClientEngineSelector = @selector(iOSclientEngine);
        SEL iOSClientVersionSelector = @selector(iOSclientVersion);
        Method clientEngineMethod = class_getInstanceMethod(self, clientEngineSelector);
        Method clientVersionMethod = class_getInstanceMethod(self, clientVersionSelector);
        Method iOSClientEngineMethod = class_getInstanceMethod(self, iOSClientEngineSelector);
        Method iOSClientVersionMethod = class_getInstanceMethod(self, iOSClientVersionSelector);
        
        BOOL methodAdded;
        
        // replace client engine
        methodAdded = class_addMethod([self class],
                                      clientEngineSelector,
                                      method_getImplementation(iOSClientEngineMethod),
                                      method_getTypeEncoding(iOSClientEngineMethod));
        if (methodAdded) {
            class_replaceMethod([self class],
                                iOSClientEngineSelector,
                                method_getImplementation(clientEngineMethod),
                                method_getTypeEncoding(clientEngineMethod));
        }
        else {
            method_exchangeImplementations(clientEngineMethod, iOSClientEngineMethod);
        }
        
        // replace client version
        methodAdded = class_addMethod([self class],
                                      clientVersionSelector,
                                      method_getImplementation(iOSClientVersionMethod),
                                      method_getTypeEncoding(iOSClientVersionMethod));
        if (methodAdded) {
            class_replaceMethod([self class],
                                iOSClientVersionSelector,
                                method_getImplementation(clientVersionMethod),
                                method_getTypeEncoding(clientVersionMethod));
        }
        else {
            method_exchangeImplementations(clientVersionMethod, iOSClientVersionMethod);
        }
    });
}

- (NSString *)iOSclientEngine {
    return kClientEngine;
}

- (NSString *)iOSclientVersion {
    return OPTIMIZELY_SDK_TVOS_VERSION;
}

@end
