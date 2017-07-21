/****************************************************************************
 * Copyright 2016-2017, Optimizely, Inc. and contributors                   *
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
NSString *const OPTLYLoggerMessagesUserMutuallyExcluded = @"[BUCKETER] User %@ is not in experiment %@ of group %@."; // user id, experiment key, group ID // user id
// error
NSString *const OPTLYLoggerMessagesForcedBucketingFailed = @"[BUCKETER] Entity %@ is not in the datafile. Not activating user %@."; // changed text from from 'variation' to 'entity'

// ---- Client ----
// error
NSString *const OPTLYLoggerMessagesActivationFailure = @"[CLIENT] Not activating user %@ for experiment %@."; // NOTE: also in Optimizely
NSString *const OPTLYLoggerMessagesClientDummyOptimizelyError = @"[CLIENT] Optimizely is not initialized.";
NSString *const OPTLYLoggerMessagesGetVariationFailure = @"[CLIENT] Could not get variation for user %@ for experiment %@."; // user ID, experiment key
NSString *const OPTLYLoggerMessagesTrackFailure = @"[CLIENT] Not tracking event %@ for user %@."; // NOTE: also in Optimizely

// ---- Data Store ----
// Event Data Store
// debug
NSString *const OPTLYLoggerMessagesDataStoreDatabaseEventDataStoreError = @"[DATA STORE] Event data store initialization failed with the following error: %@";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseSaveError = @"[DATA STORE] Error saving events to database. Data: %@, eventType: %@, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetError = @"[DATA STORE] Error getting events. Number of events requested: %ld, eventType: %@, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNumberEvents = @"[DATA STORE] Error getting number of events. eventType: %@, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveError = @"[DATA STORE] Error removing events. Number of events to remove: %ld, eventType: %@, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveEventError = @"[DATA STORE] Remove event error: %@, eventType: %@, event: %@.";
// warning
NSString *const OPTLYLoggerMessagesDataStoreEventsRemoveAllWarning = @"[DATA STORE] Warning: Removing all events from data store! These events will not be tracked by Optimizely.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNoEvents = @"[DATA STORE] Get event returned no event. eventType: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemovingOldEvents = @"[DATA STORE] Event storage is full. Removing %lu events.";

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
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileSaved = @"[DATAFILE MANAGER] Datafile saved for project %@.";

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
NSString *const OPTLYLoggerMessagesEventNotPassAudienceEvaluation = @"[EVENT BUILDER] None of the experiments of %@ pass audience evaluation.";
NSString *const OPTLYLoggerMessagesRevenueValueInvalid = @"[EVENT BUILDER] Provided revenue value is not an integer.";
NSString *const OPTLYLoggerMessagesEventTagValueInvalid = @"[EVENT BUILDER] Provided event tag %@ is neither an integer nor a string; skipping.";


// ---- Event Dispatcher ----
// info
NSString *const OPTLYLoggerMessagesEventDispatcherAttemptingToSendConversionEvent = @"[EVENT DISPATCHER] Attempting to send conversion event %@ for user %@";
NSString *const OPTLYLoggerMessagesEventDispatcherAttemptingToSendImpressionEvent = @"[EVENT DISPATCHER] Attempting to send impression event for user %@ in experiment %@";
NSString *const OPTLYLoggerMessagesEventDispatcherTrackingSuccess = @"[EVENT DISPATCHER] Successfully tracked event %@ for user %@";
NSString *const OPTLYLoggerMessagesEventDispatcherActivationSuccess = @"[EVENT DISPATCHER] Successfully activated user %@ in experiment %@";
// warning
NSString *const OPTLYLoggerMessagesEventDispatcherInvalidInterval =  @"[EVENT DISPATCHER] Invalid dispatch interval set: %ld";

// debug
NSString *const OPTLYLoggerMessagesEventDispatcherProperties =  @"[EVENT DISPATCHER] Event dispatch interval: %ld [second(s)]";
NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerEnabled = @"[EVENT DISPATCHER] Network timer enabled with interval: %ld [second(s)].";
NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerDisabled = @"[EVENT DISPATCHER] Network timer disabled";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushingEvents = @"[EVENT DISPATCHER] Flushing events";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsNoEvents = @"[EVENT DISPATCHER] No events to flush";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsMax = @"[EVENT DISPATCHER] Max number of flush events attempted %lu.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushingSavedEvents = @"[EVENT DISPATCHER] Flushing saved %@. Number of events: %lu";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventsNoEvents =  @"[EVENT DISPATCHER] No %@ to flush";
NSString *const OPTLYLoggerMessagesEventDispatcherDispatchFailed =  @"[EVENT DISPATCHER] %@ dispatch failed with error: %@";
NSString *const OPTLYLoggerMessagesEventDispatcherPendingEvent = @"[EVENT DISPATCHER] Event already pending dispatch: %@";
NSString *const OPTLYLoggerMessagesEventDispatcherEventSaved = @"[EVENT DISPATCHER] %@ saved: %@"; //event type, event
NSString *const OPTLYLoggerMessagesEventDispatcherRemovedEvent = @"[EVENT DISPATCHER] %@ removed: %@ with error: %@"; //event type, event, error
NSString *const OPTLYLoggerMessagesEventDispatcherEventNotTracked = @"[EVENT DISPATCHER] Not tracking event %@ for user %@."; // event key, userId
NSString *const OPTLYLoggerMessagesEventDispatcherActivationFailure = @"[EVENT DISPATCHER] Not activating user %@ for experiment %@.";
NSString *const OPTLYLoggerMessagesEventDispatcherInvalidEvent = @"[EVENT DISPATCHER] Invalid event.";

// ---- Live Variables ----
// info
NSString *const OPTLYLoggerMessagesNoVariationFoundForExperimentWithLiveVariable = @"[LIVE VARIABLES] Variation not found for user ID: %@ with experiment key: %@ containing live variable: %@.";
// warning
NSString *const OPTLYLoggerMessagesNoExperimentsContainVariable = @"[LIVE VARIABLES] No experiment was found to contain variable key: %@.";
NSString *const OPTLYLoggerMessagesVariableUnknownForVariableKey = @"[LIVE VARIABLES] Live variable not found for variable key: %@."; // live variable key

// ---- Manager ----
// error
NSString *const OPTLYLoggerMessagesManagerBuilderNotValid = @"[MANAGER] An Optimizely Manager instance was not able to be initialized because the OPTLYManagerBuilder object was invalid.";
NSString *const OPTLYLoggerMessagesManagerDatafileManagerDoesNotConformToOPTLYDatafileManagerProtocol = @"[MANAGER] Datafile manager does not conform to the OPTLYDatafileManager protocol.";
NSString *const OPTLYLoggerMessagesManagerErrorHandlerDoesNotConformToOPTLYErrorHandlerProtocol = @"[MANAGER] Error handler does not conform to the OPTLYErrorHandler protocol.";
NSString *const OPTLYLoggerMessagesManagerEventDispatcherDoesNotConformToOPTLYEventDispatcherProtocol = @"[MANAGER] Event dispatcher does not conform to the OPTLYEventDispatcher protocol.";
NSString *const OPTLYLoggerMessagesManagerLoggerDoesNotConformToOPTLYLoggerProtocol = @"[MANAGER] Logger does not conform to the OPTLYLogger protocol.";
NSString *const OPTLYLoggerMessagesManagerMustBeInitializedWithProjectId = @"[MANAGER] An Optimizely Manager instance must be initialized with a project ID.";
NSString *const OPTLYLoggerMessagesManagerProjectIdCannotBeEmptyString = @"[MANAGER] The project ID for the Optimizely Manager instance cannot be an empty string";

// ---- Project Config Getters ----
// warning
NSString *const OPTLYLoggerMessagesAttributeUnknownForAttributeKey = @"[PROJECT CONFIG] Attribute not found for attribute key: %@. Attribute key is not in the datafile."; // attribute key
NSString *const OPTLYLoggerMessagesAudienceUnknownForAudienceId = @"[PROJECT CONFIG] Audience not found for audience ID: %@. Audience ID is not in the datafile."; // audience id
NSString *const OPTLYLoggerMessagesEventIdUnknownForEventKey = @"[PROJECT CONFIG] Event ID not found for event key: %@. Event ID is not in the datafile."; // event key
NSString *const OPTLYLoggerMessagesEventUnknownForEventKey = @"[PROJECT CONFIG] Event not found for event key: %@. Event key is not in the datafile."; // event key
NSString *const OPTLYLoggerMessagesExperimentIdUnknownForExperimentKey = @"[PROJECT CONFIG] Experiment ID not found for experiment key: %@. Experiment key is not in the datafile."; // experiment key
NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentId = @"[PROJECT CONFIG] Experiment not found for experiment ID: %@. Experiment ID is not in the datafile."; // experiment id
NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentKey = @"[PROJECT CONFIG] Experiment key not found for experiment: %@. Experiment key is not in the datafile.";  // experiment key
NSString *const OPTLYLoggerMessagesGroupUnknownForGroupId = @"[PROJECT CONFIG] Group not found for group ID: %@. Group ID is not in the datafile."; // group id

// ---- User Profile ----
// debug
NSString *const OPTLYLoggerMessagesUserProfileBucketerUserDataRetrieved = @"[USER PROFILE] Retrieved bucketing data for user: %@, experiment ID: %@, variation ID: %@.";
NSString *const OPTLYLoggerMessagesUserProfileAttemptToSaveVariation = @"[USER PROFILE] Attempting to save experiment ID %@ with variation ID %@ for user %@."; // experiment ID, variation ID, user ID
NSString *const OPTLYLoggerMessagesUserProfileNoVariation = @"[USER PROFILE] Variation for user %@, experiment ID %@ not found."; // user ID, experiment ID
NSString *const OPTLYLoggerMessagesUserProfileRemoveVariation = @"[USER PROFILE] Removed variation ID %@ for user %@, experiment ID %@."; // variation ID, user ID, experiment ID
NSString *const OPTLYLoggerMessagesUserProfileRemoveVariationNotFound = @"[USER PROFILE] Not removing variation for user %@, experiment ID %@. Variation not found."; // user ID, experiment ID
NSString *const OPTLYLoggerMessagesUserProfileSavedVariation = @"[USER PROFILE] Saved experiment ID %@ with variation ID %@ for user %@.";
NSString *const OPTLYLoggerMessagesUserProfileVariation = @"[USER PROFILE] Variation ID %@ for user %@, experiment ID %@ found."; // variation ID, user ID, experiment ID
// warning
NSString *const OPTLYLoggerMessagesUserProfileUnableToSaveVariation = @"[USER PROFILE] Unable to save experiment ID %@ with variation ID %@ for user %@."; // experiment ID, variation ID, user ID
NSString *const OPTLYLoggerMessagesUserProfileVariationNoLongerInDatafile = @"[USER PROFILE] Variation ID: %@ for experiment ID: %@ no longer found in datafile."; // variation ID, experiment ID

// ---- Validator ----
// info
NSString *const OPTLYLoggerMessagesExperimentNotRunning = @"[VALIDATOR] Experiment %@ is not running.";
NSString *const OPTLYLoggerMessagesFailAudienceTargeting = @"[VALIDATOR] User %@ does not meet conditions to be in experiment %@.";

// ---- HTTP Request Manager ----
// Debug (not through logger handler)
NSString *const OPTLYHTTPRequestManagerGETWithParametersAttempt = @"[HTTP] GET with parameter attempt: %lu";
NSString *const OPTLYHTTPRequestManagerGETIfModifiedSince = @"[HTTP] GET if modified attempt: %lu";
NSString *const OPTLYHTTPRequestManagerPOSTWithParameters = @"[HTTP] POST attempt: %lu";
NSString *const OPTLYHTTPRequestManagerBackoffRetryStates = @"[HTTP] Retry attempt: %d exponentialMultiplier: %u delay_ns: %lu, delayTime: %lu";

@implementation OPTLYLoggerMessages

@end
