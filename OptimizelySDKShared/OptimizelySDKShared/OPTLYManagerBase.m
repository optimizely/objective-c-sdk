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
#import "OPTLYClient.h"
#import "OPTLYDatafileManager.h"
#import "OPTLYManagerBase.h"
#import "OPTLYManagerBuilder.h"

@interface OPTLYManagerBase()
@property (strong, readwrite, nonatomic, nullable) OPTLYClient *optimizelyClient;
@end

@implementation OPTLYManagerBase

- (NSString *)description
{
    return [NSString stringWithFormat:@"projectId: %@ \nclientEngine: %@\nclientVersion: %@\ndatafile:%@\nlogger:%@\nerrorHandler:%@\ndatafileManager:%@\neventDispatcher:%@\nuserProfile:%@", self.projectId, self.clientEngine, self.clientVersion, self.datafile, self.logger, self.errorHandler, self.datafileManager, self.eventDispatcher, self.userProfile];
}

#pragma mark - Client Getters

- (OPTLYClient *)initialize {
    OPTLYClient *client = [self initializeClientWithManagerSettingsAndDatafile:self.datafile];
    if (client.optimizely != nil) {
        self.optimizelyClient = client;
    }
    return client;
}

- (OPTLYClient *)initializeWithDatafile:(NSData *)datafile {
    OPTLYClient *client = [self initializeClientWithManagerSettingsAndDatafile:datafile];
    if (client.optimizely != nil) {
        self.optimizelyClient = client;
        return client;
    }
    else {
        return [self initialize];
    }
}

- (void)initializeWithCallback:(void (^)(NSError * _Nullable, OPTLYClient * _Nullable))callback {
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
    OPTLYClient *client = [OPTLYClient init:^(OPTLYClientBuilder * _Nonnull builder) {
        builder.datafile = datafile;
        builder.errorHandler = self.errorHandler;
        builder.eventDispatcher = self.eventDispatcher;
        builder.logger = self.logger;
        builder.userProfile = self.userProfile;
        builder.clientEngine = self.clientEngine;
        builder.clientVersion = self.clientVersion;
    }];
    return client;
}

@end
