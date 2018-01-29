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
#import "OPTLYNotificationDelegate.h"

static NSString *const kDataModelDatafileName = @"optimizely_6372300739_v4";
static NSString *const kUserId = @"userId";
static NSString *const kExperimentKey = @"testExperimentWithFirefoxAudience";
static NSString *const kVariationId = @"6362476365";

@interface OPTLYNotificationCenter()
// notification Count represeting total number of notifications.
@property (nonatomic, readonly) NSUInteger notificationsCount;
@end

@interface OPTLYNotificationCenterTest : XCTestCase<OPTLYNotificationDelegate>
@property (nonatomic, strong) OPTLYNotificationCenter *notificationCenter;
@property (nonatomic, strong) OPTLYNotificationCenterTest *activateNotification;
@property (nonatomic, strong) OPTLYNotificationCenterTest *anotherActivateNotification;
@property (nonatomic, strong) OPTLYNotificationCenterTest *trackNotification;
@property (nonatomic, strong) OPTLYProjectConfig *projectConfig;
@end

@implementation OPTLYNotificationCenterTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    self.projectConfig = [OPTLYProjectConfig init:^(OPTLYProjectConfigBuilder * _Nullable builder){
        builder.datafile = datafile;
        builder.logger = [OPTLYLoggerDefault new];
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
        builder.userProfileService = [OPTLYUserProfileServiceNoOp new];
    }];
    self.notificationCenter = [[OPTLYNotificationCenter alloc] initWithProjectConfig:self.projectConfig];
    self.activateNotification = [OPTLYNotificationCenterTest new];
    self.anotherActivateNotification = [OPTLYNotificationCenterTest new];
    self.trackNotification = [OPTLYNotificationCenterTest new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    // clean up all notifications
    [_notificationCenter clearAllNotifications];
}

- (void)testAddAndRemoveNotificationListener {
    
    // Verify that callback added successfully.
    NSUInteger notificationId = [_notificationCenter addNotification:OPTLYNotificationTypeActivate activateListener:_activateNotification];
    XCTAssertEqual(1, notificationId);
    XCTAssertEqual(1, _notificationCenter.notificationsCount);
    
    // Verify that callback removed successfully.
    XCTAssertEqual(YES, [_notificationCenter removeNotification:notificationId]);
    XCTAssertEqual(0, _notificationCenter.notificationsCount);
    
    //Verify return false with invalid ID.
    XCTAssertEqual(NO, [_notificationCenter removeNotification:notificationId]);
    
    // Verify that callback added successfully and return right notification ID.
    XCTAssertEqual(_notificationCenter.notificationId, [_notificationCenter addNotification:OPTLYNotificationTypeActivate activateListener:_activateNotification]);
    XCTAssertEqual(1, _notificationCenter.notificationsCount);
}

- (void)testAddSameNotificationListenerMultipleTimes {
    [_notificationCenter addNotification:OPTLYNotificationTypeActivate activateListener:_activateNotification];
    
    // Verify that adding same callback multiple times will gets failed.
    XCTAssertEqual(-1, [_notificationCenter addNotification:OPTLYNotificationTypeActivate activateListener:_activateNotification]);
    XCTAssertEqual(1, _notificationCenter.notificationsCount);
}

- (void)testAddInvalidNotificationListeners {
    // Verify that AddNotification gets failed on adding invalid notification listeners.
    XCTAssertEqual(0, [_notificationCenter addNotification:OPTLYNotificationTypeTrack activateListener:_activateNotification]);
    XCTAssertEqual(0, [_notificationCenter addNotification:OPTLYNotificationTypeActivate trackListener:_trackNotification]);
    
    // Verify that no notifion has been added.
    XCTAssertEqual(0, _notificationCenter.notificationsCount);
}

- (void)testClearNotifications {

    // Add activate notifications.
    [_notificationCenter addNotification:OPTLYNotificationTypeActivate activateListener:_activateNotification];
    [_notificationCenter addNotification:OPTLYNotificationTypeActivate activateListener:_anotherActivateNotification];
    
    // Add track notification.
    [_notificationCenter addNotification:OPTLYNotificationTypeTrack trackListener:_trackNotification];
    
    // Verify that callbacks added successfully.
    XCTAssertEqual(3, _notificationCenter.notificationsCount);
    
    // Verify that only decision callbacks are removed.
    [_notificationCenter clearNotifications:OPTLYNotificationTypeActivate];
    XCTAssertEqual(1, _notificationCenter.notificationsCount);
    
    // Verify that clearNotifications does not break on calling twice for same type.
    [_notificationCenter clearNotifications:OPTLYNotificationTypeActivate];
    [_notificationCenter clearNotifications:OPTLYNotificationTypeActivate];
    
    // Verify that clearNotifications does not break after calling clearAllNotifications.
    [_notificationCenter clearAllNotifications];
    [_notificationCenter clearNotifications:OPTLYNotificationTypeTrack];
}

- (void)testClearAllNotifications {
    
    // Add activate notifications.
    [_notificationCenter addNotification:OPTLYNotificationTypeActivate activateListener:_activateNotification];
    [_notificationCenter addNotification:OPTLYNotificationTypeActivate activateListener:_anotherActivateNotification];
    
    // Add track notification.
    [_notificationCenter addNotification:OPTLYNotificationTypeTrack trackListener:_trackNotification];
    
    // Verify that callbacks added successfully.
    XCTAssertEqual(3, _notificationCenter.notificationsCount);
    
    // Verify that clearAllNotifications remove all the callbacks.
    [_notificationCenter clearAllNotifications];
    XCTAssertEqual(0, _notificationCenter.notificationsCount);
    
    // Verify that clearAllNotifications does not break on calling twice or after clearNotifications.
    [_notificationCenter clearNotifications:OPTLYNotificationTypeActivate];
    [_notificationCenter clearAllNotifications];
    [_notificationCenter clearAllNotifications];
}

- (void)testSendNotifications {
    id activateNotificationMock = OCMPartialMock(_activateNotification);
    id anotherActivateNotificationMock = OCMPartialMock(_anotherActivateNotification);
    id trackNotificationMock = OCMPartialMock(_trackNotification);
    
    // Add activate notifications.
    [_notificationCenter addNotification:OPTLYNotificationTypeActivate activateListener:activateNotificationMock];
    [_notificationCenter addNotification:OPTLYNotificationTypeActivate activateListener:anotherActivateNotificationMock];
    
    // Add track notification.
    [_notificationCenter addNotification:OPTLYNotificationTypeTrack trackListener:trackNotificationMock];
    
    // Fire decision type notifications.
    OPTLYExperiment *experiment = [_projectConfig getExperimentForKey:kExperimentKey];
    OPTLYVariation *variation = [experiment getVariationForVariationId:kVariationId];
    NSDictionary *attributes = [NSDictionary new];
    NSDictionary *event = [NSDictionary new];
    NSString *userId = [NSString stringWithFormat:@"%@", kUserId];
    
    // Verify that only the registered notifications of decision type are called.
    [_notificationCenter sendNotifications:OPTLYNotificationTypeActivate args:[NSArray arrayWithObjects:experiment, userId, attributes, variation, event, nil]];
    
    OCMReject(_trackNotification);
    OCMVerify(_activateNotification);
    OCMVerify(_anotherActivateNotification);
    
    NSString *eventKey = [NSString stringWithFormat:@"%@", kUserId];
    NSDictionary *eventTags = [NSDictionary new];
    
    // Verify that only the registered notifications of track type are called.
    [_notificationCenter sendNotifications:OPTLYNotificationTypeTrack args:[NSArray arrayWithObjects:eventKey, userId, attributes, eventTags, event, nil]];

    OCMVerify(_trackNotification);
    OCMReject(_activateNotification);
    OCMReject(_anotherActivateNotification);

    // Verify that after clearing notifications, SendNotification should not call any notification
    // which were previously registered.
    [_notificationCenter clearAllNotifications];
    
    [_notificationCenter sendNotifications:OPTLYNotificationTypeActivate args:[NSArray arrayWithObjects:experiment, userId, attributes, variation, event, nil]];
    
    // Again verify notifications which were registered are not called.
    OCMReject(_trackNotification);
    OCMReject(_activateNotification);
    OCMReject(_anotherActivateNotification);
}

- (void)onActivate:(OPTLYExperiment *)experiment userId:(NSString *)userId attributes:(NSDictionary<NSString *,NSString *> *)attributes variation:(OPTLYVariation *)variation event:(NSDictionary<NSString *,NSString *> *)event {
    
}

- (void)onTrack:(NSString *)eventKey userId:(NSString *)userId attributes:(NSDictionary<NSString *,NSString *> *)attributes eventTags:(NSDictionary *)eventTags event:(NSDictionary<NSString *,NSString *> *)event { 
    
}

@end
