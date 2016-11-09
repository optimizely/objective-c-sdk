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

#import "OPTLYLoggerMessages.h"

// ---- errors ----
NSString *const OPTLYLoggerMessagesBuilderNotValid = @"An Optimizely instance was not able to be initialized because the OPTLYBuilder object was invalid";
NSString *const OPTLYLoggerMessagesEventNotAssociatedWithExperiment = @"Event %@ is not associated with any experiment."; // event key
NSString *const OPTLYLoggerMessagesAttributeInvalidFormat = @"Provided attribute %@ is in an invalid format."; // added id parameter, changed to singular
NSString *const OPTLYLoggerMessagesForcedBucketingFailed = @"Entity %@ is not in the datafile. Not activating user %@."; // changed text from from 'variation' to 'entity'

// ---- warnings ----
NSString *const OPTLYLoggerMessagesExperimentUnknown = @"Experiment %@ is not in the datafile."; // experiment id
NSString *const OPTLYLoggerMessagesEventUnknown = @"Event %@ is not in the datafile." ; //event key
NSString *const OPTLYLoggerMessagesAttributeUnknown = @"Attribute(s) %@ not in the datafile."; // attribute ids
NSString *const OPTLYLoggerMessagesAudienceUnknown = @"Audience %@ not in the datafile."; // audience id
NSString *const OPTLYLoggerMessagesGetVariationFailed = @"Could not get variation for user %@ for experiment %@."; // user ID, experiment key
NSString *const OPTLYDatafileManagerInitializedWithoutProjectIdMessage = @"Optimizely Datafile Manager must be initialized with a project ID.";

// ---- info ----
NSString *const OPTLYLoggerMessagesAudienceTargetingFail = @"User %@ does not meet conditions to be in experiment %@.";
NSString *const OPTLYLoggerMessagesActivationSuccess = @"Activating user %@ in experiment %@.";
NSString *const OPTLYLoggerMessagesActivationFailure = @"Not activating user %@ for experiment %@.";
NSString *const OPTLYLoggerMessagesConversionSuccess = @"Tracking event %@ for user %@.";
NSString *const OPTLYLoggerMessagesNoExperimentsForGoal = @"There are no valid experiments for event %@ to track.";
NSString *const OPTLYLoggerMessagesVariationUserAssigned = @"User %@ is in variation %@ of experiment %@.";
NSString *const OPTLYLoggerMessagesForcedVariationUser = @"User %@ is forced in variation %@.";
NSString *const OPTLYLoggerMessagesConversionFailAudienceTargeting = @"User %@ does not meet conditions to be in experiment %@.";
NSString *const OPTLYLoggerMessagesExperimentNotRunning = @"Experiment %@ is not running.";
NSString *const OPTLYLoggerMessagesUserNotTracked = @"Not tracking user if experiment isn’t running or user isn’t in experiment audience";

NSString *const OPTLYLoggerMessagesUserMutuallyExcluded = @"User %ld is mutually excluded"; // user id
NSString *const OPTLYLoggerMessagesNotTrackedUnknownEvent = @"Not tracking event %@ for user %@. Event is not in datafile."; // event key, userId
NSString *const OPTLYLoggerMessagesNotTrackedNoParams = @"Not tracking event %@ for user %@. Params not generated."; // event key, userId
NSString *const OPTLYLoggerMessagesNotTrackedDispatchFailed = @"Not tracking event %@ for user %@. Event dispatch failed."; // event key, userId
NSString *const OPTLYLoggerMessagesExperimentIdUnknown = @"Experiment id for %@ is not in the datafile."; // experiment key
NSString *const OPTLYLoggerMessagesEventIdUnknown = @"Event id %@ is not in the datafile."; //event key
// conversion and tracking event creation errors
NSString *const OPTLYLoggerMessagesVariationtNameInvalid = @"Variation name is not valid.";
NSString *const OPTLYLoggerMessagesUserIdInvalid = @"User id is not valid.";
NSString *const OPTLYLoggerMessagesExperimentKeyInvalid = @"Experiment key is not valid.";
NSString *const OPTLYLoggerMessagesVariationIdInvalid = @"Variation id is not valid.";
NSString *const OPTLYLoggerMessagesBucketerInvalid = @"Bucketer is not valid.";
NSString *const OPTLYLoggerMessagesNoImpressionNoParams = @"No impression sent for experiment %@, user %@. Params not generated."; // experiment key, userId
NSString *const OPTLYLoggerMessagesExperimentNotPartOfEvent = @"Experiment %@ is not associated with event %@.";
NSString *const OPTLYLoggerMessagesAttributeValueInvalidFormat = @"Provided value for attribute %@ is in an invalid format."; 
// project config getters
NSString *const OPTLYLoggerMessagesExperimentIdUnknownForExperimentKey = @"Experiment id not found for experiment key: %@."; // experiment id
NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentKey = @"Experiment not found for experiment key: %@."; // experiment key
NSString *const OPTLYLoggerMessagesEventIdUnknownForEventKey = @"Event id not found for event key: %@."; // event key
NSString *const OPTLYLoggerMessagesEventUnknownForEventKey = @"Event not found for event key: %@."; // event key
NSString *const OPTLYLoggerMessagesAttributeUnknownForAttributeKey = @"Attribute not found for attribute key: %@."; // attribute key
NSString *const OPTLYLoggerMessagesAudienceUnknownForAudienceId = @"Audience not found for audience id: %@."; // audience id
NSString *const OPTLYLoggerMessagesGroupUnknownForGroupId = @"Group not found for group id: %@."; // group id

NSString *const OPTLYLoggerMessagesEventDispatcherInterval = @"Event dispatcher interval set: %ld";

// ---- Debug ----
// Event Dispatcher
NSString *const OPTLYLoggerMessagesImpressionDispatching = @"Dispatching impression event to URL %@ with params %@.";
NSString *const OPTLYLoggerMessagesConversionDispatching = @"Dispatching conversion event to URL %@ with params %@.";
NSString *const OPTLYLoggerMessagesDispatchEventNoOp = @"Called dispatchEvent with URL: %@ and params: %@";

NSString *const OPTLYLoggerMessagesBucketAssigned = @"Assigned bucket %@ to user %@.";

@implementation OPTLYLoggerMessages

@end
