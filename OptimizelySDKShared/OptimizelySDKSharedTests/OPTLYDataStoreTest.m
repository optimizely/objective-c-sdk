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

@interface OPTLYDataStore(Test)
@property (nonatomic, strong) NSDictionary *eventsCache;
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
    
    [self.dataStore saveData:self.testDataNSUserDefault eventType:OPTLYDataStoreEventTypeImpression error:&error];
    [self.dataStore saveFile:kTestFileName data:self.testFileData type:OPTLYDataStoreDataTypeDatafile error:&error];
    [self.dataStore saveUserData:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeUserProfile];
    
    [self.dataStore removeAll:&error];
    
    // check event storage
    NSArray *results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert([results count] == 0, @"RemoveAll failed to remove all saved events. Events left - %ld", (unsigned long)[results count]);
    
    // check file storage
    bool fileExists = [self.dataStore fileExists:kTestFileName type:OPTLYDataStoreDataTypeDatabase];
    XCTAssertFalse(fileExists, @"RemoveAll failed to remove file.");
    
    // check NSUserDefault storage
    XCTAssertNil([self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile], @"RemoveAll failed to remove NSUserDefault data.");
}

- (void)testEventsStorage {
    
    NSDictionary *testEventData1 =
    @{
      @"userFeatures": @[@{
                             @"value": @"alda",
                             @"shouldIndex": @true,
                             @"name": @"nameOfPerson",
                             @"type": @"custom"
                             }],
      @"timestamp": @1478510071576,
      @"clientVersion": @"0.2.0-debug",
      @"eventEntityId": @"7723870635",
      @"revision": @"7",
      @"isGlobalHoldback": @false,
      @"accountId": @"4902200114",
      @"layerStates": @[],
      @"projectId": @"7738070017",
      @"eventMetrics": @[@{
                             @"name": @"revenue",
                             @"value": @88
                             }],
      @"visitorId": @"1",
      @"eventName": @"people",
      @"clientEngine": @"objective-c-sdk-core",
      @"eventFeatures": @[]
      };
    
    NSDictionary *testEventData2 =
    @{
      @"userFeatures": @[@{
                             @"value": @"alda",
                             @"shouldIndex": @true,
                             @"name": @"nameOfPerson",
                             @"type": @"custom"
                             }],
      @"timestamp": @1478510071576,
      @"clientVersion": @"0.2.0-debug",
      @"eventEntityId": @"7723870635",
      @"revision": @"7",
      @"isGlobalHoldback": @false,
      @"accountId": @"4902200114",
      @"layerStates": @[],
      @"projectId": @"7738070017",
      @"eventMetrics": @[@{
                             @"name": @"revenue",
                             @"value": @88
                             }],
      @"visitorId": @"2",
      @"eventName": @"people",
      @"clientEngine": @"objective-c-sdk-core",
      @"eventFeatures": @[]
      };
    
    NSDictionary *testEventData3 =
    @{
      @"userFeatures": @[@{
                             @"value": @"alda",
                             @"shouldIndex": @true,
                             @"name": @"nameOfPerson",
                             @"type": @"custom"
                             }],
      @"timestamp": @1478510071576,
      @"clientVersion": @"0.2.0-debug",
      @"eventEntityId": @"7723870635",
      @"revision": @"7",
      @"isGlobalHoldback": @false,
      @"accountId": @"4902200114",
      @"layerStates": @[],
      @"projectId": @"7738070017",
      @"eventMetrics": @[@{
                             @"name": @"revenue",
                             @"value": @88
                             }],
      @"visitorId": @"3",
      @"eventName": @"people",
      @"clientEngine": @"objective-c-sdk-core",
      @"eventFeatures": @[]
      };
    
    NSDictionary *testEventData4 =
    @{
      @"userFeatures": @[@{
                             @"value": @"alda",
                             @"shouldIndex": @true,
                             @"name": @"nameOfPerson",
                             @"type": @"custom"
                             }],
      @"timestamp": @1478510071576,
      @"clientVersion": @"0.2.0-debug",
      @"eventEntityId": @"7723870635",
      @"revision": @"7",
      @"isGlobalHoldback": @false,
      @"accountId": @"4902200114",
      @"layerStates": @[],
      @"projectId": @"7738070017",
      @"eventMetrics": @[@{
                             @"name": @"revenue",
                             @"value": @88
                             }],
      @"visitorId": @"4",
      @"eventName": @"people",
      @"clientEngine": @"objective-c-sdk-core",
      @"eventFeatures": @[]
      };
    
    NSInteger totalEntity = 4;
    NSError *error = nil;
    
    // test insert
    [self.dataStore saveData:testEventData1 eventType:OPTLYDataStoreEventTypeImpression error:&error];
    [self.dataStore saveData:testEventData2 eventType:OPTLYDataStoreEventTypeImpression error:&error];
    [self.dataStore saveData:testEventData3 eventType:OPTLYDataStoreEventTypeImpression error:&error];
    [self.dataStore saveData:testEventData4 eventType:OPTLYDataStoreEventTypeImpression error:&error];
    
    XCTAssertNil(error, @"Save data failed.");
#if TARGET_OS_TV
    NSString *eventTypeName = [OPTLYDataStore stringForDataEventEnum:OPTLYDataStoreEventTypeImpression];
    OPTLYQueue *impressionQueue = nil;
    impressionQueue = [self.dataStore.eventsCache objectForKey:eventTypeName];
#endif

#if TARGET_OS_TV // tvOS data should always be cached
    XCTAssert([impressionQueue size] == 4, @"Data not cached as expected.");
#endif
    
    NSArray *results = nil;
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    
    // ---- test getOldestEvent ----
    NSDictionary *result = [self.dataStore getOldestEvent:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssertNotNil(result, @"Data insertion failed or invalid number of results retrieved from getOldestEvent.");
    XCTAssert([result isEqualToDictionary:testEventData1], @"Invalid result data retrieved for getOldestEvent.");
    
    // ---- test getFirstNEvents ----
    NSInteger n = 3;
    results = [self.dataStore getFirstNEvents:n eventType:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert([results count] == n, @"Data insertion failed or invalid number of results retrieved from getFirstNEvents.");
    XCTAssert([results[0] isEqualToDictionary:testEventData1], @"Invalid result data 1 retrieved for getFirstNEvents.");
    XCTAssert([results[1] isEqualToDictionary:testEventData2], @"Invalid result data 2 retrieved for getFirstNEvents.");
    XCTAssert([results[2] isEqualToDictionary:testEventData3], @"Invalid result data 3 retrieved for getFirstNEvents.");
    
    // ---- test getAllEntries ----
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert([results count] == totalEntity, @"Data insertion failed or invalid number of results retrieved from getAllEvents");
    XCTAssert([results[0] isEqualToDictionary:testEventData1], @"Invalid result data 1 retrieved for getAllEvents.");
    XCTAssert([results[1] isEqualToDictionary:testEventData2], @"Invalid result data 2 retrieved for getAllEvents.");
    XCTAssert([results[2] isEqualToDictionary:testEventData3], @"Invalid result data 3 retrieved for getAllEvents.");
    XCTAssert([results[3] isEqualToDictionary:testEventData4], @"Invalid result data 4 retrieved for getAllEvents.");
    
    // ---- test numberOfEvents ----
    NSInteger numberOfEvents = [self.dataStore numberOfEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert(numberOfEvents == totalEntity, @"Invalid count from numberOfEvents.");
    
    // ---- test removeOldestEvent ----
    [self.dataStore removeOldestEvent:OPTLYDataStoreEventTypeImpression error:&error];
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    numberOfEvents = [self.dataStore numberOfEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert(numberOfEvents == totalEntity-1, @"Invalid event count after removeOldestEvent was called.");
#if TARGET_OS_TV // tvOS data should always be cached
    XCTAssert([impressionQueue size] == totalEntity-1, @"Cached data not removed as expected.");
#endif
    XCTAssert([results[0] isEqualToDictionary:testEventData2], @"Invalid result data 1 retrieved after removeOldestEvent was called.");
    XCTAssert([results[1] isEqualToDictionary:testEventData3], @"Invalid result data 2 retrieved after removeOldestEvent was called.");
    XCTAssert([results[2] isEqualToDictionary:testEventData4], @"Invalid result data 3 retrieved after removeOldestEvent was called.");
    
    // ---- test removeFirstNEvents ----
    NSInteger nEventsToDelete = 2;
    [self.dataStore removeFirstNEvents:nEventsToDelete eventType:OPTLYDataStoreEventTypeImpression error:&error];
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert([results count] == totalEntity-1-nEventsToDelete, @"Invalid event count when removeFirstNEvents was called.");
#if TARGET_OS_TV // tvOS data should always be cached
    XCTAssert([impressionQueue size] == totalEntity-1-nEventsToDelete, @"Cached data not removed as expected.");
#endif
    XCTAssert([results[0] isEqualToDictionary:testEventData4], @"Invalid result data 1 retrieved after removeFirstNEvents was called.");
    
    // ---- test removeAllEvents ----
    [self.dataStore removeAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert([results count] == 0, @"Invalid event count when removeAllEvents was called.");
#if TARGET_OS_TV // tvOS data should always be cached
    XCTAssert([impressionQueue size]  == 0, @"Cached data not removed as expected.");
#endif
    
    // ---- test removeSavedEvents ----
    [self.dataStore saveData:testEventData1 eventType:OPTLYDataStoreEventTypeImpression error:&error];
    [self.dataStore saveData:testEventData2 eventType:OPTLYDataStoreEventTypeConversion error:&error];
    [self.dataStore removeAllEvents:&error];
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert([results count] == 0, @"Invalid impression event count when removeSavedEvents was called.");
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeConversion error:&error];
    XCTAssert([results count] == 0, @"Invalid conversion event count when removeSavedEvents was called.");
    
    // ---- test removeAllEvents ----
    [self.dataStore saveData:testEventData1 eventType:OPTLYDataStoreEventTypeImpression error:&error];
    [self.dataStore saveData:testEventData2 eventType:OPTLYDataStoreEventTypeConversion error:&error];
    [self.dataStore removeAll:&error];
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeImpression error:&error];
    XCTAssert([results count] == 0, @"Invalid impression event count when removeSavedEvents was called.");
    results = [self.dataStore getAllEvents:OPTLYDataStoreEventTypeConversion error:&error];
    XCTAssert([results count] == 0, @"Invalid conversion event count when removeSavedEvents was called.");
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
    [self.dataStore saveFile:kTestFileName data:self.testFileData type:OPTLYDataStoreDataTypeDatabase error:nil];
    [self.dataStore saveFile:kTestFileName data:self.testFileData type:OPTLYDataStoreDataTypeDatafile error:nil];
    [self.dataStore saveFile:kTestFileName data:self.testFileData type:OPTLYDataStoreDataTypeEventDispatcher error:nil];
    [self.dataStore saveFile:kTestFileName data:self.testFileData type:OPTLYDataStoreDataTypeUserProfile error:nil];
    
    bool fileExists = [self.dataStore fileExists:kTestFileName type:OPTLYDataStoreDataTypeDatabase];
    XCTAssertTrue(fileExists, @"Saved database file should exist.");
    fileExists = [self.dataStore fileExists:kTestFileName type:OPTLYDataStoreDataTypeDatafile];
    XCTAssertTrue(fileExists, @"Saved datafile should exist.");
    fileExists = [self.dataStore fileExists:kTestFileName type:OPTLYDataStoreDataTypeEventDispatcher];
    XCTAssertTrue(fileExists, @"Saved event dispatcher file should exist.");
    fileExists = [self.dataStore fileExists:kTestFileName type:OPTLYDataStoreDataTypeUserProfile];
    XCTAssertTrue(fileExists, @"Saved user profile file should exist.");
    
    [self.dataStore removeAllFiles:nil];
    
    BOOL isDir = true;
    NSFileManager *defaultFileManager= [NSFileManager defaultManager];
    bool optlyDir = [defaultFileManager fileExistsAtPath:self.dataStore.baseDirectory isDirectory:&isDir];
    XCTAssertFalse(optlyDir, @"Optimizely file folder should not exist.");
}

// NSUserDefault
- (void)testSaveUserData
{
    [self.dataStore saveUserData:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeUserProfile];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *retrievedData = [defaults objectForKey:[OPTLYDataStore stringForDataTypeEnum:OPTLYDataStoreDataTypeUserProfile]];
    XCTAssert([self.testDataNSUserDefault isEqualToDictionary:retrievedData], @"Invalid data save.");
}

-(void)testGetUserDataForType
{
    [self.dataStore saveUserData:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeUserProfile];
    NSDictionary *retrievedData = [self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    XCTAssert([self.testDataNSUserDefault isEqualToDictionary:retrievedData], @"Invalid data retrieved.");
}

- (void)testRemoveUserDataForType
{
    [self.dataStore saveUserData:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeUserProfile];
    [self.dataStore removeUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    NSDictionary *retrievedData = [self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    [self.dataStore removeUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    XCTAssertNil(retrievedData, @"Data removal failed.");
}

- (void)testRemovedObjectInUserData
{
    [self.dataStore saveUserData:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeUserProfile];
    [self.dataStore removeObjectInUserData:@"testKey2" type:OPTLYDataStoreDataTypeUserProfile];
    NSDictionary *retrievedData = [self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    NSDictionary *data = @{@"testKey1":@"testValue1"};
    XCTAssert([data isEqualToDictionary:retrievedData], @"Invalid object removed from data.");
}

- (void)testRemoveAllUserData
{
    [self.dataStore saveUserData:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeUserProfile];
    [self.dataStore saveUserData:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeDatabase];
    [self.dataStore saveUserData:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeDatafile];
    [self.dataStore saveUserData:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeEventDispatcher];
    [self.dataStore removeAllUserData];
    XCTAssertNil([self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile], @"User profile data should not exist.");
    XCTAssertNil([self.dataStore getUserDataForType:OPTLYDataStoreDataTypeDatabase], @"Database data should not exixt.");
    XCTAssertNil([self.dataStore getUserDataForType:OPTLYDataStoreDataTypeDatafile], @"Datafile data should not exist.");
    XCTAssertNil([self.dataStore getUserDataForType:OPTLYDataStoreDataTypeEventDispatcher], @"Event dispatcher data should not exist.");
}
@end
