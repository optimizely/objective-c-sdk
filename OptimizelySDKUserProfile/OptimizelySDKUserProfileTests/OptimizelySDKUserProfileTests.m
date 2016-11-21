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
#import <OptimizelySDKShared/OPTLYDataStore.h>
#import "OPTLYUserProfile.h"

static NSString * const kUserId1 = @"6369992311";
static NSString * const kExperimentKey1 = @"testExperiment1";
static NSString * const kVariationKey1 = @"testVariation1";
static NSString * const kUserId2 = @"6369992312";
static NSString * const kExperimentKey2 = @"testExperiment2";
static NSString * const kVariationKey2 = @"testVariation2";
static NSString * const kUserId3 = @"6369992313";
static NSString * const kExperimentKey3 = @"testExperiment3";
static NSString * const kVariationKey3 = @"testVariation3";

@interface OPTLYUserProfile(test)
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@end

@interface OptimizelySDKUserProfileTests : XCTestCase
@property (nonatomic, strong) OPTLYUserProfile *userProfile;
@end

@implementation OptimizelySDKUserProfileTests

- (void)setUp {
    self.userProfile = [OPTLYUserProfile initWithBuilderBlock:^(OPTLYUserProfileBuilder *builder) {
        builder.logger = [OPTLYLoggerDefault new];
    }];
    [self.userProfile save:kUserId1 experiment:kExperimentKey1 variation:kVariationKey1];
    [self.userProfile save:kUserId2 experiment:kExperimentKey2 variation:kVariationKey2];
    [self.userProfile save:kUserId3 experiment:kExperimentKey3 variation:kVariationKey3];
    [super setUp];
}

- (void)tearDown {
    [self.userProfile.dataStore removeAllUserData];
    [super tearDown];
}

- (void)testUserProfileInitWithBuilderBlock
{
    XCTAssertNotNil(self.userProfile.logger);
    XCTAssert([self.userProfile.logger isKindOfClass:[OPTLYLoggerDefault class]]);
}

- (void)testSave
{
    NSDictionary *userData = [self.userProfile.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    NSArray *users = [userData allKeys];
    XCTAssert([users count] == 3, @"Invalid number of user profile data saved.");
    
    NSDictionary *userDataForUserId1 = [userData objectForKey:kUserId1];
    NSString *variationKey1 = [userDataForUserId1 objectForKey:kExperimentKey1];
    XCTAssert([variationKey1 isEqualToString:kVariationKey1], @"Invalid variation saved for userID 1.");
    
    NSDictionary *userDataForUserId2 = [userData objectForKey:kUserId2];
    NSString *variationKey2 = [userDataForUserId2 objectForKey:kExperimentKey2];
    XCTAssert([variationKey2 isEqualToString:kVariationKey2], @"Invalid variation saved for userID 2.");
    
    NSDictionary *userDataForUserId3 = [userData objectForKey:kUserId3];
    NSString *variationKey3 = [userDataForUserId3 objectForKey:kExperimentKey3];
    XCTAssert([variationKey3 isEqualToString:kVariationKey3], @"Invalid variation saved for userID 3.");
}

- (void)testGetVariation
{
    NSString *variationKey1 = [self.userProfile getVariationFor:kUserId1 experiment:kExperimentKey1];
    XCTAssert([variationKey1 isEqualToString:kVariationKey1], @"Invalid variation for userId 1 for getVariation.");
    
    NSString *variationKey2 = [self.userProfile getVariationFor:kUserId2 experiment:kExperimentKey2];
    XCTAssert([variationKey2 isEqualToString:kVariationKey2], @"Invalid variation for userId 2 for getVariation.");
    
    NSString *variationKey3 = [self.userProfile getVariationFor:kUserId3 experiment:kExperimentKey3];
    XCTAssert([variationKey3 isEqualToString:kVariationKey3], @"Invalid variation for userId 3 for getVariation.");
}

- (void)testRemoveVariation
{
    [self.userProfile remove:kUserId1 experiment:kExperimentKey1];
    NSString *variationKey1 = [self.userProfile getVariationFor:kUserId1 experiment:kExperimentKey1];
    XCTAssertNil(variationKey1, @"Variation for userId 1 should be removed.");
    
    [self.userProfile remove:kUserId2 experiment:kExperimentKey1];
    NSString *variationKey2 = [self.userProfile getVariationFor:kUserId2 experiment:kExperimentKey2];
    XCTAssertNotNil(variationKey2, @"Variation for userId 1 should not have been removed.");
    
    [self.userProfile remove:kUserId3 experiment:kExperimentKey2];
    NSString *variationKey3 = [self.userProfile getVariationFor:kUserId3 experiment:kExperimentKey3];
    XCTAssertNotNil(variationKey3, @"Variation for userId 3 should not have been removed.");
}

- (void)testFlearUserExperimentRecordsForUser
{
    [self.userProfile removeUserExperimentRecordsForUser:kUserId1];
    
    NSString *variationKey1 = [self.userProfile getVariationFor:kUserId1 experiment:kExperimentKey1];
    XCTAssertNil(variationKey1, @"Variation for userId 1 should be removed.");
    
    NSString *variationKey2 = [self.userProfile getVariationFor:kUserId2 experiment:kExperimentKey2];
    XCTAssertNotNil(variationKey2, @"Variation for userId 2 should not be removed.");
    
    NSString *variationKey3 = [self.userProfile getVariationFor:kUserId3 experiment:kExperimentKey3];
    XCTAssertNotNil(variationKey3, @"Variation for userId 3 should not be removed.");
    
    NSDictionary *userData = [self.userProfile.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    XCTAssert([userData count] == 2, @"Invalid user data count.");
}

- (void)testCleanUserExperimentRecords
{
    [self.userProfile removeAllUserExperimentRecords];
    
    NSString *variationKey1 = [self.userProfile getVariationFor:kUserId1 experiment:kExperimentKey1];
    XCTAssertNil(variationKey1, @"Variation for userId 1 should be removed.");
    
    NSString *variationKey2 = [self.userProfile getVariationFor:kUserId2 experiment:kExperimentKey2];
    XCTAssertNil(variationKey2, @"Variation for userId 2 should be removed.");
    
    NSString *variationKey3 = [self.userProfile getVariationFor:kUserId3 experiment:kExperimentKey3];
    XCTAssertNil(variationKey3, @"Variation for userId 3 should be removed.");

    NSDictionary *userData = [self.userProfile.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    XCTAssert([userData count] == 0, @"User data should have been removed.");
}

@end
