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
static NSString * const kExperimentKey1 = @"testExperiment1";
static NSString * const kVariationKey1 = @"testVariation1";
static NSString * const kUserId2 = @"6369992312";
static NSString * const kExperimentKey2 = @"testExperiment2";
static NSString * const kVariationKey2 = @"testVariation2";
static NSString * const kUserId3 = @"6369992313";
static NSString * const kExperimentKey3a = @"testExperiment3";
static NSString * const kVariationKey3a = @"testVariation3";
static NSString * const kExperimentKey3b = @"testExperiment3";
static NSString * const kVariationKey3b = @"testVariation3";
static NSString * const kExperimentKey3c = @"testExperiment3";
static NSString * const kVariationKey3c = @"testVariation3";

static NSString * const kOriginalDatafileName = @"InitialDatafile";
static NSString * const kUpdatedDatafileName = @"UpdatedDatafile";
static NSString * const kRemovedVariationDatafileName = @"RemovedVariationDatafile";
static NSString * const kUserProfileExperimentKey = @"User_Profile_Experiment";
static NSString * const kUserProfileExperimentOriginalVariationKey = @"original";
static NSString * const kUserProfileExperimentTreatmentVariationKey = @"treatment";
static NSData *originalDatafile;
static NSData *updatedDatafile;
static NSData *removedVariationDatafile;

@interface OPTLYUserProfile(test)
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@end

@interface OptimizelySDKUserProfileTests : XCTestCase
@property (nonatomic, strong) OPTLYUserProfile *userProfile;
@end

@implementation OptimizelySDKUserProfileTests

+ (void)setUp {
    [super setUp];
    
    // load the datafiles
    originalDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kOriginalDatafileName];
    updatedDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kUpdatedDatafileName];
    removedVariationDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kRemovedVariationDatafileName];
    
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
    self.userProfile = [OPTLYUserProfile initWithBuilderBlock:^(OPTLYUserProfileBuilder *builder) {
        builder.logger = [OPTLYLoggerDefault new];
    }];
    [self.userProfile saveUser:kUserId1 experiment:kExperimentKey1 variation:kVariationKey1];
    [self.userProfile saveUser:kUserId2 experiment:kExperimentKey2 variation:kVariationKey2];
    [self.userProfile saveUser:kUserId3 experiment:kExperimentKey3a variation:kVariationKey3a];
    [self.userProfile saveUser:kUserId3 experiment:kExperimentKey3b variation:kVariationKey3b];
    [self.userProfile saveUser:kUserId3 experiment:kExperimentKey3c variation:kVariationKey3c];
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
    NSString *variationKey1 = [userDataForUserId1 objectForKey:kExperimentKey1];
    XCTAssert([variationKey1 isEqualToString:kVariationKey1], @"Invalid variation saved for userID 1.");
    
    NSDictionary *userDataForUserId2 = [userData objectForKey:kUserId2];
    NSString *variationKey2 = [userDataForUserId2 objectForKey:kExperimentKey2];
    XCTAssert([variationKey2 isEqualToString:kVariationKey2], @"Invalid variation saved for userID 2.");
    
    NSDictionary *userDataForUserId3a = [userData objectForKey:kUserId3];
    NSString *variationKey3a = [userDataForUserId3a objectForKey:kExperimentKey3a];
    XCTAssert([variationKey3a isEqualToString:kVariationKey3a], @"Invalid variation saved for userID 3a.");
    
    NSDictionary *userDataForUserId3b = [userData objectForKey:kUserId3];
    NSString *variationKey3b = [userDataForUserId3b objectForKey:kExperimentKey3b];
    XCTAssert([variationKey3b isEqualToString:kVariationKey3b], @"Invalid variation saved for userID 3b.");
    
    NSDictionary *userDataForUserId3c = [userData objectForKey:kUserId3];
    NSString *variationKey3c = [userDataForUserId3c objectForKey:kExperimentKey3c];
    XCTAssert([variationKey3c isEqualToString:kVariationKey3c], @"Invalid variation saved for userID 3c.");
}

- (void)testGetVariation
{
    NSString *variationKey1 = [self.userProfile getVariationForUser:kUserId1 experiment:kExperimentKey1];
    XCTAssert([variationKey1 isEqualToString:kVariationKey1], @"Invalid variation for userId 1 for getVariation.");
    
    NSString *variationKey2 = [self.userProfile getVariationForUser:kUserId2 experiment:kExperimentKey2];
    XCTAssert([variationKey2 isEqualToString:kVariationKey2], @"Invalid variation for userId 2 for getVariation.");
    
    NSString *variationKey3a = [self.userProfile getVariationForUser:kUserId3 experiment:kExperimentKey3a];
    XCTAssert([variationKey3a isEqualToString:kVariationKey3a], @"Invalid variation for userId 3a for getVariation.");
    
    NSString *variationKey3b = [self.userProfile getVariationForUser:kUserId3 experiment:kExperimentKey3b];
    XCTAssert([variationKey3b isEqualToString:kVariationKey3b], @"Invalid variation for userId 3b for getVariation.");
    
    NSString *variationKey3c = [self.userProfile getVariationForUser:kUserId3 experiment:kExperimentKey3c];
    XCTAssert([variationKey3c isEqualToString:kVariationKey3c], @"Invalid variation for userId 3c for getVariation.");

}

- (void)testRemoveVariation
{
    [self.userProfile removeUser:kUserId1 experiment:kExperimentKey1];
    NSString *variationKey1 = [self.userProfile getVariationForUser:kUserId1 experiment:kExperimentKey1];
    XCTAssertNil(variationKey1, @"Variation for userId 1 should be removed.");
    
    [self.userProfile removeUser:kUserId2 experiment:kExperimentKey1];
    NSString *variationKey2 = [self.userProfile getVariationForUser:kUserId2 experiment:kExperimentKey2];
    XCTAssertNotNil(variationKey2, @"Variation for userId 1 should not have been removed.");
    
    [self.userProfile removeUser:kUserId3 experiment:kExperimentKey2];

    NSString *variationKey3a = [self.userProfile getVariationForUser:kUserId3 experiment:kExperimentKey3a];
    XCTAssertNotNil(variationKey3a, @"Variation for userId 3a should not have been removed.");
    
    [self.userProfile removeUser:kUserId3 experiment:kExperimentKey3c];
    NSString *variationKey3c = [self.userProfile getVariationForUser:kUserId3 experiment:kExperimentKey3c];
    XCTAssertNil(variationKey3c, @"Variation for userId 3c should have been removed.");
}

- (void)testClearUserExperimentRecordsForUser
{
    [self.userProfile removeUserExperimentRecordsForUser:kUserId1];
    
    NSString *variationKey1 = [self.userProfile getVariationForUser:kUserId1 experiment:kExperimentKey1];
    XCTAssertNil(variationKey1, @"Variation for userId 1 should have been removed.");
    
    NSString *variationKey2 = [self.userProfile getVariationForUser:kUserId2 experiment:kExperimentKey2];
    XCTAssertNotNil(variationKey2, @"Variation for userId 2 should not be removed.");
    
    NSString *variationKey3a = [self.userProfile getVariationForUser:kUserId3 experiment:kExperimentKey3a];
    XCTAssertNotNil(variationKey3a, @"Variation for userId 3a should not be removed.");
    
    NSString *variationKey3b = [self.userProfile getVariationForUser:kUserId3 experiment:kExperimentKey3b];
    XCTAssertNotNil(variationKey3b, @"Variation for userId 3b should not be removed.");
    
    NSString *variationKey3c = [self.userProfile getVariationForUser:kUserId3 experiment:kExperimentKey3c];
    XCTAssertNotNil(variationKey3c, @"Variation for userId 3c should not be removed.");
    
    NSDictionary *userData = [self.userProfile.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    XCTAssert([userData count] == 2, @"Invalid user data count.");
}

- (void)testCleanUserExperimentRecords
{
    [self.userProfile removeAllUserExperimentRecords];
    
    NSString *variationKey1 = [self.userProfile getVariationForUser:kUserId1 experiment:kExperimentKey1];
    XCTAssertNil(variationKey1, @"Variation for userId 1 should be removed.");
    
    NSString *variationKey2 = [self.userProfile getVariationForUser:kUserId2 experiment:kExperimentKey2];
    XCTAssertNil(variationKey2, @"Variation for userId 2 should be removed.");
    
    NSString *variationKey3a = [self.userProfile getVariationForUser:kUserId3 experiment:kExperimentKey3a];
    XCTAssertNil(variationKey3a, @"Variation for userId 3 should be removed.");

    NSString *variationKey3b = [self.userProfile getVariationForUser:kUserId3 experiment:kExperimentKey3b];
    XCTAssertNil(variationKey3b, @"Variation for userId 3b should be removed.");
    
    NSString *variationKey3c = [self.userProfile getVariationForUser:kUserId3 experiment:kExperimentKey3c];
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
    OPTLYManager *manager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = @"projectId";
        __block id<OPTLYLogger> logger = builder.logger;
        builder.userProfile = [OPTLYUserProfile initWithBuilderBlock:^(OPTLYUserProfileBuilder * _Nullable builder) {
            builder.logger = logger;
        }];
    }];
    XCTAssertNotNil(manager);
    
    OPTLYClient *originalClient = [manager initializeClientWithDatafile:originalDatafile];
    XCTAssertNotNil(originalClient);
    OPTLYVariation *originalVariation = [originalClient activateExperiment:kUserProfileExperimentKey userId:kUserId1];
    XCTAssertNotNil(originalVariation);
    XCTAssertEqualObjects(originalVariation.variationKey, kUserProfileExperimentOriginalVariationKey);
    XCTAssertNotNil([originalClient.optimizely.userProfile getVariationForUser:kUserId1 experiment:kUserProfileExperimentKey], @"User experiment should be stored");
    
    OPTLYClient *updatedClient = [manager initializeClientWithDatafile:updatedDatafile];
    XCTAssertNotNil(updatedClient);
    OPTLYVariation *updatedVariation = [updatedClient activateExperiment:kUserProfileExperimentKey userId:kUserId2];
    XCTAssertNotNil(updatedVariation);
    XCTAssertEqualObjects(updatedVariation.variationKey, kUserProfileExperimentTreatmentVariationKey);
    OPTLYVariation *variationForUser1 = [updatedClient activateExperiment:kUserProfileExperimentKey userId:kUserId1];
    XCTAssertNotNil(variationForUser1);
    XCTAssertEqualObjects(originalVariation.variationKey, variationForUser1.variationKey);
    XCTAssertEqualObjects(originalVariation.variationId, variationForUser1.variationId);
}

- (void)testStickyBucketingRevertsWhenVariationIsRemoved {
    // make sure we have 2 different datafiles
    XCTAssertNotNil(originalDatafile);
    XCTAssertNotNil(removedVariationDatafile);
    XCTAssertNotEqualObjects(originalDatafile, removedVariationDatafile);
    
    // instantiate the manager
    OPTLYManager *manager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = @"projectId";
        __block id<OPTLYLogger> logger = builder.logger;
        builder.userProfile = [OPTLYUserProfile initWithBuilderBlock:^(OPTLYUserProfileBuilder * _Nullable builder) {
            builder.logger = logger;
        }];
    }];
    XCTAssertNotNil(manager);
    
    OPTLYClient *originalClient = [manager initializeClientWithDatafile:originalDatafile];
    XCTAssertNotNil(originalClient);
    OPTLYVariation *originalVariation = [originalClient activateExperiment:kUserProfileExperimentKey userId:kUserId1];
    XCTAssertNotNil(originalVariation);
    XCTAssertEqualObjects(originalVariation.variationKey, kUserProfileExperimentOriginalVariationKey);
    XCTAssertNotNil([originalClient.optimizely.userProfile getVariationForUser:kUserId1 experiment:kUserProfileExperimentKey], @"User experiment should be stored");
    
    // update client with a new datafile
    OPTLYClient *updatedClient = [manager initializeClientWithDatafile:removedVariationDatafile];
    XCTAssertNotNil(updatedClient);
    XCTAssertNotNil([updatedClient.optimizely.userProfile getVariationForUser:kUserId1 experiment:kUserProfileExperimentKey], @"User experiment should be same as original client");
    OPTLYVariation *variationForUser1 = [updatedClient activateExperiment:kUserProfileExperimentKey userId:kUserId1];
    XCTAssertNotNil(variationForUser1);
    XCTAssertNotEqualObjects(originalVariation.variationKey, variationForUser1.variationKey);
    XCTAssertNotEqualObjects(originalVariation.variationId, variationForUser1.variationId);
    XCTAssertEqualObjects(variationForUser1.variationKey, kUserProfileExperimentTreatmentVariationKey, @"treatment should be the new variation since original was removed");
}

@end
