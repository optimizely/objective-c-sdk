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

@import UIKit;

@interface OPTLYManagerBase()
@property (strong, readwrite, nonatomic, nullable) OPTLYClient *optimizelyClient;
/// Version number of the Optimizely iOS SDK
@property (nonatomic, readwrite, strong, nonnull) NSString *clientVersion;
/// iOS Device Model
@property (nonatomic, readwrite, strong, nonnull) NSString *deviceModel;
/// iOS OS Version
@property (nonatomic, readwrite, strong, nonnull) NSString *osVersion;
/// iOS App Version
@property (nonatomic, readwrite, strong, nonnull) NSString *appVersion;
@end

@implementation OPTLYManagerBase

#pragma mark - Constructors

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        // _clientVersion is initialized by OPTLYManager subclass .
        _deviceModel = [[[UIDevice currentDevice] model] copy];
        _osVersion = [[[UIDevice currentDevice] systemVersion] copy];
        {
            NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
            _appVersion = [dict[@"CFBundleShortVersionString"] copy];
        }
    };
    return self;
}

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

- (nonnull NSDictionary *)newDefaultAttributes {
    return @{@"optimizely_ios_device_model":_deviceModel,
             @"optimizely_ios_sdk_version":_clientVersion,
             @"optimizely_ios_os_version":_osVersion,
             @"optimizely_ios_app_version":_appVersion};
}

- (OPTLYClient *)initializeClientWithManagerSettingsAndDatafile:(NSData *)datafile {
    OPTLYClient *client = [OPTLYClient init:^(OPTLYClientBuilder * _Nonnull builder) {
        builder.datafile = datafile;
        builder.errorHandler = self.errorHandler;
        builder.eventDispatcher = self.eventDispatcher;
        builder.logger = self.logger;
        builder.userProfileService = self.userProfileService;
        builder.clientEngine = self.clientEngine;
        builder.clientVersion = self.clientVersion;
    }];
    client.defaultAttributes = [self newDefaultAttributes];
    return client;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"projectId: %@ \nclientEngine: %@\nclientVersion: %@\ndatafile:%@\nlogger:%@\nerrorHandler:%@\ndatafileManager:%@\neventDispatcher:%@\nuserProfile:%@", self.projectId, self.clientEngine, self.clientVersion, self.datafile, self.logger, self.errorHandler, self.datafileManager, self.eventDispatcher, self.userProfileService];
}
@end
