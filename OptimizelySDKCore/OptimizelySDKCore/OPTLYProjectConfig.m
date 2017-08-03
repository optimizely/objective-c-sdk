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

#import "OPTLYAttribute.h"
#import "OPTLYAudience.h"
#import "OPTLYBucketer.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYEvent.h"
#import "OPTLYExperiment.h"
#import "OPTLYGroup.h"
#import "OPTLYLog.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYValidator.h"
#import "OPTLYUserProfileBasic.h"
#import "OPTLYVariable.h"
#import "OPTLYVariation.h"

NSString * const kExpectedDatafileVersion  = @"3";

@interface OPTLYProjectConfig()

@property (nonatomic, strong) NSDictionary<NSString *, OPTLYAudience *><Ignore> *audienceIdToAudienceMap;
@property (nonatomic, strong) NSDictionary<NSString *, OPTLYEvent *><Ignore> *eventKeyToEventMap;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *><Ignore> *eventKeyToEventIdMap;
@property (nonatomic, strong) NSDictionary<NSString *, OPTLYExperiment *><Ignore> *experimentIdToExperimentMap;
@property (nonatomic, strong) NSDictionary<NSString *, OPTLYExperiment *><Ignore> *experimentKeyToExperimentMap;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *><Ignore> *experimentKeyToExperimentIdMap;
@property (nonatomic, strong) NSDictionary<NSString *, OPTLYGroup *><Ignore> *groupIdToGroupMap;
@property (nonatomic, strong) NSDictionary<NSString *, OPTLYAttribute *><Ignore> *attributeKeyToAttributeMap;
@property (nonatomic, strong) NSDictionary<NSString *, OPTLYVariable *><Ignore> *variableKeyToVariableMap;

@end

@implementation OPTLYProjectConfig

+ (nullable instancetype)init:(nonnull OPTLYProjectConfigBuilderBlock)builderBlock {
    return [[self alloc] initWithBuilder:[OPTLYProjectConfigBuilder builderWithBlock:builderBlock]];
}

- (instancetype)initWithBuilder:(OPTLYProjectConfigBuilder *)builder {
    // check for valid error handler
    if (builder.errorHandler) {
        if (![OPTLYErrorHandler conformsToOPTLYErrorHandlerProtocol:[builder.errorHandler class]]) {
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesErrorHandlerInvalid
                                             userInfo:@{NSLocalizedDescriptionKey :
                                                            NSLocalizedString(OPTLYErrorHandlerMessagesErrorHandlerInvalid, nil)}];
            [[[OPTLYErrorHandlerNoOp alloc] init] handleError:error];
            
            NSString *logMessage = OPTLYErrorHandlerMessagesErrorHandlerInvalid;
            [[[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelAll] logMessage:logMessage withLevel:OptimizelyLogLevelError];
            return nil;
        }
    }
    
    // check for valid logger
    if (builder.logger) {
        if (![builder.logger conformsToProtocol:@protocol(OPTLYLogger)]) {
            builder.logger = [OPTLYLoggerDefault new];
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesLoggerInvalid
                                             userInfo:@{NSLocalizedDescriptionKey :
                                                            NSLocalizedString(OPTLYErrorHandlerMessagesLoggerInvalid, nil)}];
            [builder.errorHandler handleError:error];
            
            NSString *logMessage = OPTLYErrorHandlerMessagesLoggerInvalid;
            [builder.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
            return nil;
        }
    }
    
    // check that datafile exists
    if (!builder.datafile) {
        NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesDatafileInvalid
                                         userInfo:@{NSLocalizedDescriptionKey :
                                                        NSLocalizedString(OPTLYErrorHandlerMessagesDataFileInvalid, nil)}];
        [builder.errorHandler handleError:error];
        
        NSString *logMessage = OPTLYErrorHandlerMessagesDataFileInvalid;
        [builder.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        return nil;
    }
    
    // check datafile is valid
    @try {
        NSError *datafileError;
        OPTLYProjectConfig *projectConfig = [[OPTLYProjectConfig alloc] initWithData:builder.datafile error:&datafileError];
        
        // check if project config's datafile version matches expected datafile version
        if (![projectConfig.version isEqualToString:kExpectedDatafileVersion]) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesInvalidDatafileVersion, kExpectedDatafileVersion, projectConfig.version];
            [builder.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        }
        
        if (datafileError)
        {
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesDatafileInvalid
                                             userInfo:datafileError.userInfo];
            [builder.errorHandler handleError:error];
            return nil;
        }
        else {
            self = projectConfig;
        }
    }
    @catch (NSException *datafileException) {
        [builder.errorHandler handleException:datafileException];
    }
    
    if (builder.userProfile) {
        if (![OPTLYUserProfileUtility conformsToOPTLYUserProfileProtocol:[builder.userProfile class]]) {
            [builder.logger logMessage:OPTLYErrorHandlerMessagesUserProfileInvalid withLevel:OptimizelyLogLevelWarning];
        } else {
            _userProfile = (id<OPTLYUserProfile, Ignore>)builder.userProfile;
        }
    }
    
    _clientEngine = builder.clientEngine;
    _clientVersion = builder.clientVersion;
    
    _errorHandler = (id<OPTLYErrorHandler, Ignore>)builder.errorHandler;
    _logger = (id<OPTLYLogger, Ignore>)builder.logger;
    return self;
}

- (nullable instancetype)initWithDatafile:(nonnull NSData *)datafile {
    return [OPTLYProjectConfig init:^(OPTLYProjectConfigBuilder * _Nullable builder) {
        builder.datafile = datafile;
    }];
}

#pragma mark -- Getters --
- (OPTLYAudience *)getAudienceForId:(NSString *)audienceId
{
    OPTLYAudience *audience = self.audienceIdToAudienceMap[audienceId];
    if (!audience) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceUnknownForAudienceId, audienceId];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return audience;
}

- (OPTLYAttribute *)getAttributeForKey:(NSString *)attributeKey {
    OPTLYAttribute *attribute = self.attributeKeyToAttributeMap[attributeKey];
    if (!attribute) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAttributeUnknownForAttributeKey, attributeKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return attribute;
}

- (NSString *)getEventIdForKey:(NSString *)eventKey {
    NSString *eventId = self.eventKeyToEventIdMap[eventKey];
    if (!eventId) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventIdUnknownForEventKey, eventKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return eventId;
}

- (OPTLYEvent *)getEventForKey:(NSString *)eventKey{
    OPTLYEvent *event = self.eventKeyToEventMap[eventKey];
    if (!event) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventUnknownForEventKey, eventKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return event;
}

- (OPTLYExperiment *)getExperimentForId:(NSString *)experimentId {
    OPTLYExperiment *experiment = self.experimentIdToExperimentMap[experimentId];
    if (!experiment) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesExperimentUnknownForExperimentId, experimentId];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return experiment;
}

- (OPTLYExperiment *)getExperimentForKey:(NSString *)experimentKey {
    OPTLYExperiment *experiment = self.experimentKeyToExperimentMap[experimentKey];
    if (!experiment) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesExperimentUnknownForExperimentKey, experimentKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return experiment;
}

- (NSString *)getExperimentIdForKey:(NSString *)experimentKey
{
    NSString *experimentId = self.experimentKeyToExperimentIdMap[experimentKey];
    if (!experimentId) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesExperimentIdUnknownForExperimentKey, experimentKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return experimentId;
}

- (OPTLYGroup *)getGroupForGroupId:(NSString *)groupId {
    OPTLYGroup *group = self.groupIdToGroupMap[groupId];
    if (!group) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesGroupUnknownForGroupId, groupId];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return group;
}

- (OPTLYVariable *)getVariableForVariableKey:(NSString *)variableKey {
    OPTLYVariable *variable = self.variableKeyToVariableMap[variableKey];
    if (!variable) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    }
    return variable;
}

#pragma mark -- Property Getters --

- (NSArray *)allExperiments
{
    if (!_allExperiments) {
        NSMutableArray *all = [[NSMutableArray alloc] initWithArray:self.experiments];
        for (OPTLYGroup *group in self.groups) {
            for (OPTLYExperiment *experiment in group.experiments) {
                [all addObject:experiment];
            }
        }
        _allExperiments = [all copy];
    }
    return _allExperiments;
}

- (NSDictionary *)audienceIdToAudienceMap
{
    if (!_audienceIdToAudienceMap) {
        _audienceIdToAudienceMap = [self generateAudienceIdToAudienceMap];
    }
    return _audienceIdToAudienceMap;
}


- (NSDictionary *)attributeKeyToAttributeMap
{
    if (!_attributeKeyToAttributeMap) {
        _attributeKeyToAttributeMap = [self generateAttributeToKeyMap];
    }
    return _attributeKeyToAttributeMap;
}

- (NSDictionary *)eventKeyToEventIdMap {
    if (!_eventKeyToEventIdMap) {
        _eventKeyToEventIdMap = [self generateEventKeyToEventIdMap];
    }
    return _eventKeyToEventIdMap;
}

- (NSDictionary *)eventKeyToEventMap {
    if (!_eventKeyToEventMap) {
        _eventKeyToEventMap = [self generateEventKeyToEventMap];
    }
    return _eventKeyToEventMap;
}

- (NSDictionary<NSString *, OPTLYExperiment *> *)experimentIdToExperimentMap {
    if (!_experimentIdToExperimentMap) {
        _experimentIdToExperimentMap = [self generateExperimentIdToExperimentMap];
    }
    return _experimentIdToExperimentMap;
}

- (NSDictionary<NSString *, OPTLYExperiment *> *)experimentKeyToExperimentMap {
    if (!_experimentKeyToExperimentMap) {
        _experimentKeyToExperimentMap = [self generateExperimentKeyToExperimentMap];
    }
    return  _experimentKeyToExperimentMap;
}

- (NSDictionary<NSString *, NSString *> *)experimentKeyToExperimentIdMap
{
    if (!_experimentKeyToExperimentIdMap) {
        _experimentKeyToExperimentIdMap = [self generateExperimentKeyToIdMap];
    }
    return _experimentKeyToExperimentIdMap;
}

- (NSDictionary<NSString *, OPTLYGroup *> *)groupIdToGroupMap {
    if (!_groupIdToGroupMap) {
        _groupIdToGroupMap = [OPTLYProjectConfig generateGroupIdToGroupMapFromGroupsArray:_groups];
    }
    return _groupIdToGroupMap;
}

- (NSDictionary<NSString *, OPTLYVariable *> *)variableKeyToVariableMap {
    if (!_variableKeyToVariableMap) {
        _variableKeyToVariableMap = [self generateVariableKeyToVariableMap];
    }
    return _variableKeyToVariableMap;
}

#pragma mark -- Generate Mappings --

- (NSDictionary *)generateAudienceIdToAudienceMap
{
    NSMutableDictionary *map = [NSMutableDictionary new];
    for (OPTLYAudience *audience in self.audiences) {
        NSString *audienceId = audience.audienceId;
        map[audienceId] = audience;
    }
    return map;
}

- (NSDictionary *)generateAttributeToKeyMap
{
    NSMutableDictionary *map = [NSMutableDictionary new];
    for (OPTLYAttribute *attribute in self.attributes) {
        NSString *attributeKey = attribute.attributeKey;
        map[attributeKey] = attribute;
    }
    return map;
}

+ (NSDictionary<NSString *, OPTLYEvent *> *)generateEventIdToEventMapFromEventArray:(NSArray<OPTLYEvent *> *) events {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithCapacity:events.count];
    for (OPTLYEvent *event in events) {
        map[event.eventId] = event;
    }
    return [NSDictionary dictionaryWithDictionary:map];
}

- (NSDictionary<NSString *, NSString *> *)generateEventKeyToEventIdMap
{
    NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithCapacity:self.events.count];
    for (OPTLYEvent *event in self.events) {
        map[event.eventKey] = event.eventId;
    }
    return [map copy];
}

- (NSDictionary<NSString *, OPTLYEvent *> *)generateEventKeyToEventMap
{
    NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithCapacity:self.events.count];
    for (OPTLYEvent *event in self.events) {
        map[event.eventKey] = event;
    }
    return [map copy];
}

- (NSDictionary<NSString *, OPTLYExperiment *> *)generateExperimentIdToExperimentMap {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    for (OPTLYExperiment *experiment in self.allExperiments) {
        map[experiment.experimentId] = experiment;
    }
    
    return [NSDictionary dictionaryWithDictionary:map];
}

- (NSDictionary<NSString *, OPTLYExperiment *> *)generateExperimentKeyToExperimentMap {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    for (OPTLYExperiment *experiment in self.allExperiments) {
        map[experiment.experimentKey] = experiment;
    }
    return [NSDictionary dictionaryWithDictionary:map];
}

- (NSDictionary<NSString *, NSString *> *)generateExperimentKeyToIdMap {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    for (OPTLYExperiment *experiment in self.allExperiments) {
        map[experiment.experimentKey] = experiment.experimentId;
    }
    return [map copy];
}

+ (NSDictionary<NSString *, OPTLYGroup *> *)generateGroupIdToGroupMapFromGroupsArray:(NSArray<OPTLYGroup *> *) groups{
    NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithCapacity:groups.count];
    for (OPTLYGroup *group in groups) {
        map[group.groupId] = group;
    }
    return [NSDictionary dictionaryWithDictionary:map];
}

- (NSDictionary<NSString *, OPTLYVariable *> *)generateVariableKeyToVariableMap {
    NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
    for (OPTLYVariable *variable in self.variables) {
        map[variable.variableKey] = variable;
    }
    return [NSDictionary dictionaryWithDictionary:map];
}

# pragma mark - Helper Methods

// TODO: Remove bucketer from parameters -- this is not needed
- (OPTLYVariation *)getVariationForExperiment:(NSString *)experimentKey
                                       userId:(NSString *)userId
                                   attributes:(NSDictionary<NSString *,NSString *> *)attributes
                                     bucketer:(id<OPTLYBucketer>)bucketer
{
    if (![OPTLYValidator isExperimentActive:self
                              experimentKey:experimentKey]) {
        return false;
    }
    
    // check if experiment is whitelisted
    OPTLYExperiment *experiment = [self getExperimentForKey:experimentKey];
    if ([self checkWhitelistingForUser:userId experiment:experiment]) {
        return [self getWhitelistedVariationForUser:userId experiment:experiment];
    }
    
    // check for sticky bucketing
    NSString *experimentId = [self getExperimentIdForKey:experimentKey];
    if (self.userProfile != nil) {
        NSString *storedVariationId = [self.userProfile getVariationIdForUserId:userId experimentId:experimentId];
        if (storedVariationId != nil) {
            [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileBucketerUserDataRetrieved, userId, experimentId, storedVariationId]
                          withLevel:OptimizelyLogLevelDebug];
            OPTLYVariation *storedVariation = [[self getExperimentForId:experimentId] getVariationForVariationId:storedVariationId];
            if (storedVariation != nil) {
                return storedVariation;
            }
            else { // stored variation is no longer in datafile
                [self.userProfile removeUserId:userId experimentId:experimentId];
                [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileVariationNoLongerInDatafile, storedVariationId, experimentId]
                              withLevel:OptimizelyLogLevelWarning];
            }
        }
    }
    
    // validate preconditions
    OPTLYVariation *bucketedVariation = nil;
    if ([OPTLYValidator userPassesTargeting:self
                              experimentKey:experiment.experimentKey
                                     userId:userId
                                 attributes:attributes]) {
        // bucket user into a variation
        bucketedVariation = [bucketer bucketExperiment:experiment withUserId:userId];
    }
    if (bucketedVariation != nil) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesVariationUserAssigned, userId, bucketedVariation.variationKey, experimentKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        // Attempt to save user profile
        [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileAttemptToSaveVariation, experimentId, bucketedVariation.variationId, userId]
                      withLevel:OptimizelyLogLevelDebug];
        [self.userProfile saveUserId:userId
                        experimentId:experimentId
                         variationId:bucketedVariation.variationId];
    }
    return bucketedVariation;
}

# pragma mark - Helper Methods
// check if the user is in the whitelisted mapping
- (BOOL)checkWhitelistingForUser:(NSString *)userId experiment:(OPTLYExperiment *)experiment {
    if (experiment.forcedVariations[userId] != nil) {
        return true;
    }
    return false;
}

// get the variation the user was whitelisted into
- (OPTLYVariation *)getWhitelistedVariationForUser:(NSString *)userId experiment:(OPTLYExperiment *)experiment {
    NSString *forcedVariationKey = experiment.forcedVariations[userId];
    OPTLYVariation *forcedVariation = [experiment getVariationForVariationKey:forcedVariationKey];
    if (forcedVariation != nil) {
        // Log user forced into variation
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesForcedVariationUser, userId, forcedVariation.variationKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    }
    else {
        // Log error: variation not in datafile not activating user
        [OPTLYErrorHandler handleError:self.errorHandler
                                  code:OPTLYErrorTypesDataUnknown
                           description:NSLocalizedString(OPTLYErrorHandlerMessagesVariationUnknown, variationId)];
    }
    return forcedVariation;
}
@end
