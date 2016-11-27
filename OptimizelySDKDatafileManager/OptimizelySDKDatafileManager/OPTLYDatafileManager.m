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
#import <OptimizelySDKCore/OPTLYLog.h>
#import <OptimizelySDKCore/OPTLYErrorHandler.h>
#import <OptimizelySDKShared/OPTLYDataStore.h>
#import <OptimizelySDKShared/OPTLYNetworkService.h>
#import "OPTLYDatafileManager.h"

static NSString *const kCDNAddressFormat = @"https://cdn.optimizely.com/json/%@.json";
NSTimeInterval const kDefaultDatafileFetchInterval = 0;

@interface OPTLYDatafileManager ()
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@property (nonatomic, strong) OPTLYNetworkService *networkService;
@property (nonatomic, strong) NSTimer *datafileDownloadTimer;
@end

@implementation OPTLYDatafileManager

+ (nullable instancetype)initWithBuilderBlock:(nonnull OPTLYDatafileManagerBuilderBlock)block {
    return [[self alloc] initWithBuilder:[OPTLYDatafileManagerBuilder builderWithBlock:block]];
}

- (instancetype)initWithBuilder:(OPTLYDatafileManagerBuilder *)builder {
    if (builder != nil) {
        self = [super init];
        if (self != nil) {
            _datafileFetchInterval = kDefaultDatafileFetchInterval;
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
    OPTLYLogInfo(@"Downloading datafile: %@", projectId);
    [self.networkService downloadProjectConfig:self.projectId
                             completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                 if (error != nil) {
                                     [self.errorHandler handleError:error];
                                 }
                                 else if ([(NSHTTPURLResponse *)response statusCode] == 200) { // got datafile OK
                                     [self saveDatafile:data];
                                     OPTLYLogInfo(@"Datafile for project ID %@ downloaded. Saving datafile.");
                                 }
                                 else {
                                     // TODO: Josh W. handle bad response
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
