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

#import "OPTLYDatafileManager.h"
#import <OptimizelySDKShared/OPTLYFileManager.h>
#import <OptimizelySDKShared/OPTLYNetworkService.h>

static NSString *const kCDNAddressFormat = @"https://cdn.optimizely.com/json/%@.json";
NSTimeInterval const kDefaultDatafileFetchInterval = 0;

@interface OPTLYDatafileManager ()

@property OPTLYFileManager *fileManager;
@property OPTLYNetworkService *networkService;

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
            _logger = builder.logger;
            _networkService = [[OPTLYNetworkService alloc] init];
            _fileManager = [OPTLYFileManager new];
            // Only fetch the datafile if the polling interval is greater than 0
            if (self.datafileFetchInterval > 0) {
                // TODO: Josh W. start timer to poll for the datafile
            }
        }
        return self;
    }
    else {
        return nil;
    }
}

- (NSString *)datafileURLForProject:(NSString *)projectID {
    return [NSString stringWithFormat:kCDNAddressFormat, projectID];
}

- (void)requestDatafile:(NSString *)projectId completionHandler:(OPTLYHTTPRequestManagerResponse)completion {
    [self.networkService downloadProjectConfig:self.projectId
                        completionHandler:completion];
}

- (void)saveDatafile:(NSData *)datafile {
    NSError *error;
    [self.fileManager saveFile:self.projectId
                          data:datafile
                          type:OPTLYFileManagerDataTypeDatafile
                         error:&error];

}

@end
