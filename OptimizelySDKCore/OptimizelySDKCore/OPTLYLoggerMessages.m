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
NSString *const OPTLYLoggerMessagesExperimentIdUnknownForExperimentKey = @"Experiment id not found for experiment key: %@."; // experiment id
NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentKey = @"Experiment not found for experiment key: %@."; // experiment key
NSString *const OPTLYLoggerMessagesEventIdUnknownForEventKey = @"Event id not found for event key: %@."; // event key
NSString *const OPTLYLoggerMessagesEventUnknownForEventKey = @"Event not found for event key: %@."; // event key
NSString *const OPTLYLoggerMessagesAttributeUnknownForAttributeKey = @"Attribute not found for attribute key: %@."; // attribute key
NSString *const OPTLYLoggerMessagesAudienceUnknownForAudienceId = @"Audience not found for audience id: %@."; // audience id
NSString *const OPTLYLoggerMessagesGroupUnknownForGroupId = @"Group not found for group id: %@."; // group id
NSString *const OPTLYLoggerMessagesEventDispatcherInterval = @"Event dispatcher interval set: %ld";

// ---- Debug ----
NSString *const OPTLYLoggerMessagesBucketAssigned = @"Assigned bucket %@ to user %@.";

// ---- Event Tracking ----
// info
NSString *const OPTLYLoggerMessagesConversionSuccess = @"Tracking event %@ for user %@.";
NSString *const OPTLYLoggerMessagesActivationSuccess = @"Activating user %@ in experiment %@.";
// warning
NSString *const OPTLYLoggerMessagesEventDispatcherInvalidInterval =  @"Invalid event handler dispatch interval set - %ld";
NSString *const OPTLYLoggerMessagesEventDispatcherInvalidTimeout = @"Invalid event handler dispatch timeout set - %ld";
// debug
NSString *const OPTLYLoggerMessagesDispatchingImpressionEvent = @"Dispatching impression event with params %@.";
NSString *const OPTLYLoggerMessagesDispatchingConversionEvent = @"Dispatching conversion event with params %@.";
NSString *const OPTLYLoggerMessagesEventDispatcherProperties =  @"Event dispatcher values set: interval - %ld, timeout - %ld, max backoff retries - %ld";
NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerEnabled = @"Event dispatcher network timer enabled - %ld, %ld, %ld.";
NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerDisabled = @"Event dispatcher network timer disabled.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsNoEvents = @"No events to send for flushEvents call.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsBackoffSkipRetry = @"At dispatch call %ld. Skipping dispatch retry.";
NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchFlushSavedEventNoEvents =  @"No %@ events to send for flush saved events call.";
NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchSuccess = @"%@ event sent with parameters - %@.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsBackoffMaxRetries = @"Attempt to dispatch saved events failed. Re-tries have exceeded max allowed time - %ld.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventSuccess = @"%@ event successfully sent with parameters - %@. Removing event from storage.";
NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchFailed = @"%@ event not sent. Parameters - %@. Error received - %@. Saving event...";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventFailure = @"%@ event not sent. Parameters - %@.";
NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventRetrievalFailure = @"Error retrieving saved event data - %@";
// error
NSString *const OPTLYLoggerMessagesEventNotTracked = @"Not tracking event %@ for experiment %@."; // event key, userId
NSString *const OPTLYLoggerMessagesActivationFailure = @"Not activating user %@ for experiment %@.";


// ---- Data Store ----
// File Manager
// debug
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveAllFilesError = @"File manager remove all files error - %@";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveAllFilesForDataTypeError = @"File manager remove files for data type - %ld, error - %@";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFileForDataTypeError = @"File manager remove file for data type - %ld, file name - %@, error - %@";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerGetFile = @"File manager get file for data type - %ld, file name - %@, error - %@";
NSString *const OPTLYLoggerMessagesDataStoreFileManagerSaveFile = @"File manager save file for data type - %ld, file name - %@, error - %@";

// Database
// debug
NSString *const OPTLYLoggerMessagesDataStoreDatabaseCreateTableError = @"Creating database table %@ error - %@";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseSaveError = @"Database save error: data - %@, eventType - %ld, cachedData - %u, error - %@";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetError = @"Database get error: number of events - %ld, eventType - %ld, cachedData - %u, error - %@";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNumberEvents = @"Database can only get number of events error: cachedData - %u, eventType - %ld, error - %@.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveError = @"Database remove error: number of events - %ld, eventType - %ld, cachedData - %u, error - %@";
// warning
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNoEvents = @"Database get event returned no event: eventType - %ld, cachedData - %u";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseSaveTVOSWarning = @"tvOS can only save to cached data: data - %@, eventType - %ld.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetTVOSWarning = @"tvOS can only get data from cache: number of events - %ld, eventType - %ld.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNumberEventsTVOSWarning = @"tvOS can only get number of events from cache: eventType - %ld.";
NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveTVOSWarning = @"tvOS can only remove data from cache: number of events - %ld, eventType - %ld.";



@implementation OPTLYLoggerMessages

@end
