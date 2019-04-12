/****************************************************************************
 * Copyright 2016-2019, Optimizely, Inc. and contributors                   *
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

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "Optimizely.h"
#import "OPTLYNotificationCenter.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYLogger.h"
#import "OPTLYUserProfileServiceBasic.h"
#import "OPTLYTestHelper.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYExperiment.h"
#import "OPTLYVariation.h"

static NSString *const kDataModelDatafileName = @"optimizely_6372300739_v4";
static NSString *const kFeatureFlagKey = @"booleanFeature";
static NSString *const kUserId = @"userId";
static NSString *const kExperimentKey = @"testExperimentWithFirefoxAudience";
static NSString *const kVariationId = @"6362476365";

static NSString *const kAttributeKeyBrowserName = @"browser_name";
static NSString *const kAttributeValueBrowserValue = @"firefox";
static NSString *const kAttributeKeyBrowserBuildNo = @"browser_buildno";
static NSString *const kAttributeKeyBrowserVersion = @"browser_version";
static NSString *const kAttributeKeyObject = @"dummy_object";
static NSString * const kAttributeKeyBrowserType = @"browser_type";
static NSString * const kAttributeKeyBrowserBuildNumber = @"browser_build_number";
static NSString * const kAttributeKeyBrowserIsDefault = @"browser_is_default";

@interface OPTLYNotificationCenter()
// notification Count represeting total number of notifications.
@property (nonatomic, readonly) NSUInteger notificationsCount;
@end

@interface OPTLYNotificationCenterTest : XCTestCase
@property (nonatomic, strong) NSData *datafile;
@property (nonatomic, strong) Optimizely *optimizely;
@property (nonatomic, strong) OPTLYNotificationCenter *notificationCenter;
@property (nonatomic, copy) ActivateListener activateNotification;
@property (nonatomic, copy) ActivateListener anotherActivateNotification;
@property (nonatomic, copy) TrackListener trackNotification;
@property (nonatomic, copy) DecisionListener decisionNotification;
@property (nonatomic, strong) OPTLYProjectConfig *projectConfig;
@end

@implementation OPTLYNotificationCenterTest

- (void)setUp {
    [super setUp];
    
    self.datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:@"test_data_10_experiments"];    
    self.optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.datafile;
        builder.logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelOff];;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    self.projectConfig = [[OPTLYProjectConfig alloc] initWithBuilder:[OPTLYProjectConfigBuilder builderWithBlock:^(OPTLYProjectConfigBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.logger = [OPTLYLoggerDefault new];
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
        builder.userProfileService = [OPTLYUserProfileServiceNoOp new];
    }]];
    self.notificationCenter = [[OPTLYNotificationCenter alloc] initWithProjectConfig:self.projectConfig];
    __weak typeof(self) weakSelf = self;
    weakSelf.activateNotification = ^(OPTLYExperiment *experiment, NSString *userId, NSDictionary<NSString *, id> *attributes, OPTLYVariation *variation, NSDictionary<NSString *,NSString *> *event) {
        NSString *logMessage = @"activate notification called with %@";
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, experiment.experimentKey] withLevel:OptimizelyLogLevelInfo];
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, userId] withLevel:OptimizelyLogLevelInfo];
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, variation.variationKey] withLevel:OptimizelyLogLevelInfo];
    };
    weakSelf.anotherActivateNotification = ^(OPTLYExperiment *experiment, NSString *userId, NSDictionary<NSString *, id> *attributes, OPTLYVariation *variation, NSDictionary<NSString *,NSString *> *event) {
        NSString *logMessage = @"activate notification called with %@";
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, experiment.experimentKey] withLevel:OptimizelyLogLevelInfo];
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, userId] withLevel:OptimizelyLogLevelInfo];
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, variation.variationKey] withLevel:OptimizelyLogLevelInfo];
    };
    weakSelf.trackNotification = ^(NSString *eventKey, NSString *userId, NSDictionary<NSString *, id> *attributes, NSDictionary *eventTags, NSDictionary<NSString *,NSString *> *event) {
        NSString *logMessage = @"track notification called with %@";
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, eventKey] withLevel:OptimizelyLogLevelInfo];
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, userId] withLevel:OptimizelyLogLevelInfo];
    };
    weakSelf.decisionNotification = ^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        NSString *logMessage = @"decision notification called with %@";
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, type] withLevel:OptimizelyLogLevelInfo];
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, userId] withLevel:OptimizelyLogLevelInfo];
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, decisionInfo] withLevel:OptimizelyLogLevelInfo];
    };
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    // clean up all notifications
    [_notificationCenter clearAllNotificationListeners];
}

- (void)testAddAndRemoveNotificationListener {
    
    // Verify that callback added successfully.
    NSUInteger notificationId = [_notificationCenter addActivateNotificationListener:_activateNotification];
    XCTAssertEqual(1, notificationId);
    XCTAssertEqual(1, _notificationCenter.notificationsCount);
    
    // Verify that callback removed successfully.
    XCTAssertEqual(YES, [_notificationCenter removeNotificationListener:notificationId]);
    XCTAssertEqual(0, _notificationCenter.notificationsCount);
    
    //Verify return false with invalid ID.
    XCTAssertEqual(NO, [_notificationCenter removeNotificationListener:notificationId]);
    
    // Verify that callback added successfully and return right notification ID.
    XCTAssertEqual(_notificationCenter.notificationId, [_notificationCenter addActivateNotificationListener:_activateNotification]);
    XCTAssertEqual(1, _notificationCenter.notificationsCount);
}

- (void)testAddSameNotificationListenerMultipleTimes {
    [_notificationCenter addActivateNotificationListener:_activateNotification];
    
    // Verify that adding same callback multiple times will gets failed.
    XCTAssertEqual(-1, [_notificationCenter addActivateNotificationListener:_activateNotification]);
    XCTAssertEqual(1, _notificationCenter.notificationsCount);
}

- (void)testClearNotifications {
    
    // Add activate notifications.
    [_notificationCenter addActivateNotificationListener:_activateNotification];
    [_notificationCenter addActivateNotificationListener:_anotherActivateNotification];
    
    // Add track notification.
    [_notificationCenter addTrackNotificationListener:_trackNotification];
    
    // Add decision notification.
    [_notificationCenter addDecisionNotificationListener:_decisionNotification];
    
    // Verify that callbacks added successfully.
    XCTAssertEqual(4, _notificationCenter.notificationsCount);
    
    // Verify that only decision callbacks are removed.
    [_notificationCenter clearNotificationListeners:OPTLYNotificationTypeActivate];
    [_notificationCenter clearNotificationListeners:OPTLYNotificationTypeDecision];
    XCTAssertEqual(1, _notificationCenter.notificationsCount);
    
    // Verify that ClearNotifications does not break on calling twice for same type.
    [_notificationCenter clearNotificationListeners:OPTLYNotificationTypeActivate];
    [_notificationCenter clearNotificationListeners:OPTLYNotificationTypeActivate];
    
    // Verify that ClearNotifications does not break after calling ClearAllNotifications.
    [_notificationCenter clearAllNotificationListeners];
    [_notificationCenter clearNotificationListeners:OPTLYNotificationTypeTrack];
    [_notificationCenter clearNotificationListeners:OPTLYNotificationTypeDecision];
}

- (void)testClearAllNotifications {
    
    // Add activate notifications.
    [_notificationCenter addActivateNotificationListener:_activateNotification];
    [_notificationCenter addActivateNotificationListener:_anotherActivateNotification];
    
    // Add track notification.
    [_notificationCenter addTrackNotificationListener:_trackNotification];
    
    // Add decision notification.
    [_notificationCenter addDecisionNotificationListener:_decisionNotification];
    
    // Verify that callbacks added successfully.
    XCTAssertEqual(4, _notificationCenter.notificationsCount);
    
    // Verify that ClearAllNotifications remove all the callbacks.
    [_notificationCenter clearAllNotificationListeners];
    XCTAssertEqual(0, _notificationCenter.notificationsCount);
    
    // Verify that ClearAllNotifications does not break on calling twice or after ClearNotifications.
    [_notificationCenter clearNotificationListeners:OPTLYNotificationTypeActivate];
    [_notificationCenter clearAllNotificationListeners];
    [_notificationCenter clearAllNotificationListeners];
}

- (void)testSendNotifications {
    
    // Add activate notifications.
    [_notificationCenter addActivateNotificationListener:_activateNotification];
    [_notificationCenter addActivateNotificationListener:_anotherActivateNotification];
    
    // Add track notification.
    [_notificationCenter addTrackNotificationListener:_trackNotification];
    
    // Add decision notification.
    [_notificationCenter addDecisionNotificationListener:_decisionNotification];
    
    // Fire decision type notifications.
    
    OPTLYExperiment *experiment = [_projectConfig getExperimentForKey:kExperimentKey];
    OPTLYVariation *variation = [experiment getVariationForVariationId:kVariationId];
    NSDictionary *attributes = [NSDictionary new];
    NSDictionary *event = [NSDictionary new];
    NSString *userId = [NSString stringWithFormat:@"%@", kUserId];
    
    NSDictionary *activateArgs = @{
                           OPTLYNotificationExperimentKey: experiment,
                           OPTLYNotificationUserIdKey: userId,
                           OPTLYNotificationAttributesKey: attributes,
                           OPTLYNotificationVariationKey: variation,
                           OPTLYNotificationLogEventParamsKey: event,
                           };
    // Verify that only the registered notifications of decision type are called.
    [_notificationCenter sendNotifications:OPTLYNotificationTypeActivate args:activateArgs];
    
    OCMReject(_trackNotification);
    OCMVerify(_decisionNotification);
    OCMVerify(_activateNotification);
    OCMVerify(_anotherActivateNotification);
    
    NSString *eventKey = [NSString stringWithFormat:@"%@", kUserId];
    NSDictionary *eventTags = [NSDictionary new];
    
    NSDictionary *trackArgs = @{
                           OPTLYNotificationEventKey: eventKey,
                           OPTLYNotificationUserIdKey: userId,
                           OPTLYNotificationAttributesKey: attributes,
                           OPTLYNotificationVariationKey: variation,
                           OPTLYNotificationEventTagsKey: eventTags,
                           OPTLYNotificationLogEventParamsKey: event
                           };
    
    
    // Verify that only the registered notifications of track type are called.
    [_notificationCenter sendNotifications:OPTLYNotificationTypeTrack args:trackArgs];
    
    OCMVerify(_trackNotification);
    OCMReject(_decisionNotification);
    OCMReject(_activateNotification);
    OCMReject(_anotherActivateNotification);
    
    // Verify that after clearing notifications, SendNotification should not call any notification
    // which were previously registered.
    [_notificationCenter clearAllNotificationListeners];
    
    [_notificationCenter sendNotifications:OPTLYNotificationTypeActivate args:activateArgs];
    
    // Again verify notifications which were registered are not called.
    OCMReject(_trackNotification);
    OCMReject(_decisionNotification);
    OCMReject(_activateNotification);
    OCMReject(_anotherActivateNotification);
}

- (void) testSendIsFeatureEnabledNotification {
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.optimizely.notificationCenter addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqual(kUserId, userId);
        XCTAssertEqual(kFeatureFlagKey, decisionInfo[DecisionInfo.FeatureKey]);
    }];
    
    // Should return true when experiments in feature flag does belongs to same group.
    XCTAssertTrue([self.optimizely isFeatureEnabled:kFeatureFlagKey userId:kUserId attributes:nil], @"should return true when experiments in feature flag does belongs to same group");
    [self.optimizely.notificationCenter clearAllNotificationListeners];
}

- (void) testSendGetEnabledFeaturesNotification {
    
    NSDictionary *_attributes = @{
                                  kAttributeKeyBrowserType : @"firefox",
                                  kAttributeKeyBrowserVersion : @(68.1),
                                  kAttributeKeyBrowserBuildNumber : @(106),
                                  kAttributeKeyBrowserIsDefault : @YES
                                  };
    __weak typeof(self) weakSelf = self;
    [weakSelf.optimizely.notificationCenter addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqual(kUserId, userId);
        XCTAssertEqual(_attributes, attributes);
    }];
    
    NSArray<NSString *> *enabledFeatures = @[@"booleanFeature", @"booleanSingleVariableFeature", @"multiVariateFeature", @"featureEnabledFalse"];
    NSArray<NSString *> *features = [self.optimizely getEnabledFeatures:kUserId attributes:_attributes];
    XCTAssertEqualObjects(features, enabledFeatures);
    [self.optimizely.notificationCenter clearAllNotificationListeners];
}

- (void) testSendGetFeatureVariableNotification {
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.optimizely.notificationCenter addDecisionNotificationListener:^(NSString * _Nonnull type, NSString * _Nonnull userId, NSDictionary<NSString *,id> * _Nullable attributes, NSDictionary<NSString *,id> * _Nonnull decisionInfo) {
        XCTAssertEqual(kUserId, userId);
        XCTAssertEqual(@"booleanVariable", decisionInfo[DecisionInfo.VariableKey]);
        XCTAssertEqual(@"booleanSingleVariableFeature", decisionInfo[DecisionInfo.FeatureKey]);
        XCTAssertEqual(false, [(NSNumber *)decisionInfo[DecisionInfo.VariableValueKey] boolValue]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceExperimentKey]);
        XCTAssertEqualObjects([NSNull null], decisionInfo[DecisionInfo.SourceVariationKey]);
    }];
    [self.optimizely getFeatureVariableBoolean:@"booleanSingleVariableFeature" variableKey:@"booleanVariable" userId:kUserId attributes:nil];
    [self.optimizely.notificationCenter clearAllNotificationListeners];
}

- (void) testSendNotificationWithAnyAttributes {
    // Add activate notifications.
    [_notificationCenter addActivateNotificationListener:_activateNotification];
    
    // Add track notification.
    [_notificationCenter addTrackNotificationListener:_trackNotification];
    
    // Fire decision type notifications.
    OPTLYExperiment *experiment = [_projectConfig getExperimentForKey:kExperimentKey];
    OPTLYVariation *variation = [experiment getVariationForVariationId:kVariationId];
    NSDictionary *attributes = @{
        kAttributeKeyBrowserName: kAttributeValueBrowserValue,
        kAttributeKeyBrowserBuildNo: @(10),
        kAttributeKeyBrowserVersion: @(0.3),
        kAttributeKeyObject: @{
            kAttributeKeyBrowserName: kAttributeValueBrowserValue,
        }
    };
    NSDictionary *logEvent = [NSDictionary new];
    NSString *userId = [NSString stringWithFormat:@"%@", kUserId];
    
    NSDictionary *activateArgs = @{
                                   OPTLYNotificationExperimentKey: experiment,
                                   OPTLYNotificationUserIdKey: userId,
                                   OPTLYNotificationAttributesKey: attributes,
                                   OPTLYNotificationVariationKey: variation,
                                   OPTLYNotificationLogEventParamsKey: logEvent,
                                   };
    
    // Verify that only the registered notifications of decision type are called.
    [_notificationCenter sendNotifications:OPTLYNotificationTypeActivate args:activateArgs];
    
    NSString *eventKey = [NSString stringWithFormat:@"%@", kUserId];
    NSDictionary *eventTags = [NSDictionary new];
    
    NSDictionary *trackArgs = @{
                                OPTLYNotificationEventKey: eventKey,
                                OPTLYNotificationUserIdKey: userId,
                                OPTLYNotificationAttributesKey: attributes,
                                OPTLYNotificationVariationKey: variation,
                                OPTLYNotificationEventTagsKey: eventTags,
                                OPTLYNotificationLogEventParamsKey: logEvent
                                };
    
    // Verify that only the registered notifications of track type are called.
    [_notificationCenter sendNotifications:OPTLYNotificationTypeTrack args:trackArgs];
}

- (void)testSendNotificationsWithInvalidArgs {
    
    // Add activate notifications.
    [_notificationCenter addActivateNotificationListener:_activateNotification];
    
    // Add track notification.
    [_notificationCenter addTrackNotificationListener:_trackNotification];
    
    // Fire decision type notifications.
    OPTLYExperiment *experiment = [_projectConfig getExperimentForKey:kExperimentKey];
    OPTLYVariation *variation = [experiment getVariationForVariationId:kVariationId];
    NSDictionary *attributes = [NSDictionary new];
    NSDictionary *event = [NSDictionary new];
    NSString *userId = [NSString stringWithFormat:@"%@", kUserId];
    
    // Verify that only the registered notifications of decision type are called.
    [_notificationCenter sendNotifications:OPTLYNotificationTypeActivate args:@[experiment, userId, attributes, variation]];
    
    OCMReject(_trackNotification);
    OCMReject(_activateNotification);
    
    NSString *eventKey = [NSString stringWithFormat:@"%@", kUserId];
    NSDictionary *eventTags = [NSDictionary new];
    
    // Verify that only the registered notifications of track type are called.
    [_notificationCenter sendNotifications:OPTLYNotificationTypeTrack args:@[eventKey, userId, eventTags, event]];
    
    OCMReject(_trackNotification);
    OCMReject(_activateNotification);
}

@end
