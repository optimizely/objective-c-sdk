//
//  OptimizelySDKTVOS.h
//  OptimizelySDKTVOS
//
//  Created by Alda Luong on 10/27/16.
//  Copyright © 2016 Optimizely. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for OptimizelySDKTVOS.
FOUNDATION_EXPORT double OptimizelySDKTVOSVersionNumber;

//! Project version string for OptimizelySDKTVOS.
FOUNDATION_EXPORT const unsigned char OptimizelySDKTVOSVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <OptimizelySDKTVOS/PublicHeader.h>


-(OPTLYOptimizelyClient)getOptimizely;
-(void)sendEvent:


- (instancetype)initWithPollInterval:(NSInteger)pollInterval;

- (void)sendEvent:(nonnull OPTLYEvent *)event
completionHandler:(nullable void(^)(NSURLResponse * _Nullable response, NSError * _Nullable error))completion;

- (void)sendEvent:(nonull OPTLYEventDecisionTicket *)decisionTicket
completionHandler:(nullable void(^)(NSURLResponse * _Nullable response, NSError * _Nullable error))completion;

- (void)sendEvent:(nonull OPTLYEventDecision *)decision
completionHandler:(nullable void(^)(NSURLResponse * _Nullable response, NSError * _Nullable error))completion;

- (void)flushEvents;
- (void)flushEventsWithCompletionHandler:(nullable void(^)(NSURResponse * _Nullable response, NSError * _Nullable error))completion;

- (void)save:(nonnull NSString *)userId
  experiment:(nonnull NSString *)experimentKey
   variation:(nonnull NSString *)variationKey
       error:(NSError *)error;

- (nullable NSString *)lookup:(nonnull NSString *)userId
                   experiment:(nonnull NSString *)experimentKey
                        error:(NSError *)error;

- (nullable NSString *)variationForUserId:(nonnull NSString *)userId
                               experiment:(nonnull NSString *)experimentKey
                                    error:(NSError *)error;

- (nullable NSString *)getVariationFor:(nonnull NSString *)userId
                            experiment:(nonnull NSString *)experimentKey
                                 error:(NSError *)error;


- (void)remove:(nonnull NSString *)userId
    experiment:(nonnull NSString *)experimentKey
         error:(NSError *)error;


- (void)requestDatafile:(nonnull NSString *)projectId
      completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;

- (void)save:(nonnull NSString *)projectId
completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;



- (NSString *)storeEvent:(nonnull OPTLYEvent *)event
                   error:(nullable NSError *)error;

- (void)removeEvent:(nonnull NSString *)eventId
              error:(nullable NSError *)error;
