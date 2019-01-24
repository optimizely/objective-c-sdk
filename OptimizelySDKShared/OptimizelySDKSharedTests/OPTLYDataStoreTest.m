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
#import <OptimizelySDKShared/OptimizelySDKShared.h>

static NSString *const kTestFileName = @"testFileManager.txt";
static NSString *const kBadTestFileName = @"badTestFileManager.txt";
static NSString *const kTestString = @"testString";

static NSString * const kDatabase = @"database";
static NSString * const kDatafile = @"datafile";
static NSString * const kUserProfile = @"user-profile";
static NSString * const kEventDispatcher = @"event-dispatcher";
static NSString * const kClientEngine = @"objective-c-sdk";

@interface OPTLYDataStore(Test)
@property (nonatomic, strong) NSDictionary *eventsCache;
- (void)saveEvent:(nonnull NSDictionary *)data
        eventType:(OPTLYDataStoreEventType)eventType
            error:(NSError * _Nullable __autoreleasing * _Nullable)error
       completion:(void(^)(void))completion
;
@end

@interface OPTLYDataStoreTest : XCTestCase
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@property (nonatomic, strong) NSData *testFileData;
@property (nonatomic, strong) NSDictionary *testDataNSUserDefault;
@end

@implementation OPTLYDataStoreTest

- (void)setUp {
    [super setUp];
    self.dataStore = [OPTLYDataStore new];
    self.testFileData = [kTestString dataUsingEncoding:NSUTF8StringEncoding];
    self.testDataNSUserDefault = @{@"testKey1":@"testValue1", @"testKey2" : @"testKey2"};
}

- (void)tearDown {
    [self.dataStore removeAll:nil];
    self.dataStore = nil;
    self.testFileData = nil;
    self.testDataNSUserDefault = nil;
    [super tearDown];
}

- (void)testRemoveAll
{
    NSError *error;
    
    [self.dataStore saveEvent:self.testDataNSUserDefault eventType:OPTLYDataStoreEventTypeImpression error:&error];
    [self.dataStore saveFile:kTestFileName data:self.testFileData type:OPTLYDataStoreDataTypeDatafile error:&error];
    [self.dataStore saveUserData:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeUserProfileService];
    
    [self.dataStore removeAll:&error];
    
    // check event storage
    NSArray *results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert([results count] == 0, @"RemoveAll failed to remove all saved events. Events left - %ld", (unsigned long)[results count]);
    
    // check file storage
    bool fileExists = [self.dataStore fileExists:kTestFileName type:OPTLYDataStoreDataTypeDatabase];
    XCTAssertFalse(fileExists, @"RemoveAll failed to remove file.");
    
    // check NSUserDefault storage
    XCTAssertNil([self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfileService], @"RemoveAll failed to remove NSUserDefault data.");
}

- (void)testEventsStorage {
    
    NSDictionary *testEventData1 =
    @{
      @"userFeatures": @[@{
                             @"value": @"alda",
                             @"shouldIndex": @YES,
                             @"name": @"nameOfPerson",
                             @"type": @"custom"
                             }],
      @"timestamp": @1478510071576,
      @"clientVersion": @"0.2.0-debug",
      @"revision": @"7",
      @"isGlobalHoldback": @NO,
      @"accountId": @"4902200114",
      @"projectId": @"7738070017",
      @"visitorId": @"1",
      @"clientEngine": kClientEngine
      };
    
    NSDictionary *testEventData2 =
    @{
      @"userFeatures": @[@{
                             @"value": @"alda",
                             @"shouldIndex": @YES,
                             @"name": @"nameOfPerson",
                             @"type": @"custom"
                             }],
      @"timestamp": @1478510071576,
      @"clientVersion": @"0.2.0-debug",
      @"revision": @"7",
      @"isGlobalHoldback": @NO,
      @"accountId": @"4902200114",
      @"projectId": @"7738070017",
      @"visitorId": @"2",
      @"clientEngine": kClientEngine
      };
    
    NSDictionary *testEventData3 =
    @{
      @"userFeatures": @[@{
                             @"value": @"alda",
                             @"shouldIndex": @YES,
                             @"name": @"nameOfPerson",
                             @"type": @"custom"
                             }],
      @"timestamp": @1478510071576,
      @"clientVersion": @"0.2.0-debug",
      @"revision": @"7",
      @"isGlobalHoldback": @NO,
      @"accountId": @"4902200114",
      @"projectId": @"7738070017",
      @"visitorId": @"3",
      @"clientEngine": kClientEngine
      };
    
    NSDictionary *testEventData4 =
    @{
      @"userFeatures": @[@{
                             @"value": @"alda",
                             @"shouldIndex": @YES,
                             @"name": @"nameOfPerson",
                             @"type": @"custom"
                             }],
      @"timestamp": @1478510071576,
      @"clientVersion": @"0.2.0-debug",
      @"revision": @"7",
      @"isGlobalHoldback": @NO,
      @"accountId": @"4902200114",
      @"projectId": @"7738070017",
      @"visitorId": @"4",
      @"clientEngine": kClientEngine
      };
    
    NSInteger totalEntity = 4;
    NSError *error = nil;
    
    // test insert
    [self.dataStore saveEvent:testEventData1 eventType:OPTLYDataStoreEventTypeImpression error:&error];
    [self.dataStore saveEvent:testEventData2 eventType:OPTLYDataStoreEventTypeImpression error:&error];
    [self.dataStore saveEvent:testEventData3 eventType:OPTLYDataStoreEventTypeImpression error:&error];
    [self.dataStore saveEvent:testEventData4 eventType:OPTLYDataStoreEventTypeImpression error:&error];
    
    XCTAssertNil(error, @"Save data failed.");
    NSArray *results = nil;
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    
    // ---- test getOldestEvent ----
    NSDictionary *result = [self.dataStore getOldestEvent:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssertNotNil(result, @"Data insertion failed or invalid number of results retrieved from getOldestEvent.");
    XCTAssert([result[@"json"] isEqualToDictionary:testEventData1], @"Invalid result data retrieved for getOldestEvent.");
    
    // ---- test getFirstNEvents ----
    NSInteger n = 3;
    results = [self.dataStore getFirstNEvents:n eventType:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert([results count] == n, @"Data insertion failed or invalid number of results retrieved from getFirstNEvents.");
    XCTAssert([results[0][@"json"] isEqualToDictionary:testEventData1], @"Invalid result data 1 retrieved for getFirstNEvents.");
    XCTAssert([results[1][@"json"] isEqualToDictionary:testEventData2], @"Invalid result data 2 retrieved for getFirstNEvents.");
    XCTAssert([results[2][@"json"] isEqualToDictionary:testEventData3], @"Invalid result data 3 retrieved for getFirstNEvents.");
    
    // ---- test getAllEntries ----
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert([results count] == totalEntity, @"Data insertion failed or invalid number of results retrieved from getAllEvents");
    XCTAssert([results[0][@"json"] isEqualToDictionary:testEventData1], @"Invalid result data 1 retrieved for getAllEvents.");
    XCTAssert([results[1][@"json"] isEqualToDictionary:testEventData2], @"Invalid result data 2 retrieved for getAllEvents.");
    XCTAssert([results[2][@"json"] isEqualToDictionary:testEventData3], @"Invalid result data 3 retrieved for getAllEvents.");
    XCTAssert([results[3][@"json"] isEqualToDictionary:testEventData4], @"Invalid result data 4 retrieved for getAllEvents.");
    
    // ---- test numberOfEvents ----
    NSInteger numberOfEvents = [self.dataStore numberOfEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert(numberOfEvents == totalEntity, @"Invalid count from numberOfEvents.");
    
    // ---- test removeOldestEvent ----
    [self.dataStore removeOldestEvent:OPTLYDataStoreEventTypeImpression error:&error];
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    numberOfEvents = [self.dataStore numberOfEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert(numberOfEvents == totalEntity-1, @"Invalid event count after removeOldestEvent was called.");
    XCTAssert([results[0][@"json"] isEqualToDictionary:testEventData2], @"Invalid result data 1 retrieved after removeOldestEvent was called.");
    XCTAssert([results[1][@"json"] isEqualToDictionary:testEventData3], @"Invalid result data 2 retrieved after removeOldestEvent was called.");
    XCTAssert([results[2][@"json"] isEqualToDictionary:testEventData4], @"Invalid result data 3 retrieved after removeOldestEvent was called.");
    
    // ---- test removeFirstNEvents ----
    NSInteger nEventsToDelete = 2;
    [self.dataStore removeFirstNEvents:nEventsToDelete eventType:OPTLYDataStoreEventTypeImpression error:&error];
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert([results count] == totalEntity-1-nEventsToDelete, @"Invalid event count when removeFirstNEvents was called.");
    XCTAssert([results[0][@"json"] isEqualToDictionary:testEventData4], @"Invalid result data 1 retrieved after removeFirstNEvents was called.");
    
    // ---- test removeAllEvents of an event type ----
    [self.dataStore removeAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert([results count] == 0, @"Invalid event count when removeAllEvents was called.");
    
    // ---- test removeEvent ----
    [self.dataStore saveEvent:testEventData1 eventType:OPTLYDataStoreEventTypeImpression error:&error];
    NSDictionary *event = [self.dataStore getOldestEvent:OPTLYDataStoreEventTypeImpression error:&error];
    [self.dataStore removeEvent:event eventType:OPTLYDataStoreEventTypeImpression error:&error];
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert([results count] == 0, @"Invalid impression event count when removeEvent was called.");
    
    // ---- test removeAllEvents ----
    [self.dataStore saveEvent:testEventData1 eventType:OPTLYDataStoreEventTypeImpression error:&error];
    [self.dataStore saveEvent:testEventData2 eventType:OPTLYDataStoreEventTypeConversion error:&error];
    [self.dataStore removeAll:&error];
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert([results count] == 0, @"Invalid impression event count when removeSavedEvents was called.");
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeConversion error:&error];
    XCTAssert([results count] == 0, @"Invalid conversion event count when removeSavedEvents was called.");
}

- (void)testSingleQuoteStringSaveAndRemove {
    NSDictionary *testEventData1 =
    @{
      @"userFeatures": @[@{
                             @"value": @"ali'`s",
                             @"shouldIndex": @YES,
                             @"name": @"nameOfPerson",
                             @"type": @"custom"
                             }],
      @"timestamp": @1478510071576,
      @"clientVersion": @"0.2.0-debug",
      @"eventEntityId": @"7723870635",
      @"revision": @"7",
      @"isGlobalHoldback": @NO,
      @"accountId": @"4902200114",
      @"layerStates": @[],
      @"projectId": @"7738070017",
      @"eventMetrics": @[@{
                             @"name": @"revenue",
                             @"value": @88
                             }],
      @"visitorId": @"1",
      @"eventName": @"people",
      @"clientEngine": kClientEngine,
      @"eventFeatures": @[]
      };
    
    NSError *error = nil;
    
    XCTAssertTrue([self.dataStore saveEvent:testEventData1
                                  eventType:OPTLYDataStoreEventTypeConversion
                                      error:&error]);
    XCTAssertNil(error);
    NSArray *events = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeConversion error:&error];
    
    XCTAssertNil(error);
    
    NSDictionary *event = [events lastObject][@"json"];
    XCTAssertTrue([event isEqual:testEventData1]);
    XCTAssertTrue([self.dataStore removeEvent:[events lastObject]
                                    eventType:OPTLYDataStoreEventTypeConversion
                                        error:&error]);
    XCTAssertNil(error);
}

# pragma mark - File Manager Tests

- (void)testSaveFile {
    
    NSError *error;
    [self.dataStore saveFile:kTestFileName data:self.testFileData type:OPTLYDataStoreDataTypeDatafile error:nil];
    
    NSFileManager *defaultFileManager= [NSFileManager defaultManager];
    
    NSString *baseDir = self.dataStore.baseDirectory;
    NSString *fileDir = [baseDir stringByAppendingPathComponent:kDatafile];
    NSString *filePath = [fileDir stringByAppendingPathComponent:kTestFileName];
    // check if the file exists
    bool fileExists = [defaultFileManager fileExistsAtPath:filePath];
    XCTAssertTrue(fileExists, @"Saved file not found.");
    
    // check the contents of the file
    NSData *fileData = [NSData dataWithContentsOfFile:filePath options:0 error:&error];
    XCTAssert(fileData != nil, @"Saved file has no content.");
    XCTAssert([fileData isEqualToData:self.testFileData],  @"Invalid file content of saved file.");
}

- (void)testGetFile {
    NSError *error;
    [self.dataStore saveFile:kTestFileName data:self.testFileData type:OPTLYDataStoreDataTypeDatafile error:&error];
    NSData *fileData =[self.dataStore getFile:kTestFileName type:OPTLYDataStoreDataTypeDatafile error:&error];
    XCTAssert([fileData isEqualToData:self.testFileData], @"Invalid file content from retrieved file.");
    fileData = [self.dataStore getFile:kBadTestFileName type:OPTLYDataStoreDataTypeDatafile error:&error];
    XCTAssert(fileData == nil, @"Bad file name. getFile should return nil.");
}

- (void)testFileExists {
    NSError *error;
    [self.dataStore saveFile:kTestFileName data:self.testFileData type:OPTLYDataStoreDataTypeDatafile error:&error];
    
    // check that the file exists
    bool fileExists = [self.dataStore fileExists:kTestFileName type:OPTLYDataStoreDataTypeDatafile];
    XCTAssertTrue(fileExists, @"fileExists should return true.");
    
    // check that the file does no exist for a bad file name
    fileExists = [self.dataStore fileExists:kBadTestFileName type:OPTLYDataStoreDataTypeDatafile];
    XCTAssertFalse(fileExists, @"fileExists should return false.");
}

- (void)testDataTypeExists {
    NSError *error;
    [self.dataStore saveFile:kTestFileName data:self.testFileData type:OPTLYDataStoreDataTypeDatafile error:&error];
    
    // check that the file exists after the file save
    bool dataTypeExists = [self.dataStore dataTypeExists:OPTLYDataStoreDataTypeDatafile];
    XCTAssertTrue(dataTypeExists, @"Data type should exist.");
    
    // check that the file does not exist after the file removal
    [self.dataStore removeFilesForDataType:OPTLYDataStoreDataTypeDatafile error:nil];
    dataTypeExists = [self.dataStore dataTypeExists:OPTLYDataStoreDataTypeDatafile];
    XCTAssertFalse(dataTypeExists, @"Deleted data type should not exist.");
}

- (void)testRemoveDataType
{
    [self.dataStore saveFile:kTestFileName data:self.testFileData type:OPTLYDataStoreDataTypeDatafile error:nil];
    // check that the file exists after the file save
    bool fileExists = [self.dataStore fileExists:kTestFileName type:OPTLYDataStoreDataTypeDatafile];
    XCTAssertTrue(fileExists, @"Saved file should exist.");
    
    [self.dataStore removeFilesForDataType:OPTLYDataStoreDataTypeDatafile error:nil];
    
    BOOL isDir;
    NSFileManager *defaultFileManager= [NSFileManager defaultManager];
    NSString *datafileDir = [self.dataStore.baseDirectory stringByAppendingString:kDatafile];
    bool optlyDir = [defaultFileManager fileExistsAtPath:datafileDir isDirectory:&isDir];
    XCTAssertFalse(optlyDir, @"Datafile subdirectory should not exist.");
}

- (void)testRemoveAllFiles
{
    for (int i = 0; i < OPTLYDataStoreDataTypeCOUNT; ++i) {
        [self.dataStore saveFile:kTestFileName data:self.testFileData type:i error:nil];
        bool fileExists = [self.dataStore fileExists:kTestFileName type:i];
        NSString *dataType = [OPTLYDataStore stringForDataTypeEnum:i];
        XCTAssertTrue(fileExists, @"%@ file should exist.", dataType);
    }
    
    [self.dataStore removeAllFiles:nil];
    
    BOOL isDir = true;
    NSFileManager *defaultFileManager= [NSFileManager defaultManager];
    bool optlyDir = [defaultFileManager fileExistsAtPath:self.dataStore.baseDirectory isDirectory:&isDir];
    XCTAssertFalse(optlyDir, @"Optimizely file folder should not exist.");
}

// NSUserDefault
- (void)testSaveUserData
{
    [self.dataStore saveUserData:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeUserProfileService];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *retrievedData = [defaults objectForKey:[OPTLYDataStore stringForDataTypeEnum:OPTLYDataStoreDataTypeUserProfileService]];
    XCTAssert([self.testDataNSUserDefault isEqualToDictionary:retrievedData], @"Invalid data save.");
}

- (void)testGetUserDataForType
{
    [self.dataStore saveUserData:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeUserProfileService];
    NSDictionary *retrievedData = [self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfileService];
    XCTAssert([self.testDataNSUserDefault isEqualToDictionary:retrievedData], @"Invalid data retrieved.");
}

- (void)testRemoveUserDataForType
{
    [self.dataStore saveUserData:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeUserProfileService];
    [self.dataStore removeUserDataForType:OPTLYDataStoreDataTypeUserProfileService];
    NSDictionary *retrievedData = [self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfileService];
    [self.dataStore removeUserDataForType:OPTLYDataStoreDataTypeUserProfileService];
    XCTAssertNil(retrievedData, @"Data removal failed.");
}

- (void)testRemovedObjectInUserData
{
    [self.dataStore saveUserData:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeUserProfileService];
    [self.dataStore removeObjectInUserData:@"testKey2" type:OPTLYDataStoreDataTypeUserProfileService];
    NSDictionary *retrievedData = [self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfileService];
    NSDictionary *data = @{@"testKey1":@"testValue1"};
    XCTAssert([data isEqualToDictionary:retrievedData], @"Invalid object removed from data.");
}

- (void)testRemoveAllUserData
{
    for (int i = 0; i < OPTLYDataStoreDataTypeCOUNT; ++i) {
        [self.dataStore saveUserData:self.testDataNSUserDefault type:i];
    }

    [self.dataStore removeAllUserData];
    
    for (int i = 0; i < OPTLYDataStoreDataTypeCOUNT; ++i) {
        NSString *dataType = [OPTLYDataStore stringForDataTypeEnum:i];
        XCTAssertNil([self.dataStore getUserDataForType:i], @"%@ file should not exist.", dataType);
    }
}

- (void)testEventSaveDoesNotExceedMaxNumber {
    NSInteger maxNumberEvents = 10;
    self.dataStore.maxNumberOfEventsToSave = maxNumberEvents;
    
    NSInteger numberOfEventsSaved = 10;
    for (NSInteger i = 0; i < numberOfEventsSaved; ++i) {
        [self.dataStore saveEvent:self.testDataNSUserDefault
                        eventType:OPTLYDataStoreEventTypeConversion
                            error:nil];
    }
    
    dispatch_group_t dispatchSavedEventsGroup = dispatch_group_create();
    dispatch_group_enter(dispatchSavedEventsGroup);
    [self.dataStore saveEvent:self.testDataNSUserDefault
                    eventType:OPTLYDataStoreEventTypeConversion
                        error:nil
                   completion:^{
                       dispatch_group_leave(dispatchSavedEventsGroup);
                   }];
    dispatch_group_wait(dispatchSavedEventsGroup, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)));
    NSInteger numberOfSavedEvents = [self.dataStore numberOfEvents:OPTLYDataStoreEventTypeConversion error:nil];
    double percentageOfEventsToRemove = OPTLYDataStorePercentageOfEventsToRemoveUponOverflow/100.0;
    XCTAssert(numberOfSavedEvents == (maxNumberEvents - maxNumberEvents*percentageOfEventsToRemove), @"Invalid number of events saved: %lu.", numberOfSavedEvents);
 }

@end
