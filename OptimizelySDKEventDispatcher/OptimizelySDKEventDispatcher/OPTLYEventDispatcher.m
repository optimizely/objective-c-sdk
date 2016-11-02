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

#import "OPTLYEventDispatcher.h"

@implementation OPTLYEventDispatcher : NSObject

- (instancetype)initWithInterval:(NSInteger)pollingInterval {
    self = [super init];
    if (self) {
        [self setupApplicationNotificationHandlers];
    }
    return self;
}

#pragma mark -- Application Lifecycle Handlers --
- (void)setupApplicationNotificationHandlers {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    UIApplication *app = [UIApplication sharedApplication];
    
        [defaultCenter addObserver:self
                          selector:@selector(applicationDidBecomeActive:)
                              name:UIApplicationDidBecomeActiveNotification
                            object:app];
        
        [defaultCenter addObserver:self
                          selector:@selector(applicationDidEnterBackground:)
                              name:UIApplicationDidEnterBackgroundNotification
                            object:app];
        
        [defaultCenter addObserver:self
                          selector:@selector(applicationWillEnterForeground:)
                              name:UIApplicationWillEnterForegroundNotification
                            object:app];
        
        [defaultCenter addObserver:self
                          selector:@selector(applicationWillResignActive:)
                              name:UIApplicationWillResignActiveNotification
                            object:app];
        
        [defaultCenter addObserver:self
                          selector:@selector(applicationWillTerminate:)
                              name:UIApplicationWillTerminateNotification
                            object:app];
    });
}

- (void)applicationDidBecomeActive:(id)notificaton {
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationDidEnterBackground:(id)notification {
    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(id)notification {
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationWillResignActive:(id)notification {
    NSLog(@"applicationWillResignActive");
}

- (void)applicationWillTerminate:(id)notification {
    NSLog(@"applicationWillTerminate");
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dispatchEvent:(NSDictionary *)params
                toURL:(NSURL *)url
    completionHandler:(void(^)(NSURLResponse *response, NSError *error))completion
{
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:url];
    [requestManager POSTWithParameters:params completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (completion) {
            completion(response, error);
        }
    }];
}

@end
