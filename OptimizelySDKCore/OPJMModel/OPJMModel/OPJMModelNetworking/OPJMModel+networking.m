/****************************************************************************
 * Modifications to JSONModel by Optimizely, Inc.                           *
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
//
//  OPJMModel+networking.m
//  OPJMModel
//

#import "OPJMModel+networking.h"
#import "OPJMHTTPClient.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"

BOOL _isLoading;

@implementation OPJMModel(Networking)

@dynamic isLoading;

-(BOOL)isLoading
{
    return _isLoading;
}

-(void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
}

-(instancetype)initFromURLWithString:(NSString *)urlString completion:(OPJMModelBlock)completeBlock
{
    id placeholder = [super init];
    __block id blockSelf = self;

    if (placeholder) {
        //initialization
        self.isLoading = YES;

        [OPJMHTTPClient getJSONFromURLWithString:urlString
                                      completion:^(NSDictionary *json, OPJMModelError* e) {

                                          OPJMModelError* initError = nil;
                                          blockSelf = [self initWithDictionary:json error:&initError];

                                          if (completeBlock) {
                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                                                  completeBlock(blockSelf, e?e:initError );
                                              });
                                          }

                                          self.isLoading = NO;

                                      }];
    }
    return placeholder;
}

+ (void)getModelFromURLWithString:(NSString*)urlString completion:(OPJMModelBlock)completeBlock
{
    [OPJMHTTPClient getJSONFromURLWithString:urlString
                                  completion:^(NSDictionary* jsonDict, OPJMModelError* err)
    {
        OPJMModel* model = nil;

        if(err == nil)
        {
            model = [[self alloc] initWithDictionary:jsonDict error:&err];
        }

        if(completeBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                completeBlock(model, err);
            });
        }
    }];
}

+ (void)postModel:(OPJMModel*)post toURLWithString:(NSString*)urlString completion:(OPJMModelBlock)completeBlock
{
    [OPJMHTTPClient postJSONFromURLWithString:urlString
                                   bodyString:[post toJSONString]
                                   completion:^(NSDictionary* jsonDict, OPJMModelError* err)
    {
        OPJMModel* model = nil;

        if(err == nil)
        {
            model = [[self alloc] initWithDictionary:jsonDict error:&err];
        }

        if(completeBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                completeBlock(model, err);
            });
        }
    }];
}

@end
