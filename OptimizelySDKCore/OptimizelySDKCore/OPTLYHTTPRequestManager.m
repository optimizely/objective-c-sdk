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

#import "OPTLYErrorHandlerMessages.h"
#import "OPTLYHTTPRequestManager.h"
#import "OPTLYLog.h"

static NSString * const kHTTPRequestMethodGet = @"GET";
static NSString * const kHTTPRequestMethodPost = @"POST";
static NSString * const kHTTPHeaderFieldContentType = @"Content-Type";
static NSString * const kHTTPHeaderFieldValueApplicationJSON = @"application/json";

// The total backoff and retry interval is
//  pow(2,OPTLYHTTPRequestManagerMaxBackoffRetryAttempts) * OPTLYHTTPRequestManagerMaxBackoffRetryTimeInterval_ms

// The number of re-tries following the first failed attempt
NSInteger kMaxBackoffRetryAttempts = 3;
// TODO: Confirm with Michael Hood if this is a good time unit
NSInteger kMaxBackoffRetryTimeInterval_ms = 1;

// TODO: Wrap this in a TEST preprocessor definition
@interface OPTLYHTTPRequestManager()
@property (nonatomic, assign) NSInteger retryAttemptTest;
@property (nonatomic, strong) NSMutableArray *delaysTest;
@end

@implementation OPTLYHTTPRequestManager

# pragma mark - Object Initializers

- (id)init
{
    NSAssert(YES, @"Use initWithURL initialization method.");
    
    self = [super init];
    return self;
}

- (id)initWithURL:(NSURL *)url
{
    if (self = [super init]) {
        _url = url;
    }
    return self;
}

// Create global serial GCD queue for NSURL tasks
dispatch_queue_t networkTasksQueue()
{
    static dispatch_queue_t _networkTasksQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkTasksQueue = dispatch_queue_create("com.Optimizely.networkTasksQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return _networkTasksQueue;
}

# pragma mark - GET
- (void)GET:(OPTLYHTTPRequestManagerResponse)completion {
    [self GETWithBackoffRetry:NO completionHandler:completion];
}

- (void)GETWithBackoffRetry:(BOOL)backoffRetry
          completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    if (backoffRetry) {
        // TODO: Wrap this in a TEST preprocessor definition
        self.delaysTest = [NSMutableArray new];
        [self GETWithParameters:nil backoffRetryAttempt:0 error:nil completionHandler:completion];
    } else {
        [self GETWithParameters:nil completionHandler:completion];
    }
}

# pragma mark - GET (with parameters)
- (void)GETWithParameters:(NSDictionary *)parameters
        completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    NSURLSession *ephemeralSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURL *urlWithParameterQuery = [self buildQueryURL:self.url withParameters:parameters];
    NSURLSessionDataTask *downloadTask = [ephemeralSession dataTaskWithURL:urlWithParameterQuery
                                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                             if (completion) {
                                                                 completion(data, response, error);
                                                             }
                                                         }];
    
    [downloadTask resume];
}

- (void)GETWithParameters:(NSDictionary *)parameters
             backoffRetry:(BOOL)backoffRetry
        completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    if (backoffRetry) {
        // TODO: Wrap this in a TEST preprocessor definition
        self.delaysTest = [NSMutableArray new];
        [self GETWithParameters:parameters backoffRetryAttempt:0 error:nil completionHandler:completion];
    } else {
        [self GETWithParameters:parameters completionHandler:completion];
    }
}

- (void)GETWithParameters:(NSDictionary *)parameters
      backoffRetryAttempt:(NSInteger)backoffRetryAttempt
                    error:(NSError *)error
        completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    OPTLYLogDebug(@"GET with parameter attempt: %lu", backoffRetryAttempt);
    
    // TODO: Wrap this in a TEST preprocessor definition
    self.retryAttemptTest = backoffRetryAttempt;
    
    if (backoffRetryAttempt > OPTLYHTTPRequestManagerMaxBackoffRetryAttempts) {
        if (completion) {
            NSString *errorMessage = [NSString stringWithFormat:OPTLYErrorHandlerMessagesHTTPRequestManagerGETRetryFailure, error];
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesHTTPRequestManager
                                             userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
            OPTLYLogDebug(errorMessage);
            completion(nil, nil, error);
        }
        
        // TODO: Wrap this in a TEST preprocessor definition
        self.delaysTest = nil;
        
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self GETWithParameters:parameters completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (error) {
            dispatch_time_t delayTime = [self backoffDelay:backoffRetryAttempt];
            dispatch_after(delayTime, networkTasksQueue(), ^(void){
                [strongSelf GETWithParameters:parameters backoffRetryAttempt:backoffRetryAttempt+1 error:error completionHandler:completion];
            });
        } else {
            if (completion) {
                completion(data, response, error);
            }
        }
    }];
}

# pragma mark - GET (if modified)
- (void)GETIfModifiedSince:(NSString *)lastModifiedDate
         completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self url]];
    [request setValue:lastModifiedDate forHTTPHeaderField:@"If-Modified-Since"];
    
    NSURLSession *ephemeralSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [ephemeralSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(data, response, error);
        }
    }];
    
    [dataTask resume];
}

- (void)GETIfModifiedSince:(NSString *)lastModifiedDate
              backoffRetry:(BOOL)backoffRetry
         completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    if (backoffRetry) {
        // TODO: Wrap this in a TEST preprocessor definition
        self.delaysTest = [NSMutableArray new];
        [self GETIfModifiedSince:lastModifiedDate backoffRetryAttempt:0 error:nil completionHandler:completion];
    } else {
        [self GETIfModifiedSince:lastModifiedDate completionHandler:completion];
    }
}

- (void)GETIfModifiedSince:(NSString *)lastModifiedDate
       backoffRetryAttempt:(NSInteger)backoffRetryAttempt
                     error:(NSError *)error
         completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    OPTLYLogDebug(@"GET if modified attempt: %lu", backoffRetryAttempt);
    
    // TODO: Wrap this in a TEST preprocessor definition
    self.retryAttemptTest = backoffRetryAttempt;
    
    if (backoffRetryAttempt > OPTLYHTTPRequestManagerMaxBackoffRetryAttempts) {
        if (completion) {
            NSString *errorMessage = [NSString stringWithFormat:OPTLYErrorHandlerMessagesHTTPRequestManagerGETIfModifiedFailure, error];
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesHTTPRequestManager
                                             userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
            OPTLYLogDebug(errorMessage);
            completion(nil, nil, error);
        }
        
        // TODO: Wrap this in a TEST preprocessor definition
        self.delaysTest = nil;

        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self GETIfModifiedSince:lastModifiedDate completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (error) {
            dispatch_time_t delayTime = [self backoffDelay:backoffRetryAttempt];
            dispatch_after(delayTime, networkTasksQueue(), ^(void){
                [strongSelf GETIfModifiedSince:lastModifiedDate backoffRetryAttempt:backoffRetryAttempt+1 error:error completionHandler:completion];
            });
        } else {
            if (completion) {
                completion(data, response, error);
            }
        }
    }];
}


# pragma mark - POST
- (void)POSTWithParameters:(NSDictionary *)parameters
         completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    NSURLSession *ephemeralSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self url]];
    [request setHTTPMethod:kHTTPRequestMethodPost];
    
    NSError *JSONSerializationError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters
                                                   options:kNilOptions error:&JSONSerializationError];
    if (JSONSerializationError) {
        if (completion) {
            completion(nil, nil, JSONSerializationError);
        }
        return;
    }
    
    [request addValue:kHTTPHeaderFieldValueApplicationJSON forHTTPHeaderField:kHTTPHeaderFieldContentType];
    
    NSURLSessionUploadTask *uploadTask = [ephemeralSession uploadTaskWithRequest:request
                                                                        fromData:data
                                                               completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                   if (completion) {
                                                                       completion(data, response, error);
                                                                   }
                                                               }];
    
    [uploadTask resume];
}

- (void)POSTWithParameters:(NSDictionary *)parameters
              backoffRetry:(BOOL)backoffRetry
         completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    if (backoffRetry) {
        // TODO: Wrap this in a TEST preprocessor definition
        self.delaysTest = [NSMutableArray new];
        [self POSTWithParameters:parameters backoffRetryAttempt:0 error:nil completionHandler:completion];
    } else {
        [self POSTWithParameters:parameters completionHandler:completion];
    }
}

- (void)POSTWithParameters:(NSDictionary *)parameters
       backoffRetryAttempt:(NSInteger)backoffRetryAttempt
                     error:(NSError *)error
         completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    OPTLYLogDebug(@"POST attempt: %lu", backoffRetryAttempt);
    
    // TODO: Wrap this in a TEST preprocessor definition
    self.retryAttemptTest = backoffRetryAttempt;
    
    if (backoffRetryAttempt > OPTLYHTTPRequestManagerMaxBackoffRetryAttempts) {
        if (completion) {
            NSString *errorMessage = [NSString stringWithFormat:OPTLYErrorHandlerMessagesHTTPRequestManagerPOSTRetryFailure, error];
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesHTTPRequestManager
                                             userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
            OPTLYLogDebug(errorMessage);
            completion(nil, nil, error);
        }
        
        // TODO: Wrap this in a TEST preprocessor definition
        self.delaysTest = nil;
        
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self POSTWithParameters:parameters completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __typeof__(self) strongSelf = weakSelf;
        if (error) {
            dispatch_time_t delayTime = [self backoffDelay:backoffRetryAttempt];
            dispatch_after(delayTime, networkTasksQueue(), ^(void){
                [strongSelf POSTWithParameters:parameters backoffRetryAttempt:backoffRetryAttempt+1 error:error completionHandler:completion];
            });
        } else {
            if (completion) {
                completion(data, response, error);
            }
        }
    }];
}

# pragma mark - Helper Methods
+ (NSInteger)backoffRetryDuration_ms
{
    NSInteger duration = (pow(2, kOPTLYHTTPRequestManagerMaxBackoffRetryAttempts+1) - 1) * kOPTLYHTTPRequestManagerMaxBackoffRetryTimeInterval_ms;
    return duration;
}

// calculates the exponential backoff time based on the retry attempt number
- (dispatch_time_t)backoffDelay:(NSInteger)backoffRetryAttempt
{
    uint32_t exponentialMultiplier = pow(2.0, backoffRetryAttempt);
    uint64_t delay_ns = OPTLYHTTPRequestManagerMaxBackoffRetryTimeInterval_ms * exponentialMultiplier * NSEC_PER_MSEC;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, delay_ns);
    
    OPTLYLogDebug(@"Retry attempt: %d exponentialMultiplier: %u delay_ns: %lu, delayTime: %lu", backoffRetryAttempt, exponentialMultiplier, delay_ns, delayTime);
    
    // TODO: Wrap this in a TEST preprocessor definition
    self.delaysTest[backoffRetryAttempt] = [NSNumber numberWithLongLong:delay_ns];
    
    return delayTime;
}

- (NSURL *)buildQueryURL:(NSURL *)url
          withParameters:(NSDictionary *)parameters
{
    if (parameters == nil || [parameters count] == 0) {
        return url;
    }
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    
    components.scheme = url.scheme;
    components.host = url.host;
    components.path = url.path;
    
    NSMutableArray *queryItems = [NSMutableArray new];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop)
     {
         NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:key value:object];
         [queryItems addObject:queryItem];
     }];
    components.queryItems = queryItems;
    
    return components.URL;
}

@end
