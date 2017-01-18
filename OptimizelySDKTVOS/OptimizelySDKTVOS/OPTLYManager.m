/****************************************************************************
 * Copyright 2017, Optimizely, Inc. and contributors                        *
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

#import <OptimizelySDKCore/OPTLYErrorHandler.h>
#import <OptimizelySDKCore/OPTLYLogger.h>
#import <OptimizelySDKEventDispatcher/OPTLYEventDispatcher.h>
#import <OptimizelySDKDatafileManager/OPTLYDatafileManager.h>
#import <OptimizelySDKShared/OPTLYManagerBuilder.h>
#import <OptimizelySDKUserProfile/OPTLYUserProfile.h>
#import "OPTLYManager.h"

static NSString * const kClientEngine = @"tvos-sdk";

@implementation OPTLYManager

+ (instancetype)init:(OPTLYManagerBuilderBlock)block {
    return [OPTLYManager initWithBuilder:[OPTLYManagerBuilder builderWithBlock:block]];
}

+ (instancetype)initWithBuilder:(OPTLYManagerBuilder *)builder {
    return [[self alloc] initWithBuilder:builder];
}

- (instancetype)init {
    return [self initWithBuilder:nil];
}

- (instancetype)initWithBuilder:(OPTLYManagerBuilder *)builder {
    self = [super init];
    if (self != nil) {
        
        // --- logger ---
        if (!builder.logger) {
            self.logger = [OPTLYLoggerDefault new];
        } else {
            self.logger = builder.logger;
        }
        
        // --- error handler ---
        if (!builder.errorHandler) {
            self.errorHandler = [OPTLYErrorHandlerNoOp new];
        } else {
            self.errorHandler = builder.errorHandler;
        }
        
        // check if the builder is nil
        if (!builder) {
            [self.logger logMessage:OPTLYLoggerMessagesManagerBuilderNotValid
                          withLevel:OptimizelyLogLevelError];
            
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesBuilderInvalid
                                             userInfo:@{NSLocalizedDescriptionKey :
                                                            [NSString stringWithFormat:NSLocalizedString(OPTLYErrorHandlerMessagesManagerBuilderInvalid, nil)]}];
            [self.errorHandler handleError:error];
            
            return nil;
        }
        
        // --- datafile ----
        self.datafile = builder.datafile;
        
        // --- project id ---
        self.projectId = builder.projectId;
        
        // --- datafile manager ---
        if (!builder.datafileManager) {
            // set default datafile manager if no datafile manager is set
            self.datafileManager = [OPTLYDatafileManagerDefault init:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
                builder.projectId = self.projectId;
                builder.errorHandler = self.errorHandler;
                builder.logger = self.logger;
            }];
        } else {
            self.datafileManager = builder.datafileManager;
        }
        
        // --- event dispatcher ---
        if (!builder.eventDispatcher) {
            // set default event dispatcher if no event dispatcher is set
            self.eventDispatcher = [OPTLYEventDispatcherDefault init:^(OPTLYEventDispatcherBuilder * _Nullable builder) {
                builder.logger = self.logger;
            }];
        } else {
            self.eventDispatcher = builder.eventDispatcher;
        }
        
        // --- user profile ---
        if (!builder.userProfile) {
            // set default user profile if no user profile is set
            self.userProfile = [OPTLYUserProfileDefault init:^(OPTLYUserProfileBuilder * _Nullable builder) {
                builder.logger = self.logger;
            }];
        } else {
            self.userProfile = builder.userProfile;
        }
        
        // --- client engine ---
        _clientEngine = kClientEngine;
        
        // --- client version ---
        _clientVersion = OPTIMIZELY_SDK_TVOS_VERSION;
    }
    return self;
}

@end
