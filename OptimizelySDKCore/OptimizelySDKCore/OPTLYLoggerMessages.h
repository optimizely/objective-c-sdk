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

// ---- errors ----
extern NSString *const OPTLYLoggerMessagesBuilderNotValid;
extern NSString *const OPTLYLoggerMessagesEventNotAssociatedWithExperiment;
extern NSString *const OPTLYLoggerMessagesAttributeInvalidFormat;
extern NSString *const OPTLYLoggerMessagesForcedBucketingFailed;
extern NSString *const OPTLYLoggerMessagesDatafileFetchIntervalInvalid;
extern NSString *const OPTLYLoggerMessagesManagerMustBeInitializedWithProjectId;
extern NSString *const OPTLYLoggerMessagesManagerBuilderNotValid;

// ---- warnings ----
extern NSString *const OPTLYLoggerMessagesExperimentUnknown;
extern NSString *const OPTLYLoggerMessagesEventUnknown;
extern NSString *const OPTLYLoggerMessagesAttributeUnknown;
extern NSString *const OPTLYLoggerMessagesAudienceUnknown;
extern NSString *const OPTLYLoggerMessagesGetVariationFailed;
extern NSString *const OPTLYDatafileManagerInitializedWithoutProjectIdMessage;

// ---- info ----
extern NSString *const OPTLYLoggerMessagesAudienceTargetingFail;
extern NSString *const OPTLYLoggerMessagesNoExperimentsForGoal;
extern NSString *const OPTLYLoggerMessagesVariationUserAssigned;
extern NSString *const OPTLYLoggerMessagesForcedVariationUser;
extern NSString *const OPTLYLoggerMessagesFailAudienceTargeting;
extern NSString *const OPTLYLoggerMessagesExperimentNotRunning;
extern NSString *const OPTLYLoggerMessagesUserMutuallyExcluded;
extern NSString *const OPTLYLoggerMessagesExperimentIdUnknown;
extern NSString *const OPTLYLoggerMessagesEventIdUnknown;
extern NSString *const OPTLYLoggerMessagesVariationIdInvalid;
extern NSString *const OPTLYLoggerMessagesUserIdInvalid;
extern NSString *const OPTLYLoggerMessagesExperimentKeyInvalid;
extern NSString *const OPTLYLoggerMessagesVariationIdInvalid;
extern NSString *const OPTLYLoggerMessagesBucketerInvalid;
extern NSString *const OPTLYLoggerMessagesExperimentNotPartOfEvent;
extern NSString *const OPTLYLoggerMessagesAttributeValueInvalidFormat;
extern NSString *const OPTLYLoggerMessagesExperimentIdUnknownForExperimentKey;
extern NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentKey;
extern NSString *const OPTLYLoggerMessagesEventIdUnknownForEventKey;
extern NSString *const OPTLYLoggerMessagesEventUnknownForEventKey;
extern NSString *const OPTLYLoggerMessagesAttributeUnknownForAttributeKey;
extern NSString *const OPTLYLoggerMessagesAudienceUnknownForAudienceId;
extern NSString *const OPTLYLoggerMessagesGroupUnknownForGroupId;
extern NSString *const OPTLYLoggerMessagesVariationUnknownForVariationKey;
extern NSString *const OPTLYLoggerMessagesEventDispatcherInterval;
extern NSString *const OPTLYLoggerMessagesVariableUnknownForVariableKey;

// ---- debug ----
extern NSString *const OPTLYLoggerMessagesBucketAssigned;

// ---- Event Dispatcher ----
// info
extern NSString *const OPTLYLoggerMessagesConversionSuccess;
extern NSString *const OPTLYLoggerMessagesActivationSuccess;
// warning
extern NSString *const OPTLYLoggerMessagesEventDispatcherInvalidInterval;
extern NSString *const OPTLYLoggerMessagesEventDispatcherInvalidTimeout;
// debug
extern NSString *const OPTLYLoggerMessagesDispatchingImpressionEvent;
extern NSString *const OPTLYLoggerMessagesDispatchingConversionEvent;
extern NSString *const OPTLYLoggerMessagesEventDispatcherProperties;
extern NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerEnabled;
extern NSString *const OPTLYLoggerMessagesEventDispatcherNetworkTimerDisabled;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsNoEvents;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsBackoffSkipRetry;
extern NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchFlushSavedEventNoEvents;
extern NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchSuccess;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushEventsBackoffMaxRetries;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventSuccess;
extern NSString *const OPTLYLoggerMessagesEventDispatcherEventDispatchFailed;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventFailure;
extern NSString *const OPTLYLoggerMessagesEventDispatcherFlushSavedEventRetrievalFailure;
// error
extern NSString *const OPTLYLoggerMessagesEventNotTracked;
extern NSString *const OPTLYLoggerMessagesActivationFailure;

// ---- Data Store ----
// warning
extern NSString *const OPTLYLoggerMessagesDataStoreEventsRemoveAllWarning;

// File Manager
// debug
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveAllFilesError;
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFilesForDataTypeError;
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerRemoveFileForDataTypeError;
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerGetFile;
extern NSString *const OPTLYLoggerMessagesDataStoreFileManagerSaveFile;

// Database
// debug
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseCreateTableError;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseSaveError;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetError;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNumberEvents;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNoEvents;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveError;
// warning
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseSaveTVOSWarning;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetTVOSWarning;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseGetNumberEventsTVOSWarning;
extern NSString *const OPTLYLoggerMessagesDataStoreDatabaseRemoveTVOSWarning;

// ---- User Profile ----
// warning
extern NSString *const OPTLYLoggerMessagesUserProfileVariationNoLongerInDatafile;
extern NSString *const OPTLYLoggerMessagesUserProfileUnableToSaveVariation;
// Debug
extern NSString *const OPTLYLoggerMessagesUserProfileVariation;
extern NSString *const OPTLYLoggerMessagesUserProfileNoVariation;
extern NSString *const OPTLYLoggerMessagesUserProfileRemoveVariation;
extern NSString *const OPTLYLoggerMessagesUserProfileRemoveVariationNotFound;
extern NSString *const OPTLYLoggerMessagesUserProfileAttemptToSaveVariation;
extern NSString *const OPTLYLoggerMessagesUserProfileSavedVariation;

// ---- Bucketing ----
// Debug
extern NSString *const OPTLYLoggerMessagesBucketerSavingUserData;
extern NSString *const OPTLYLoggerMessagesBucketerUserDataRetrieved;

// ---- Datafile Nanager ----
// Info
extern NSString *const OPTLYLoggerMessagesDatafileManagerDatafileDownloading;
extern NSString *const OPTLYLoggerMessagesDatafileManagerDatafileDownloaded;
// Debug
extern NSString *const OPTLYLoggerMessagesDatafileManagerLastModifiedDate;
extern NSString *const OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedNoChanges;
extern NSString *const OPTLYLoggerMessagesDatafileManagerDatafileNotDownloadedError;
extern NSString *const OPTLYLoggerMessagesDatafileManagerLastModifedDate;
extern NSString *const OPTLYLoggerMessagesDatafileManagerLastModifedDateNotFound;

// ---- Live Variables ----
// Info
extern NSString *const OPTLYLoggerMessagesNoVariationFoundForExperimentWithLiveVariable;
// Warning
extern NSString *const OPTLYLoggerMessagesNoExperimentsContainVariable;

@interface OPTLYLoggerMessages : NSObject

@end
