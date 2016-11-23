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

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModelLib.h>

@class OPTLYAttribute, OPTLYAudience, OPTLYBucketer, OPTLYEvent, OPTLYExperiment, OPTLYGroup, OPTLYVariation;
@protocol OPTLYAttribute, OPTLYAudience, OPTLYBucketer, OPTLYErrorHandler, OPTLYEvent, OPTLYExperiment, OPTLYGroup, OPTLYLogger, OPTLYUserProfile, OPTLYVariation;

/*
    This class represents all the data contained in the project datafile 
    and includes helper methods to efficiently access its data.
 */

@interface OPTLYProjectConfig : JSONModel

/// Account Id
@property (nonatomic, strong, nonnull) NSString *accountId;
/// Project Id
@property (nonatomic, strong, nonnull) NSString *projectId;
/// JSON Version
@property (nonatomic, strong, nonnull) NSString *version;
/// Datafile Revision number
@property (nonatomic, strong, nonnull) NSString *revision;
/// List of Optimizely Experiment objects
@property (nonatomic, strong, nonnull) NSArray<OPTLYExperiment> *experiments;
/// List of Optimizely Event Type objects
@property (nonatomic, strong, nonnull) NSArray<OPTLYEvent> *events;
/// List of audience ids
@property (nonatomic, strong, nonnull) NSArray<OPTLYAudience> *audiences;
/// List of attributes objects
@property (nonatomic, strong, nonnull) NSArray<OPTLYAttribute> *attributes;
/// List of group objects
@property (nonatomic, strong, nonnull) NSArray<OPTLYGroup> *groups;

/// a comprehensive list of experiments that includes experiments being whitelisted (in Groups)
@property (nonatomic, strong, nullable) NSArray<OPTLYExperiment, Ignore> *allExperiments;
@property (nonatomic, strong, nullable) NSArray<OPTLYVariation, Ignore> *allVariations;
@property (nonatomic, strong, nullable) id<OPTLYLogger, Ignore> logger;
@property (nonatomic, strong, nullable) id<OPTLYErrorHandler, Ignore> errorHandler;
@property (nonatomic, strong, nullable) id<OPTLYUserProfile, Ignore> userProfile;

/**
 * Initialize the Project Config from the Data File.
 */
// TODO - make initializer with builder block
- (nullable instancetype)initWithDatafile:(nullable NSData *)datafile
                               withLogger:(nullable id<OPTLYLogger>)logger
                         withErrorHandler:(nullable id<OPTLYErrorHandler>)errorHandler
                          withUserProfile:(nullable id<OPTLYUserProfile>)userProfile;

/**
 * Get an Experiment object for a key.
 */
- (nullable OPTLYExperiment *)getExperimentForKey:(nonnull NSString *)experimentKey;

/**
 * Get an Experiment object for an Id.
 */
- (nullable OPTLYExperiment *)getExperimentForId:(nonnull NSString *)experimentId;

/**
* Get an experiment Id for the human readable experiment key
**/
- (nullable NSString *)getExperimentIdForKey:(nonnull NSString *)experimentKey;

/**
 * Get a Group object for an Id.
 */
- (nullable OPTLYGroup *)getGroupForGroupId:(nonnull NSString *)groupId;

/**
 * Gets an event id for a corresponding event key
 */
- (nullable NSString *)getEventIdForKey:(nonnull NSString *)eventKey;

/**
 * Gets an event for a corresponding event key
 */
- (nullable OPTLYEvent *)getEventForKey:(nonnull NSString *)eventKey;

/**
* Get an attribute for a given key.
*/
- (nullable OPTLYAttribute *)getAttributeForKey:(nonnull NSString *)attributeKey;

/**
 * Get an audience for a given audience id.
 */
- (nullable OPTLYAudience *)getAudienceForId:(nonnull NSString *)audienceId;

/**
 * Get variation for experiment and user ID with user attributes.
 */
- (nullable OPTLYVariation *)getVariationForExperiment:(nonnull NSString *)experimentKey
                                                userId:(nonnull NSString *)userId
                                            attributes:(nullable NSDictionary<NSString *,NSString *> *)attributes
                                              bucketer:(nullable id<OPTLYBucketer>)bucketer;
/**
 * Get variation for given variation key.
 */
- (nullable OPTLYVariation *)getVariationForVariationKey:(nonnull NSString *)variationKey;

/*
 * Returns the client type (e.g., objective-c-sdk-core, objective-c-sdk-iOS, objective-c-sdk-tvOS)
 */
- (nonnull NSString *)clientEngine;

/*
 * Returns the client version number
 */
- (nonnull NSString *)clientVersion;

@end
