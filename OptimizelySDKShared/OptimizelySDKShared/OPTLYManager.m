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

#import <OptimizelySDKCore/OPTLYErrorHandler.h>
#import <OptimizelySDKCore/OPTLYLogger.h>
#import <OptimizelySDKCore/OPTLYLoggerMessages.h>
#import <OptimizelySDKShared/OPTLYManagerBuilder.h>
#import <OptimizelySDKCore/OPTLYNetworkService.h>
#import "OPTLYClient.h"
#import "OPTLYDatafileManager.h"
#import "OPTLYManager.h"
#import "OPTLYManagerBuilder.h"

@interface OPTLYManager()
@property (strong, readwrite, nonatomic, nullable) OPTLYClient *optimizelyClient;
@end

@implementation OPTLYManager

+ (instancetype)initWithBuilderBlock:(OPTLYManagerBuilderBlock)block {
    return [[self alloc] initWithBuilder:[OPTLYManagerBuilder builderWithBlock:block]];
}

- (instancetype)init {
    return [self initWithBuilder:nil];
}

- (instancetype)initWithBuilder:(OPTLYManagerBuilder *)builder {
    if (builder != nil) {
        self = [super init];
        if (self != nil) {
            if (builder.projectId == nil) {
                [builder.logger logMessage:OPTLYLoggerMessagesManagerMustBeInitializedWithProjectId
                                 withLevel:OptimizelyLogLevelError];
                return nil;
            }
            _datafile = builder.datafile;
            _datafileManager = builder.datafileManager;
            _errorHandler = builder.errorHandler;
            _eventDispatcher = builder.eventDispatcher;
            _logger = builder.logger;
            _projectId = builder.projectId;
            _userProfile = builder.userProfile;
        }
        return self;
    }
    else {
        if (_logger == nil) {
            _logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelAll];
        }
        [_logger logMessage:OPTLYLoggerMessagesManagerBuilderNotValid
                  withLevel:OptimizelyLogLevelError];
        
        NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesBuilderInvalid
                                         userInfo:@{NSLocalizedDescriptionKey :
                                                        [NSString stringWithFormat:NSLocalizedString(OPTLYErrorHandlerMessagesManagerBuilderInvalid, nil)]}];
        
        if (_errorHandler == nil) {
            _errorHandler = [[OPTLYErrorHandlerNoOp alloc] init];
        }
        [_errorHandler handleError:error];
        return nil;
    }
}

- (OPTLYClient *)initializeClient {
    OPTLYClient *client = [self initializeClientWithManagerSettingsAndDatafile:self.datafile];
    if (client.optimizely != nil) {
        self.optimizelyClient = client;
    }
    return client;
}

- (OPTLYClient *)initializeClientWithDatafile:(NSData *)datafile {
    OPTLYClient *client = [self initializeClientWithManagerSettingsAndDatafile:datafile];
    if (client.optimizely != nil) {
        self.optimizelyClient = client;
        return client;
    }
    else {
        return [self initializeClient];
    }
}

- (void)initializeClientWithCallback:(void (^)(NSError * _Nullable, OPTLYClient * _Nullable))callback {
    [self.datafileManager downloadDatafile:self.projectId completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([(NSHTTPURLResponse *)response statusCode] == 304) {
            data = [self.datafileManager getSavedDatafile];
        }
        if (!error) {
            OPTLYClient *client = [self initializeClientWithManagerSettingsAndDatafile:data];
            if (client.optimizely) {
                self.optimizelyClient = client;
            }
        } else {
            // TODO - log error
        }
        
        if (callback) {
            callback(error, self.optimizelyClient);
        }
    }];
}

- (OPTLYClient *)getOptimizely {
    return self.optimizelyClient;
}

- (OPTLYClient *)initializeClientWithManagerSettingsAndDatafile:(NSData *)datafile {
    OPTLYClient *client = [OPTLYClient initWithBuilderBlock:^(OPTLYClientBuilder * _Nonnull builder) {
        builder.datafile = datafile;
        builder.errorHandler = self.errorHandler;
        builder.eventDispatcher = self.eventDispatcher;
        builder.logger = self.logger;
        builder.userProfile = self.userProfile;
    }];
    return client;
}

@end
