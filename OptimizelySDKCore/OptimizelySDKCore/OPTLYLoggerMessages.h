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

/*
    This class contains all the log messages that will be called by the SDK.
*/

#import <Foundation/Foundation.h>

// ---- Optimizely ----
// debug
extern NSString *const OPTLYLoggerMessagesVariationUserAssigned;
// info
extern NSString *const OPTLYLoggerMessagesActivationSuccess;
extern NSString *const OPTLYLoggerMessagesConversionSuccess;

// ---- Bucketer ----
// debug
extern NSString *const OPTLYLoggerMessagesBucketAssigned;
// info
extern NSString *const OPTLYLoggerMessagesForcedVariationUser;
extern NSString *const OPTLYLoggerMessagesUserMutuallyExcluded;
// error
extern NSString *const OPTLYLoggerMessagesForcedBucketingFailed;

// ---- Client ----
// error
extern NSString *const OPTLYLoggerMessagesActivationFailure;
extern NSString *const OPTLYLoggerMessagesGetVariationFailure;
extern NSString *const OPTLYLoggerMessagesTrackFailure;

// ---- Data Store ----
// Event Data Store
// debug
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseEventDataStoreError;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseSaveError;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetError;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNumberEvents;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveError;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveEventError;
// warning
extern NSString *const OPTLYLoggerMessagesDataStoreEventsRemoveAllWarning;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNoEvents;

// File Manager
// debug
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerGetFile;
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveAllFilesError;
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFileForDataTypeError;
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFilesForDataTypeError;
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerSaveFile;

// ---- Datafile Manager ----
// debug
extern NSString *const OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedError;
extern NSString *const OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedNoChanges;
extern NSString *const OPTLYLoggerMessagesDatafileManagerLastModifiedDate;
extern NSString *const OPTLYLoggerMessagesDatafileManagerLastModifiedDateFound;
extern NSString *const OPTLYLoggerMessagesDatafileManagerLastModifiedDateNotFound;
// info
extern NSString *const OPTLYLoggerMessagesDatafileManagerDatafileDownloaded;
extern NSString *const OPTLYLoggerMessagesDatafileManagerDatafileDownloading;

// Datafile Manager Builder
// warning
extern NSString *const OPTLYLoggerMessagesDatafileManagerInitializedWithoutProjectIdMessage;
// error
extern NSString *const OPTLYLoggerMessagesDatafileFetchIntervalInvalid;

// ---- Datafile Versioning ----
// warning
extern NSString *const OPTLYLoggerMessagesInvalidDatafileVersion;

// ---- Event Builder ----
// debug
extern NSString *const OPTLYLoggerMessagesAttributeInvalidFormat;
extern NSString *const OPTLYLoggerMessagesAttributeValueInvalidFormat;
extern NSString *const OPTLYLoggerMessagesEventNotAssociatedWithExperiment;
extern NSString *const OPTLYLoggerMessagesExperimentNotPartOfEvent;
// warning
extern NSString *const OPTLYLoggerMessagesBucketerInvalid;
extern NSString *const OPTLYLoggerMessagesEventKeyInvalid;
extern NSString *const OPTLYLoggerMessagesExperimentKeyInvalid;
extern NSString *const OPTLYLoggerMessagesNotBuildingDecisionEventTicket;
extern NSString *const OPTLYLoggerMessagesUserIdInvalid;
extern NSString *const OPTLYLoggerMessagesVariationIdInvalid;

// ---- Event Dispatcher ----
// debug
extern NSString *const OPTLYLoggerMessagesEventDispatcherDispatchingConversionEvent;
extern NSString *const OPTLYLoggerMessagesEventDispatcherDispatchingImpressionEvent;
extern NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchFailed;
extern NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchSuccess;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsBackoffMaxRetries;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsBackoffSkipRetry;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsNoEvents;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventFailure;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventRetrievalFailure;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventSuccess;
extern NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchFlushSavedEventNoEvents;
extern NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerEnabled;
extern NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerDisabled;
extern NSString *const OPTLYLoggerMessagesEventDispatcherProperties;
// warning
extern NSString *const OPTLYLoggerMessagesEventDispatcherInvalidInterval;
extern NSString *const OPTLYLoggerMessagesEventDispatcherInvalidTimeout;

// ---- Live Variables ----
// info
extern NSString *const OPTLYLoggerMessagesNoVariationFoundForExperimentWithLiveVariable;
// warning
extern NSString *const OPTLYLoggerMessagesNoExperimentsContainVariable;
extern NSString *const OPTLYLoggerMessagesVariableUnknownForVariableKey;

// ---- Manager ----
// error
extern NSString *const OPTLYLoggerMessagesManagerBuilderNotValid;
extern NSString *const OPTLYLoggerMessagesManagerMustBeInitializedWithProjectId;

// ---- Project Config Getters ----
// warning
extern NSString *const OPTLYLoggerMessagesAttributeUnknownForAttributeKey;
extern NSString *const OPTLYLoggerMessagesAudienceUnknownForAudienceId;
extern NSString *const OPTLYLoggerMessagesEventIdUnknownForEventKey;
extern NSString *const OPTLYLoggerMessagesEventUnknownForEventKey;
extern NSString *const OPTLYLoggerMessagesExperimentIdUnknownForExperimentKey;
extern NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentId;
extern NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentKey;
extern NSString *const OPTLYLoggerMessagesGroupUnknownForGroupId;

// ---- User Profile ----
// debug
extern NSString *const OPTLYLoggerMessagesUserProfileBucketerUserDataRetrieved;
extern NSString *const OPTLYLoggerMessagesUserProfileAttemptToSaveVariation;
extern NSString *const OPTLYLoggerMessagesUserProfileNoVariation;
extern NSString *const OPTLYLoggerMessagesUserProfileRemoveVariation;
extern NSString *const OPTLYLoggerMessagesUserProfileRemoveVariationNotFound;
extern NSString *const OPTLYLoggerMessagesUserProfileSavedVariation;
extern NSString *const OPTLYLoggerMessagesUserProfileVariation;
// warning
extern NSString *const OPTLYLoggerMessagesUserProfileUnableToSaveVariation;
extern NSString *const OPTLYLoggerMessagesUserProfileVariationNoLongerInDatafile;

// ---- Validator ----
// info
extern NSString *const OPTLYLoggerMessagesExperimentNotRunning;
extern NSString *const OPTLYLoggerMessagesFailAudienceTargeting;

@interface OPTLYLoggerMessages : NSObject

@end
