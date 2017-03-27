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
#ifdef UNIVERSAL
    #import "JSONModelLib.h"
#else
    #import <JSONModel/JSONModelLib.h>
#endif
#import "OPTLYProjectConfigBuilder.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString * const kExpectedDatafileVersion;
NS_ASSUME_NONNULL_END

@class OPTLYAttribute, OPTLYAudience, OPTLYBucketer, OPTLYEvent, OPTLYExperiment, OPTLYGroup, OPTLYUserProfile, OPTLYVariation, OPTLYVariable;
@protocol OPTLYAttribute, OPTLYAudience, OPTLYBucketer, OPTLYErrorHandler, OPTLYEvent, OPTLYExperiment, OPTLYGroup, OPTLYLogger, OPTLYVariable, OPTLYVariation;

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
/// Flag for IP anonymization
@property (nonatomic, assign) BOOL anonymizeIP;
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
/// List of live variable objects
/// TODO: Make variables required
@property (nonatomic, strong, nonnull) NSArray<OPTLYVariable, Optional> *variables;

/// a comprehensive list of experiments that includes experiments being whitelisted (in Groups)
@property (nonatomic, strong, nullable) NSArray<OPTLYExperiment, Ignore> *allExperiments;
@property (nonatomic, strong, nullable) id<OPTLYLogger, Ignore> logger;
@property (nonatomic, strong, nullable) id<OPTLYErrorHandler, Ignore> errorHandler;
@property (nonatomic, strong, readonly, nullable) id<OPTLYUserProfile, Ignore> userProfile;

/// Returns the client type (e.g., objective-c-sdk, ios-sdk, tvos-sdk)
@property (nonatomic, strong, readonly, nonnull) NSString<Ignore> *clientEngine;
/// Returns the client version number
@property (nonatomic, strong, readonly, nonnull) NSString<Ignore> *clientVersion;

/**
 * Initialize the Project Config from a builder block.
 */
+ (nullable instancetype)init:(nonnull OPTLYProjectConfigBuilderBlock)builderBlock;

/**
 * Initialize the Project Config from a datafile.
 */
- (nullable instancetype)initWithDatafile:(nonnull NSData *)datafile;

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
 * Get a variable for a given live variable key.
 */
- (nullable OPTLYVariable *)getVariableForVariableKey:(nonnull NSString *)variableKey;

/**
 * Get variation for experiment and user ID with user attributes.
 */
- (nullable OPTLYVariation *)getVariationForExperiment:(nonnull NSString *)experimentKey
                                                userId:(nonnull NSString *)userId
                                            attributes:(nullable NSDictionary<NSString *,NSString *> *)attributes
                                              bucketer:(nullable id<OPTLYBucketer>)bucketer;

@end
