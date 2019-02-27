/****************************************************************************
 * Copyright 2016,2018-2019, Optimizely, Inc. and contributors              *
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
#import "OPTLYProjectConfig.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYEventParameterKeys.h"
#import "OPTLYDecisionEventTicket.h"
#import "OPTLYDecisionService.h"
#import "OPTLYBucketer.h"
#import "OPTLYEventFeature.h"
#import "OPTLYExperiment.h"
#import "OPTLYEventMetric.h"
#import "OPTLYVariation.h"
#import "OPTLYEvent.h"
#import "OPTLYControlAttributes.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYLogger.h"
#import "Optimizely.h"

static NSString * const kDatafileName = @"test_data_10_experiments";
static NSString * const kDatafileNameAnonymizeIPFalse = @"test_data_25_experiments";
static NSString * const kUserId = @"6369992312";
static NSString * const kAccountId = @"6365361536";
static NSString * const kProjectId = @"6377970066";
static NSString * const kRevision = @"83";
static NSString * const kLayerId = @"1234";
static NSInteger kEventRevenue = 88;
static double kEventValue = 123.456;
static NSString * const kTotalRevenueId = @"6316734272";
static NSString * const kAttributeKeyBrowserType = @"browser_type";
static NSString * const kAttributeValueFirefox = @"firefox";
static NSString * const kAttributeValueChrome = @"chrome";
static NSString * const kAttributeKeyBrowserVersion = @"browser_version";
static NSString * const kAttributeKeyBrowserBuildNumber = @"browser_build_number";
static NSString * const kAttributeKeyBrowserIsDefault = @"browser_is_default";

// events with experiment, but no audiences
static NSString * const kEventWithoutAudienceName = @"testEvent";
static OPTLYEvent *eventWithoutAudience;
static NSString * const kEventWithoutAudienceId = @"6372590948";
static NSString * const kExperimentWithoutAudienceKey = @"testExperiment1";
static NSString * const kExperimentWithoutAudienceId = @"6367863211";
static NSString * const kVariationWithoutAudienceId = @"6384330452";

// events with experiment and audiences
static NSString * const kEventWithAudienceName = @"testEventWithAudiences";
static OPTLYEvent *eventWithAudience;
static NSString * const kEventWithAudienceId = @"6384781388";
static NSString * const kExperimentWithAudienceKey = @"testExperimentWithFirefoxAudience";
static OPTLYExperiment *experimentWithAudience;
static NSString * const kExperimentWithAudienceId = @"6383811281";
static NSString * const kVariationWithAudienceId = @"6333082303";

// experiment not running parameters
static NSString * const kEventWithExperimentNotRunningName = @"testEventWithExperimentNotRunning";
static NSString * const kEventWithExperimentNotRunningId = @"6380961307";
static NSString * const kExperimentNotRunningKey = @"testExperimentNotRunning";
static NSString * const kExperimentNotRunningId = @"6367444440";

// events without experiments
static NSString * const kEventWithoutExperimentName = @"testEventWithoutExperiments";
static NSString * const kEventWithoutExperimentId = @"6386521015";

// events with multiple experiments
static NSString * const kEventWithMultipleExperimentsName = @"testEventWithMultipleExperiments";
static NSString * const kEventWithMultipleExperimentsId = @"6372952486";

// events with invalid experiments
static NSString * const kEventWithInvalidExperimentName = @"testEventWithInvalidExperiment";
static NSString * const kEventWithInvalidExperimentId = @"6370392433";

typedef enum : NSUInteger {
    ImpressionTicket,
    ConversionTicket
} Ticket;

@interface Optimizely(test)
- (NSArray<NSDictionary *> *)decisionsFor:(OPTLYEvent *)event
                                   userId:(NSString *)userId
                               attributes:(NSDictionary<NSString *,id> *)attributes;
@end

@interface OPTLYEventBuilderDefault(Tests)
- (NSString *)sdkVersion;
- (NSArray *)createUserFeatures:(OPTLYProjectConfig *)config
                     attributes:(NSDictionary *)attributes;
@end

@interface OPTLYEventBuilderTest : XCTestCase
@property (nonatomic, strong) Optimizely *optimizely;
@property (nonatomic, strong) OPTLYProjectConfig *config;
@property (nonatomic, strong) OPTLYEventBuilderDefault *eventBuilder;
@property (nonatomic, strong) OPTLYBucketer *bucketer;
@property (nonatomic, strong) NSDate *begTimestamp;
@property (nonatomic, strong) NSMutableDictionary *attributes;
@property (nonatomic, strong) NSMutableDictionary *attributeIds;
@property (nonatomic, strong) NSMutableDictionary *reservedAttributes;
@end

@implementation OPTLYEventBuilderTest

- (void)setUp {
    [super setUp];
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatafileName];
    self.optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelOff];
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
    self.config = [[OPTLYProjectConfig alloc] initWithDatafile:datafile];
    self.eventBuilder = [[OPTLYEventBuilderDefault alloc] initWithConfig:self.config];
    self.bucketer = [[OPTLYBucketer alloc] initWithConfig:self.config];
    self.attributes = [NSMutableDictionary dictionaryWithDictionary:@{kAttributeKeyBrowserType : kAttributeValueFirefox,
                                                                      kAttributeKeyBrowserVersion : @(68.1),
                                                                      kAttributeKeyBrowserBuildNumber : @(106),
                                                                      kAttributeKeyBrowserIsDefault : @YES
                                                                      }];
    self.attributeIds = [NSMutableDictionary dictionaryWithDictionary:@{kAttributeKeyBrowserType : @"6359881003",
                                                                        kAttributeKeyBrowserVersion : @"6359881004",
                                                                        kAttributeKeyBrowserBuildNumber : @"6359881005",
                                                                        kAttributeKeyBrowserIsDefault : @"6359881006"
                                                                        }];
    self.reservedAttributes = [NSMutableDictionary dictionaryWithDictionary:@{OptimizelyBotFiltering : @YES}];
    eventWithoutAudience = [self.config getEventForKey:kEventWithoutAudienceName];
    eventWithAudience = [self.config getEventForKey:kEventWithAudienceName];
    experimentWithAudience = [self.config getExperimentForKey:kExperimentWithAudienceKey];
    
    // need to do this cast because this is what happens when we get the event time stamp
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    long long currentTimeIntervalCast = currentTimeInterval;
    self.begTimestamp = [NSDate dateWithTimeIntervalSince1970:currentTimeIntervalCast];
}

- (void)tearDown {
    [super tearDown];
    self.config = nil;
    self.eventBuilder = nil;
    self.bucketer = nil;
}

#pragma mark - Test BuildConversionTicket:... Audiences

- (void)testBuildConversionTicketWithNoAudience {
    NSDictionary *params = [self.eventBuilder buildConversionEventForUser:kUserId
                                                                    event:eventWithoutAudience
                                                                eventTags:nil
                                                               attributes:nil];
    
    [self checkTicket:ConversionTicket
            forParams:params
               config:self.config
       experimentKeys:@[kExperimentWithoutAudienceId]
          variationId:nil
           attributes:self.reservedAttributes
             eventKey:kEventWithoutAudienceName
            eventTags:nil tags:nil
             bucketer:self.bucketer userId:kUserId];
}

- (void)testBuildConversionTicketWithValidAudience {
    NSDictionary *params = [self.eventBuilder buildConversionEventForUser:kUserId
                                                                    event:eventWithAudience
                                                                eventTags:nil
                                                               attributes:self.attributes];
    
    
    [self.attributes addEntriesFromDictionary:self.reservedAttributes];
    [self checkTicket:ConversionTicket
            forParams:params
               config:self.config
       experimentKeys:@[kExperimentWithAudienceId]
          variationId:nil
           attributes:self.attributes
             eventKey:kEventWithAudienceName
            eventTags:nil tags:nil
             bucketer:self.bucketer userId:kUserId];
}

#pragma mark - Test buildConversionTicket:... Invalid Args

- (void)testBuildConversionTicketWithInvalidAudience
{
    // check without attributes that satisfy audience requirement
    NSDictionary *attributes = @{@"browser_type":@"chrome"};
    NSDictionary *conversionTicket = [self.eventBuilder buildConversionEventForUser:kUserId
                                                                              event:eventWithAudience
                                                                          eventTags:nil
                                                                         attributes:attributes];
    
    XCTAssertNotNil(conversionTicket, @"Conversion ticket should not be nil.");
    NSDictionary *visitor = conversionTicket[OPTLYEventParameterKeysVisitors][0];
    NSDictionary *snapshot = visitor[OPTLYEventParameterKeysSnapshots][0];
}

- (void)testBuildConversionTicketWithExperimentNotRunning {
    OPTLYEvent *event = [self.config getEventForKey:kEventWithExperimentNotRunningName];
    NSDictionary *conversionTicket = [self.eventBuilder buildConversionEventForUser:kUserId
                                                                              event:event
                                                                          eventTags:nil
                                                                         attributes:nil];
    
    
    XCTAssertNotNil(conversionTicket, @"Conversion ticket should not be nil.");
    NSDictionary *visitor = conversionTicket[OPTLYEventParameterKeysVisitors][0];
    NSDictionary *snapshot = visitor[OPTLYEventParameterKeysSnapshots][0];
    NSDictionary *decisions = snapshot[OPTLYEventParameterKeysDecisions];
    XCTAssertEqual([decisions count], 0, @"Conversion ticket should not have any decision");
}

- (void)testBuildConversionTicketWithInvalidExperiment {
    OPTLYEvent *event = [self.config getEventForKey:kEventWithInvalidExperimentName];
    NSDictionary *conversionTicket = [self.eventBuilder buildConversionEventForUser:kUserId
                                                                              event:event
                                                                          eventTags:nil
                                                                         attributes:nil];
    
    
    XCTAssertNotNil(conversionTicket, @"Conversion ticket should not be nil.");
    NSDictionary *visitor = conversionTicket[OPTLYEventParameterKeysVisitors][0];
    NSDictionary *snapshot = visitor[OPTLYEventParameterKeysSnapshots][0];
    NSDictionary *decisions = snapshot[OPTLYEventParameterKeysDecisions];
    XCTAssertEqual([decisions count], 0, @"Conversion ticket should not have any decision");
}

- (void)testBuildConversionTicketWithNoConfig {
    self.config = nil;
    self.eventBuilder = [[OPTLYEventBuilderDefault alloc] initWithConfig:self.config];
    NSDictionary *conversionTicket = [self.eventBuilder buildConversionEventForUser:kUserId
                                                                              event:eventWithAudience
                                                                          eventTags:nil
                                                                         attributes:self.attributes];
    
    
    XCTAssertNil(conversionTicket, @"Conversion ticket should be nil.");
}

#pragma mark - Test Objective-C NSNumber's

- (void)testObjectiveCAtEncode
{
    // Test facts we need to know about @encode and NSNumber objCType's in order
    // to implement Optimizely event metrics correctly.  The short story
    // is Optimizely event metrics need to be numbers but "boolean"
    // NSNumber's serialize as JSON booleans not JSON numbers, so must
    // be disallowed.
    XCTAssertEqualObjects(@(@encode(bool)),@"B",@"Expected @encode(bool) == B");
    XCTAssertEqualObjects(@(@encode(char)),@"c",@"Expected @encode(char) == c");
    XCTAssertEqualObjects(@(@encode(unsigned char)),@"C",@"Expected @encode(unsigned char) == C");
    XCTAssertEqualObjects(@(@encode(short)),@"s",@"Expected @encode(short) == s");
    XCTAssertEqualObjects(@(@encode(unsigned short)),@"S",@"Expected @encode(unsigned short) == S");
    XCTAssertEqualObjects(@(@encode(int)),@"i",@"Expected @encode(int) == i");
    XCTAssertEqualObjects(@(@encode(unsigned int)),@"I",@"Expected @encode(unsigned int) == I");
#if __LP64__
    NSLog(@"64 bit platform");
    // Objective-C "long" == "long long" == 8 bytes (LP64 size)
    // https://developer.apple.com/library/content/documentation/General/Conceptual/CocoaTouch64BitGuide/Major64-BitChanges/Major64-BitChanges.html
    XCTAssertEqualObjects(@(@encode(long)),@(@encode(long long)),@"Expected @encode(long) == %@",@(@encode(long long)));
    XCTAssertEqualObjects(@(@encode(unsigned long)),@(@encode(unsigned long long)),@"Expected @encode(unsigned long) == %@",@(@encode(unsigned long long)));
#else
    NSLog(@"32 bit platform");
    // Objective-C "long" == "int" == 4 bytes (LP32 size)
    // https://developer.apple.com/library/content/documentation/General/Conceptual/CocoaTouch64BitGuide/Major64-BitChanges/Major64-BitChanges.html
    XCTAssertEqualObjects(@(@encode(long)),@(@encode(long long)),@"Expected @encode(long) == %@",@(@encode(int)));
    XCTAssertEqualObjects(@(@encode(unsigned long)),@(@encode(unsigned long long)),@"Expected @encode(unsigned int) == %@",@(@encode(unsigned int)));
#endif
    XCTAssertEqualObjects(@(@encode(long long)),@"q",@"Expected @encode(long long) == q");
    XCTAssertEqualObjects(@(@encode(unsigned long long)),@"Q",@"Expected @encode(unsigned long long) == Q");
    XCTAssertEqualObjects(@(@encode(float)),@"f",@"Expected @encode(float) == f");
    XCTAssertEqualObjects(@(@encode(double)),@"d",@"Expected @encode(double) == d");
}

- (void)testObjectiveCBooleanNSNumbers
{
    // Test facts we need to know about "boolean" NSNumber's in order
    // to implement Optimizely event metrics correctly.  The short story
    // is Optimizely event metrics need to be numbers but "boolean"
    // NSNumber's serialize as JSON booleans not JSON numbers, so must
    // be disallowed.
    // Confirm behavior of Apple NSJSONSerialization wrt NSNumber's
    // created via "+ (NSNumber *)numberWithBool:(BOOL)value;"
    // NOTE: We pass a small a test dictionary to NSJSONSerialization's
    // method instead of mere NSNumber by itself because Apple's
    // NSJSONSerialization is sadly incomplete wrt RFC 7159 .
    {
        // "NSCFBoolean is a private class in the NSNumber class cluster."
        // http://nshipster.com/bool/
        // Some Objective-C quirkiness goes on here as one might
        // have reasonably predicted that @YES and @NO would have
        // objCType == "B" , but it is not so.
        NSLog(@"[@YES objCType] == %@", @([@YES objCType]));
        NSLog(@"[@NO objCType] == %@", @([@NO objCType]));
        XCTAssertEqualObjects(@([@YES objCType]),@"c",@"Expected [@YES objCType] == c");
        XCTAssertEqualObjects(@([@NO objCType]),@"c",@"Expected [@NO objCType] == c");
    }
    {
        NSObject *object = @{@"key":[NSNumber numberWithBool:YES]};
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
        XCTAssertNil(error, @"Not expecting NSJSONSerialization error");
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(string,@"{\"key\":true}");
    }
    {
        NSObject *object = @{@"key":[NSNumber numberWithBool:NO]};
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
        XCTAssertNil(error, @"Not expecting NSJSONSerialization error");
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(string,@"{\"key\":false}");
    }
    {
        XCTAssertEqualObjects(@YES,[NSNumber numberWithBool:YES],@"Expected @YES == [NSNumber numberWithBool:YES]");
        XCTAssertEqualObjects(@NO,[NSNumber numberWithBool:NO],@"Expected @NO == [NSNumber numberWithBool:NO]");
    }
    {
        NSObject *object = @{@"key":@YES};
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
        XCTAssertNil(error, @"Not expecting NSJSONSerialization error");
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(string,@"{\"key\":true}");
    }
    {
        NSObject *object = @{@"key":@NO};
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
        XCTAssertNil(error, @"Not expecting NSJSONSerialization error");
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(string,@"{\"key\":false}");
    }
    // CONCLUDE: Optimizely event metric 'value' is specified to be
    // a number, so we'll need a JSON number transmitted to server.
    // However, we see above that NSNumber's created via
    // "+ (NSNumber *)numberWithBool:(BOOL)value;" do not qualify.
}

- (void)testObjectiveCCharNSNumbers
{
    // Test facts we need to know about "char" and "unsigned char" NSNumber's .
    // It turns out that "char" NSNumber's do serialize as JSON numbers
    // which are acceptable.
    {
        NSObject *object = @{@"key":[NSNumber numberWithChar:'A']};
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
        XCTAssertNil(error, @"Not expecting NSJSONSerialization error");
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(string,@"{\"key\":65}");
    }
    {
        NSObject *object = @{@"key":[NSNumber numberWithUnsignedChar:(unsigned char)'A']};
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
        XCTAssertNil(error, @"Not expecting NSJSONSerialization error");
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(string,@"{\"key\":65}");
    }
    {
        NSObject *object = @{@"key":[NSNumber numberWithUnsignedChar:'\xFF']};
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
        XCTAssertNil(error, @"Not expecting NSJSONSerialization error");
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        // Oddly, signed chars serialize just like unsigned chars, even if negative.
        // This possibly says something about the benefits and drawbacks of using
        // signed "char" NSNumber's in code, but the litmus test for Optimizely server
        // is that it receives a number, and this qualifies.
        XCTAssertEqualObjects(string,@"{\"key\":255}");
    }
    {
        NSObject *object = @{@"key":[NSNumber numberWithUnsignedChar:(unsigned char)'\xFF']};
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
        XCTAssertNil(error, @"Not expecting NSJSONSerialization error");
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(string,@"{\"key\":255}");
    }
    {
        NSObject *object = @{@"key":@'A'};
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
        XCTAssertNil(error, @"Not expecting NSJSONSerialization error");
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(string,@"{\"key\":65}");
    }
}

#pragma mark - Test revenue Metric

- (void)testRevenueMetric {
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@(kEventRevenue)};
    [self commonBuildConversionTicketTest:tags sentEventTags:tags sentTags:tags];
}

- (void)testRevenueMetricWithDouble
{
    // The SDK issues a console warning about casting double to "long long",
    // but a "revenue" key-value pair will appear in the transmitted event.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(888.88)}
                            sentEventTags:@{OPTLYEventMetricNameRevenue:@(888LL)}
                                 sentTags:@{OPTLYEventMetricNameRevenue:@(888.88)}];
}

- (void)testRevenueMetricWithHugeDouble
{
    // The SDK prevents double's outside the range [LLONG_MIN, LLONG_MAX]
    // from being cast into nonsense and sent.  Instead a console warning
    // is issued and the 'revenue' key-value pair will not appear in the transmitted event.
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@(1.0e100)};
    [self commonBuildConversionTicketTest:tags sentEventTags:@{} sentTags:tags];
}

- (void)testRevenueMetricWithBoundaryDouble1
{
    // The SDK prevents double's outside the range [LLONG_MIN, LLONG_MAX]
    // from being cast into nonsense and sent.  Instead a console warning
    // is issued and the 'revenue' key-value pair will not appear in the transmitted event.
    // This is a little tricky since casting LLONG_MIN to double loses some bits
    // of precision and then casting back to "long long" can't restore the lost bits.
    // Multiply by a value slightly less than 1.0 to assure we stay inside.
    const double stayInside = 0.99999;
    double doubleRevenue = stayInside*(double)LLONG_MIN;
    long long longLongRevenue = (long long)doubleRevenue;
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(doubleRevenue)}
                            sentEventTags:@{OPTLYEventMetricNameRevenue:@(longLongRevenue)}
                                 sentTags:@{OPTLYEventMetricNameRevenue:@(doubleRevenue)}];
}

- (void)testRevenueMetricWithBoundaryDouble2
{
    // Like previous test but using LLONG_MAX instead of LLONG_MIN .
    // The SDK prevents double's outside the range [LLONG_MIN, LLONG_MAX]
    // from being cast into nonsense and sent.  Instead a console warning
    // is issued and the 'revenue' key-value pair will not appear in the transmitted event.
    // This is a little tricky since casting LLONG_MIN to double loses some bits
    // of precision and then casting back to "long long" can't restore the lost bits.
    // Multiply by a value slightly less than 1.0 to assure we stay inside.
    const double stayInside = 0.99999;
    double doubleRevenue = stayInside*(double)LLONG_MAX;
    long long longLongRevenue = (long long)doubleRevenue;
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(doubleRevenue)}
                            sentEventTags:@{OPTLYEventMetricNameRevenue:@(longLongRevenue)}
                                 sentTags:@{OPTLYEventMetricNameRevenue:@(doubleRevenue)}];
}

- (void)testRevenueMetricWithBoundaryDouble3
{
    // The SDK prevents double's outside the range [LLONG_MIN, LLONG_MAX]
    // from being cast into nonsense and sent.  Instead a console warning
    // is issued and the 'revenue' key-value pair will not appear in the transmitted event.
    // This is a little tricky since casting LLONG_MIN to double loses some bits
    // of precision and then casting back to "long long" can't restore the lost bits.
    // Multiply by a value slightly more than 1.0 to assure we stay outside.
    const double stayOutside = 1.00001;
    double doubleRevenue = stayOutside*(double)LLONG_MIN;
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(doubleRevenue)}
                            sentEventTags:@{}
                                 sentTags:@{OPTLYEventMetricNameRevenue:@(doubleRevenue)}];
}

- (void)testRevenueMetricWithBoundaryDouble4
{
    // Like previous test but using LLONG_MAX instead of LLONG_MIN .
    // The SDK prevents double's outside the range [LLONG_MIN, LLONG_MAX]
    // from being cast into nonsense and sent.  Instead a console warning
    // is issued and the 'revenue' key-value pair will not appear in the transmitted event.
    // This is a little tricky since casting LLONG_MIN to double loses some bits
    // of precision and then casting back to "long long" can't restore the lost bits.
    // Multiply by a value slightly more than 1.0 to assure we stay outside.
    const double stayOutside = 1.00001;
    double doubleRevenue = stayOutside*(double)LLONG_MAX;
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(doubleRevenue)}
                            sentEventTags:@{}
                                 sentTags:@{OPTLYEventMetricNameRevenue:@(doubleRevenue)}];
}

- (void)testRevenueMetricWithCastUnsignedLongLong
{
    // "unsigned long long" which is barely in range.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@((unsigned long long)LLONG_MAX)}
                            sentEventTags:@{OPTLYEventMetricNameRevenue:@(LLONG_MAX)}
                                 sentTags:@{OPTLYEventMetricNameRevenue:@((unsigned long long)LLONG_MAX)}];
}

- (void)testRevenueMetricWithBoundaryUnsignedLongLong
{
    // The SDK prevents "unsigned long long"'s outside the range [LLONG_MIN, LLONG_MAX]
    // from being cast into nonsense and sent.  Instead a console warning
    // is issued and the 'revenue' key-value pair will not appear in the transmitted event.
    // A Bridge Too Far
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(1ULL+(unsigned long long)LLONG_MAX)}
                            sentEventTags:@{}
                                 sentTags:@{OPTLYEventMetricNameRevenue:@(1ULL+(unsigned long long)LLONG_MAX)}];
}

- (void)testRevenueMetricWithHugeUnsignedLongLong
{
    // The SDK prevents "unsigned long long"'s outside the range [LLONG_MIN, LLONG_MAX]
    // from being cast into nonsense and sent.  Instead a console warning
    // is issued and the 'revenue' key-value pair will not appear in the transmitted event.
    // NOTE: ULLONG_MAX > LLONG_MAX is such an example.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(ULLONG_MAX)}
                            sentEventTags:@{}
                                 sentTags:@{OPTLYEventMetricNameRevenue:@(ULLONG_MAX)}];
}

- (void)testRevenueMetricWithLongLongMax
{
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@(LLONG_MAX)};
    [self commonBuildConversionTicketTest:tags sentEventTags:tags sentTags:tags];
}

- (void)testRevenueMetricWithLongLongMin
{
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@(LLONG_MIN)};
    [self commonBuildConversionTicketTest:tags sentEventTags:tags sentTags:tags];
}

- (void)testRevenueMetricWithBoolean
{
    // NOTE: As discussed in code comments in test testObjectiveCBooleans ,
    // @YES won't be sent to Optimizely server, since it will serialize
    // as "true" instead of a JSON number.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@YES}
                            sentEventTags:@{}
                                 sentTags:@{OPTLYEventMetricNameRevenue:@YES}];
}

- (void)testRevenueMetricWithString
{
    // The SDK issues a console warning about casting NSString to "long long",
    // but a "revenue" key-value pair will appear in the transmitted event.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@"8.234"}
                            sentEventTags:@{OPTLYEventMetricNameRevenue:@(8LL)}
                                 sentTags:@{OPTLYEventMetricNameRevenue:@"8.234"}];
}

- (void)testRevenueMetricWithInvalidObject
{
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@[@"BAD",@"DATA"]}
                            sentEventTags:nil
                                 sentTags:nil];
}

#pragma mark - Test value Metric

- (void)testValueMetric
{
    NSDictionary *tags = @{OPTLYEventMetricNameValue:@(kEventValue)};
    [self commonBuildConversionTicketTest:tags sentEventTags:tags sentTags:tags];
}

- (void)testValueMetricWithBoolean
{
    // NOTE: As discussed in code comments in test testObjectiveCBooleans ,
    // @YES won't be sent to Optimizely server, since it will serialize
    // as "true" instead of a JSON number.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameValue:@YES}
                            sentEventTags:@{}
                                 sentTags:@{OPTLYEventMetricNameValue:@YES}];
}

- (void)testValueMetricWithString
{
    // The SDK issues a console warning about casting NSString to "double",
    // but a "value" key-value pair will appear in the transmitted event.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameValue:[NSString stringWithFormat:@"%g", kEventValue],
                                            kAttributeKeyBrowserType:kAttributeValueChrome}
                            sentEventTags:@{OPTLYEventMetricNameValue:@(kEventValue),
                                            kAttributeKeyBrowserType:kAttributeValueChrome}
                                 sentTags:@{OPTLYEventMetricNameValue:[NSString stringWithFormat:@"%g", kEventValue],
                                            kAttributeKeyBrowserType:kAttributeValueChrome}];
}

- (void)testValueMetricWithNAN
{
    // The SDK does not allow NAN partly because this value
    // doesn't serialize into JSON .  SDK issues a console warning
    // and omits the proposed "value" key-value pair which will not
    // appear in the transmitted event.  IOW, invalid value suppressed.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameValue:@(NAN),
                                            kAttributeKeyBrowserType:kAttributeValueChrome}
                            sentEventTags:@{kAttributeKeyBrowserType:kAttributeValueChrome}
                                 sentTags:@{OPTLYEventMetricNameValue:@(NAN),
                                            kAttributeKeyBrowserType:kAttributeValueChrome}];
}

- (void)testValueMetricWithINFINITY
{
    // The SDK does not allow INFINITY partly because this value
    // doesn't serialize into JSON .  SDK issues a console warning
    // and omits the proposed "value" key-value pair which will not
    // appear in the transmitted event.  IOW, invalid value suppressed.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameValue:@(INFINITY),
                                            kAttributeKeyBrowserType:kAttributeValueChrome}
                            sentEventTags:@{kAttributeKeyBrowserType:kAttributeValueChrome}
                                 sentTags:@{OPTLYEventMetricNameValue:@(INFINITY),
                                            kAttributeKeyBrowserType:kAttributeValueChrome}];
}

- (void)testValueMetricWithInvalidObject
{
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameValue:@[@"BAD",@"DATA"],
                                            kAttributeKeyBrowserType:kAttributeValueChrome}
                            sentEventTags:@{kAttributeKeyBrowserType:kAttributeValueChrome}
                                 sentTags:@{kAttributeKeyBrowserType:kAttributeValueChrome}];
}

#pragma mark - Test revenue Metric and value Metric

- (void)testRevenueMetricAndValueMetric
{
    // Test creating event containing both "revenue" and "value".  Imagine
    //     "revenue" == money received
    //     "value" == temperature measured
    // There isn't a good reason why both can't be sent in the same event.
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@(kEventRevenue),
                           OPTLYEventMetricNameValue:@(kEventValue)};
    [self commonBuildConversionTicketTest:tags sentEventTags:tags sentTags:tags];
}



#pragma mark - Test integer values as boolean

// these set of tests are for filtering bug report (Jira #4041): integer 1 is filtered out as boolean unexpectedly

- (void)testRevenueMetricAndValueMetricWithRevenueIntegerOne
{
    // Test creating event containing both "revenue" and "value".  Imagine
    //     "revenue" == money received
    //     "value" == temperature measured
    // There isn't a good reason why both can't be sent in the same event.
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@1,
                           OPTLYEventMetricNameValue:@(kEventValue)};
    NSDictionary *sentTags = tags;
    [self commonBuildConversionTicketTest:tags
                            sentEventTags:sentTags
                                 sentTags:tags];
}
- (void)testRevenueMetricAndValueMetricWithRevenueIntegerZero
{
    // Test creating event containing both "revenue" and "value".  Imagine
    //     "revenue" == money received
    //     "value" == temperature measured
    // There isn't a good reason why both can't be sent in the same event.
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@0,
                           OPTLYEventMetricNameValue:@(kEventValue)};
    NSDictionary *sentTags = tags;
    [self commonBuildConversionTicketTest:tags
                            sentEventTags:sentTags
                                 sentTags:tags];
}
- (void)testRevenueMetricAndValueMetricWithRevenueIntegerTwo
{
    // Test creating event containing both "revenue" and "value".  Imagine
    //     "revenue" == money received
    //     "value" == temperature measured
    // There isn't a good reason why both can't be sent in the same event.
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@2,
                           OPTLYEventMetricNameValue:@(kEventValue)};
    NSDictionary *sentTags = tags;
    [self commonBuildConversionTicketTest:tags
                            sentEventTags:sentTags
                                 sentTags:tags];
}
- (void)testRevenueMetricAndValueMetricWithRevenueBooleanYes
{
    // Test creating event containing both "revenue" and "value".  Imagine
    //     "revenue" == money received
    //     "value" == temperature measured
    // There isn't a good reason why both can't be sent in the same event.
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@YES,
                           OPTLYEventMetricNameValue:@(kEventValue)};
    NSDictionary *sentTags = @{OPTLYEventMetricNameValue:@(kEventValue)};
    [self commonBuildConversionTicketTest:tags
                            sentEventTags:sentTags
                                 sentTags:tags];
}
- (void)testRevenueMetricAndValueMetricWithRevenueBooleanNo
{
    // Test creating event containing both "revenue" and "value".  Imagine
    //     "revenue" == money received
    //     "value" == temperature measured
    // There isn't a good reason why both can't be sent in the same event.
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@NO,
                           OPTLYEventMetricNameValue:@(kEventValue)};
    NSDictionary *sentTags = @{OPTLYEventMetricNameValue:@(kEventValue)};
    [self commonBuildConversionTicketTest:tags
                            sentEventTags: sentTags
                                 sentTags:tags];
}

// value tag checking

- (void)testRevenueMetricAndValueMetricWithValueIntegerOne
{
    // Test creating event containing both "revenue" and "value".  Imagine
    //     "revenue" == money received
    //     "value" == temperature measured
    // There isn't a good reason why both can't be sent in the same event.
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@(kEventRevenue),
                           OPTLYEventMetricNameValue:@1};
    NSDictionary *sentTags = tags;
    [self commonBuildConversionTicketTest:tags
                            sentEventTags:sentTags
                                 sentTags:tags];
}
- (void)testRevenueMetricAndValueMetricWithValueIntegerZero
{
    // Test creating event containing both "revenue" and "value".  Imagine
    //     "revenue" == money received
    //     "value" == temperature measured
    // There isn't a good reason why both can't be sent in the same event.
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@(kEventRevenue),
                           OPTLYEventMetricNameValue:@0};
    NSDictionary *sentTags = tags;
    [self commonBuildConversionTicketTest:tags
                            sentEventTags:sentTags
                                 sentTags:tags];
}
- (void)testRevenueMetricAndValueMetricWithValueIntegerTwo
{
    // Test creating event containing both "revenue" and "value".  Imagine
    //     "revenue" == money received
    //     "value" == temperature measured
    // There isn't a good reason why both can't be sent in the same event.
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@(kEventRevenue),
                           OPTLYEventMetricNameValue:@2};
    NSDictionary *sentTags = tags;
    [self commonBuildConversionTicketTest:tags
                            sentEventTags:sentTags
                                 sentTags:tags];
}
- (void)testRevenueMetricAndValueMetricWithValueIntegerNegativeOne
{
    // Test creating event containing both "revenue" and "value".  Imagine
    //     "revenue" == money received
    //     "value" == temperature measured
    // There isn't a good reason why both can't be sent in the same event.
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@(kEventRevenue),
                           OPTLYEventMetricNameValue:@(-1)};
    NSDictionary *sentTags = tags;
    [self commonBuildConversionTicketTest:tags
                            sentEventTags:sentTags
                                 sentTags:tags];
}
- (void)testRevenueMetricAndValueMetricWithValueBooleanYes
{
    // Test creating event containing both "revenue" and "value".  Imagine
    //     "revenue" == money received
    //     "value" == temperature measured
    // There isn't a good reason why both can't be sent in the same event.
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@(kEventRevenue),
                           OPTLYEventMetricNameValue:@YES};
    NSDictionary *sentTags = @{OPTLYEventMetricNameRevenue:@(kEventRevenue)};
    [self commonBuildConversionTicketTest:tags
                            sentEventTags:sentTags
                                 sentTags:tags];
}
- (void)testRevenueMetricAndValueMetricWithValueBooleanNo
{
    // Test creating event containing both "revenue" and "value".  Imagine
    //     "revenue" == money received
    //     "value" == temperature measured
    // There isn't a good reason why both can't be sent in the same event.
    NSDictionary *tags = @{OPTLYEventMetricNameRevenue:@(kEventRevenue),
                           OPTLYEventMetricNameValue:@NO};
    NSDictionary *sentTags = @{OPTLYEventMetricNameRevenue:@(kEventRevenue)};
    [self commonBuildConversionTicketTest:tags
                            sentEventTags: sentTags
                                 sentTags:tags];
}




#pragma mark - Test BuildConversionTicket:... with Multiple eventTags

- (void)testBuildConversionTicketWithEventTags
{
    [self commonBuildConversionTicketTest:@{kAttributeKeyBrowserType:kAttributeValueChrome,
                                            @"IntegerTag":@15,
                                            @"BooleanTag":@YES,
                                            @"FloatTag":@1.23,
                                            @"InvalidArrayTag":[NSArray new]}
                            sentEventTags:@{kAttributeKeyBrowserType:kAttributeValueChrome,
                                            @"IntegerTag":@15,
                                            @"FloatTag":@1.23,
                                            @"BooleanTag":@YES}
                                 sentTags:@{kAttributeKeyBrowserType:kAttributeValueChrome,
                                            @"IntegerTag":@15,
                                            @"BooleanTag":@YES,
                                            @"FloatTag":@1.23}];
}

- (void)testBuildConversionTicketWithRevenueAndEventTags
{
    NSDictionary *tags = @{OPTLYEventMetricNameValue:@(kEventRevenue),
                           kAttributeKeyBrowserType:kAttributeValueChrome};
    [self commonBuildConversionTicketTest:tags sentEventTags:tags sentTags:tags];
}

#pragma mark - Test anonymizeIP

- (void)testBuildConversionTicketWithAnonymizeIPFalse {
    OPTLYProjectConfig *config = [self setUpForAnonymizeIPFalse];
    OPTLYEventBuilderDefault *eventBuilder = [[OPTLYEventBuilderDefault alloc] initWithConfig:config];
    NSDictionary *params = [eventBuilder buildConversionEventForUser:kUserId
                                                               event:eventWithoutAudience
                                                           eventTags:nil
                                                          attributes:nil];
    
    NSNumber *anonymizeIP = params[OPTLYEventParameterKeysAnonymizeIP];
    XCTAssert([anonymizeIP boolValue] == false, @"Incorrect value for IP anonymization.");
}

#pragma mark - Test Invalid Attribute

- (void)testCreateConversionEventWithEmptyAttributeValue {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:@{kAttributeKeyBrowserType : @""}];
    NSDictionary *params = [self.eventBuilder buildConversionEventForUser:kUserId
                                                                    event:eventWithoutAudience
                                                                eventTags:nil
                                                               attributes:attributes];
    
    
    [attributes addEntriesFromDictionary:self.reservedAttributes];
    [self checkTicket:ConversionTicket
            forParams:params
               config:self.config
       experimentKeys:@[kExperimentWithoutAudienceId]
          variationId:nil
           attributes:attributes
             eventKey:kEventWithoutAudienceName
            eventTags:nil tags:nil
             bucketer:self.bucketer userId:kUserId];
}

- (void)testCreateConversionEventWithEmptyAttributeId {
    NSMutableDictionary *datafile = [NSMutableDictionary dictionaryWithDictionary:[OPTLYTestHelper loadJSONDatafile:kDatafileName]];
    [datafile setObject:@[@{
                              @"id": @"",
                              @"key": @"browser_type"
                              }]
                 forKey:@"attributes"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:datafile options:0 error:NULL];
    self.config = [[OPTLYProjectConfig alloc] initWithDatafile:data];
    self.eventBuilder = [[OPTLYEventBuilderDefault alloc] initWithConfig:self.config];
    
    NSDictionary *params = [self.eventBuilder buildConversionEventForUser:kUserId
                                                                    event:eventWithoutAudience
                                                                eventTags:nil
                                                               attributes:self.attributes];
    
    [self checkTicket:ConversionTicket
            forParams:params
               config:self.config
       experimentKeys:@[kExperimentWithoutAudienceId]
          variationId:nil
           attributes:self.reservedAttributes
             eventKey:kEventWithoutAudienceName
            eventTags:nil tags:nil
             bucketer:self.bucketer userId:kUserId];
}


#pragma mark - Test Bot Filtering

- (void)testImpressionEventWithoutBotFiltering {
    NSMutableDictionary *datafile = [NSMutableDictionary dictionaryWithDictionary:[OPTLYTestHelper loadJSONDatafile:kDatafileName]];
    [datafile removeObjectForKey:@"botFiltering"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:datafile options:0 error:NULL];
    self.config = [[OPTLYProjectConfig alloc] initWithDatafile:data];
    self.bucketer = [[OPTLYBucketer alloc] initWithConfig:self.config];
    self.eventBuilder = [[OPTLYEventBuilderDefault alloc] initWithConfig:self.config];
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:kExperimentWithAudienceKey
                                                                        userId:kUserId
                                                                    attributes:self.attributes
                                                                      bucketer:self.bucketer];
    
    
    NSDictionary *impressionEventTicketParams = [self.eventBuilder buildImpressionEventForUser:kUserId
                                                                                    experiment:experimentWithAudience
                                                                                     variation:bucketedVariation
                                                                                    attributes:self.attributes];
    
    [self checkTicket:ImpressionTicket
            forParams:impressionEventTicketParams
               config:self.config
       experimentKeys:@[kExperimentWithAudienceKey]
          variationId:bucketedVariation.variationId
           attributes:self.attributes
             eventKey:nil eventTags:nil tags:nil
             bucketer:nil userId:kUserId];
}

- (void)testImpressionEventWithBotFilteringFalse {
    NSMutableDictionary *datafile = [NSMutableDictionary dictionaryWithDictionary:[OPTLYTestHelper loadJSONDatafile:kDatafileName]];
    [datafile setObject:@(NO) forKey:@"botFiltering"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:datafile options:0 error:NULL];
    self.config = [[OPTLYProjectConfig alloc] initWithDatafile:data];
    self.bucketer = [[OPTLYBucketer alloc] initWithConfig:self.config];
    self.eventBuilder = [[OPTLYEventBuilderDefault alloc] initWithConfig:self.config];
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:kExperimentWithAudienceKey
                                                                        userId:kUserId
                                                                    attributes:self.attributes
                                                                      bucketer:self.bucketer];
    
    
    NSDictionary *impressionEventTicketParams = [self.eventBuilder buildImpressionEventForUser:kUserId
                                                                                    experiment:experimentWithAudience
                                                                                     variation:bucketedVariation
                                                                                    attributes:self.attributes];
    
    [self.reservedAttributes setObject:@(NO) forKey:OptimizelyBotFiltering];
    [self.attributes addEntriesFromDictionary:self.reservedAttributes];
    [self checkTicket:ImpressionTicket
            forParams:impressionEventTicketParams
               config:self.config
       experimentKeys:@[kExperimentWithAudienceKey]
          variationId:bucketedVariation.variationId
           attributes:self.attributes
             eventKey:nil eventTags:nil tags:nil
             bucketer:nil userId:kUserId];
}

- (void)testConversionEventWithoutBotFiltering {
    NSMutableDictionary *datafile = [NSMutableDictionary dictionaryWithDictionary:[OPTLYTestHelper loadJSONDatafile:kDatafileName]];
    [datafile removeObjectForKey:@"botFiltering"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:datafile options:0 error:NULL];
    self.config = [[OPTLYProjectConfig alloc] initWithDatafile:data];
    self.eventBuilder = [[OPTLYEventBuilderDefault alloc] initWithConfig:self.config];
    
    NSDictionary *params = [self.eventBuilder buildConversionEventForUser:kUserId
                                                                    event:eventWithAudience
                                                                eventTags:nil
                                                               attributes:self.attributes];
    
    [self checkTicket:ConversionTicket
            forParams:params
               config:self.config
       experimentKeys:@[kExperimentWithAudienceId]
          variationId:nil
           attributes:self.attributes
             eventKey:kEventWithAudienceName
            eventTags:nil tags:nil
             bucketer:self.bucketer userId:kUserId];
}

- (void)testConversionEventWithBotFilteringFalse {
    NSMutableDictionary *datafile = [NSMutableDictionary dictionaryWithDictionary:[OPTLYTestHelper loadJSONDatafile:kDatafileName]];
    [datafile setObject:@(NO) forKey:@"botFiltering"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:datafile options:0 error:NULL];
    self.config = [[OPTLYProjectConfig alloc] initWithDatafile:data];
    self.eventBuilder = [[OPTLYEventBuilderDefault alloc] initWithConfig:self.config];
    
    NSDictionary *params = [self.eventBuilder buildConversionEventForUser:kUserId
                                                                    event:eventWithAudience
                                                                eventTags:nil
                                                               attributes:self.attributes];
    
    [self.reservedAttributes setObject:@(NO) forKey:OptimizelyBotFiltering];
    [self.attributes addEntriesFromDictionary:self.reservedAttributes];
    [self checkTicket:ConversionTicket
            forParams:params
               config:self.config
       experimentKeys:@[kExperimentWithAudienceId]
          variationId:nil
           attributes:self.attributes
             eventKey:kEventWithAudienceName
            eventTags:nil tags:nil
             bucketer:self.bucketer userId:kUserId];
}

#pragma mark - Test BuildImpressionEventTicket:...

- (void)testBuildImpressionEventTicketWithAllArguments
{
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:kExperimentWithAudienceKey
                                                                        userId:kUserId
                                                                    attributes:self.attributes
                                                                      bucketer:self.bucketer];
    
    NSDictionary *impressionEventTicketParams = [self.eventBuilder buildImpressionEventForUser:kUserId
                                                                                    experiment:experimentWithAudience
                                                                                     variation:bucketedVariation
                                                                                    attributes:self.attributes];
    [self.attributes addEntriesFromDictionary:self.reservedAttributes];
    [self checkTicket:ImpressionTicket
            forParams:impressionEventTicketParams
               config:self.config
       experimentKeys:@[kExperimentWithAudienceKey]
          variationId:bucketedVariation.variationId
           attributes:self.attributes
             eventKey:nil eventTags:nil tags:nil
             bucketer:nil userId:kUserId];
    
}

- (void)testBuildImpressionEventTicketWithNoAudience {
    OPTLYExperiment *experiment = [self.config getExperimentForKey:kExperimentWithoutAudienceKey];
    OPTLYVariation *variation = [self.config getVariationForExperiment:kExperimentWithoutAudienceKey
                                                                userId:kUserId attributes:self.attributes bucketer:self.bucketer];
    NSDictionary *impressionEventTicketParams = [self.eventBuilder buildImpressionEventForUser:kUserId
                                                                                    experiment:experiment
                                                                                     variation:variation
                                                                                    attributes:self.attributes];
    [self.attributes addEntriesFromDictionary:self.reservedAttributes];
    [self checkTicket:ImpressionTicket
            forParams:impressionEventTicketParams
               config:self.config
       experimentKeys:@[kExperimentWithoutAudienceKey]
          variationId:kVariationWithoutAudienceId
           attributes:self.attributes
             eventKey:nil eventTags:nil tags:nil
             bucketer:nil userId:kUserId];
}

- (void)testBuildImpressionTicketWithAnonymizeIPFalse {
    OPTLYProjectConfig *config = [self setUpForAnonymizeIPFalse];
    OPTLYEventBuilderDefault *eventBuilder = [[OPTLYEventBuilderDefault alloc] initWithConfig:config];
    
    OPTLYExperiment *experiment = [config getExperimentForKey:kExperimentWithoutAudienceKey];
    OPTLYVariation *variation = [config getVariationForExperiment:kExperimentWithoutAudienceKey
                                                           userId:kUserId attributes:self.attributes bucketer:self.bucketer];
    NSDictionary *impressionEventTicketParams = [eventBuilder buildImpressionEventForUser:kUserId
                                                                               experiment:experiment
                                                                                variation:variation
                                                                               attributes:nil];
    NSNumber *anonymizeIP = impressionEventTicketParams[OPTLYEventParameterKeysAnonymizeIP];
    XCTAssert([anonymizeIP boolValue] == false, @"Incorrect value for IP anonymization.");
}

- (void)testBuildImpressionEventTicketWithNoConfig {
    self.config = nil;
    OPTLYEventBuilderDefault *eventBuilder = [[OPTLYEventBuilderDefault alloc] initWithConfig:self.config];
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:kExperimentWithAudienceKey
                                                                        userId:kUserId
                                                                    attributes:self.attributes
                                                                      bucketer:self.bucketer];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wnonnull"
    NSDictionary *impressionEventTicketParams = [eventBuilder buildImpressionEventForUser:kUserId
                                                                               experiment:experimentWithAudience
                                                                                variation:bucketedVariation
                                                                               attributes:self.attributes];
    
#pragma GCC diagnostic pop // "-Wnonnull"
    XCTAssert([impressionEventTicketParams count] == 0, @"parameters should not be created with no config.");
}

- (void)testBuildImpressionEventTicketWithAllTypeAttributes {
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:kExperimentWithAudienceKey
                                                                        userId:kUserId
                                                                    attributes:self.attributes
                                                                      bucketer:self.bucketer];
    
    NSDictionary *impressionEventTicketParams = [self.eventBuilder buildImpressionEventForUser:kUserId
                                                                                experiment:experimentWithAudience
                                                                                  variation:bucketedVariation
                                                                                   attributes:self.attributes];
    [self.attributes addEntriesFromDictionary:self.reservedAttributes];
    [self checkTicket:ImpressionTicket
            forParams:impressionEventTicketParams
               config:self.config
       experimentKeys:@[kExperimentWithAudienceKey]
          variationId:bucketedVariation.variationId
           attributes:self.attributes
             eventKey:nil eventTags:nil tags:nil bucketer:nil userId:kUserId];
}

#pragma mark - Helper Methods

- (void)commonBuildConversionTicketTest:(NSDictionary*)eventTags
                          sentEventTags:(NSDictionary*)sentEventTags
                               sentTags:(NSDictionary*)sentTags {
    
    // Common subroutine for many of the testBuildEventXxx test methods.
    // Generally, a testBuildEventXxx should make at most one call
    // to commonBuildConversionTicketTest:sentEventTags:sentTags: .
    NSDictionary *params = [self.eventBuilder buildConversionEventForUser:kUserId
                                                                    event:eventWithAudience
                                                                eventTags:eventTags
                                                               attributes:self.attributes];
    [self.attributes addEntriesFromDictionary:self.reservedAttributes];
    [self checkTicket:ConversionTicket
            forParams:params
               config:self.config
       experimentKeys:@[kExperimentWithAudienceId]
          variationId:nil
           attributes:self.attributes
             eventKey:kEventWithAudienceName
            eventTags:sentEventTags tags:sentTags
             bucketer:self.bucketer userId:kUserId];
}

- (void)checkTicket:(Ticket)ticket
          forParams:(NSDictionary *)params
             config:(OPTLYProjectConfig *)config
     experimentKeys:(NSArray *)experimentKeys
        variationId:(NSString *)variationId
         attributes:(NSDictionary *)attributes
           eventKey:(NSString *)eventKey
          eventTags:(NSDictionary *)eventTags
               tags:(NSDictionary *)tags
           bucketer:(OPTLYBucketer *)bucketer
             userId:(NSString *)userId {
    
    // check if payload available
    XCTAssertNotNil(params, @"Did not find payload");
    [self checkCommonParams:params withAttributes:attributes];
    
    // chcek for visitors
    NSArray *visitors = params[OPTLYEventParameterKeysVisitors];
    XCTAssertGreaterThan([visitors count], 0, @"Did not find any visitor");
    
    for (NSDictionary *visitor in visitors) {
        // chcek for impressionOnlyParams
        NSArray *conversionOrImpressionOnlyParams = visitor[OPTLYEventParameterKeysSnapshots];
        XCTAssertGreaterThan([conversionOrImpressionOnlyParams count], 0, @"Didn't find any snapshot");
        
        for (NSDictionary *ticketParams in conversionOrImpressionOnlyParams) {
            
            switch (ticket) {
                case ImpressionTicket: {
                    [self checkImpressionTicket:ticketParams config:config experimentKeys:experimentKeys variationId:variationId];
                    break;
                }
                case ConversionTicket: {
                    OPTLYEvent *eventEntity = [config getEventForKey:eventKey];
                    [self checkConversionTicket:ticketParams config:config eventId:eventEntity.eventId eventKey:eventKey experimentKeys:experimentKeys eventTags:eventTags tags:tags attributes:attributes bucketer:bucketer userId:userId];
                    break;
                }
            }
        }
    }
}

- (void)checkImpressionTicket:(NSDictionary *)params
                       config:(OPTLYProjectConfig *)config
               experimentKeys:(NSArray *)experimentKeys
                  variationId:(NSString *)variationId {
    
    // check if impression payload available
    XCTAssertNotNil(params, @"Invalid Impression ticket");
    
    NSArray *decisions = params[OPTLYEventParameterKeysDecisions];
    
    XCTAssertGreaterThan([decisions count], 0, @"Didn't find any decision");
    XCTAssertGreaterThan([experimentKeys count], 0, @"Didn't find any experiment key");
    
    OPTLYExperiment *experiment = [config getExperimentForKey:[experimentKeys firstObject]];
    
    for (NSDictionary *decision in decisions) {
        [self checkDecision:decision campaignId:experiment.layerId experimentId:experiment.experimentId variationId:variationId];
    }
    
    NSArray *events = params[OPTLYEventParameterKeysEvents];
    XCTAssertGreaterThan([events count], 0, @"Didn't find any event");
    
    for (NSDictionary *event in events) {
        [self checkImpression:event entityId:experiment.layerId eventKey:OptimizelyActivateEventKey uuid:@""];
    }
}

- (void)checkConversionTicket:(NSDictionary *)params
                       config:(OPTLYProjectConfig *)config
                      eventId:(NSString *)eventId
                     eventKey:(NSString *)eventKey
               experimentKeys:(NSArray *)experimentKeys
                    eventTags:(NSDictionary *)eventTags
                         tags:(NSDictionary *)tags
                   attributes:(NSDictionary *)attributes
                     bucketer:(OPTLYBucketer *)bucketer
                       userId:(NSString *)userId {
    
    // check conversion if payload available
    XCTAssertNotNil(params, @"Invalid Conversion ticket");
        
    NSArray *events = params[OPTLYEventParameterKeysEvents];
    XCTAssertGreaterThan([events count], 0, @"Didn't find any event");
    
    for (NSDictionary *event in events) {
        [self checkConversion:event entityId:eventId eventKey:eventKey uuid:@"" eventTags:eventTags tags:tags];
    }
}

- (void)checkDecision:(NSDictionary *)params
           campaignId:(NSString *)campaignId
         experimentId:(NSString *)experimentId
          variationId:(NSString *)variationId {
    
    XCTAssert([campaignId isEqualToString:params[OPTLYEventParameterKeysDecisionCampaignId]], @"Invalid campaignId.");
    XCTAssert([experimentId isEqualToString:params[OPTLYEventParameterKeysDecisionExperimentId]], @"Invalid experimentId.");
    XCTAssert([variationId isEqualToString: params[OPTLYEventParameterKeysDecisionVariationId]], @"Invalid variationId.");
}

- (void)checkImpression:(NSDictionary *)params
               entityId:(NSString *)entityId
               eventKey:(NSString *)eventKey
                   uuid:(NSString *)uuid {
    
    XCTAssert([entityId isEqualToString:params[OPTLYEventParameterKeysEntityId]], @"Invalid entityId.");
    XCTAssert([eventKey isEqualToString: params[OPTLYEventParameterKeysKey]], @"Invalid eventKey.");
    XCTAssertNotNil(params[OPTLYEventParameterKeysUUID], @"Did not find uuid in impression event.");
    XCTAssertNotEqual(params[OPTLYEventParameterKeysUUID], uuid, @"Invalid uuid.");
    
    NSDate *currentTimestamp = [NSDate date];
    // check timestamp is within the correct range
    NSNumber *timestamp = params[OPTLYEventParameterKeysTimestamp];
    double time = [timestamp doubleValue]/1000;
    NSDate *eventTimestamp = [NSDate dateWithTimeIntervalSince1970:time];
    XCTAssert([self date:eventTimestamp isBetweenDate:self.begTimestamp andDate:currentTimestamp], @"Invalid timestamp: %@.", eventTimestamp);
}

- (void)checkConversion:(NSDictionary *)params
               entityId:(NSString *)entityId
               eventKey:(NSString *)eventKey
                   uuid:(NSString *)uuid
              eventTags:(NSDictionary *)eventTags
                   tags:(NSDictionary *)tags {
    
    XCTAssert([entityId isEqualToString:params[OPTLYEventParameterKeysEntityId]], @"Invalid entityId.");
    
    NSDate *currentTimestamp = [NSDate date];
    // check timestamp is within the correct range
    NSNumber *timestamp = params[OPTLYEventParameterKeysTimestamp];
    double time = [timestamp doubleValue]/1000;
    NSDate *eventTimestamp = [NSDate dateWithTimeIntervalSince1970:time];
    XCTAssert([self date:eventTimestamp isBetweenDate:self.begTimestamp andDate:currentTimestamp], @"Invalid timestamp: %@.", eventTimestamp);
    XCTAssert([eventKey isEqualToString: params[OPTLYEventParameterKeysKey]], @"Invalid eventKey.");
    XCTAssertNotNil(params[OPTLYEventParameterKeysUUID], @"Did not find uuid in conversion event.");
    XCTAssertNotEqual(params[OPTLYEventParameterKeysUUID], uuid, @"Invalid uuid.");
    
    NSDictionary *sentTags = params[OPTLYEventParameterKeysTags];
    [self checkEventTags:tags withTags:sentTags];
    [self checkEventTags:eventTags withEvent:params];
}

- (void)checkEventTags:(NSDictionary *)eventTags
              withTags:(NSDictionary *)tags {
    
    // match tags with event tags. i.e number of tags and their content.
    XCTAssertEqualObjects(eventTags, tags, @"Invalid tags transmitted in the event");
}

- (void)checkEventTags:(NSDictionary *)eventTags
             withEvent:(NSDictionary *)event {
    
    // check for number of tags atleast equalt to event tags
    XCTAssert([event count] >= [eventTags count], @"Invalid number of event tags.");
    
    // (1) this checks if all expected fields exists in event
        
    if ([[eventTags allKeys] containsObject:OPTLYEventMetricNameRevenue]) {
        NSNumber *expectedRevenue = eventTags[OPTLYEventMetricNameRevenue];
        id revenue = event[OPTLYEventMetricNameRevenue];
        XCTAssertNotNil(revenue, @"Did not find revenue in event.");
        XCTAssert([revenue isKindOfClass:[NSNumber class]], @"revenue should be an NSNumber .");
        XCTAssertEqualObjects(revenue, expectedRevenue, @"event revenue should equal to %@ .", expectedRevenue);
    }
    if ([[eventTags allKeys] containsObject:OPTLYEventMetricNameValue]) {
        NSNumber *expectedValue = eventTags[OPTLYEventMetricNameValue];
        id value = event[OPTLYEventMetricNameValue];
        XCTAssertNotNil(value, @"Did not find value in event.");
        XCTAssert([value isKindOfClass:[NSNumber class]], @"value should be an NSNumber .");
        XCTAssertEqualObjects(value, expectedValue, @"event value should equal to %@ .", expectedValue);
    }

    // (2) we also need to check if unexpected fields still exists in event ({revenue, value} check only)
    //
    // [Jira #4041] integers {1 and 0} are filtered out accidentally since @YES and @NO interpreted as @1 and @0
    //              we need compare with @YES and @NO only for boolean NSNumber (objCType == @encode(char))

    NSMutableDictionary *eventTagsDefaultsOnly = [NSMutableDictionary new];
    if(eventTags != nil) {
        eventTagsDefaultsOnly[OPTLYEventMetricNameRevenue] = eventTags[OPTLYEventMetricNameRevenue];
        eventTagsDefaultsOnly[OPTLYEventMetricNameValue] = eventTags[OPTLYEventMetricNameValue];
    }

    NSMutableDictionary *allDefaultTagsInEvent = [NSMutableDictionary new];
    allDefaultTagsInEvent[OPTLYEventMetricNameRevenue] = event[OPTLYEventMetricNameRevenue];
    allDefaultTagsInEvent[OPTLYEventMetricNameValue] = event[OPTLYEventMetricNameValue];

    XCTAssertEqualObjects(eventTagsDefaultsOnly, allDefaultTagsInEvent, @"Invalid tag filtering");
}

- (void)checkCommonParams:(NSDictionary *)params withAttributes:(NSDictionary *)attributes {
    
    // check revision
    NSString *revision = params[OPTLYEventParameterKeysRevision];
    XCTAssert([revision isEqualToString:kRevision], @"Incorrect revision number.");
    
    // check project id
    NSString *projectId = params[OPTLYEventParameterKeysProjectId];
    XCTAssert([projectId isEqualToString:kProjectId], @"Incorrect project id.");
    
    // check account id
    NSString *accountId = params[OPTLYEventParameterKeysAccountId];
    XCTAssert([accountId isEqualToString:kAccountId], @"Incorrect accound id");
    
    // check clientEngine
    NSString *clientEngine = params[OPTLYEventParameterKeysClientEngine];
    XCTAssert([clientEngine isEqualToString:[self.config clientEngine]], @"Incorrect client engine.");
    
    // check clientVersion
    NSString *clientVersion = params[OPTLYEventParameterKeysClientVersion];
    XCTAssert([clientVersion isEqualToString:[self.config clientVersion]], @"Incorrect client version.");
    
    // check enrich_decisions
    NSNumber *enrich = params[OPTLYEventParameterKeysEnrichDecisions];
    XCTAssert([enrich boolValue] == true, @"Incorrect value for enrich decisions.");

    // check anonymizeIP
    NSNumber *anonymizeIP = params[OPTLYEventParameterKeysAnonymizeIP];
    XCTAssert([anonymizeIP boolValue] == true, @"Incorrect value for IP anonymization.");
    
    NSArray *visitors = params[OPTLYEventParameterKeysVisitors];
    [self checkVisitors:visitors withAttributes:attributes];
}

- (void)checkVisitors:(NSArray *)visitors withAttributes:(NSDictionary *)attributes {
    
    XCTAssert(visitors && [visitors count] > 0, @"Didn't find any visitor.");
    NSDictionary *visitor = [visitors firstObject];
    
    // check visitor id
    NSString *visitorId = visitor[OPTLYEventParameterKeysVisitorId];
    XCTAssert([visitorId isEqualToString:kUserId], @"Incorrect visitor id.");
    
    NSArray *userFeatures = visitor[OPTLYEventParameterKeysAttributes];
    [self checkUserFeatures:userFeatures withAttributes:attributes];
}

- (void)checkUserFeatures:(NSArray *)userFeatures
           withAttributes:(NSDictionary *)attributes {
    
    NSUInteger numberOfFeatures = [userFeatures count];
    NSUInteger numberOfAttributes = [attributes count];
    
    XCTAssert(numberOfFeatures == numberOfAttributes, @"Incorrect number of user features.");
    
    if (numberOfFeatures == numberOfAttributes) {
        NSSortDescriptor *featureNameDescriptor = [[NSSortDescriptor alloc] initWithKey:OPTLYEventParameterKeysFeaturesKey ascending:YES];
        NSArray *sortedUserFeaturesByName = [userFeatures sortedArrayUsingDescriptors:@[featureNameDescriptor]];

        NSSortDescriptor *attributeKeyDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
        NSArray *sortedAttributeKeys = [[attributes allKeys] sortedArrayUsingDescriptors:@[attributeKeyDescriptor]];
        
        for (NSUInteger i = 0; i < numberOfAttributes; i++)
        {
            NSDictionary *params = sortedUserFeaturesByName[i];
            
            NSString *anAttributeKey = sortedAttributeKeys[i];
            id anAttributeValue = [attributes objectForKey:anAttributeKey];
            
            NSString *featureName = params[OPTLYEventParameterKeysFeaturesKey];
            NSString *featureID = params[OPTLYEventParameterKeysFeaturesId];
            if ([featureName isEqualToString:OptimizelyBotFiltering]) {
                // check id
                XCTAssert([featureID isEqualToString:OptimizelyBotFiltering], @"Incorrect feature id: %@. for reserved Optimizely Bucket Id", featureID);
            } else {
                // check name
                XCTAssert([featureName isEqualToString:anAttributeKey ], @"Incorrect feature name.");
                // check id
                XCTAssert([featureID isEqualToString:self.attributeIds[featureName]], @"Incorrect feature id: %@.", featureID);
            }
            
            // check type
            NSString *featureType = params[OPTLYEventParameterKeysFeaturesType];
            XCTAssert([featureType isEqualToString:OPTLYEventFeatureFeatureTypeCustomAttribute], @"Incorrect feature type.");
            
            // check value
            id featureValue = params[OPTLYEventParameterKeysFeaturesValue];
            XCTAssertEqualObjects(featureValue, anAttributeValue, @"Incorrect feature value.");
            
            // check should index
            BOOL shouldIndex = [params[OPTLYEventParameterKeysFeaturesShouldIndex] boolValue];
            XCTAssert(shouldIndex == true, @"Incorrect shouldIndex value.");
        }
    }
}

- (OPTLYProjectConfig *)setUpForAnonymizeIPFalse
{
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatafileNameAnonymizeIPFalse];
    return [[OPTLYProjectConfig alloc] initWithDatafile:datafile];
}

- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
}

@end
