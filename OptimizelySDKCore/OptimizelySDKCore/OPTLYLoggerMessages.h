/*************************************************************************** 
* Copyright 2016 Optimizely                                                *
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

// ---- warnings ----
extern NSString *const OPTLYLoggerMessagesExperimentUnknown;
extern NSString *const OPTLYLoggerMessagesEventUnknown;
extern NSString *const OPTLYLoggerMessagesAttributeUnknown;
extern NSString *const OPTLYLoggerMessagesAudienceUnknown;

// ---- info ----
extern NSString *const OPTLYLoggerMessagesAudienceTargetingFail;
extern NSString *const OPTLYLoggerMessagesActivationSuccess;
extern NSString *const OPTLYLoggerMessagesActivationFailure;
extern NSString *const OPTLYLoggerMessagesConversionSuccess;
extern NSString *const OPTLYLoggerMessagesNoExperimentsForGoal;
extern NSString *const OPTLYLoggerMessagesVariationUserAssigned;
extern NSString *const OPTLYLoggerMessagesForcedVariationUser;
extern NSString *const OPTLYLoggerMessagesConversionFailAudienceTargeting;
extern NSString *const OPTLYLoggerMessagesExperimentNotRunning;
extern NSString *const OPTLYLoggerMessagesUserNotTracked;
extern NSString *const OPTLYLoggerMessagesUserMutuallyExcluded;
extern NSString *const OPTLYLoggerMessagesNotTrackedUnknownEvent;
extern NSString *const OPTLYLoggerMessagesNotTrackedNoParams;
extern NSString *const OPTLYLoggerMessagesNotTrackedDispatchFailed;
extern NSString *const OPTLYLoggerMessagesExperimentIdUnknown;
extern NSString *const OPTLYLoggerMessagesEventIdUnknown;
extern NSString *const OPTLYLoggerMessagesVariationIdInvalid;
extern NSString *const OPTLYLoggerMessagesUserIdInvalid;
extern NSString *const OPTLYLoggerMessagesExperimentKeyInvalid;
extern NSString *const OPTLYLoggerMessagesVariationIdInvalid;
extern NSString *const OPTLYLoggerMessagesBucketerInvalid;
extern NSString *const OPTLYLoggerMessagesNoImpressionNoParams;
extern NSString *const OPTLYLoggerMessagesExperimentNotPartOfEvent;
extern NSString *const OPTLYLoggerMessagesAttributeValueInvalidFormat;
extern NSString *const OPTLYLoggerMessagesExperimentIdUnknownForExperimentKey;
extern NSString *const OPTLYLoggerMessagesExperimentUnknownForExperimentKey;
extern NSString *const OPTLYLoggerMessagesEventIdUnknownForEventKey;
extern NSString *const OPTLYLoggerMessagesEventUnknownForEventKey;
extern NSString *const OPTLYLoggerMessagesAttributeUnknownForAttributeKey;
extern NSString *const OPTLYLoggerMessagesAudienceUnknownForAudienceId;
extern NSString *const OPTLYLoggerMessagesGroupUnknownForGroupId;

// ---- debug ----
extern NSString *const OPTLYLoggerMessagesImpressionDispatching;
extern NSString *const OPTLYLoggerMessagesConversionDispatching;
extern NSString *const OPTLYLoggerMessagesDispatchEventNoOp;
extern NSString *const OPTLYLoggerMessagesBucketAssigned;

@interface OPTLYLoggerMessages : NSObject

@end
