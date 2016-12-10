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

#import "OPTLYTestHelper.h"
#import <OHHTTPStubs/OHHTTPStubs.h>

@implementation OPTLYTestHelper

+ (void)stubFailureResponse
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return YES; // Stub ALL requests without any condition
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:NSURLErrorTimedOut
                                         userInfo:nil];
        return [OHHTTPStubsResponse responseWithError:error];
    }];
}

+ (void)stubSuccessResponse
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return YES; // Stub ALL requests without any condition
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSData* stubData = [@"Data sent!" dataUsingEncoding:NSUTF8StringEncoding];
        return [OHHTTPStubsResponse responseWithData:stubData statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];
    
}

+ (NSDictionary *)loadJSONDatafile:(NSString *)datafileName {
    NSData *data = [OPTLYTestHelper loadJSONDatafileIntoDataObject:datafileName];
    NSDictionary *jsonDataFile = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    return jsonDataFile;
}

+ (NSData *)loadJSONDatafileIntoDataObject:(NSString *)datafileName {
    NSString *filePath =[[NSBundle bundleForClass:[self class]] pathForResource:datafileName ofType:@"json"];
    NSError *error;
    NSString *fileContents =[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
    {
        NSLog(@"Error reading file: %@", error.localizedDescription);
    }
    
    NSData *jsonData = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    
    NSAssert(jsonData != nil, @"Nil json data");
    
    return jsonData;
}

@end
