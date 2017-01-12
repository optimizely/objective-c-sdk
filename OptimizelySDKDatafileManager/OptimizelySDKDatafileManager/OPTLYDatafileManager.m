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

#import <UIKit/UIKit.h>
#import <OptimizelySDKCore/OPTLYErrorHandler.h>
#import <OptimizelySDKCore/OPTLYLog.h>
#import <OptimizelySDKCore/OPTLYLogger.h>
#import <OptimizelySDKCore/OPTLYNetworkService.h>
#import <OptimizelySDKShared/OPTLYDataStore.h>
#import "OPTLYDatafileManager.h"

// default datafile download interval is 2 minutes
NSTimeInterval const kDefaultDatafileFetchInterval_s = 120;

@interface OPTLYDatafileManagerDefault ()
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@property (nonatomic, strong) OPTLYNetworkService *networkService;
@property (nonatomic, strong) NSTimer *datafileDownloadTimer;
@end

@implementation OPTLYDatafileManagerDefault

+ (nullable instancetype)init:(nonnull OPTLYDatafileManagerBuilderBlock)builderBlock {
    return [[self alloc] initWithBuilder:[OPTLYDatafileManagerBuilder builderWithBlock:builderBlock]];
}

- (instancetype)initWithBuilder:(OPTLYDatafileManagerBuilder *)builder {
    if (builder != nil) {
        self = [super init];
        if (self != nil) {
            _datafileFetchInterval = kDefaultDatafileFetchInterval_s;
            _datafileFetchInterval = builder.datafileFetchInterval;
            _projectId = builder.projectId;
            _errorHandler = builder.errorHandler;
            _logger = builder.logger;
            _networkService = [OPTLYNetworkService new];
            _dataStore = [[OPTLYDataStore alloc] initWithLogger:_logger];
            
            // download datafile when we start the datafile manager
            [self downloadDatafile:self.projectId completionHandler:nil];
            [self setupNetworkTimer];
            [self setupApplicationNotificationHandlers];
        }
        return self;
    }
    else {
        return nil;
    }
}

- (void)downloadDatafile:(NSString *)projectId completionHandler:(OPTLYHTTPRequestManagerResponse)completion {
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDatafileManagerDatafileDownloading, projectId];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    
    NSString *lastSavedModifiedDate = [self getLastModifiedDate:projectId];
    logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDatafileManagerLastModifiedDate, lastSavedModifiedDate];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    
    // if datafile polling is enabled, then no need for the backoff retry
    BOOL enableBackoffRetry = self.datafileFetchInterval > 0 ? NO : YES;
    
    [self.networkService downloadProjectConfig:self.projectId
                                  backoffRetry:enableBackoffRetry
                                  lastModified:lastSavedModifiedDate
                             completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                 NSInteger statusCode = [httpResponse statusCode];
                                 NSString *logMessage = @"";
                                 if (error != nil) {
                                     [self.errorHandler handleError:error];
                                 }
                                 else if (statusCode == 200) { // got datafile OK
                                     [self saveDatafile:data];
                                     
                                     // save the last modified date
                                     NSDictionary *dictionary = [httpResponse allHeaderFields];
                                     NSString *lastModifiedDate = [dictionary valueForKey:@"Last-Modified"];
                                     [self saveLastModifiedDate:lastModifiedDate project:projectId];
                                     
                                     logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDatafileManagerDatafileDownloaded, projectId, lastModifiedDate];
                                     [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
                                 }
                                 else if (statusCode == 304) {
                                     logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedNoChanges, projectId];
                                     [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
                                 }
                                 else {
                                     // TODO: Josh W. handle bad response
                                     logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedError, projectId, error];
                                     [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
                                 }
                                 
                                 
                                 
                                 // call the completion handler
                                 if (completion != nil) {
                                     completion(data, response, error);
                                 }
                             }];
}

- (void)downloadDatafile {
    [self downloadDatafile:self.projectId completionHandler:nil];
}

- (void)saveDatafile:(NSData *)datafile {
    NSError *error;
    [self.dataStore saveFile:self.projectId
                        data:datafile
                        type:OPTLYDataStoreDataTypeDatafile
                       error:&error];
    if (error != nil) {
        [self.errorHandler handleError:error];
    }
}

- (NSData *)getSavedDatafile {
    NSError *error;
    NSData *datafile = [self.dataStore getFile:self.projectId
                       type:OPTLYDataStoreDataTypeDatafile
                      error:&error];
    if (error != nil) {
        [self.errorHandler handleError:error];
    }
    return datafile;
}

- (BOOL)isDatafileCached {
    BOOL isCached = [self.dataStore fileExists:self.projectId type:OPTLYDataStoreDataTypeDatafile];
    return isCached;
}

# pragma mark - Persistence for Last Modified Date
- (void)saveLastModifiedDate:(nonnull NSString *)lastModifiedDate
                     project:(nonnull NSString *)projectId {
    
    NSDictionary *userProfileData = [self.dataStore getUserDataForType:OPTLYDataStoreDataTypeDatafile];
    NSMutableDictionary *userProfileDataMutable = userProfileData ? [userProfileData mutableCopy] : [NSMutableDictionary new];
    userProfileDataMutable[projectId] = lastModifiedDate;
    [self.dataStore saveUserData:userProfileDataMutable
                            type:OPTLYDataStoreDataTypeDatafile];
}

- (nullable NSString *)getLastModifiedDate:(nonnull NSString *)projectId {
    NSDictionary *userData = [self.dataStore getUserDataForType:OPTLYDataStoreDataTypeDatafile];
    NSString *lastModifiedDate = [userData objectForKey:projectId];
    
    NSString *logMessage = @"";
    if ([lastModifiedDate length]) {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDatafileManagerLastModifiedDateFound, lastModifiedDate, projectId];
    } else {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDatafileManagerLastModifiedDateNotFound, projectId];
    }
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    
    return lastModifiedDate;
}


#pragma mark - Application Lifecycle Handlers
- (void)setupApplicationNotificationHandlers {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    UIApplication *app = [UIApplication sharedApplication];
    
    [defaultCenter addObserver:self
                      selector:@selector(applicationDidFinishLaunching:)
                          name:UIApplicationDidFinishLaunchingNotification
                        object:app];
    
    [defaultCenter addObserver:self
                      selector:@selector(applicationDidBecomeActive:)
                          name:UIApplicationDidBecomeActiveNotification
                        object:app];
    
    [defaultCenter addObserver:self
                      selector:@selector(applicationDidEnterBackground:)
                          name:UIApplicationDidEnterBackgroundNotification
                        object:app];
    
    [defaultCenter addObserver:self
                      selector:@selector(applicationWillTerminate:)
                          name:UIApplicationWillTerminateNotification
                        object:app];
}

- (void)applicationDidFinishLaunching:(id)notificaton {
    [self setupNetworkTimer];
    OPTLYLogInfo(@"applicationDidFinishLaunching");
}

- (void)applicationDidBecomeActive:(id)notificaton {
    [self setupNetworkTimer];
    OPTLYLogInfo(@"applicationDidBecomeActive");
}

- (void)applicationDidEnterBackground:(id)notification {
    [self disableNetworkTimer];
    OPTLYLogInfo(@"applicationDidEnterBackground");
}

- (void)applicationWillTerminate:(id)notification {
    [self disableNetworkTimer];
    OPTLYLogInfo(@"applicationWillTerminate");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self disableNetworkTimer];
}

# pragma mark - Network Timer
// The timer must be dispatched on the main thread.
- (void)setupNetworkTimer
{
    if (self.datafileFetchInterval > 0 && ![self.datafileDownloadTimer isValid]) {
        self.datafileDownloadTimer = [NSTimer timerWithTimeInterval:self.datafileFetchInterval
                                                             target:self
                                                           selector:@selector(downloadDatafile)
                                                           userInfo:nil
                                                            repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.datafileDownloadTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)disableNetworkTimer {
    [self.datafileDownloadTimer invalidate];
}

@end
