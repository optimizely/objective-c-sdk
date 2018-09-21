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
#import "OPTLYTestHelper.h"
#import <OHHTTPStubs/OHHTTPStubs.h>

#import <OptimizelySDKShared/OptimizelySDKShared.h>
#import <OptimizelySDKCore/OptimizelySDKCore.h>
#import <OptimizelySDKCore/OPTLYDatafileKeys.h>
#import <OptimizelySDKCore/OPTLYLogger.h>
#import <OptimizelySDKCore/OPTLYUserProfile.h>
#import "OPTLYUserProfileService.h"


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

@interface OPTLYUserProfileServiceDefault()
- (void)migrateLegacyUserProfileIfNeeded;
@end

@interface OPTLYUserProfileServiceDefault(test)
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@end

@interface OptimizelySDKUserProfileTests : XCTestCase
@property (nonatomic, strong) OPTLYUserProfileServiceDefault *userProfileService;
@property (nonatomic, strong) NSDictionary *userProfile1;
@property (nonatomic, strong) NSDictionary *userProfile2;
@property (nonatomic, strong) NSDictionary *userProfile3;
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
    self.userProfileService = [[OPTLYUserProfileServiceDefault alloc] initWithBuilder:[OPTLYUserProfileServiceBuilder builderWithBlock:^(OPTLYUserProfileServiceBuilder * _Nullable builder) {
        builder.logger = [OPTLYLoggerDefault new];
    }]];
    
    self.userProfile1 = @{ OPTLYDatafileKeysUserProfileServiceUserId : kUserId1,
                           OPTLYDatafileKeysUserProfileServiceExperimentBucketMap : @{ kExperimentId1 : @{ OPTLYDatafileKeysUserProfileServiceVariationId : kVariationId1 } } };
    
    self.userProfile2 = @{ OPTLYDatafileKeysUserProfileServiceUserId : kUserId2,
                           OPTLYDatafileKeysUserProfileServiceExperimentBucketMap : @{ kExperimentId2 : @{ OPTLYDatafileKeysUserProfileServiceVariationId : kVariationId2 } } };
    
    self.userProfile3 = @{ OPTLYDatafileKeysUserProfileServiceUserId : kUserId3,
                           OPTLYDatafileKeysUserProfileServiceExperimentBucketMap : @{
                                   kExperimentId3a : @{ OPTLYDatafileKeysUserProfileServiceVariationId : kVariationId3a },
                                   kExperimentId3b : @{ OPTLYDatafileKeysUserProfileServiceVariationId : kVariationId3b },
                                   kExperimentId3c : @{ OPTLYDatafileKeysUserProfileServiceVariationId : kVariationId3c } } };
    
    [self.userProfileService save:self.userProfile1];
    [self.userProfileService save:self.userProfile2];
    [self.userProfileService save:self.userProfile3];
    
    [super setUp];
}

- (void)tearDown {
    [self.userProfileService.dataStore removeAllUserData];
    [super tearDown];
}

- (void)testUserProfileInitWithBuilderBlock
{
    XCTAssertNotNil(self.userProfileService.logger);
    XCTAssert([self.userProfileService.logger isKindOfClass:[OPTLYLoggerDefault class]]);
}

- (void)testSave
{
    NSDictionary *userData = [self.userProfileService.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfileService];
    NSArray *users = [userData allKeys];
    XCTAssert([users count] == 3, @"Invalid number of user profile data saved.");
    
    NSDictionary *userDataForUserId1 = [userData objectForKey:kUserId1];
    XCTAssert([userDataForUserId1 isEqualToDictionary:self.userProfile1], @"Invalid user profile saved for userID 1: %@.", userDataForUserId1);
    
    NSDictionary *userDataForUserId2 = [userData objectForKey:kUserId2];
    XCTAssert([userDataForUserId2 isEqualToDictionary:self.userProfile2], @"Invalid user profile saved for userID 2: %@.", userDataForUserId2);
    
    NSDictionary *userDataForUserId3 = [userData objectForKey:kUserId3];
    XCTAssert([userDataForUserId3 isEqualToDictionary:self.userProfile3], @"Invalid user profile saved for userID 3: %@.", userDataForUserId3);
}

- (void)testLookup
{
    NSDictionary *userProfile1 = [self.userProfileService lookup:kUserId1];
    XCTAssert([userProfile1 isEqualToDictionary:self.userProfile1], @"Invalid user profile loookup for userID 1: %@.", userProfile1);
    
    NSDictionary *userProfile2 = [self.userProfileService lookup:kUserId2];
    XCTAssert([userProfile2 isEqualToDictionary:self.userProfile2], @"Invalid user profile loookup for userID 2: %@.", userProfile2);
    
    NSDictionary *userProfile3 = [self.userProfileService lookup:kUserId3];
    XCTAssert([userProfile3 isEqualToDictionary:self.userProfile3], @"Invalid user profile loookup for userID 3: %@.", userProfile3);
}

- (void)testClearUserExperimentRecordsForUser
{
    [self.userProfileService removeUserExperimentRecordsForUserId:kUserId1];
    
    NSDictionary *userProfile1 = [self.userProfileService lookup:kUserId1];
    XCTAssertNil(userProfile1, @"User profile for userId 1 should have been removed.");
    
    NSDictionary *userProfile2 = [self.userProfileService lookup:kUserId2];
    XCTAssertNotNil(userProfile2, @"User profile for userId 2 should not be removed.");
    
    NSDictionary *userProfile3 = [self.userProfileService lookup:kUserId3];
    XCTAssertNotNil(userProfile3, @"User profile for userId 3a should not be removed.");
    
    NSDictionary *userData = [self.userProfileService.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfileService];
    XCTAssert([userData count] == 2, @"Invalid user profile count.");
}

- (void)testCleanUserExperimentRecords
{
    [self.userProfileService removeAllUserExperimentRecords];
    
    NSDictionary *userProfile1 = [self.userProfileService lookup:kUserId1];
    XCTAssertNil(userProfile1, @"User profile for userId 1 should have been removed.");
    
    NSDictionary *userProfile2 = [self.userProfileService lookup:kUserId2];
    XCTAssertNil(userProfile2, @"User profile for userId 2 should have been removed.");
    
    NSDictionary *userProfile3 = [self.userProfileService lookup:kUserId3];
    XCTAssertNil(userProfile3, @"User profile for userId 3 should have been removed.");
    
    NSDictionary *userData = [self.userProfileService.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfileService];
    XCTAssert([userData count] == 0,  @"User data should have been removed.");
}

- (void)testBucketingPersistsWhenDatafileIsUpdated {    
    // make sure we have 2 different datafiles
    XCTAssertNotNil(originalDatafile);
    XCTAssertNotNil(updatedDatafile);
    XCTAssertNotEqualObjects(originalDatafile, updatedDatafile);
    
    // instantiate the manager
    OPTLYManagerBasic *manager = [[OPTLYManagerBasic alloc] initWithBuilder:[OPTLYManagerBuilder builderWithBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = @"projectId";
        __block id<OPTLYLogger> logger = builder.logger;
        builder.userProfileService = [[OPTLYUserProfileServiceDefault alloc] initWithBuilder:[OPTLYUserProfileServiceBuilder builderWithBlock:^(OPTLYUserProfileServiceBuilder * _Nullable builder) {
            builder.logger = logger;
        }]];
        
        [(OPTLYUserProfileServiceDefault *)builder.userProfileService removeAllUserExperimentRecords];
    }]];
    XCTAssertNotNil(manager);
    
    OPTLYClient *originalClient = [manager initializeWithDatafile:originalDatafile];
    XCTAssertNotNil(originalClient);
    OPTLYVariation *originalVariation = [originalClient variation:kUserProfileExperimentKey userId:kUserId1];
    XCTAssertEqualObjects(originalVariation.variationId, kUserProfileExperimentOriginalVariationId);
    XCTAssertNotNil([originalClient.optimizely.userProfileService lookup:kUserId1], @"User profile should be stored");
    
    OPTLYClient *updatedClient = [manager initializeWithDatafile:updatedDatafile];
    XCTAssertNotNil(updatedClient);
    
    OPTLYVariation *updatedVariation = [updatedClient variation:kUserProfileExperimentKey userId:kUserId2];
    XCTAssertEqualObjects(updatedVariation.variationId, kUserProfileExperimentTreatmentVariationId);
    
    OPTLYVariation *variationForUser1 = [updatedClient variation:kUserProfileExperimentKey userId:kUserId1];
    XCTAssertNotEqualObjects(originalVariation.variationKey, variationForUser1.variationKey, @"Variation keys should not be equal");
    XCTAssertEqualObjects(originalVariation.variationId, variationForUser1.variationId, @"Variation IDs should be the same: %@ %@", originalVariation.variationId, variationForUser1.variationId);
}

- (void)testStickyBucketingRevertsWhenVariationIsRemoved {
    // make sure we have 2 different datafiles
    XCTAssertNotNil(originalDatafile);
    XCTAssertNotNil(removedVariationDatafile);
    XCTAssertNotEqualObjects(originalDatafile, removedVariationDatafile);
    
    // instantiate the manager
    OPTLYManagerBasic *manager = [[OPTLYManagerBasic alloc] initWithBuilder:[OPTLYManagerBuilder builderWithBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = @"projectId";
        __block id<OPTLYLogger> logger = builder.logger;
        builder.userProfileService = [[OPTLYUserProfileServiceDefault alloc] initWithBuilder:[OPTLYUserProfileServiceBuilder builderWithBlock:^(OPTLYUserProfileServiceBuilder * _Nullable builder) {
            builder.logger = logger;
        }]];
    }]];
    XCTAssertNotNil(manager);
    
    OPTLYClient *originalClient = [manager initializeWithDatafile:originalDatafile];
    XCTAssertNotNil(originalClient);
    OPTLYVariation *originalVariation = [originalClient variation:kUserProfileExperimentKey userId:kUserId1];
    XCTAssertNotNil(originalVariation);
    XCTAssertEqualObjects(originalVariation.variationId, kUserProfileExperimentOriginalVariationId, @"Unexpected original variation id: %@", originalVariation.variationId);
    XCTAssertNotNil([originalClient.optimizely.userProfileService lookup:kUserId1], @"User profile should be stored");
    
    // update client with a new datafile
    OPTLYClient *updatedClient = [manager initializeWithDatafile:removedVariationDatafile];
    XCTAssertNotNil(updatedClient);
    XCTAssertNotNil([updatedClient.optimizely.userProfileService lookup:kUserId1], @"User profile should be same as original client");
    OPTLYVariation *variationForUser1 = [updatedClient variation:kUserProfileExperimentKey userId:kUserId1];
    XCTAssertNotNil(variationForUser1);
    XCTAssertNotEqualObjects(originalVariation.variationKey, variationForUser1.variationKey);
    XCTAssertNotEqualObjects(originalVariation.variationId, variationForUser1.variationId);
    XCTAssertEqualObjects(variationForUser1.variationId, kUserProfileExperimentTreatmentVariationId, @"treatment should be the new variation since original was removed");
}

- (void)testLoggerDoesntCrashWhenAskedToSaveNilvalues {
    OPTLYUserProfileServiceDefault *userProfileService = [[OPTLYUserProfileServiceDefault alloc] init];
    [userProfileService removeAllUserExperimentRecords];
    XCTAssertNotNil(userProfileService);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [userProfileService save:nil];
#pragma clang diagnostic pop
    XCTAssertEqual(0, [[userProfileService.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfileService] count]);
}

/**
 * Test whitelisting ignores use profile sticky bucketing
 */
- (void)testWhitelistingOverridesUserProfileAndStoresNothing {
    // clear user profile
    [self.userProfileService removeAllUserExperimentRecords];
    
    // initialize optimizely client with user profile
    OPTLYClient *client = [[OPTLYClient alloc] initWithBuilder:[OPTLYClientBuilder builderWithBlock:^(OPTLYClientBuilder * _Nonnull builder) {
        builder.datafile = whitelistingDatafile;
        builder.userProfileService = self.userProfileService;
    }]];
    
    // save a variation for the user into user profile
    [self.userProfileService save:self.userProfile1];
    NSDictionary *savedUserProfileDict = [self.userProfileService lookup:kUserId1];
    OPTLYUserProfile *savedUserProfile = [[OPTLYUserProfile alloc] initWithDictionary:savedUserProfileDict error:nil];
    NSString *savedUserProfileVariationId = [savedUserProfile getVariationIdForExperimentId:kExperimentId1];
    XCTAssertEqualObjects(savedUserProfileVariationId, kVariationId1);
    
    // bucket the user
    OPTLYVariation *variation = [client variation:kWhitelistingExperimentKey userId:kWhitelistingUserId];
    // make sure the user sees the whitelisted variation not the saved variation
    XCTAssertEqualObjects(variation.variationId, kWhitelistingWhitelistedVariationId);
    XCTAssertEqualObjects(variation.variationKey, kWhitelistingWhiteListedVariationKey);
}

- (void)testRemoveInvalidExperiments
{
    if (self.userProfileService ) {
        [self.userProfileService performSelector:@selector(removeInvalidExperimentsForAllUsers:) withObject:@[]];
        [self.userProfileService performSelector:@selector(removeInvalidExperimentsForAllUsers:) withObject:nil];
        [self.userProfileService performSelector:@selector(removeInvalidExperimentsForAllUsers:) withObject:@[kExperimentId3a]];
    }
    NSDictionary *userProfile1 = [self.userProfileService lookup:kUserId1];
    XCTAssertNil(userProfile1[kExperimentId3a], @"User profile experiment entry should be removed");

    NSDictionary *userProfile2 = [self.userProfileService lookup:kUserId2];
    XCTAssertNil(userProfile2[kExperimentId3a], @"User profile experiment entry should be removed");

    NSDictionary *userProfile3 = [self.userProfileService lookup:kUserId3];
     XCTAssertNil(userProfile3[kExperimentId3a], @"User profile experiment entry should be removed");

}

- (void)testLegacyUserProfileMigration
{
    [self saveUserId:kUserId1 experimentId:kExperimentId1 variationId:kVariationId1];
    [self saveUserId:kUserId2 experimentId:kExperimentId2 variationId:kVariationId2];
    [self saveUserId:kUserId3 experimentId:kExperimentId3a variationId:kVariationId3a];
    [self saveUserId:kUserId3 experimentId:kExperimentId3b variationId:kVariationId3b];
    [self saveUserId:kUserId3 experimentId:kExperimentId3c variationId:kVariationId3c];
    
    NSDictionary *legacyUserProfileData = [self.userProfileService.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    XCTAssert([legacyUserProfileData count] == 3, @"Invalid number of legacy user profile entities saved: %@.", @([legacyUserProfileData count]));
    [self.userProfileService migrateLegacyUserProfileIfNeeded];
    
    NSDictionary *newUserProfileDict1 = [self.userProfileService lookup:kUserId1];
    NSDictionary *newUserProfileDict2 = [self.userProfileService lookup:kUserId2];
    NSDictionary *newUserProfileDict3 = [self.userProfileService lookup:kUserId3];
    
    XCTAssert([newUserProfileDict1 isEqualToDictionary:self.userProfile1], @"Migrated user profile 1 is not valid: %@", newUserProfileDict1);
    XCTAssert([newUserProfileDict2 isEqualToDictionary:self.userProfile2], @"Migrated user profile 2 is not valid: %@", newUserProfileDict2);
    XCTAssert([newUserProfileDict3 isEqualToDictionary:self.userProfile3], @"Migrated user profile 3 is not valid: %@", newUserProfileDict3);
    
    legacyUserProfileData = [self.userProfileService.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    XCTAssert([legacyUserProfileData count] == 0, @"Legacy user profile should have been removed.");
    
}

#pragma mark - Helper Methods

// Legacy user profile save
- (void)saveUserId:(nonnull NSString *)userId
      experimentId:(nonnull NSString *)experimentId
       variationId:(nonnull NSString *)variationId {
    if (!userId
        || !experimentId
        || !variationId) {
        return;
    }
    NSDictionary *userProfileData = [self.userProfileService.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    NSMutableDictionary *userProfileDataMutable = userProfileData ? [userProfileData mutableCopy] : [NSMutableDictionary new];
    NSDictionary *experimentVariationMapping = userProfileDataMutable[userId];
    if (!experimentVariationMapping) {
        userProfileDataMutable[userId] = @{ experimentId : variationId };
    }
    else {
        NSMutableDictionary *mutableExperimentVariationMapping = [experimentVariationMapping mutableCopy];
        mutableExperimentVariationMapping[experimentId] = variationId;
        userProfileDataMutable[userId] = mutableExperimentVariationMapping;
    }
    [self.userProfileService.dataStore saveUserData:userProfileDataMutable type:OPTLYDataStoreDataTypeUserProfile];
}

@end
