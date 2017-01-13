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
#import <OptimizelySDKCore/OPTLYEventDispatcher.h>
#import <OptimizelySDKCore/OPTLYLogger.h>
#import <OptimizelySDKCore/OPTLYLoggerMessages.h>
#import <OptimizelySDKCore/OPTLYNetworkService.h>
#import "OPTLYClient.h"
#import "OPTLYDatafileManager.h"
#import "OPTLYManagerBasic.h"
#import "OPTLYManagerBuilder.h"

@implementation OPTLYManagerBasic

+ (instancetype)init:(OPTLYManagerBuilderBlock)block {
    return [OPTLYManagerBasic initWithBuilder:[OPTLYManagerBuilder builderWithBlock:block]];
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
            self.datafileManager = [[OPTLYDatafileManagerBasic alloc] init];
        } else {
            self.datafileManager = builder.datafileManager;
        }
        
        // --- event dispatcher ---
        if (!builder.eventDispatcher) {
            // set default event dispatcher if no event dispatcher is set
            self.eventDispatcher = [[OPTLYEventDispatcherBasic alloc] init];
        } else {
            self.eventDispatcher = builder.eventDispatcher;
        }
        
        // --- user profile ---
        if (builder.userProfile) {
            self.userProfile = builder.userProfile;
        }
        
        // --- client engine ---
        if (builder.clientEngine) {
            self.clientEngine = builder.clientEngine;
        }
        
        // --- client version ---
        if (builder.clientVersion) {
            self.clientVersion = builder.clientVersion;
        }
        
    }
    return self;
}

@end
