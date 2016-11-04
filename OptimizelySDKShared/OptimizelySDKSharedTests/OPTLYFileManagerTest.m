//
//  OPTLYFileManagerTest.m
//  OptimizelySDKDatafileManager
//
//  Created by Alda Luong on 11/3/16.
//  Copyright © 2016 Optimizely. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OPTLYFileManager.h"

static NSString *const kTestFileName = @"testFileManager";
static NSString *const kTestString = @"testString";

@interface OPTLYFileManager()
@property (nonatomic, strong) NSString *baseDir;
- (NSString *)stringForDataTypeEnum:(OPTLYFileManagerDataType)dataType;
@end

@interface OPTLYFileManagerTest : XCTestCase
@property (nonatomic, strong) OPTLYFileManager *fileManager;
@property (nonatomic, strong) NSString *fileDir;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSData *testData;
@end

@implementation OPTLYFileManagerTest

- (void)setUp {
    [super setUp];
    self.fileManager = [OPTLYFileManager new];
    self.testData = [kTestString dataUsingEncoding:NSUTF8StringEncoding];
    self.fileDir = [self.fileManager.baseDir stringByAppendingPathComponent:[self.fileManager stringForDataTypeEnum:OPTLYFileManagerDataTypeDatafile]];
    self.filePath = [self.fileDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", kTestFileName]];
}

- (void)tearDown {
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:self.filePath error:nil];
    self.fileManager = nil;
    self.testData = nil;
    self.fileDir = nil;
    self.filePath = nil;
    [super tearDown];
}

- (void)testSaveFile {
    
    NSError *error;
    [self.fileManager saveFile:kTestFileName
                          data:self.testData
                          type:OPTLYFileManagerDataTypeDatafile
                         error:&error];
    

    NSFileManager *defaultFileManager= [NSFileManager defaultManager];
    
    // check if the file exists
    bool fileExists = [defaultFileManager fileExistsAtPath:self.filePath];
    XCTAssertTrue(fileExists, @"Saved file not found.");
    
    // check the contents of the file
    NSData *fileData = [NSData dataWithContentsOfFile:self.filePath options:0 error:&error];
    XCTAssert(fileData != nil, @"Saved file has no content.");
    XCTAssert([fileData isEqualToData:self.testData],  @"Invalid file content of saved file.");
}

- (void)testGetFile {
    NSError *error;
    [self.fileManager saveFile:kTestFileName
                          data:self.testData
                          type:OPTLYFileManagerDataTypeDatafile
                         error:&error];
    NSData *fileData = [self.fileManager getFile:kTestFileName
                                            type:OPTLYFileManagerDataTypeDatafile
                                           error:&error];
    XCTAssert([fileData isEqualToData:self.testData],  @"Invalid file content from retrieved file.");
}

- (void)testFileExists {
    NSError *error;
    [self.fileManager saveFile:kTestFileName
                          data:self.testData
                          type:OPTLYFileManagerDataTypeDatafile
                         error:&error];
    
    // check that the file exists
    bool fileExists = [self.fileManager fileExists:kTestFileName type:OPTLYFileManagerDataTypeDatafile];
    XCTAssertTrue(fileExists, @"fileExists does return the correct value.");
}

- (void)testRemoveFile {
    NSError *error;
    [self.fileManager saveFile:kTestFileName
                          data:self.testData
                          type:OPTLYFileManagerDataTypeDatafile
                         error:&error];

    // check that the file exists after the file save
    bool fileExists = [self.fileManager fileExists:kTestFileName type:OPTLYFileManagerDataTypeDatafile];
    XCTAssertTrue(fileExists, @"Saved file should not exist.");

    // check that the file does not exist after the file removal
    [self.fileManager removeFile:kTestFileName type:OPTLYFileManagerDataTypeDatafile error:&error];
    fileExists = [self.fileManager fileExists:kTestFileName type:OPTLYFileManagerDataTypeDatafile];
    XCTAssertFalse(fileExists, @"Deleted file should not exist.");
}
@end
