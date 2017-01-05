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

// ---- Optimizely ----
// debug
NSString *const OPTLYLoggerMessagesVariationUserAssigned = @"[OPTIMIZELY] User %@ is in variation %@ of experiment %@.";
// info
NSString *const OPTLYLoggerMessagesActivationSuccess = @"[OPTIMIZELY] Activating user %@ in experiment %@.";
NSString *const OPTLYLoggerMessagesConversionSuccess = @"[OPTIMIZELY] Tracking event %@ for user %@.";

// ---- Bucketer ----
// debug
NSString *const OPTLYLoggerMessagesBucketAssigned = @"[BUCKETER] Assigned bucket %@ to user %@.";
// info
NSString *const OPTLYLoggerMessagesForcedVariationUser = @"[BUCKETER] User %@ is forced in variation %@.";
NSString *const OPTLYLoggerMessagesUserMutuallyExcluded = @"[BUCKETER] User %ld is mutually excluded from the experiment."; // user id
// error
NSString *const OPTLYLoggerMessagesForcedBucketingFailed = @"[BUCKETER] Entity %@ is not in the datafile. Not activating user %@."; // changed text from from 'variation' to 'entity'

// ---- Client ----
// error
NSString *const OPTLYLoggerMessagesActivationFailure = @"[CLIENT] Not activating user %@ for experiment %@."; // NOTE: also in Optimizely
NSString *const OPTLYLoggerMessagesGetVariationFailure = @"[CLIENT] Could not get variation for user %@ for experiment %@."; // user ID, experiment key
NSString *const OPTLYLoggerMessagesTrackFailure = @"[CLIENT] Not tracking event %@ for experiment %@."; // NOTE: also in Optimizely

// ---- Data Store ----
// Event Data Store
// debug
NSString *const OPTLYLoggerMessagesDataStoreDatabaseEventDataStoreError = @"[DATA STORE] Event data store initialization failed with the following error: %@";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseSaveError = @"[DATA STORE] Error saving events to database. Data: %@, eventType: %@, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetError = @"[DATA STORE] Error getting events. Number of events requested: %ld, eventType: %@, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNumberEvents = @"[DATA STORE] Error getting number of events. eventType: %@, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveError = @"[DATA STORE] Error removing events. Number of events to remove: %@, eventType: %ld, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveEventError = @"[DATA STORE] Remove event error: %@, eventType: %@, event: %@.";
// warning
NSString *const OPTLYLoggerMessagesDataStoreEventsRemoveAllWarning = @"[DATA STORE] Warning: Removing all events from data store! These events will not be tracked by Optimizely.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNoEvents = @"[DATA STORE] Get event returned no event. eventType: %@.";

// File Manager
// debug
NSString *const OPTLYLoggerMessagesDataStoreFileManagerGetFile = @"[FILE MANAGER] Error getting file for data type %ld. File name: %@. Error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveAllFilesError = @"[FILE MANAGER] Remove all files error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFileForDataTypeError = @"[FILE MANAGER] Error removing file for data type %ld. File name: %@. Error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFilesForDataTypeError = @"[FILE MANAGER] Error removing files for data type %ld. Error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerSaveFile = @"[FILE MANAGER] Error saving file for data type %ld. File name: %@. Error: %@.";

// ---- Datafile Manager ----
// debug
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedError = @"[DATAFILE MANAGER] Datafile for project %@ NOT downloaded. Error received: %@.";
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedNoChanges = @"[DATAFILE MANAGER] Datafile for project %@ NOT downloaded. No datafile changes have been made.";
NSString *const OPTLYLoggerMessagesDatafileManagerLastModifiedDateFound = @"[DATAFILE MANAGER] Last modified date %@ found for project %@.";
NSString *const OPTLYLoggerMessagesDatafileManagerLastModifiedDateNotFound = @"[DATAFILE MANAGER] Last modified date not found for project %@.";
NSString *const OPTLYLoggerMessagesDatafileManagerLastModifiedDate = @"[DATAFILE MANAGER] Datafile was last modified on %@.";
// info
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileDownloaded = @"[DATAFILE MANAGER] Datafile for project %@ downloaded. Saving datafile and last modified date: %@.";
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileDownloading = @"[DATAFILE MANAGER] Downloading datafile for project %@.";

// Datafile Manager Builder
// warning
NSString *const OPTLYLoggerMessagesDatafileManagerInitializedWithoutProjectIdMessage = @"[DATAFILE MANAGER BUILDER] Optimizely Datafile Manager must be initialized with a project ID.";
// error
NSString *const OPTLYLoggerMessagesDatafileFetchIntervalInvalid = @"[DATAFILE MANAGER BUILDER] A datafile fetch interval of %f is invalid. Please set a datafile fetch interval >= 0."; // invalid datafile fetch interval value

// ---- Datafile Versioning ----
// warning
NSString *const OPTLYLoggerMessagesInvalidDatafileVersion = @"[PROJECT CONFIG] Datafile version is invalid for this SDK version: expected %@ and received %@."; // datafile version

// ---- Event Builder ----
// debug
NSString *const OPTLYLoggerMessagesAttributeInvalidFormat = @"[EVENT BUILDER] Provided attribute %@ is in an invalid format."; // added id parameter, changed to singular
NSString *const OPTLYLoggerMessagesAttributeValueInvalidFormat = @"[EVENT BUILDER] Provided value for attribute %@ is in an invalid format.";
NSString *const OPTLYLoggerMessagesEventNotAssociatedWithExperiment = @"[EVENT BUILDER] Event key %@ is not associated with any experiment."; // event key
NSString *const OPTLYLoggerMessagesExperimentNotPartOfEvent = @"[EVENT BUILDER] Experiment %@ is not associated with event %@.";
// warning
NSString *const OPTLYLoggerMessagesBucketerInvalid = @"[EVENT BUILDER] Bucketer is not valid.";
NSString *const OPTLYLoggerMessagesEventKeyInvalid = @"[EVENT BUILDER] Event key cannot be an empty string.";
NSString *const OPTLYLoggerMessagesExperimentKeyInvalid = @"[EVENT BUILDER] Experiment key cannot be an empty string.";
NSString *const OPTLYLoggerMessagesNotBuildingDecisionEventTicket = @"[EVENT BUILDER] Not building decision event ticket for experiment key %@.";
NSString *const OPTLYLoggerMessagesUserIdInvalid = @"[EVENT BUILDER] User ID cannot be an empty string.";
NSString *const OPTLYLoggerMessagesVariationIdInvalid = @"[EVENT BUILDER] Variation ID cannot be an empty string.";

// ---- Event Dispatcher ----
// debug
NSString *const OPTLYLoggerMessagesEventDispatcherDispatchingConversionEvent = @"[EVENT DISPATCHER] Dispatching conversion event with params %@.";
NSString *const OPTLYLoggerMessagesEventDispatcherDispatchingImpressionEvent = @"[EVENT DISPATCHER] Dispatching impression event with params %@.";
NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchFailed = @"[EVENT DISPATCHER] %@ event not sent. Saving event. Parameters: %@. Error received: %@.";
NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchFlushSavedEventNoEvents =  @"[EVENT DISPATCHER] No %@ events to send for flush saved events call.";
NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchSuccess = @"[EVENT DISPATCHER] %@ event sent with parameters: %@.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsBackoffMaxRetries = @"[EVENT DISPATCHER] Attempt to dispatch saved events failed. Retries have exceeded max allowed time: %ld.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsBackoffSkipRetry = @"[EVENT DISPATCHER] At dispatch call %ld. Skipping dispatch retry.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsNoEvents = @"[EVENT DISPATCHER] No events to send for flushEvents call.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventFailure = @"[EVENT DISPATCHER] %@ event not sent and will not be removed from the queue. Parameters: %@.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventSuccess = @"[EVENT DISPATCHER] %@ event successfully sent with parameters: %@. Removing event from storage.";
NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerEnabled = @"[EVENT DISPATCHER] Network timer enabled with properties: %ld [interval], %ld [timeout], %ld [max retries].";
NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerDisabled = @"[EVENT DISPATCHER] Network timer disabled.";
NSString *const OPTLYLoggerMessagesEventDispatcherProperties =  @"[EVENT DISPATCHER] Properties set: %ld [interval], %ld [timeout], %ld [max retries].";
// warning
NSString *const OPTLYLoggerMessagesEventDispatcherInvalidInterval =  @"[EVENT DISPATCHER] Invalid event handler dispatch interval set: %ld.";
NSString *const OPTLYLoggerMessagesEventDispatcherInvalidTimeout = @"[EVENT DISPATCHER] Invalid event handler dispatch timeout set: %ld.";

// ---- Live Variables ----
// info
NSString *const OPTLYLoggerMessagesNoVariationFoundForExperimentWithLiveVariable = @"[LIVE VARIABLES] Variation not found for user ID: %@ with experiment key: %@ containing live variable: %@.";
// warning
NSString *const OPTLYLoggerMessagesNoExperimentsContainVariable = @"[LIVE VARIABLES] No experiment was found to contain variable key: %@.";
NSString *const OPTLYLoggerMessagesVariableUnknownForVariableKey = @"[LIVE VARIABLES] Live variable not found for variable key: %@."; // live variable key

// ---- Manager ----
// error
NSString *const OPTLYLoggerMessagesManagerBuilderNotValid = @"[MANAGER] An Optimizely Manager instance was not able to be initialized because the OPTLYManagerBuilder object was invalid.";
NSString *const OPTLYLoggerMessagesManagerMustBeInitializedWithProjectId = @"[MANAGER] An Optimizely Manager instance must be initialized with a project ID.";

// ---- Project Config Getters ----
// warning
NSString *const OPTLYLoggerMessagesAttributeUnknownForAttributeKey = @"[PROJECT CONFIG] Attribute not found for attribute key: %@. Attribute key is not in the datafile."; // attribute key
NSString *const OPTLYLoggerMessagesAudienceUnknownForAudienceId = @"[PROJECT CONFIG] Audience not found for audience ID: %@. Audience ID is not in the datafile."; // audience id
NSString *const OPTLYLoggerMessagesEventIdUnknownForEventKey = @"[PROJECT CONFIG] Event ID not found for event key: %@. Event ID is not in the datafile."; // event key
NSString *const OPTLYLoggerMessagesEventUnknownForEventKey = @"[PROJECT CONFIG] Event not found for event key: %@. Event key is not in the datafile."; // event key
NSString *const OPTLYLoggerMessagesExperimentIdUnknownForExperimentKey = @"[PROJECT CONFIG] Experiment ID not found for experiment key: %@. Experiment key is not in the datafile."; // experiment key
NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentId = @"[PROJECT CONFIG] Experiment not found for experiment ID: %@. Experiment ID is not in the datafile."; // experiment id
NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentKey = @"[PROJECT CONFIG] Experiment not found for experiment key: %@. Experiment key is not in the datafile."; // experiment key
NSString *const OPTLYLoggerMessagesGroupUnknownForGroupId = @"[PROJECT CONFIG] Group not found for group ID: %@. Group ID is not in the datafile."; // group id

// ---- User Profile ----
// debug
NSString *const OPTLYLoggerMessagesUserProfileBucketerUserDataRetrieved = @"[USER PROFILE] Retrieved bucketing data for user: %@, experiment: %@, variation: %@.";
NSString *const OPTLYLoggerMessagesUserProfileAttemptToSaveVariation = @"[USER PROFILE] Attempting to save experiment %@ with variation %@ for user %@.";
NSString *const OPTLYLoggerMessagesUserProfileNoVariation = @"[USER PROFILE] Variation for user %@, experiment %@ not found.";
NSString *const OPTLYLoggerMessagesUserProfileRemoveVariation = @"[USER PROFILE] Removed variation %@ for user %@, experiment %@.";
NSString *const OPTLYLoggerMessagesUserProfileRemoveVariationNotFound = @"[USER PROFILE] Not removing variation for user %@, experiment %@. Variation not found.";
NSString *const OPTLYLoggerMessagesUserProfileSavedVariation = @"[USER PROFILE] Saved experiment %@ with variation %@ for user %@.";
NSString *const OPTLYLoggerMessagesUserProfileVariation = @"[USER PROFILE] Variation %@ for user %@, experiment %@ found.";
// warning
NSString *const OPTLYLoggerMessagesUserProfileUnableToSaveVariation = @"[USER PROFILE] Unable to save experiment %@ with variation %@ for user %@.";
NSString *const OPTLYLoggerMessagesUserProfileVariationNoLongerInDatafile = @"[USER PROFILE] Variation %@ for experiment %@ no longer found in datafile.";

// ---- Validator ----
// info
NSString *const OPTLYLoggerMessagesExperimentNotRunning = @"[VALIDATOR] Experiment %@ is not running.";
NSString *const OPTLYLoggerMessagesFailAudienceTargeting = @"[VALIDATOR] User %@ does not meet conditions to be in experiment %@.";

@implementation OPTLYLoggerMessages

@end
