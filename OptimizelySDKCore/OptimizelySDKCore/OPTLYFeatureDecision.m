//
//  OPTLYFeatureDecision.m
//  OptimizelySDKCore
//
//  Created by Abdur Rafay on 20/12/2017.
//  Copyright © 2017 Optimizely. All rights reserved.
//

#import "OPTLYFeatureDecision.h"
#import "OPTLYExperiment.h"
#import "OPTLYVariation.h"

NSString * const DecisionSourceExperiment = @"experiment";
NSString * const DecisionSourceRollout = @"rollout";

@implementation OPTLYFeatureDecision

- (instancetype)initWithExperiment:(OPTLYExperiment *)experiment variation:(OPTLYVariation *)variation source:(NSString *)source {
    self = [super init];
    if (self) {
        _experiment = experiment;
        _variation = variation;
        _source = source;
    }
    return self;
}

@end
