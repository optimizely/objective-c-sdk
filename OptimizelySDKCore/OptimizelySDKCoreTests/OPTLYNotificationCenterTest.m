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


- (void)onActivate:(OPTLYExperiment *)experiment userId:(NSString *)userId attributes:(NSDictionary<NSString *,NSString *> *)attributes variation:(OPTLYVariation *)variation event:(NSDictionary<NSString *,NSString *> *)event {
    
}

- (void)onTrack:(NSString *)eventKey userId:(NSString *)userId attributes:(NSDictionary<NSString *,NSString *> *)attributes eventTags:(NSDictionary *)eventTags event:(NSDictionary<NSString *,NSString *> *)event { 
    
}

@end
