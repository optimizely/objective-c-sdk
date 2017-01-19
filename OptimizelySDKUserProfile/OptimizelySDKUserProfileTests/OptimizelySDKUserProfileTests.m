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
#import "OPTLYTestHelper.h"
#import <OHHTTPStubs/OHHTTPStubs.h>

#import <OptimizelySDKShared/OptimizelySDKShared.h>
#import <OptimizelySDKCore/OptimizelySDKCore.h>
#import <OptimizelySDKCore/OPTLYLogger.h>
#import "OPTLYUserProfile.h"


static NSString * const kUserId1 = @"6369992311";
static NSString * const kExperimentId1 = @"testExperiment1";
static NSString * const kVariationId1 = @"testVariation1";
static NSString * const kUserId2 = @"6369992312";
static NSString * const kExperimentId2 = @"testExperiment2";
static NSString * const kVariationId2 = @"testVariation2";
static NSString * const kUserId3 = @"6369992313";
static NSString * const kExperimentId3a = @"testExperiment3a";
static NSString * const kVariationId3a = @"testVariation3a";
static NSString * const kExperimentId3b = @"testExperiment3b";
static NSString * const kVariationId3b = @"testVariation3b";
static NSString * const kExperimentId3c = @"testExperiment3c";
static NSString * const kVariationId3c = @"testVariation3c";
static NSString * const kWhitelistingUserId = @"userId";
static NSString * const kWhitelistingExperimentId = @"3";
static NSString * const kWhitelistingExperimentKey = @"whiteListExperiment";
static NSString * const kWhitelistingNormalVariationId = @"normalvariationId";
static NSString * const kWhitelistingWhitelistedVariationId = @"variation4";
static NSString * const kWhitelistingWhiteListedVariationKey = @"whiteListedVariation";

// datafile names
static NSString * const kOriginalDatafileName = @"InitialDatafile";
static NSString * const kUpdatedDatafileName = @"UpdatedDatafile";
static NSString * const kRemovedVariationDatafileName = @"RemovedVariationDatafile";
static NSString * const kWhitelistingTestDatafileName = @"WhitelistingTestDatafile";

static NSString * const kUserProfileExperimentKey = @"User_Profile_Experiment";
static NSString * const kUserProfileExperimentId = @"7926463378";
static NSString * const kUserProfileExperimentOriginalVariationId = @"7958211143";
static NSString * const kUserProfileExperimentTreatmentVariationId = @"7954100907";
static NSString * const kUserProfileSecondExperimentKey = @"second_experiment";
static NSString * const kUserProfileSecondExperimentId = @"3";
static NSString * const kUserProfileSecondExperimentVariation = @"2";

// datafiles
static NSData *originalDatafile;
static NSData *updatedDatafile;
static NSData *removedVariationDatafile;
static NSData *whitelistingDatafile;

@interface OPTLYUserProfileDefault(test)
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@end

@interface OptimizelySDKUserProfileTests : XCTestCase
@property (nonatomic, strong) OPTLYUserProfileDefault *userProfile;
@end

@implementation OptimizelySDKUserProfileTests

+ (void)setUp {
    [super setUp];
    
    // load the datafiles
    originalDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kOriginalDatafileName];
    updatedDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kUpdatedDatafileName];
    removedVariationDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kRemovedVariationDatafileName];
    whitelistingDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kWhitelistingTestDatafileName];
    
    // stub all requests
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        // every requests passes this test
        return true;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        // return bad request
        return [OHHTTPStubsResponse responseWithData:[[NSData alloc] init]
                                          statusCode:400
                                             headers:@{@"Content-Type":@"application/json"}];
    }];
}

+ (void)tearDown {
    [super tearDown];
    [OHHTTPStubs removeAllStubs];
}

- (void)setUp {
    self.userProfile = [OPTLYUserProfileDefault init:^(OPTLYUserProfileBuilder *builder) {
        builder.logger = [OPTLYLoggerDefault new];
    }];
    [self.userProfile saveUserId:kUserId1 experimentId:kExperimentId1 variationId:kVariationId1];
    [self.userProfile saveUserId:kUserId2 experimentId:kExperimentId2 variationId:kVariationId2];
    [self.userProfile saveUserId:kUserId3 experimentId:kExperimentId3a variationId:kVariationId3a];
    [self.userProfile saveUserId:kUserId3 experimentId:kExperimentId3b variationId:kVariationId3b];
    [self.userProfile saveUserId:kUserId3 experimentId:kExperimentId3c variationId:kVariationId3c];
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

- (void)testSaveUserData
{
    NSDictionary *userData = [self.userProfile.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    NSArray *users = [userData allKeys];
    XCTAssert([users count] == 3, @"Invalid number of user profile data saved.");
    
    NSDictionary *userDataForUserId1 = [userData objectForKey:kUserId1];
    NSString *variationKey1 = [userDataForUserId1 objectForKey:kExperimentId1];
    XCTAssert([variationKey1 isEqualToString:kVariationId1], @"Invalid variation saved for userID 1.");
    
    NSDictionary *userDataForUserId2 = [userData objectForKey:kUserId2];
    NSString *variationKey2 = [userDataForUserId2 objectForKey:kExperimentId2];
    XCTAssert([variationKey2 isEqualToString:kVariationId2], @"Invalid variation saved for userID 2.");
    
    // test experiment a and variation a is saved for user 3
    NSDictionary *userDataForUserId3a = [userData objectForKey:kUserId3];
    NSString *variationKey3a = [userDataForUserId3a objectForKey:kExperimentId3a];
    XCTAssert([variationKey3a isEqualToString:kVariationId3a], @"Invalid variation saved for userID 3a.");
    
    // test experiment b and variation b is saved for user 3
    NSDictionary *userDataForUserId3b = [userData objectForKey:kUserId3];
    NSString *variationKey3b = [userDataForUserId3b objectForKey:kExperimentId3b];
    XCTAssert([variationKey3b isEqualToString:kVariationId3b], @"Invalid variation saved for userID 3b.");
    
    // test experiment c and variation c is saved for user 3
    NSDictionary *userDataForUserId3c = [userData objectForKey:kUserId3];
    NSString *variationKey3c = [userDataForUserId3c objectForKey:kExperimentId3c];
    XCTAssert([variationKey3c isEqualToString:kVariationId3c], @"Invalid variation saved for userID 3c.");
}

- (void)testGetVariation
{
    NSString *variationKey1 = [self.userProfile getVariationIdForUserId:kUserId1 experimentId:kExperimentId1];
    XCTAssert([variationKey1 isEqualToString:kVariationId1], @"Invalid variation for userId 1 for getVariation.");
    
    NSString *variationKey2 = [self.userProfile getVariationIdForUserId:kUserId2 experimentId:kExperimentId2];
    XCTAssert([variationKey2 isEqualToString:kVariationId2], @"Invalid variation for userId 2 for getVariation.");
    
    NSString *variationKey3a = [self.userProfile getVariationIdForUserId:kUserId3 experimentId:kExperimentId3a];
    XCTAssert([variationKey3a isEqualToString:kVariationId3a], @"Invalid variation for userId 3a for getVariation.");
    
    NSString *variationKey3b = [self.userProfile getVariationIdForUserId:kUserId3 experimentId:kExperimentId3b];
    XCTAssert([variationKey3b isEqualToString:kVariationId3b], @"Invalid variation for userId 3b for getVariation.");
    
    NSString *variationKey3c = [self.userProfile getVariationIdForUserId:kUserId3 experimentId:kExperimentId3c];
    XCTAssert([variationKey3c isEqualToString:kVariationId3c], @"Invalid variation for userId 3c for getVariation.");

}

- (void)testRemoveVariation
{
    [self.userProfile removeUserId:kUserId1 experimentId:kExperimentId1];
    NSString *variationKey1 = [self.userProfile getVariationIdForUserId:kUserId1 experimentId:kExperimentId1];
    XCTAssertNil(variationKey1, @"Variation for userId 1 should be removed.");
    
    [self.userProfile removeUserId:kUserId2 experimentId:kExperimentId1];
    NSString *variationKey2 = [self.userProfile getVariationIdForUserId:kUserId2 experimentId:kExperimentId2];
    XCTAssertNotNil(variationKey2, @"Variation for userId 1 should not have been removed.");
    
    [self.userProfile removeUserId:kUserId3 experimentId:kExperimentId2];

    NSString *variationKey3a = [self.userProfile getVariationIdForUserId:kUserId3 experimentId:kExperimentId3a];
    XCTAssertNotNil(variationKey3a, @"Variation for userId 3a should not have been removed.");
    
    [self.userProfile removeUserId:kUserId3 experimentId:kExperimentId3c];
    NSString *variationKey3c = [self.userProfile getVariationIdForUserId:kUserId3 experimentId:kExperimentId3c];
    XCTAssertNil(variationKey3c, @"Variation for userId 3c should have been removed.");
}

- (void)testClearUserExperimentRecordsForUser
{
    [self.userProfile removeUserExperimentRecordsForUserId:kUserId1];
    
    NSString *variationKey1 = [self.userProfile getVariationIdForUserId:kUserId1 experimentId:kExperimentId1];
    XCTAssertNil(variationKey1, @"Variation for userId 1 should have been removed.");
    
    NSString *variationKey2 = [self.userProfile getVariationIdForUserId:kUserId2 experimentId:kExperimentId2];
    XCTAssertNotNil(variationKey2, @"Variation for userId 2 should not be removed.");
    
    NSString *variationKey3a = [self.userProfile getVariationIdForUserId:kUserId3 experimentId:kExperimentId3a];
    XCTAssertNotNil(variationKey3a, @"Variation for userId 3a should not be removed.");
    
    NSString *variationKey3b = [self.userProfile getVariationIdForUserId:kUserId3 experimentId:kExperimentId3b];
    XCTAssertNotNil(variationKey3b, @"Variation for userId 3b should not be removed.");
    
    NSString *variationKey3c = [self.userProfile getVariationIdForUserId:kUserId3 experimentId:kExperimentId3c];
    XCTAssertNotNil(variationKey3c, @"Variation for userId 3c should not be removed.");
    
    NSDictionary *userData = [self.userProfile.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    XCTAssert([userData count] == 2, @"Invalid user data count.");
}

- (void)testCleanUserExperimentRecords
{
    [self.userProfile removeAllUserExperimentRecords];
    
    NSString *variationKey1 = [self.userProfile getVariationIdForUserId:kUserId1 experimentId:kExperimentId1];
    XCTAssertNil(variationKey1, @"Variation for userId 1 should be removed.");
    
    NSString *variationKey2 = [self.userProfile getVariationIdForUserId:kUserId2 experimentId:kExperimentId2];
    XCTAssertNil(variationKey2, @"Variation for userId 2 should be removed.");
    
    NSString *variationKey3a = [self.userProfile getVariationIdForUserId:kUserId3 experimentId:kExperimentId3a];
    XCTAssertNil(variationKey3a, @"Variation for userId 3 should be removed.");

    NSString *variationKey3b = [self.userProfile getVariationIdForUserId:kUserId3 experimentId:kExperimentId3b];
    XCTAssertNil(variationKey3b, @"Variation for userId 3b should be removed.");
    
    NSString *variationKey3c = [self.userProfile getVariationIdForUserId:kUserId3 experimentId:kExperimentId3c];
    XCTAssertNil(variationKey3c, @"Variation for userId 3c should be removed.");
    
    NSDictionary *userData = [self.userProfile.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    XCTAssert([userData count] == 0, @"User data should have been removed.");
}

- (void)testBucketingPersistsWhenDatafileIsUpdated {    
    // make sure we have 2 different datafiles
    XCTAssertNotNil(originalDatafile);
    XCTAssertNotNil(updatedDatafile);
    XCTAssertNotEqualObjects(originalDatafile, updatedDatafile);
    
    // instantiate the manager
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = @"projectId";
        __block id<OPTLYLogger> logger = builder.logger;
        builder.userProfile = [OPTLYUserProfileDefault init:^(OPTLYUserProfileBuilder * _Nullable builder) {
            builder.logger = logger;
        }];
        
        [(OPTLYUserProfileDefault *)builder.userProfile removeAllUserExperimentRecords];
    }];
    XCTAssertNotNil(manager);
    
    OPTLYClient *originalClient = [manager initializeWithDatafile:originalDatafile];
    XCTAssertNotNil(originalClient);
    OPTLYVariation *originalVariation = [originalClient variation:kUserProfileExperimentKey userId:kUserId1];
    XCTAssertEqualObjects(originalVariation.variationId, kUserProfileExperimentOriginalVariationId);
    XCTAssertNotNil([originalClient.optimizely.userProfile getVariationIdForUserId:kUserId1 experimentId:kUserProfileExperimentId], @"User experiment should be stored");
    
    OPTLYClient *updatedClient = [manager initializeWithDatafile:updatedDatafile];
    XCTAssertNotNil(updatedClient);
    
    OPTLYVariation *updatedVariation = [updatedClient variation:kUserProfileExperimentKey userId:kUserId2];
    XCTAssertEqualObjects(updatedVariation.variationId, kUserProfileExperimentTreatmentVariationId);
    
    OPTLYVariation *variationForUser1 = [updatedClient variation:kUserProfileExperimentKey userId:kUserId1];
    XCTAssertNotEqualObjects(originalVariation.variationKey, variationForUser1.variationKey, @"variation keys should not be equal");
    XCTAssertEqualObjects(originalVariation.variationId, variationForUser1.variationId, @"variation ids should be the same: %@ %@", originalVariation.variationId, variationForUser1.variationId);
}

- (void)testStickyBucketingRevertsWhenVariationIsRemoved {
    // make sure we have 2 different datafiles
    XCTAssertNotNil(originalDatafile);
    XCTAssertNotNil(removedVariationDatafile);
    XCTAssertNotEqualObjects(originalDatafile, removedVariationDatafile);
    
    // instantiate the manager
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = @"projectId";
        __block id<OPTLYLogger> logger = builder.logger;
        builder.userProfile = [OPTLYUserProfileDefault init:^(OPTLYUserProfileBuilder * _Nullable builder) {
            builder.logger = logger;
        }];
    }];
    XCTAssertNotNil(manager);
    
    OPTLYClient *originalClient = [manager initializeWithDatafile:originalDatafile];
    XCTAssertNotNil(originalClient);
    OPTLYVariation *originalVariation = [originalClient variation:kUserProfileExperimentKey userId:kUserId1];
    XCTAssertNotNil(originalVariation);
    XCTAssertEqualObjects(originalVariation.variationId, kUserProfileExperimentOriginalVariationId);
    XCTAssertNotNil([originalClient.optimizely.userProfile getVariationIdForUserId:kUserId1 experimentId:kUserProfileExperimentId], @"User experiment should be stored");
    
    // update client with a new datafile
    OPTLYClient *updatedClient = [manager initializeWithDatafile:removedVariationDatafile];
    XCTAssertNotNil(updatedClient);
    XCTAssertNotNil([updatedClient.optimizely.userProfile getVariationIdForUserId:kUserId1 experimentId:kUserProfileExperimentId], @"User experiment should be same as original client");
    OPTLYVariation *variationForUser1 = [updatedClient variation:kUserProfileExperimentKey userId:kUserId1];
    XCTAssertNotNil(variationForUser1);
    XCTAssertNotEqualObjects(originalVariation.variationKey, variationForUser1.variationKey);
    XCTAssertNotEqualObjects(originalVariation.variationId, variationForUser1.variationId);
    XCTAssertEqualObjects(variationForUser1.variationId, kUserProfileExperimentTreatmentVariationId, @"treatment should be the new variation since original was removed");
}

- (void)testLoggerDoesntCrashWhenAskedToSaveNilvalues {
    OPTLYUserProfileDefault *userProfile = [[OPTLYUserProfileDefault alloc] init];
    [userProfile removeAllUserExperimentRecords];
    XCTAssertNotNil(userProfile);
    [userProfile saveUserId:nil experimentId:kExperimentId1 variationId:kVariationId1];
    [userProfile saveUserId:kUserId1 experimentId:nil variationId:kVariationId1];
    [userProfile saveUserId:kUserId1 experimentId:kExperimentId1 variationId:nil];
    [userProfile saveUserId:nil experimentId:nil variationId:kVariationId1];
    [userProfile saveUserId:kUserId1 experimentId:nil variationId:nil];
    [userProfile saveUserId:nil experimentId:nil variationId:nil];
    XCTAssertEqual(0, [[userProfile.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile] count]);
}

/**
 * Test multiple experiment and variation mappings can be saved per project
 */
- (void)testUserProfileCanStoreMultipleExperimentVariationMappings {
    OPTLYUserProfileDefault *userProfile = [[OPTLYUserProfileDefault alloc] init];
    [userProfile removeAllUserExperimentRecords];
    // store experiment variation for variations with 0 traffic allocation
    [userProfile saveUserId:kUserId1 experimentId:kUserProfileExperimentId variationId:kUserProfileExperimentTreatmentVariationId];
    [userProfile saveUserId:kUserId1 experimentId:kUserProfileSecondExperimentId variationId:kUserProfileSecondExperimentVariation];
    
    // instantiate the manager
    OPTLYManagerBasic *manager = [OPTLYManagerBasic init:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = @"projectId";
        __block id<OPTLYLogger> logger = builder.logger;
        builder.userProfile = userProfile;
    }];
    XCTAssertNotNil(manager);
    
    // initialize client
    OPTLYClient *client = [manager initializeWithDatafile:originalDatafile];
    XCTAssertNotNil(client);
    
    OPTLYVariation *firstExperimentVariation = [client variation:kUserProfileExperimentKey userId:kUserId1];
    XCTAssertEqualObjects(firstExperimentVariation.variationId, kUserProfileExperimentTreatmentVariationId);
    OPTLYVariation *secondExperimentVariation = [client variation:kUserProfileSecondExperimentKey userId:kUserId1];
    XCTAssertEqualObjects(secondExperimentVariation.variationId, kUserProfileSecondExperimentVariation);
}

/**
 * Test whitelisting ignores use profile sticky bucketing
 */
- (void)testWhitelistingOverridesUserProfileAndStoresNothing {
    // clear user profile
    [self.userProfile removeAllUserExperimentRecords];
    
    // initialize optimizely client with user profile
    OPTLYClient *client = [OPTLYClient init:^(OPTLYClientBuilder * _Nonnull builder) {
        builder.datafile = whitelistingDatafile;
        builder.userProfile = self.userProfile;
    }];
    
    // save a variation for the user into user profile
    [self.userProfile saveUserId:kWhitelistingUserId experimentId:kWhitelistingExperimentId variationId:kWhitelistingNormalVariationId];
    NSString *savedVariationId = [self.userProfile getVariationIdForUserId:kWhitelistingUserId experimentId:kWhitelistingExperimentId];
    XCTAssertEqualObjects(savedVariationId, kWhitelistingNormalVariationId);
    
    // bucket the user
    OPTLYVariation *variation = [client variation:kWhitelistingExperimentKey userId:kWhitelistingUserId];
    // make sure the user sees the whitelisted variation not the saved variation
    XCTAssertEqualObjects(variation.variationId, kWhitelistingWhitelistedVariationId);
    XCTAssertEqualObjects(variation.variationKey, kWhitelistingWhiteListedVariationKey);
    
    // saved variation is still saved in use profile
    savedVariationId = [self.userProfile getVariationIdForUserId:kWhitelistingUserId experimentId:kWhitelistingExperimentId];
    XCTAssertEqualObjects(savedVariationId, kWhitelistingNormalVariationId);
}

@end
