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
NSString *const OPTLYLoggerMessagesDatafileFetchIntervalInvalid = @"A datafile fetch interval of %f is invalid. Please set a datafile fetch interval >= 0."; // invalid datafile fetch interval value
NSString *const OPTLYLoggerMessagesManagerMustBeInitializedWithProjectId = @"An Optimizely Manager instance must be initialized with a project ID";
NSString *const OPTLYLoggerMessagesManagerBuilderNotValid = @"An Optimizely Manager instance was not able to be initialized because the OPTLYManagerBuilder object was invalid";

// ---- warnings ----
NSString *const OPTLYLoggerMessagesExperimentUnknown = @"Experiment %@ is not in the datafile."; // experiment id
NSString *const OPTLYLoggerMessagesEventUnknown = @"Event %@ is not in the datafile." ; //event key
NSString *const OPTLYLoggerMessagesAttributeUnknown = @"Attribute(s) %@ not in the datafile."; // attribute ids
NSString *const OPTLYLoggerMessagesAudienceUnknown = @"Audience %@ not in the datafile."; // audience id
NSString *const OPTLYLoggerMessagesGetVariationFailed = @"Could not get variation for user %@ for experiment %@."; // user ID, experiment key
NSString *const OPTLYDatafileManagerInitializedWithoutProjectIdMessage = @"Optimizely Datafile Manager must be initialized with a project ID.";

// ---- info ----
NSString *const OPTLYLoggerMessagesAudienceTargetingFail = @"User %@ does not meet conditions to be in experiment %@.";
NSString *const OPTLYLoggerMessagesNoExperimentsForGoal = @"There are no valid experiments for event %@ to track.";
NSString *const OPTLYLoggerMessagesVariationUserAssigned = @"User %@ is in variation %@ of experiment %@.";
NSString *const OPTLYLoggerMessagesForcedVariationUser = @"User %@ is forced in variation %@.";
NSString *const OPTLYLoggerMessagesFailAudienceTargeting = @"User %@ does not meet conditions to be in experiment %@.";
NSString *const OPTLYLoggerMessagesExperimentNotRunning = @"Experiment %@ is not running.";
NSString *const OPTLYLoggerMessagesUserMutuallyExcluded = @"User %ld is mutually excluded"; // user id
NSString *const OPTLYLoggerMessagesExperimentIdUnknown = @"Experiment id for %@ is not in the datafile."; // experiment key
NSString *const OPTLYLoggerMessagesEventIdUnknown = @"Event id %@ is not in the datafile."; //event key
// conversion and tracking event creation errors
NSString *const OPTLYLoggerMessagesVariationtNameInvalid = @"Variation name is not valid.";
NSString *const OPTLYLoggerMessagesUserIdInvalid = @"User id is not valid.";
NSString *const OPTLYLoggerMessagesExperimentKeyInvalid = @"Experiment key is not valid.";
NSString *const OPTLYLoggerMessagesVariationIdInvalid = @"Variation id is not valid.";
NSString *const OPTLYLoggerMessagesBucketerInvalid = @"Bucketer is not valid.";
NSString *const OPTLYLoggerMessagesExperimentNotPartOfEvent = @"Experiment %@ is not associated with event %@.";
NSString *const OPTLYLoggerMessagesAttributeValueInvalidFormat = @"Provided value for attribute %@ is in an invalid format."; 
// project config getters
// warning
NSString *const OPTLYLoggerMessagesExperimentIdUnknownForExperimentKey = @"Experiment id not found for experiment key: %@."; // experiment id
NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentKey = @"Experiment not found for experiment key: %@."; // experiment key
NSString *const OPTLYLoggerMessagesEventIdUnknownForEventKey = @"Event id not found for event key: %@."; // event key
NSString *const OPTLYLoggerMessagesEventUnknownForEventKey = @"Event not found for event key: %@."; // event key
NSString *const OPTLYLoggerMessagesAttributeUnknownForAttributeKey = @"Attribute not found for attribute key: %@."; // attribute key
NSString *const OPTLYLoggerMessagesAudienceUnknownForAudienceId = @"Audience not found for audience id: %@."; // audience id
NSString *const OPTLYLoggerMessagesGroupUnknownForGroupId = @"Group not found for group id: %@."; // group id
NSString *const OPTLYLoggerMessagesVariationUnknownForVariationKey = @"Unknown variation for variation key: %@."; // variation key
NSString *const OPTLYLoggerMessagesVariableUnknownForVariableKey = @"Live variable not found for variable key: %@."; // live variable key
NSString *const OPTLYLoggerMessagesEventDispatcherInterval = @"Event dispatcher interval set: %ld";

// ---- Debug ----
NSString *const OPTLYLoggerMessagesBucketAssigned = @"Assigned bucket %@ to user %@.";

// ---- Event Dispatcher ----
// info
NSString *const OPTLYLoggerMessagesEventDispatcherTrackingEvent = @"[EVENT DISPATCHER] Tracking event %@ for user %@";
NSString *const OPTLYLoggerMessagesEventDispatcherActivatingUser = @"[EVENT DISPATCHER] Activating user %@ in experiment %@";
NSString *const OPTLYLoggerMessagesEventDispatcherTrackingSuccess = @"[EVENT DISPATCHER] Successfully tracked event %@ for user %@";
NSString *const OPTLYLoggerMessagesEventDispatcherActivationSuccess = @"[EVENT DISPATCHER] Successfully activated user %@ in experiment %@ success";
// warning
NSString *const OPTLYLoggerMessagesEventDispatcherInvalidInterval =  @"[EVENT DISPATCHER] Invalid event handler dispatch interval set: %ld";
NSString *const OPTLYLoggerMessagesEventDispatcherInvalidTimeout = @"[EVENT DISPATCHER] Invalid event handler dispatch timeout set: %ld";
// debug
NSString *const OPTLYLoggerMessagesEventDispatcherProperties =  @"[EVENT DISPATCHER] Properties set: %ld [interval], %ld [timeout]";
NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerEnabled = @"[EVENT DISPATCHER] Network timer enabled with properties: %ld [interval], %ld [timeout]";
NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerDisabled = @"[EVENT DISPATCHER] Network timer disabled";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushingEvents = @"[EVENT DISPATCHER] Flushing events";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsNoEvents = @"[EVENT DISPATCHER] No events to flush";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushingSavedEvents = @"[EVENT DISPATCHER] Flushing saved %@. Number of events: %lu";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventsNoEvents =  @"[EVENT DISPATCHER] No %@ to flush";
NSString *const OPTLYLoggerMessagesEventDispatcherDispatchFailed =  @"[EVENT DISPATCHER] %@ dispatch failed with error: %@";
NSString *const OPTLYLoggerMessagesEventDispatcherPendingEvent = @"[EVENT DISPATCHER] Event already pending dispatch: %@";
NSString *const OPTLYLoggerMessagesEventDispatcherEventSaved = @"[EVENT DISPATCHER] %@ saved: %@"; //event type, event
NSString *const OPTLYLoggerMessagesEventDispatcherRemovedEvent = @"[EVENT DISPATCHER] %@ removed: %@"; //event type, event
// error
NSString *const OPTLYLoggerMessagesEventDispatcherEventNotTracked = @"[EVENT DISPATCHER] Not tracking event %@ for experiment %@."; // event key, userId
NSString *const OPTLYLoggerMessagesEventDispatcherActivationFailure = @"[EVENT DISPATCHER] Not activating user %@ for experiment %@.";

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
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveAllFilesError = @"[FILE MANAGER] Remove all files error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFilesForDataTypeError = @"[FILE MANAGER] Error removing files for data type %ld. Error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFileForDataTypeError = @"[FILE MANAGER] Error removing file for data type %ld. File name: %@. Error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerGetFile = @"[FILE MANAGER] Error getting file for data type %ld. File name: %@. Error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerSaveFile = @"[FILE MANAGER] Error saving file for data type %ld. File name: %@. Error: %@.";

// ---- User Profile ----
//warning
NSString *const OPTLYLoggerMessagesUserProfileVariationNoLongerInDatafile = @"Variation %@ for experiment %@ no longer found in datafile.";
NSString *const OPTLYLoggerMessagesUserProfileUnableToSaveVariation = @"Unable to save experiment %@ with variation %@ for user %@.";
// Debug
NSString *const OPTLYLoggerMessagesUserProfileVariation = @"Variation %@ for user %@, experiment %@ found.";
NSString *const OPTLYLoggerMessagesUserProfileNoVariation = @"Variation for user %@, experiment %@ not found.";
NSString *const OPTLYLoggerMessagesUserProfileRemoveVariation = @"Removed variation %@ for user %@, experiment %@.";
NSString *const OPTLYLoggerMessagesUserProfileRemoveVariationNotFound = @"Not removing variation for user %@, experiment %@. Variation not found.";
NSString *const OPTLYLoggerMessagesUserProfileAttemptToSaveVariation = @"Attempting to save experiment %@ with variation %@ for user %@.";
NSString *const OPTLYLoggerMessagesUserProfileSavedVariation = @"Saved experiment %@ with variation %@ for user %@.";

// ---- Bucketing ----
// Debug
NSString *const OPTLYLoggerMessagesBucketerSavingUserData = @"Saving bucketing data for user: %@, experiment: %@, variation: %@.";
NSString *const OPTLYLoggerMessagesBucketerUserDataRetrieved = @"Retrieved bucketing data for user: %@, experiment: %@, variation: %@.";

// ---- Datafile Nanager ----
// Info
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileDownloading = @"[DATAFILE MANAGER] Downloading datafile for project %@.";
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileDownloaded = @"[DATAFILE MANAGER] Datafile for project %@ downloaded. Saving datafile and last modified date: %@.";
// Debug
NSString *const OPTLYLoggerMessagesDatafileManagerLastModifiedDate = @"[DATAFILE MANAGER] Datafile was last modified on %@.";
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedNoChanges = @"[DATAFILE MANAGER] Datafile for project %@ NOT downloaded. No datafile changes have been made.";
NSString *const OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedError = @"[DATAFILE MANAGER] Datafile for project %@ NOT downloaded. Error received: %@.";
NSString *const OPTLYLoggerMessagesDatafileManagerLastModifedDate = @"[DATAFILE MANAGER] Last modified date %@ found for project %@.";
NSString *const OPTLYLoggerMessagesDatafileManagerLastModifedDateNotFound = @"[DATAFILE MANAGER] Last modified date not found for project %@.";

// ---- Live Variables ----
// Info
NSString *const OPTLYLoggerMessagesNoVariationFoundForExperimentWithLiveVariable = @"Variation not found for user ID: %@ with experiment key: %@ containing live variable: %@.";
// Warning
NSString *const OPTLYLoggerMessagesNoExperimentsContainVariable = @"No experiment was found to contain variable key: %@.";

// ---- Datafile Versioning ----
// Warning
NSString *const OPTLYLoggerMessagesInvalidDatafileVersion = @"Datafile version is invalid for this SDK version: expected %@ and received %@."; // datafile version

@implementation OPTLYLoggerMessages

@end
