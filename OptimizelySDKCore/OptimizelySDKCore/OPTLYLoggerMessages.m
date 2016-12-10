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

// ---- Event Tracking ----
// info
NSString *const OPTLYLoggerMessagesConversionSuccess = @"[EVENT DISPATCH] Tracking event %@ for user %@.";
NSString *const OPTLYLoggerMessagesActivationSuccess = @"[EVENT DISPATCH] Activating user %@ in experiment %@.";
// warning
NSString *const OPTLYLoggerMessagesEventDispatcherInvalidInterval =  @"[EVENT DISPATCH] Invalid event handler dispatch interval set: %ld.";
NSString *const OPTLYLoggerMessagesEventDispatcherInvalidTimeout = @"[EVENT DISPATCH] Invalid event handler dispatch timeout set: %ld.";
// debug
NSString *const OPTLYLoggerMessagesDispatchingImpressionEvent = @"[EVENT DISPATCH] Dispatching impression event with params %@.";
NSString *const OPTLYLoggerMessagesDispatchingConversionEvent = @"[EVENT DISPATCH] Dispatching conversion event with params %@.";
NSString *const OPTLYLoggerMessagesEventDispatcherProperties =  @"[EVENT DISPATCH] Properties set: %ld [interval], %ld [timeout], %ld [max retries].";
NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerEnabled = @"[EVENT DISPATCH] Network timer enabled with properties: %ld [interval], %ld [timeout], %ld [max retries].";
NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerDisabled = @"[EVENT DISPATCH] Network timer disabled.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsNoEvents = @"[EVENT DISPATCH] No events to send for flushEvents call.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsBackoffSkipRetry = @"[EVENT DISPATCH] At dispatch call %ld. Skipping dispatch retry.";
NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchFlushSavedEventNoEvents =  @"No %@ events to send for flush saved events call.";
NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchSuccess = @"[EVENT DISPATCH] %@ event sent with parameters: %@.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsBackoffMaxRetries = @"[EVENT DISPATCH] Attempt to dispatch saved events failed. Retries have exceeded max allowed time: %ld.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventSuccess = @"[EVENT DISPATCH] %@ event successfully sent with parameters: %@. Removing event from storage.";
NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchFailed = @"[EVENT DISPATCH] %@ event not sent. Saving event. Parameters: %@. Error received: %@.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventFailure = @"[EVENT DISPATCH] %@ event not sent and will not be removed from the queue. Parameters: %@.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventRetrievalFailure = @"[EVENT DISPATCH] Error retrieving saved event data: %@.";
// error
NSString *const OPTLYLoggerMessagesEventNotTracked = @"[EVENT DISPATCH] Not tracking event %@ for experiment %@."; // event key, userId
NSString *const OPTLYLoggerMessagesActivationFailure = @"[EVENT DISPATCH] Not activating user %@ for experiment %@.";


// ---- Data Store ----
// warning
NSString *const OPTLYLoggerMessagesDataStoreEventsRemoveAllWarning = @"[DATA STORE] Warning: Removing all events from data store! These events will not be tracked by Optimizely.";

// File Manager
// debug
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveAllFilesError = @"[FILE MANAGER] Remove all files error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFilesForDataTypeError = @"[FILE MANAGER] Error removing files for data type %ld. Error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFileForDataTypeError = @"[FILE MANAGER] Error removing file for data type %ld. File name: %@. Error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerGetFile = @"[FILE MANAGER] Error getting file for data type %ld. File name: %@. Error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerSaveFile = @"[FILE MANAGER] Error saving file for data type %ld. File name: %@. Error: %@.";

// Database
// debug
NSString *const OPTLYLoggerMessagesDataStoreDatabaseCreateTableError = @"[DATABASE] Error creating table %@. Error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseSaveError = @"[DATABASE] Error saving database. Data: %@, eventType: %ld, cachedData: %u, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetError = @"[DATABASE] Error getting events. Number of events requested: %ld, eventType: %ld, cachedData: %u, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNumberEvents = @"[DATABASE] Error getting number of events. cachedData: %u, eventType: %ld, error: %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveError = @"[DATABASE] Error removing data. Number of events to remove: %ld, eventType: %ld, cachedData: %u, error: %@.";
// warning
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNoEvents = @"[DATABASE] Get event returned no event. eventType: %ld, cachedData: %u.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseSaveTVOSWarning = @"[DATABASE] tvOS can only save to cached data. Data: %@, eventType: %ld.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetTVOSWarning = @"[DATABASE] tvOS can only get data from cache. Number of events: %ld, eventType: %ld.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNumberEventsTVOSWarning = @"[DATABASE] tvOS can only get number of events from cache. eventType: %ld.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveTVOSWarning = @"[DATABASE] tvOS can only remove data from cache> Number of events: %ld, eventType: %ld.";

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

@implementation OPTLYLoggerMessages

@end
