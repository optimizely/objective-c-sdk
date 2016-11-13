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
#import "OPTLYDatabase.h"
#import "OPTLYFileManager.h"
#import "OPTLYDatabaseEntity.h"
#import "OPTLYDatastore.h"

static NSString *const kTestFileName = @"testFileManager.txt";
static NSString *const kBadTestFileName = @"badTestFileManager.txt";
static NSString *const kTestString = @"testString";

static NSString * const kDatabase = @"database";
static NSString * const kDatafile = @"datafile";
static NSString * const kUserProfile = @"user-profile";
static NSString * const kEventDispatcher = @"event-dispatcher";

@interface OPTLYDataStore(Test)
- (NSString *)stringForDataTypeEnum:(OPTLYDataStoreDataType)dataType;
@end

@interface OPTLYDataStoreTest : XCTestCase
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@property (nonatomic, strong) NSData *testData;
@property (nonatomic, strong) NSDictionary *testDataNSUserDefault;
@end

@implementation OPTLYDataStoreTest

- (void)setUp {
    [super setUp];
    self.dataStore = [OPTLYDataStore new];
    self.testData = [kTestString dataUsingEncoding:NSUTF8StringEncoding];
    self.testDataNSUserDefault = @{@"testKey1":@"testValue1", @"testKey2" : @"testKey2"};
    [self.dataStore save:self.testDataNSUserDefault type:OPTLYDataStoreDataTypeUserProfile];
}

- (void)tearDown {
    [self.dataStore removeAllData:nil];
    self.testData = nil;
    [super tearDown];
}

#if TARGET_OS_IOS
- (void)testDatabaseAPIs {
    NSError *error = nil;
    
    NSDictionary *testData =
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
      @"visitorId": @"1234",
      @"eventName": @"people",
      @"clientEngine": @"objective-c-sdk-core",
      @"eventFeatures": @[]
      };
    
    // test insert
    [self.dataStore insertData:testData table:OPTLYDatabaseEventsTable error:&error];
    [self.dataStore insertData:testData table:OPTLYDatabaseEventsTable error:&error];
    [self.dataStore insertData:testData table:OPTLYDatabaseEventsTable error:&error];
    [self.dataStore insertData:testData table:OPTLYDatabaseEventsTable error:&error];
    [self.dataStore insertData:testData table:OPTLYDatabaseEventsTable error:&error];
    [self.dataStore insertData:testData table:OPTLYDatabaseEventsTable error:&error];
    
    // test retrieveFirstNEntries
    NSInteger n = 3;
    NSArray *results = [self.dataStore retrieveFirstNEntries:n table:OPTLYDatabaseEventsTable error:&error];
    XCTAssert([results count] == n, @"Data insertion failed or invalid number of results retrieved from retrieveFirstNEntries.");
    
    // test retrieveAllEntries
    NSInteger totalEntity = 6;
    results = [self.dataStore retrieveAllEntries:OPTLYDatabaseEventsTable error:&error];
    NSInteger numberOfRows = [self.dataStore numberOfRows:OPTLYDatabaseEventsTable error:&error];
    XCTAssert([results count] == totalEntity, @"Data insertion failed or invalid number of results retrieved from retrieveAllEntries");
    
    // test numberOfRows
    XCTAssert(numberOfRows == totalEntity, @"Invalid count from numberOfRows.");
    
    // test contents of retrieveAllEntries
    OPTLYDatabaseEntity *entity = results[0];
    NSString *entityString = entity.entityValue;
    NSDictionary *resultData = [NSJSONSerialization JSONObjectWithData:[entityString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    XCTAssert([resultData isEqualToDictionary:testData], @"Invalid result data retrieved.");
    
    // test deleteEntities
    NSMutableArray *entityIds = [NSMutableArray new];
    for (OPTLYDatabaseEntity *entity in results) {
        NSNumber *resultId = entity.entityId;
        [entityIds addObject:resultId];
    }
    [self.dataStore deleteEntities:entityIds table:OPTLYDatabaseEventsTable error:&error];
    
    numberOfRows = [self.dataStore numberOfRows:OPTLYDatabaseEventsTable error:&error];
    XCTAssert(numberOfRows == 0, @"Deletion failed. Invalid number of results retrieved from database");
}
#endif


# pragma mark - File Manager Tests

- (void)testSaveFile {
    
    NSError *error;
    [self.dataStore saveFile:kTestFileName data:self.testData type:OPTLYDataStoreDataTypeDatafile error:nil];
    
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
    XCTAssert([fileData isEqualToData:self.testData],  @"Invalid file content of saved file.");
}

- (void)testGetFile {
    NSError *error;
    [self.dataStore saveFile:kTestFileName data:self.testData type:OPTLYDataStoreDataTypeDatafile error:&error];
    NSData *fileData =[self.dataStore getFile:kTestFileName type:OPTLYDataStoreDataTypeDatafile error:&error];
    XCTAssert([fileData isEqualToData:self.testData], @"Invalid file content from retrieved file.");
    fileData = [self.dataStore getFile:kBadTestFileName type:OPTLYDataStoreDataTypeDatafile error:&error];
    XCTAssert(fileData == nil, @"Bad file name. getFile should return nil.");
}

- (void)testFileExists {
    NSError *error;
    [self.dataStore saveFile:kTestFileName data:self.testData type:OPTLYDataStoreDataTypeDatafile error:&error];
    
    // check that the file exists
    bool fileExists = [self.dataStore fileExists:kTestFileName type:OPTLYDataStoreDataTypeDatafile];
    XCTAssertTrue(fileExists, @"fileExists should return true.");
    
    // check that the file does no exist for a bad file name
    fileExists = [self.dataStore fileExists:kBadTestFileName type:OPTLYDataStoreDataTypeDatafile];
    XCTAssertFalse(fileExists, @"fileExists should return false.");
}

- (void)testDataTypeExists {
    NSError *error;
    [self.dataStore saveFile:kTestFileName data:self.testData type:OPTLYDataStoreDataTypeDatafile error:&error];
    
    // check that the file exists after the file save
    bool dataTypeExists = [self.dataStore dataTypeExists:OPTLYDataStoreDataTypeDatafile];
    XCTAssertTrue(dataTypeExists, @"Data type should exist.");
    
    // check that the file does not exist after the file removal
    [self.dataStore removeDataType:OPTLYDataStoreDataTypeDatafile error:nil];
    dataTypeExists = [self.dataStore dataTypeExists:OPTLYDataStoreDataTypeDatafile];
    XCTAssertFalse(dataTypeExists, @"Deleted data type should not exist.");
}

- (void)testRemoveDataType
{
    [self.dataStore saveFile:kTestFileName data:self.testData type:OPTLYDataStoreDataTypeDatafile error:nil];
    // check that the file exists after the file save
    bool fileExists = [self.dataStore fileExists:kTestFileName type:OPTLYDataStoreDataTypeDatafile];
    XCTAssertTrue(fileExists, @"Saved file should exist.");
    
    [self.dataStore removeDataType:OPTLYDataStoreDataTypeDatafile error:nil];
    
    bool isDir = true;
    NSFileManager *defaultFileManager= [NSFileManager defaultManager];
    NSString *datafileDir = [self.dataStore.baseDirectory stringByAppendingString:kDatafile];
    bool optlyDir = [defaultFileManager fileExistsAtPath:datafileDir isDirectory:&isDir];
    XCTAssertFalse(optlyDir, @"Datafile subdirectory should not exist.");
}

- (void)testRemoveAllData
{
    [self.dataStore saveFile:kTestFileName data:self.testData type:OPTLYDataStoreDataTypeDatabase error:nil];
    [self.dataStore saveFile:kTestFileName data:self.testData type:OPTLYDataStoreDataTypeDatafile error:nil];
    [self.dataStore saveFile:kTestFileName data:self.testData type:OPTLYDataStoreDataTypeEventDispatcher error:nil];
    [self.dataStore saveFile:kTestFileName data:self.testData type:OPTLYDataStoreDataTypeUserProfile error:nil];
    
    bool fileExists = [self.dataStore fileExists:kTestFileName type:OPTLYDataStoreDataTypeDatabase];
    XCTAssertTrue(fileExists, @"Saved database file should exist.");
    fileExists = [self.dataStore fileExists:kTestFileName type:OPTLYDataStoreDataTypeDatafile];
    XCTAssertTrue(fileExists, @"Saved datafile should exist.");
    fileExists = [self.dataStore fileExists:kTestFileName type:OPTLYDataStoreDataTypeEventDispatcher];
    XCTAssertTrue(fileExists, @"Saved event dispatcher file should exist.");
    fileExists = [self.dataStore fileExists:kTestFileName type:OPTLYDataStoreDataTypeUserProfile];
    XCTAssertTrue(fileExists, @"Saved user profile file should exist.");
    
    [self.dataStore removeAllData:nil];
    
    bool isDir = true;
    NSFileManager *defaultFileManager= [NSFileManager defaultManager];
    bool optlyDir = [defaultFileManager fileExistsAtPath:self.dataStore.baseDirectory isDirectory:&isDir];
    XCTAssertFalse(optlyDir, @"Optimizely file folder should not exist.");
}

// NSUserDefault
- (void)testSaveData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *retrievedData = [defaults objectForKey:[self.dataStore stringForDataTypeEnum:OPTLYDataStoreDataTypeUserProfile]];
    XCTAssert([self.testDataNSUserDefault isEqualToDictionary:retrievedData], @"Invalid data save.");
}

-(void)testGetDataForType
{
    NSDictionary *retrievedData = [self.dataStore getDataForType:OPTLYDataStoreDataTypeUserProfile];
    XCTAssert([self.testDataNSUserDefault isEqualToDictionary:retrievedData], @"Invalid data retrieved.");
}

- (void)testRemoveDataForType
{
    [self.dataStore removeDataForType:OPTLYDataStoreDataTypeUserProfile];
    NSDictionary *retrievedData = [self.dataStore getDataForType:OPTLYDataStoreDataTypeUserProfile];
    [self.dataStore removeDataForType:OPTLYDataStoreDataTypeUserProfile];
    XCTAssertNil(retrievedData, @"Data removal failed.");
}

- (void)testRemovedObjectInData
{
    [self.dataStore removeObjectInData:@"testKey2" type:OPTLYDataStoreDataTypeUserProfile];
    NSDictionary *retrievedData = [self.dataStore getDataForType:OPTLYDataStoreDataTypeUserProfile];
    NSDictionary *data = @{@"testKey1":@"testValue1"};
    XCTAssert([data isEqualToDictionary:retrievedData], @"Invalid object removed from data.");
}

@end
