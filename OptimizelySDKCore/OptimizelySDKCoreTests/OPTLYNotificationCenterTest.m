/****************************************************************************
 * Copyright 2016-2018, Optimizely, Inc. and contributors                   *
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
#import "OPTLYNotificationCenter.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYLogger.h"
#import "OPTLYUserProfileServiceBasic.h"
#import "OPTLYTestHelper.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYExperiment.h"
#import "OPTLYVariation.h"

static NSString *const kDataModelDatafileName = @"optimizely_6372300739_v4";
static NSString *const kUserId = @"userId";
static NSString *const kExperimentKey = @"testExperimentWithFirefoxAudience";
static NSString *const kVariationId = @"6362476365";

@interface OPTLYNotificationCenter()
// notification Count represeting total number of notifications.
@property (nonatomic, readonly) NSUInteger notificationsCount;
@end

@interface OPTLYNotificationCenterTest : XCTestCase
@property (nonatomic, strong) OPTLYNotificationCenter *notificationCenter;
@property (nonatomic, copy) ActivateListener activateNotification;
@property (nonatomic, copy) ActivateListener anotherActivateNotification;
@property (nonatomic, copy) TrackListener trackNotification;
@property (nonatomic, strong) OPTLYProjectConfig *projectConfig;
@end

@implementation OPTLYNotificationCenterTest

- (void)setUp {
    [super setUp];
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
    weakSelf.activateNotification = ^(OPTLYExperiment *experiment, NSString *userId, NSDictionary<NSString *,NSString *> *attributes, OPTLYVariation *variation, NSDictionary<NSString *,NSString *> *event) {
        NSString *logMessage = @"activate notification called with %@";
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, experiment.experimentKey] withLevel:OptimizelyLogLevelInfo];
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, userId] withLevel:OptimizelyLogLevelInfo];
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, variation.variationKey] withLevel:OptimizelyLogLevelInfo];
    };
    weakSelf.anotherActivateNotification = ^(OPTLYExperiment *experiment, NSString *userId, NSDictionary<NSString *,NSString *> *attributes, OPTLYVariation *variation, NSDictionary<NSString *,NSString *> *event) {
        NSString *logMessage = @"activate notification called with %@";
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, experiment.experimentKey] withLevel:OptimizelyLogLevelInfo];
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, userId] withLevel:OptimizelyLogLevelInfo];
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, variation.variationKey] withLevel:OptimizelyLogLevelInfo];
    };
    weakSelf.trackNotification = ^(NSString *eventKey, NSString *userId, NSDictionary<NSString *,NSString *> *attributes, NSDictionary *eventTags, NSDictionary<NSString *,NSString *> *event) {
        NSString *logMessage = @"track notification called with %@";
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, eventKey] withLevel:OptimizelyLogLevelInfo];
        [weakSelf.projectConfig.logger logMessage:[NSString stringWithFormat:logMessage, userId] withLevel:OptimizelyLogLevelInfo];
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
    
    // Verify that callbacks added successfully.
    XCTAssertEqual(3, _notificationCenter.notificationsCount);
    
    // Verify that only decision callbacks are removed.
    [_notificationCenter clearNotificationListeners:OPTLYNotificationTypeActivate];
    XCTAssertEqual(1, _notificationCenter.notificationsCount);
    
    // Verify that ClearNotifications does not break on calling twice for same type.
    [_notificationCenter clearNotificationListeners:OPTLYNotificationTypeActivate];
    [_notificationCenter clearNotificationListeners:OPTLYNotificationTypeActivate];
    
    // Verify that ClearNotifications does not break after calling ClearAllNotifications.
    [_notificationCenter clearAllNotificationListeners];
    [_notificationCenter clearNotificationListeners:OPTLYNotificationTypeTrack];
}

- (void)testClearAllNotifications {
    
    // Add activate notifications.
    [_notificationCenter addActivateNotificationListener:_activateNotification];
    [_notificationCenter addActivateNotificationListener:_anotherActivateNotification];
    
    // Add track notification.
    [_notificationCenter addTrackNotificationListener:_trackNotification];
    
    // Verify that callbacks added successfully.
    XCTAssertEqual(3, _notificationCenter.notificationsCount);
    
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
    
    // Fire decision type notifications.
    OPTLYExperiment *experiment = [_projectConfig getExperimentForKey:kExperimentKey];
    OPTLYVariation *variation = [experiment getVariationForVariationId:kVariationId];
    NSDictionary *attributes = [NSDictionary new];
    NSDictionary *event = [NSDictionary new];
    NSString *userId = [NSString stringWithFormat:@"%@", kUserId];
    
    // Verify that only the registered notifications of decision type are called.
    [_notificationCenter sendNotifications:OPTLYNotificationTypeActivate args:@[experiment, userId, attributes, variation, event]];
    
    OCMReject(_trackNotification);
    OCMVerify(_activateNotification);
    OCMVerify(_anotherActivateNotification);
    
    NSString *eventKey = [NSString stringWithFormat:@"%@", kUserId];
    NSDictionary *eventTags = [NSDictionary new];
    
    // Verify that only the registered notifications of track type are called.
    [_notificationCenter sendNotifications:OPTLYNotificationTypeTrack args:@[eventKey, userId, attributes, eventTags, event]];
    
    OCMVerify(_trackNotification);
    OCMReject(_activateNotification);
    OCMReject(_anotherActivateNotification);
    
    // Verify that after clearing notifications, SendNotification should not call any notification
    // which were previously registered.
    [_notificationCenter clearAllNotificationListeners];
    
    [_notificationCenter sendNotifications:OPTLYNotificationTypeActivate args:@[experiment, userId, attributes, variation, event]];
    
    // Again verify notifications which were registered are not called.
    OCMReject(_trackNotification);
    OCMReject(_activateNotification);
    OCMReject(_anotherActivateNotification);
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
