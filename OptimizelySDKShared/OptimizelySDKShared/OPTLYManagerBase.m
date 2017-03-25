/****************************************************************************
 * Copyright 2016-2017, Optimizely, Inc. and contributors                   *
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

#ifdef UNIVERSAL
    #import "OPTLYErrorHandler.h"
    #import "OPTLYEventDispatcher.h"
    #import "OPTLYLogger.h"
    #import "OPTLYLoggerMessages.h"
#else
    #import <OptimizelySDKCore/OPTLYErrorHandler.h>
    #import <OptimizelySDKCore/OPTLYEventDispatcherBasic.h>
    #import <OptimizelySDKCore/OPTLYLogger.h>
    #import <OptimizelySDKCore/OPTLYLoggerMessages.h>
#endif
#import "OPTLYClient.h"
#import "OPTLYDatafileManagerBasic.h"
#import "OPTLYManagerBase.h"
#import "OPTLYManagerBuilder.h"

@interface OPTLYManagerBase()
@property (strong, readwrite, nonatomic, nullable) OPTLYClient *optimizelyClient;
@end

@implementation OPTLYManagerBase

#pragma mark - Client Getters

- (OPTLYClient *)initialize {
    // the datafile could have been set in the builder (this should take precedence over the saved datafile)
    if (!self.datafile) {
        self.datafile = [self.datafileManager getSavedDatafile];
    }
    self.optimizelyClient = [self initializeClientWithManagerSettingsAndDatafile:self.datafile];
    return self.optimizelyClient;
}

- (OPTLYClient *)initializeWithDatafile:(NSData *)datafile {
    self.optimizelyClient = [self initializeClientWithManagerSettingsAndDatafile:datafile];
    return self.optimizelyClient;
}

- (void)initializeWithCallback:(void (^)(NSError * _Nullable, OPTLYClient * _Nullable))callback {
    [self.datafileManager downloadDatafile:self.projectId completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([(NSHTTPURLResponse *)response statusCode] == 304) {
            data = [self.datafileManager getSavedDatafile];
        }
        self.optimizelyClient = [self initializeClientWithManagerSettingsAndDatafile:data];
        
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

- (NSString *)description {
    return [NSString stringWithFormat:@"projectId: %@ \nclientEngine: %@\nclientVersion: %@\ndatafile:%@\nlogger:%@\nerrorHandler:%@\ndatafileManager:%@\neventDispatcher:%@\nuserProfile:%@", self.projectId, self.clientEngine, self.clientVersion, self.datafile, self.logger, self.errorHandler, self.datafileManager, self.eventDispatcher, self.userProfile];
}
@end
