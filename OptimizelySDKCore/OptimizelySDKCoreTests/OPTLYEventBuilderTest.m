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
#import "OPTLYProjectConfig.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYEventParameterKeys.h"
#import "OPTLYDecisionEventTicket.h"
#import "OPTLYDecisionService.h"
#import "OPTLYBucketer.h"
#import "OPTLYMacros.h"
#import "OPTLYEventFeature.h"
#import "OPTLYExperiment.h"
#import "OPTLYEventMetric.h"
#import "OPTLYVariation.h"
#import "OPTLYEvent.h"

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
static NSString * const kAttributeId = @"6359881003";
static NSString * const kAttributeKeyBrowserType = @"browser_type";
static NSString * const kAttributeValueFirefox = @"firefox";
static NSString * const kAttributeValueChrome = @"chrome";

// events with experiment, but no audiences
static NSString * const kEventWithoutAudienceName = @"testEvent";
static NSString * const kEventWithoutAudienceId = @"6372590948";
static NSString * const kExperimentWithoutAudienceKey = @"testExperiment1";
static NSString * const kExperimentWithoutAudienceId = @"6367863211";
static NSString * const kVariationWithoutAudienceId = @"6384330452";

// events with experiment and audiences
static NSString * const kEventWithAudienceName = @"testEventWithAudiences";
static NSString * const kEventWithAudienceId = @"6384781388";
static NSString * const kExperimentWithAudienceKey = @"testExperimentWithFirefoxAudience";
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

typedef enum : NSUInteger {
    ImpressionTicket,
    ConversionTicket
} Ticket;

@interface OPTLYEventBuilderDefault(Tests)
- (NSString *)sdkVersion;
- (NSArray *)createUserFeatures:(OPTLYProjectConfig *)config
                     attributes:(NSDictionary *)attributes;
@end

@interface OPTLYEventBuilderTest : XCTestCase
@property (nonatomic, strong) OPTLYProjectConfig *config;
@property (nonatomic, strong) OPTLYEventBuilderDefault *eventBuilder;
@property (nonatomic, strong) OPTLYBucketer *bucketer;
@property (nonatomic, strong) NSDate *begTimestamp;

@end

@implementation OPTLYEventBuilderTest

- (void)setUp {
    [super setUp];
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatafileName];
    self.config = [[OPTLYProjectConfig alloc] initWithDatafile:datafile];
    self.eventBuilder = [OPTLYEventBuilderDefault new];
    self.bucketer = [[OPTLYBucketer alloc] initWithConfig:self.config];
    
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

- (void)testBuildConversionTicketWithNoAudience
{
    NSDictionary *params = [self.eventBuilder buildConversionTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithoutAudienceName
                                                     eventTags:nil
                                                    attributes:nil];
    
    [self checkTicket:ConversionTicket
            forParams:params
               config:self.config
       experimentKeys:@[kExperimentWithoutAudienceId]
          variationId:nil
           attributes:nil
             eventKey:kEventWithoutAudienceName
            eventTags:nil bucketer:self.bucketer userId:kUserId];
}

- (void)testBuildConversionTicketWithValidAudience
{
    NSDictionary *attributes = @{ kAttributeKeyBrowserType : kAttributeValueFirefox };
    NSDictionary *params = [self.eventBuilder buildConversionTicket:self.config
                                        bucketer:self.bucketer
                                          userId:kUserId
                                       eventName:kEventWithAudienceName
                                       eventTags:nil
                                      attributes:attributes];
    
    [self checkTicket:ConversionTicket
            forParams:params
               config:self.config
       experimentKeys:@[kExperimentWithAudienceId]
          variationId:nil
           attributes:attributes
             eventKey:kEventWithAudienceName
            eventTags:nil bucketer:self.bucketer userId:kUserId];
}

#pragma mark - Test buildConversionTicket:... Invalid Args

- (void)testBuildConversionTicketWithInvalidAudience
{
    // check without attributes that satisfy audience requirement
    NSDictionary *attributes = @{@"browser_type":@"chrome"};
    
    NSDictionary *conversionTicket = [self.eventBuilder buildConversionTicket:self.config
                                                           bucketer:self.bucketer
                                                             userId:kUserId
                                                          eventName:kEventWithAudienceName
                                                          eventTags:nil
                                                         attributes:attributes];
    XCTAssertNil(conversionTicket, @"Conversion ticket should be nil.");
}

- (void)testBuildConversionTicketWithExperimentNotRunning
{
    NSDictionary *conversionTicket = [self.eventBuilder buildConversionTicket:self.config
                                                           bucketer:self.bucketer
                                                             userId:kUserId
                                                          eventName:kEventWithExperimentNotRunningName
                                                          eventTags:nil
                                                         attributes:nil];
    XCTAssertNil(conversionTicket, @"Conversion ticket should be nil.");
}

- (void)testBuildConversionTicketWithoutExperiment
{
    NSDictionary *conversionTicket = [self.eventBuilder buildConversionTicket:self.config
                                                           bucketer:self.bucketer
                                                             userId:kUserId
                                                          eventName:kEventWithoutExperimentName
                                                          eventTags:nil
                                                         attributes:nil];
    XCTAssertNil(conversionTicket, @"Conversion ticket should be nil.");
}

- (void)testBuildConversionTicketWithNoConfig
{
    NSDictionary *attributes = @{ kAttributeKeyBrowserType : kAttributeValueFirefox };
    NSDictionary *conversionTicket = [self.eventBuilder buildConversionTicket:nil
                                                           bucketer:self.bucketer
                                                             userId:kUserId
                                                          eventName:kEventWithAudienceName
                                                          eventTags:nil
                                                         attributes:attributes];
    
    XCTAssertNil(conversionTicket, @"Conversion ticket should be nil.");
}

- (void)testBuildConversionTicketWithNoBucketer
{
    NSDictionary *attributes = @{ kAttributeKeyBrowserType : kAttributeValueFirefox };
    NSDictionary *conversionTicket = [self.eventBuilder buildConversionTicket:self.config
                                                                     bucketer:nil
                                                                       userId:kUserId
                                                                    eventName:kEventWithAudienceName
                                                                    eventTags:nil
                                                                   attributes:attributes];
    
    XCTAssertNil(conversionTicket, @"Conversion ticket should be nil.");
}

- (void)testBuildConversionTicketWithNoUserID
{
    NSDictionary *attributes = @{ kAttributeKeyBrowserType : kAttributeValueFirefox };
    NSDictionary *conversionTicket = [self.eventBuilder buildConversionTicket:self.config
                                                                     bucketer:self.bucketer
                                                                       userId:nil
                                                                    eventName:kEventWithAudienceName
                                                                    eventTags:nil
                                                                   attributes:attributes];
    
    XCTAssertNil(conversionTicket, @"Conversion ticket should be nil.");
}

- (void)testBuildConversionTicketWithNoEvent
{
    NSDictionary *attributes = @{ kAttributeKeyBrowserType : kAttributeValueFirefox };
    NSDictionary *conversionTicket = [self.eventBuilder buildConversionTicket:self.config
                                                                     bucketer:self.bucketer
                                                                       userId:kUserId
                                                                    eventName:nil
                                                                    eventTags:nil
                                                                   attributes:attributes];
    
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

- (void)testRevenueMetric
{
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(kEventRevenue)}
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(kEventRevenue)}];
}

- (void)testRevenueMetricWithDouble
{
    // The SDK issues a console warning about casting double to "long long",
    // but a "revenue" key-value pair will appear in the transmitted event.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(888.88)}
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(888LL)}];
}

- (void)testRevenueMetricWithHugeDouble
{
    // The SDK prevents double's outside the range [LLONG_MIN, LLONG_MAX]
    // from being cast into nonsense and sent.  Instead a console warning
    // is issued and the 'revenue' key-value pair will not appear in the transmitted event.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(1.0e100)}
                       sentEventTags:@{}];
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
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(longLongRevenue)}];
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
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(longLongRevenue)}];
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
                       sentEventTags:@{}];
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
                       sentEventTags:@{}];
}

- (void)testRevenueMetricWithCastUnsignedLongLong
{
    // "unsigned long long" which is barely in range.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@((unsigned long long)LLONG_MAX)}
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(LLONG_MAX)}];
}

- (void)testRevenueMetricWithBoundaryUnsignedLongLong
{
    // The SDK prevents "unsigned long long"'s outside the range [LLONG_MIN, LLONG_MAX]
    // from being cast into nonsense and sent.  Instead a console warning
    // is issued and the 'revenue' key-value pair will not appear in the transmitted event.
    // A Bridge Too Far
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(1ULL+(unsigned long long)LLONG_MAX)}
                       sentEventTags:@{}];
}

- (void)testRevenueMetricWithHugeUnsignedLongLong
{
    // The SDK prevents "unsigned long long"'s outside the range [LLONG_MIN, LLONG_MAX]
    // from being cast into nonsense and sent.  Instead a console warning
    // is issued and the 'revenue' key-value pair will not appear in the transmitted event.
    // NOTE: ULLONG_MAX > LLONG_MAX is such an example.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(ULLONG_MAX)}
                       sentEventTags:@{}];
}

- (void)testRevenueMetricWithLongLongMax
{
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(LLONG_MAX)}
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(LLONG_MAX)}];
}

- (void)testRevenueMetricWithLongLongMin
{
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(LLONG_MIN)}
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(LLONG_MIN)}];
}

- (void)testRevenueMetricWithBoolean
{
    // NOTE: As discussed in code comments in test testObjectiveCBooleans ,
    // @YES won't be sent to Optimizely server, since it will serialize
    // as "true" instead of a JSON number.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@YES}
                       sentEventTags:@{}];
}

- (void)testRevenueMetricWithString
{
    // The SDK issues a console warning about casting NSString to "long long",
    // but a "revenue" key-value pair will appear in the transmitted event.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@"8.234"}
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(8LL)}];
}

- (void)testRevenueMetricWithInvalidObject
{
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@[@"BAD",@"DATA"]}
                       sentEventTags:@{}];
}

#pragma mark - Test value Metric

- (void)testValueMetric
{
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameValue:@(kEventValue)}
                       sentEventTags:@{OPTLYEventMetricNameValue:@(kEventValue)}];
}

- (void)testValueMetricWithBoolean
{
    // NOTE: As discussed in code comments in test testObjectiveCBooleans ,
    // @YES won't be sent to Optimizely server, since it will serialize
    // as "true" instead of a JSON number.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameValue:@YES}
                       sentEventTags:@{}];
}

- (void)testValueMetricWithString
{
    // The SDK issues a console warning about casting NSString to "double",
    // but a "value" key-value pair will appear in the transmitted event.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameValue:[NSString stringWithFormat:@"%g", kEventValue],
                                       kAttributeKeyBrowserType:kAttributeValueChrome}
                       sentEventTags:@{OPTLYEventMetricNameValue:@(kEventValue),
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
                       sentEventTags:@{kAttributeKeyBrowserType:kAttributeValueChrome}];
}

- (void)testValueMetricWithINFINITY
{
    // The SDK does not allow INFINITY partly because this value
    // doesn't serialize into JSON .  SDK issues a console warning
    // and omits the proposed "value" key-value pair which will not
    // appear in the transmitted event.  IOW, invalid value suppressed.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameValue:@(INFINITY),
                                       kAttributeKeyBrowserType:kAttributeValueChrome}
                       sentEventTags:@{kAttributeKeyBrowserType:kAttributeValueChrome}];
}

- (void)testValueMetricWithInvalidObject
{
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameValue:@[@"BAD",@"DATA"],
                                       kAttributeKeyBrowserType:kAttributeValueChrome}
                       sentEventTags:@{kAttributeKeyBrowserType:kAttributeValueChrome}];
}

#pragma mark - Test revenue Metric and value Metric

- (void)testRevenueMetricAndValueMetric
{
    // Test creating event containing both "revenue" and "value".  Imagine
    //     "revenue" == money received
    //     "value" == temperature measured
    // There isn't a good reason why both can't be sent in the same event.
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameRevenue:@(kEventRevenue),
                                       OPTLYEventMetricNameValue:@(kEventValue)}
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(kEventRevenue),
                                       OPTLYEventMetricNameValue:@(kEventValue)}];
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
                                       @"BooleanTag":@YES}];
}

- (void)testBuildConversionTicketWithRevenueAndEventTags
{
    [self commonBuildConversionTicketTest:@{OPTLYEventMetricNameValue:@(kEventRevenue),
                                       kAttributeKeyBrowserType:kAttributeValueChrome}
                       sentEventTags:@{OPTLYEventMetricNameValue:@(kEventRevenue),
                                       kAttributeKeyBrowserType:kAttributeValueChrome}];
}

#pragma mark - Test anonymizeIP

- (void)testBuildConversionTicketWithAnonymizeIPFalse {
    OPTLYProjectConfig *config = [self setUpForAnonymizeIPFalse];
    OPTLYEventBuilderDefault *eventBuilder = [OPTLYEventBuilderDefault new];
    OPTLYBucketer *bucketer = [[OPTLYBucketer alloc] initWithConfig:config];
    
    NSDictionary *params = [eventBuilder buildConversionTicket:config
                                                 bucketer:bucketer
                                                   userId:kUserId
                                                eventName:kEventWithoutAudienceName
                                                eventTags:nil
                                               attributes:nil];
    
    NSNumber *anonymizeIP = params[OPTLYEventParameterKeysAnonymizeIP];
    XCTAssert([anonymizeIP boolValue] == false, @"Incorrect value for IP anonymization.");
}

#pragma mark - Test Invalid Attribute

- (void)testCreateImpressionEventWithEmptyAttributeValue
{
    NSDictionary *attributes = @{OptimizelyBucketId : @""};
    NSDictionary *params = [self.eventBuilder buildConversionTicket:self.config
                                                           bucketer:self.bucketer
                                                             userId:kUserId
                                                          eventName:kEventWithoutAudienceName
                                                          eventTags:nil
                                                         attributes:attributes];
    
    [self checkTicket:ConversionTicket
            forParams:params
               config:self.config
       experimentKeys:@[kExperimentWithoutAudienceId]
          variationId:nil
           attributes:attributes
             eventKey:kEventWithoutAudienceName
            eventTags:nil bucketer:self.bucketer userId:kUserId];
}


#pragma mark - Test Bucketing ID

- (void)testCreateImpressionEventWithBucketingIDAttribute
{
    NSDictionary *attributes = @{OptimizelyBucketId : kAttributeValueFirefox};
    NSDictionary *params = [self.eventBuilder buildConversionTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithoutAudienceName
                                                     eventTags:nil
                                                    attributes:@{OptimizelyBucketId:kAttributeValueFirefox}];
    
    [self checkTicket:ConversionTicket
            forParams:params
               config:self.config
       experimentKeys:@[kExperimentWithoutAudienceId]
          variationId:nil
           attributes:attributes
             eventKey:kEventWithoutAudienceName
            eventTags:nil bucketer:self.bucketer userId:kUserId];
}

- (void)testCreateConversionEventWithBucketingIDAttribute
{
    NSDictionary *attributes = @{OptimizelyBucketId : kAttributeValueFirefox};
    NSDictionary *params = [self.eventBuilder buildConversionTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithoutAudienceName
                                                     eventTags:nil
                                                    attributes:@{OptimizelyBucketId:kAttributeValueFirefox}];
    [self checkTicket:ConversionTicket
            forParams:params
               config:self.config
       experimentKeys:@[kExperimentWithoutAudienceId]
          variationId:nil
           attributes:attributes
             eventKey:kEventWithoutAudienceName
            eventTags:nil bucketer:self.bucketer userId:kUserId];
}

#pragma mark - Test BuildImpressionEventTicket:...

- (void)testBuildImpressionEventTicketWithAllArguments
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:kExperimentWithAudienceKey
                                                                        userId:kUserId
                                                                    attributes:attributes
                                                                      bucketer:self.bucketer];
    
    
    NSDictionary *impressionEventTicketParams = [self.eventBuilder buildImpressionEventTicket:self.config
                                                                                   userId:kUserId
                                                                            experimentKey:kExperimentWithAudienceKey
                                                                              variationId:bucketedVariation.variationId
                                                                               attributes:attributes];
    [self checkTicket:ImpressionTicket
            forParams:impressionEventTicketParams
               config:self.config
        experimentKeys:@[kExperimentWithAudienceKey]
          variationId:bucketedVariation.variationId
           attributes:attributes
             eventKey:nil eventTags:nil bucketer:nil userId:kUserId];
    
}

- (void)testBuildImpressionEventTicketWithNoAudience
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    NSDictionary *impressionEventTicketParams = [self.eventBuilder buildImpressionEventTicket:self.config
                                                                                   userId:kUserId
                                                                            experimentKey:kExperimentWithoutAudienceKey
                                                                              variationId:kVariationWithoutAudienceId
                                                                               attributes:attributes];
    [self checkTicket:ImpressionTicket
            forParams:impressionEventTicketParams
               config:self.config
        experimentKeys:@[kExperimentWithoutAudienceKey]
          variationId:kVariationWithoutAudienceId
           attributes:attributes
             eventKey:nil eventTags:nil bucketer:nil userId:kUserId];
}

- (void)testBuildImpressionEventTicketWithUnknownExperiment
{
    NSString *invalidExperimentKey = @"InvalidExperiment";
    NSString *invalidVariationId = @"5678";
    
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    NSDictionary *impressionEventTicketParams = [self.eventBuilder buildImpressionEventTicket:self.config
                                                                                   userId:kUserId
                                                                            experimentKey:invalidExperimentKey
                                                                              variationId:invalidVariationId
                                                                               attributes:attributes];
    XCTAssert([impressionEventTicketParams count] == 0, @"parameters should not be created with unknown experiment.");
}

- (void)testBuildImpressionTicketWithAnonymizeIPFalse {
    OPTLYProjectConfig *config = [self setUpForAnonymizeIPFalse];
    OPTLYEventBuilderDefault *eventBuilder = [OPTLYEventBuilderDefault new];
    
    NSDictionary *impressionEventTicketParams = [eventBuilder buildImpressionEventTicket:config
                                                                              userId:kUserId
                                                                       experimentKey:kExperimentWithoutAudienceKey
                                                                         variationId:kVariationWithoutAudienceId
                                                                          attributes:nil];
    NSNumber *anonymizeIP = impressionEventTicketParams[OPTLYEventParameterKeysAnonymizeIP];
    XCTAssert([anonymizeIP boolValue] == false, @"Incorrect value for IP anonymization.");
}

- (void)testBuildImpressionEventTicketWithNoConfig
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:kExperimentWithAudienceKey
                                                                        userId:kUserId
                                                                    attributes:attributes
                                                                      bucketer:self.bucketer];
    
    
    NSDictionary *impressionEventTicketParams = [self.eventBuilder buildImpressionEventTicket:nil
                                                                                       userId:kUserId
                                                                                experimentKey:kExperimentWithAudienceKey
                                                                                  variationId:bucketedVariation.variationId
                                                                                   attributes:attributes];
    
    XCTAssert([impressionEventTicketParams count] == 0, @"parameters should not be created with no config.");
}

- (void)testBuildImpressionEventTicketWithNoExperiment
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:kExperimentWithAudienceKey
                                                                        userId:kUserId
                                                                    attributes:attributes
                                                                      bucketer:self.bucketer];
    
    
    NSDictionary *impressionEventTicketParams = [self.eventBuilder buildImpressionEventTicket:self.config
                                                                                       userId:kUserId
                                                                                experimentKey:nil
                                                                                  variationId:bucketedVariation.variationId
                                                                                   attributes:attributes];
    
    XCTAssert([impressionEventTicketParams count] == 0, @"parameters should not be created with no Experiment.");
}

- (void)testBuildImpressionEventTicketWithNoUserId
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:kExperimentWithAudienceKey
                                                                        userId:kUserId
                                                                    attributes:attributes
                                                                      bucketer:self.bucketer];
    
    
    NSDictionary *impressionEventTicketParams = [self.eventBuilder buildImpressionEventTicket:self.config
                                                                                       userId:nil
                                                                                experimentKey:kExperimentWithAudienceKey
                                                                                  variationId:bucketedVariation.variationId
                                                                                   attributes:attributes];
    
    XCTAssert([impressionEventTicketParams count] == 0, @"parameters should not be created with no UserId.");
}

- (void)testBuildImpressionEventTicketWithNoVariation
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    NSDictionary *impressionEventTicketParams = [self.eventBuilder buildImpressionEventTicket:self.config
                                                                                       userId:kUserId
                                                                                experimentKey:kExperimentWithAudienceKey
                                                                                  variationId:nil
                                                                                   attributes:attributes];
    
    XCTAssert([impressionEventTicketParams count] == 0, @"parameters should not be created with no Variation.");
}

#pragma mark - Helper Methods

- (void)commonBuildConversionTicketTest:(NSDictionary*)eventTags sentEventTags:(NSDictionary*)sentEventTags
{
    // Common subroutine for many of the testBuildEventXxx test methods.
    // Generally, a testBuildEventXxx should make at most one call
    // to commonBuildConversionTicketTest:sentEventTags: .
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    NSDictionary *params = [self.eventBuilder buildConversionTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithAudienceName
                                                     eventTags:eventTags
                                                    attributes:attributes];
    [self checkTicket:ConversionTicket
            forParams:params
               config:self.config
       experimentKeys:@[kExperimentWithAudienceId]
          variationId:nil
           attributes:attributes
             eventKey:kEventWithAudienceName
            eventTags:sentEventTags bucketer:self.bucketer userId:kUserId];
}

- (void)checkTicket:(Ticket)ticket
          forParams:(NSDictionary *)params
             config:(OPTLYProjectConfig *)config
     experimentKeys:(NSArray *)experimentKeys
        variationId:(NSString *)variationId
         attributes:(NSDictionary *)attributes
           eventKey:(NSString *)eventKey
          eventTags:(NSDictionary *)eventTags
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
                    [self checkConversionTicket:ticketParams config:config eventId:eventEntity.eventId eventKey:eventKey experimentKeys:experimentKeys
                                    eventTags:eventTags attributes:attributes bucketer:bucketer userId:userId];
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
                   attributes:(NSDictionary *)attributes
                     bucketer:(OPTLYBucketer *)bucketer
                       userId:(NSString *)userId {
    
    
    // check conversion if payload available
    XCTAssertNotNil(params, @"Invalid Conversion ticket");
    
    NSArray *decisions = params[OPTLYEventParameterKeysDecisions];
    
    XCTAssertGreaterThan([decisions count], 0, @"Didn't find any decision");
    XCTAssertGreaterThan([experimentKeys count], 0, @"Didn't find any experiment key");
    
    for (int i=0; i < [decisions count]; i++) {
        NSDictionary *decision = decisions[i];
        OPTLYExperiment *experiment = [config getExperimentForId:experimentKeys[i]];
        OPTLYVariation *bucketedVariation = [config getVariationForExperiment:experiment.experimentKey
                                                                       userId:userId
                                                                   attributes:attributes
                                                                     bucketer:bucketer];
        [self checkDecision:decision campaignId:experiment.layerId experimentId:experiment.experimentId variationId:bucketedVariation.variationId];
    }
    
    NSArray *events = params[OPTLYEventParameterKeysEvents];
    XCTAssertGreaterThan([events count], 0, @"Didn't find any event");
    
    for (NSDictionary *event in events) {
        [self checkConversion:event entityId:eventId eventKey:eventKey uuid:@"" eventTags:eventTags];
    }
}

- (void)checkDecision:(NSDictionary *)params
           campaignId:(NSString *)campaignId
         experimentId:(NSString *)experimentId
          variationId:(NSString *)variationId {
    
    XCTAssert([campaignId isEqualToString:params[OPTLYEventParameterKeysDecisionCampaignId]], @"Invalid campaignId.");
    XCTAssert([experimentId isEqualToString:params[OPTLYEventParameterKeysDecisionExperimentId]], @"Invalid experimentId.");
    XCTAssert([variationId isEqualToString: params[OPTLYEventParameterKeysDecisionVariationId]], @"Invalid variationId.");
    NSNumber *isLayerHoldback = params[OPTLYEventParameterKeysDecisionIsLayerHoldback];
    XCTAssert([isLayerHoldback boolValue] == false, @"Invalid isLayerHoldback value.");
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
              eventTags:(NSDictionary *)eventTags {
    
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
    
    NSDictionary *tags = params[OPTLYEventParameterKeysTags];
    [self checkEventTags:eventTags withTags:tags];
    [self checkEventTags:eventTags withEvent:params];
}

- (void)checkEventTags:(NSDictionary *)eventTags
              withTags:(NSDictionary *)tags {
    
    // check for equal number of tags with event tags
    XCTAssert([eventTags count] == [tags count], @"Invalid number of event tags.");
    
    for (NSString *eventTag in [eventTags allKeys]) {
        if (!([eventTag isEqualToString:OPTLYEventMetricNameRevenue] || [eventTag isEqualToString:OPTLYEventMetricNameValue])) {
            XCTAssertNotNil(tags[eventTag], @"Invalid event tag name.");
            XCTAssert([eventTags[eventTag] isEqual: tags[eventTag]], @"Invalid event tag value.");
        }
    }
}

- (void)checkEventTags:(NSDictionary *)eventTags
             withEvent:(NSDictionary *)event {
    
    // check for number of tags atleast equalt to event tags
    XCTAssert([event count] >= [eventTags count], @"Invalid number of event tags.");
    
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
           withAttributes:(NSDictionary *)attributes
{
    NSMutableDictionary *filteredAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    
    for (NSString *attributeKey in [attributes allKeys]) {
        NSString *attributeValue = attributes[attributeKey];
        if ([attributeValue length] ==0) {
            [filteredAttributes removeObjectForKey:attributeKey];
        }
    }
    
    NSUInteger numberOfFeatures = [userFeatures count];
    NSUInteger numberOfAttributes = [filteredAttributes count];
    
    XCTAssert(numberOfFeatures == numberOfAttributes, @"Incorrect number of user features.");
    
    if (numberOfFeatures == numberOfAttributes) {
        NSSortDescriptor *featureNameDescriptor = [[NSSortDescriptor alloc] initWithKey:OPTLYEventParameterKeysFeaturesName ascending:YES];
        NSArray *sortedUserFeaturesByName = [userFeatures sortedArrayUsingDescriptors:@[featureNameDescriptor]];
        
        NSSortDescriptor *attributeKeyDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
        NSArray *sortedAttributeKeys = [[filteredAttributes allKeys] sortedArrayUsingDescriptors:@[attributeKeyDescriptor]];
        
        for (NSUInteger i = 0; i < numberOfAttributes; i++)
        {
            NSDictionary *params = sortedUserFeaturesByName[i];
            
            NSString *anAttributeKey = sortedAttributeKeys[i];
            NSString *anAttributeValue = [filteredAttributes objectForKey:anAttributeKey];
            
            NSString *featureName = params[OPTLYEventParameterKeysFeaturesKey];
            NSString *featureID = params[OPTLYEventParameterKeysFeaturesId];
            if ([featureName isEqualToString:OptimizelyBucketIdEventParam]) {
                // check id
                XCTAssert([featureID isEqualToString:OptimizelyBucketId], @"Incorrect feature id: %@. for reserved Optimizely Bucket Id", featureID);
            } else {
                // check name
                XCTAssert([featureName isEqualToString:anAttributeKey ], @"Incorrect feature name.");
                // check id
                XCTAssert([featureID isEqualToString:kAttributeId], @"Incorrect feature id: %@.", featureID);
            }
            
            // check type
            NSString *featureType = params[OPTLYEventParameterKeysFeaturesType];
            XCTAssert([featureType isEqualToString:OPTLYEventFeatureFeatureTypeCustomAttribute], @"Incorrect feature type.");
            
            // check value
            NSString *featureValue = params[OPTLYEventParameterKeysFeaturesValue];
            XCTAssert([featureValue isEqualToString:anAttributeValue], @"Incorrect feature value.");
            
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
