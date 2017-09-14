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
#import "OPTLYEventTicket.h"
#import "OPTLYEventParameterKeys.h"
#import "OPTLYDecisionEventTicket.h"
#import "OPTLYDecisionService.h"
#import "OPTLYBucketer.h"
#import "OPTLYMacros.h"
#import "OPTLYEventFeature.h"
#import "OPTLYExperiment.h"
#import "OPTLYEventMetric.h"
#import "OPTLYVariation.h"

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

#pragma mark - Test buildEventTicket:... Audiences

- (void)testBuildEventTicketWithNoAudience
{
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithoutAudienceName
                                                     eventTags:nil
                                                    attributes:nil];
    [self checkCommonParams:params
             withAttributes:nil];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithoutAudienceId
                 eventName:kEventWithoutAudienceName
                 eventTags:nil
                attributes:nil
                    userId:kUserId
             experimentIds:@[kExperimentWithoutAudienceId]];
    
}

- (void)testBuildEventTicketWithValidAudience
{
    // check without attributes that satisfy audience requirement
    NSDictionary *attributes = @{@"browser_type":@"firefox"};
    
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithAudienceName
                                                     eventTags:nil
                                                    attributes:attributes];
    [self checkCommonParams:params withAttributes:attributes];
    
    // check with attributes
    attributes = @{ kAttributeKeyBrowserType : kAttributeValueFirefox };
    params = [self.eventBuilder buildEventTicket:self.config
                                        bucketer:self.bucketer
                                          userId:kUserId
                                       eventName:kEventWithAudienceName
                                       eventTags:nil
                                      attributes:attributes];
    [self checkCommonParams:params withAttributes:attributes];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithAudienceId
                 eventName:kEventWithAudienceName
                 eventTags:nil
                attributes:attributes
                    userId:kUserId
             experimentIds:@[kExperimentWithAudienceId]];
}

#pragma mark - Test buildEventTicket:... Invalid Args

- (void)testBuildEventTicketWithInvalidAudience
{
    // check without attributes that satisfy audience requirement
    NSDictionary *attributes = @{@"browser_type":@"chrome"};
    
    NSDictionary *eventTicket = [self.eventBuilder buildEventTicket:self.config
                                                           bucketer:self.bucketer
                                                             userId:kUserId
                                                          eventName:kEventWithAudienceName
                                                          eventTags:nil
                                                         attributes:attributes];
    XCTAssertNil(eventTicket, @"Event ticket should be nil.");
}

- (void)testBuildEventTicketWithExperimentNotRunning
{
    NSDictionary *eventTicket = [self.eventBuilder buildEventTicket:self.config
                                                           bucketer:self.bucketer
                                                             userId:kUserId
                                                          eventName:kEventWithExperimentNotRunningName
                                                          eventTags:nil
                                                         attributes:nil];
    XCTAssertNil(eventTicket, @"Event ticket should be nil.");
}

- (void)testBuildEventTicketWithoutExperiment
{
    NSDictionary *eventTicket = [self.eventBuilder buildEventTicket:self.config
                                                           bucketer:self.bucketer
                                                             userId:kUserId
                                                          eventName:kEventWithoutExperimentName
                                                          eventTags:nil
                                                         attributes:nil];
    XCTAssertNil(eventTicket, @"Event ticket should be nil.");
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
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@(kEventRevenue)}
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(kEventRevenue)}];
}

- (void)testRevenueMetricWithDouble
{
    // The SDK issues a console warning about casting double to "long long",
    // but a "revenue" key-value pair will appear in the transmitted event.
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@(888.88)}
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(888LL)}];
}

- (void)testRevenueMetricWithHugeDouble
{
    // The SDK prevents double's outside the range [LLONG_MIN, LLONG_MAX]
    // from being cast into nonsense and sent.  Instead a console warning
    // is issued and the 'revenue' key-value pair will not appear in the transmitted event.
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@(1.0e100)}
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
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@(doubleRevenue)}
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
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@(doubleRevenue)}
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
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@(doubleRevenue)}
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
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@(doubleRevenue)}
                       sentEventTags:@{}];
}

- (void)testRevenueMetricWithCastUnsignedLongLong
{
    // "unsigned long long" which is barely in range.
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@((unsigned long long)LLONG_MAX)}
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(LLONG_MAX)}];
}

- (void)testRevenueMetricWithBoundaryUnsignedLongLong
{
    // The SDK prevents "unsigned long long"'s outside the range [LLONG_MIN, LLONG_MAX]
    // from being cast into nonsense and sent.  Instead a console warning
    // is issued and the 'revenue' key-value pair will not appear in the transmitted event.
    // A Bridge Too Far
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@(1ULL+(unsigned long long)LLONG_MAX)}
                       sentEventTags:@{}];
}

- (void)testRevenueMetricWithHugeUnsignedLongLong
{
    // The SDK prevents "unsigned long long"'s outside the range [LLONG_MIN, LLONG_MAX]
    // from being cast into nonsense and sent.  Instead a console warning
    // is issued and the 'revenue' key-value pair will not appear in the transmitted event.
    // NOTE: ULLONG_MAX > LLONG_MAX is such an example.
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@(ULLONG_MAX)}
                       sentEventTags:@{}];
}

- (void)testRevenueMetricWithLongLongMax
{
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@(LLONG_MAX)}
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(LLONG_MAX)}];
}

- (void)testRevenueMetricWithLongLongMin
{
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@(LLONG_MIN)}
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(LLONG_MIN)}];
}

- (void)testRevenueMetricWithBoolean
{
    // NOTE: As discussed in code comments in test testObjectiveCBooleans ,
    // @YES won't be sent to Optimizely server, since it will serialize
    // as "true" instead of a JSON number.
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@YES}
                       sentEventTags:@{}];
}

- (void)testRevenueMetricWithString
{
    // The SDK issues a console warning about casting NSString to "long long",
    // but a "revenue" key-value pair will appear in the transmitted event.
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@"8.234"}
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(8LL)}];
}

- (void)testRevenueMetricWithInvalidObject
{
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@[@"BAD",@"DATA"]}
                       sentEventTags:@{}];
}

#pragma mark - Test value Metric

- (void)testValueMetric
{
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameValue:@(kEventValue)}
                       sentEventTags:@{OPTLYEventMetricNameValue:@(kEventValue)}];
}

- (void)testValueMetricWithBoolean
{
    // NOTE: As discussed in code comments in test testObjectiveCBooleans ,
    // @YES won't be sent to Optimizely server, since it will serialize
    // as "true" instead of a JSON number.
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameValue:@YES}
                       sentEventTags:@{}];
}

- (void)testValueMetricWithString
{
    // The SDK issues a console warning about casting NSString to "double",
    // but a "value" key-value pair will appear in the transmitted event.
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameValue:[NSString stringWithFormat:@"%g", kEventValue],
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
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameValue:@(NAN),
                                       kAttributeKeyBrowserType:kAttributeValueChrome}
                       sentEventTags:@{kAttributeKeyBrowserType:kAttributeValueChrome}];
}

- (void)testValueMetricWithINFINITY
{
    // The SDK does not allow INFINITY partly because this value
    // doesn't serialize into JSON .  SDK issues a console warning
    // and omits the proposed "value" key-value pair which will not
    // appear in the transmitted event.  IOW, invalid value suppressed.
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameValue:@(INFINITY),
                                       kAttributeKeyBrowserType:kAttributeValueChrome}
                       sentEventTags:@{kAttributeKeyBrowserType:kAttributeValueChrome}];
}

- (void)testValueMetricWithInvalidObject
{
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameValue:@[@"BAD",@"DATA"],
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
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameRevenue:@(kEventRevenue),
                                       OPTLYEventMetricNameValue:@(kEventValue)}
                       sentEventTags:@{OPTLYEventMetricNameRevenue:@(kEventRevenue),
                                       OPTLYEventMetricNameValue:@(kEventValue)}];
}

#pragma mark - Test buildEventTicket:... with Multiple eventTags

- (void)testBuildEventTicketWithEventTags
{
    [self commonBuildEventTicketTest:@{kAttributeKeyBrowserType:kAttributeValueChrome,
                                       @"IntegerTag":@15,
                                       @"BooleanTag":@YES,
                                       @"FloatTag":@1.23,
                                       @"InvalidArrayTag":[NSArray new]}
                       sentEventTags:@{kAttributeKeyBrowserType:kAttributeValueChrome,
                                       @"IntegerTag":@15,
                                       @"FloatTag":@1.23,
                                       @"BooleanTag":@YES}];
}

- (void)testBuildEventTicketWithRevenueAndEventTags
{
    [self commonBuildEventTicketTest:@{OPTLYEventMetricNameValue:@(kEventRevenue),
                                       kAttributeKeyBrowserType:kAttributeValueChrome}
                       sentEventTags:@{OPTLYEventMetricNameValue:@(kEventRevenue),
                                       kAttributeKeyBrowserType:kAttributeValueChrome}];
}

#pragma mark - Test buildEventTicket:... with Multiple Experiments

- (void)testBuildEventTicketWithEventMultipleExperiments
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueChrome};
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithMultipleExperimentsName
                                                     eventTags:@{ OPTLYEventMetricNameRevenue : [NSNumber numberWithInteger:kEventRevenue] }
                                                    attributes:attributes];
    [self checkCommonParams:params withAttributes:attributes];
    [self checkEventMetrics:params
                  eventTags:@{OPTLYEventMetricNameRevenue:@(kEventRevenue)}];
    NSArray *experimentIds = @[@"6364835526", @"6450630664", @"6367863211", @"6376870125", @"6383811281", @"6358043286", @"6370392407", @"6367444440", @"6370821515", @"6447021179"];
    NSArray *layerStates = params[OPTLYEventParameterKeysLayerStates];
    NSUInteger numberOfLayers = [layerStates count];
    NSUInteger numberOfExperiments = [experimentIds count];
    // 6383811281 (testExperimentWithFirefoxAudience) is excluded because the attributes do not match
    // 6367444440 (testExperimentNotRunning) is excluded because the experiment is not running
    // 6450630664 should be exlucded becuase it is mutually excluded.
    XCTAssert(numberOfLayers == (numberOfExperiments - 3), @"Incorrect number of layers.");
}

#pragma mark - Test anonymizeIP

- (void)testBuildEventTicketWithAnonymizeIPFalse {
    OPTLYProjectConfig *config = [self setUpForAnonymizeIPFalse];
    OPTLYEventBuilderDefault *eventBuilder = [OPTLYEventBuilderDefault new];
    OPTLYBucketer *bucketer = [[OPTLYBucketer alloc] initWithConfig:config];
    
    NSDictionary *params = [eventBuilder buildEventTicket:config
                                                 bucketer:bucketer
                                                   userId:kUserId
                                                eventName:kEventWithoutAudienceName
                                                eventTags:nil
                                               attributes:nil];
    
    NSNumber *anonymizeIP = params[OPTLYEventParameterKeysAnonymizeIP];
    XCTAssert([anonymizeIP boolValue] == false, @"Incorrect value for IP anonymization.");
}

#pragma mark - Test Bucketing ID

- (void)testCreateImpressionEventWithBucketingIDAttribute
{
    NSDictionary *attributes = @{OptimizelyBucketId : kAttributeValueFirefox};
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithoutAudienceName
                                                     eventTags:nil
                                                    attributes:@{OptimizelyBucketId:kAttributeValueFirefox}];
    [self checkCommonParams:params
             withAttributes:attributes];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithoutAudienceId
                 eventName:kEventWithoutAudienceName
                 eventTags:nil
                attributes:attributes
                    userId:kUserId
             experimentIds:@[kExperimentWithoutAudienceId]];
}

- (void)testCreateConversionEventWithBucketingIDAttribute
{
    NSDictionary *attributes = @{OptimizelyBucketId : kAttributeValueFirefox};
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithoutAudienceName
                                                     eventTags:nil
                                                    attributes:@{OptimizelyBucketId:kAttributeValueFirefox}];
    [self checkCommonParams:params
             withAttributes:attributes];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithoutAudienceId
                 eventName:kEventWithoutAudienceName
                 eventTags:nil
                attributes:attributes
                    userId:kUserId
             experimentIds:@[kExperimentWithoutAudienceId]];
}

#pragma mark - Test buildDecisionEventTicket:...

- (void)testBuildDecisionEventTicketWithAllArguments
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:kExperimentWithAudienceKey
                                                                        userId:kUserId
                                                                    attributes:attributes
                                                                      bucketer:self.bucketer];
    
    
    NSDictionary *decisionEventTicketParams = [self.eventBuilder buildDecisionEventTicket:self.config
                                                                                   userId:kUserId
                                                                            experimentKey:kExperimentWithAudienceKey
                                                                              variationId:bucketedVariation.variationId
                                                                               attributes:attributes];
    [self checkCommonParams:decisionEventTicketParams withAttributes:attributes];
    [self checkDecisionTicketParams:decisionEventTicketParams
                             config:self.config
                           bucketer:self.bucketer
                         attributes:attributes
                      experimentKey:kExperimentWithAudienceKey
                             userId:kUserId];
    
}

- (void)testBuildDecisionEventTicketWithNoAudience
{
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    NSDictionary *decisionEventTicketParams = [self.eventBuilder buildDecisionEventTicket:self.config
                                                                                   userId:kUserId
                                                                            experimentKey:kExperimentWithoutAudienceKey
                                                                              variationId:kVariationWithoutAudienceId
                                                                               attributes:attributes];
    [self checkCommonParams:decisionEventTicketParams withAttributes:attributes];
    [self checkDecisionTicketParams:decisionEventTicketParams
                             config:self.config
                           bucketer:self.bucketer
                         attributes:attributes
                      experimentKey:kExperimentWithoutAudienceKey
                             userId:kUserId];
}

- (void)testBuildDecisionEventTicketWithUnknownExperiment
{
    NSString *invalidExperimentKey = @"InvalidExperiment";
    NSString *invalidVariationId = @"5678";
    
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    
    NSDictionary *decisionEventTicketParams = [self.eventBuilder buildDecisionEventTicket:self.config
                                                                                   userId:kUserId
                                                                            experimentKey:invalidExperimentKey
                                                                              variationId:invalidVariationId
                                                                               attributes:attributes];
    XCTAssert([decisionEventTicketParams count] == 0, @"parameters should not be created with unknown experiment.");
}

- (void)testBuildDecisionTicketWithAnonymizeIPFalse {
    OPTLYProjectConfig *config = [self setUpForAnonymizeIPFalse];
    OPTLYEventBuilderDefault *eventBuilder = [OPTLYEventBuilderDefault new];
    
    NSDictionary *decisionEventTicketParams = [eventBuilder buildDecisionEventTicket:config
                                                                              userId:kUserId
                                                                       experimentKey:kExperimentWithoutAudienceKey
                                                                         variationId:kVariationWithoutAudienceId
                                                                          attributes:nil];
    NSNumber *anonymizeIP = decisionEventTicketParams[OPTLYEventParameterKeysAnonymizeIP];
    XCTAssert([anonymizeIP boolValue] == false, @"Incorrect value for IP anonymization.");
}

#pragma mark - Helper Methods

- (void)commonBuildEventTicketTest:(NSDictionary*)eventTags sentEventTags:(NSDictionary*)sentEventTags
{
    // Common subroutine for many of the testBuildEventXxx test methods.
    // Generally, a testBuildEventXxx should make at most one call
    // to commonBuildEventTicketTest:sentEventTags: .
    NSDictionary *attributes = @{kAttributeKeyBrowserType : kAttributeValueFirefox};
    NSDictionary *params = [self.eventBuilder buildEventTicket:self.config
                                                      bucketer:self.bucketer
                                                        userId:kUserId
                                                     eventName:kEventWithAudienceName
                                                     eventTags:eventTags
                                                    attributes:attributes];
    [self checkCommonParams:params withAttributes:attributes];
    [self checkEventTicket:params
                    config:self.config
                   eventId:kEventWithAudienceId
                 eventName:kEventWithAudienceName
                 eventTags:sentEventTags
                attributes:attributes
                    userId:kUserId
             experimentIds:@[kExperimentWithAudienceId]];
}

- (void)checkDecisionTicketParams:(NSDictionary *)params
                           config:(OPTLYProjectConfig *)config
                         bucketer:(OPTLYBucketer *)bucketer
                       attributes:(NSDictionary *)attributes
                    experimentKey:(NSString *)experimentKey
                           userId:(NSString *)userId
{
    // check layer id
    XCTAssert([params[OPTLYEventParameterKeysLayerId] isEqualToString:kLayerId], @"Layer id is invalid.");
    
    // check decision
    NSDictionary *decision = params[OPTLYEventParameterKeysDecision];
    OPTLYVariation *bucketedVariation = [config getVariationForExperiment:experimentKey
                                                                   userId:userId
                                                               attributes:attributes
                                                                 bucketer:bucketer];
    NSString *experimentId = [config getExperimentIdForKey:experimentKey];
    [self checkDecision:decision experimentId:experimentId bucketedVariationId:bucketedVariation.variationId];
}

- (void)checkEventTicket:(NSDictionary *)params
                  config:(OPTLYProjectConfig *)config
                 eventId:(NSString *)eventId
               eventName:(NSString *)eventName
               eventTags:(NSDictionary *)eventTags
              attributes:(NSDictionary *)attributes
                  userId:(NSString *)userId
           experimentIds:(NSArray *)experimentIds
{
    XCTAssert([params[OPTLYEventParameterKeysEventEntityId] isEqualToString:eventId], @"Invalid entityId.");
    XCTAssert([params[OPTLYEventParameterKeysEventName] isEqualToString:eventName], @"Invalid event name: %@. Should be: %@.", params[OPTLYEventParameterKeysEventName], eventName);
    if ([params[OPTLYEventParameterKeysEventEntityId] isEqualToString:eventId]
        && [params[OPTLYEventParameterKeysEventName] isEqualToString:eventName]) {
        NSArray *eventFeatures = params[OPTLYEventParameterKeysEventFeatures];
        [self checkEventFeatures:eventFeatures eventTags:eventTags];
        [self checkEventMetrics:params eventTags:eventTags];
        NSArray *layerStates = params[OPTLYEventParameterKeysLayerStates];
        [self checkLayerStates:config
                   layerStates:layerStates
                 experimentIds:experimentIds
                        userId:userId
                    attributes:attributes];
    }
}

- (void)checkCommonParams:(NSDictionary *)params
           withAttributes:(NSDictionary *)attributes
{
    NSDate *currentTimestamp = [NSDate date];
    
    // check timestamp is within the correct range
    NSNumber *timestamp = params[OPTLYEventParameterKeysTimestamp];
    double time = [timestamp doubleValue]/1000;
    NSDate *eventTimestamp = [NSDate dateWithTimeIntervalSince1970:time];
    XCTAssert([self date:eventTimestamp isBetweenDate:self.begTimestamp andDate:currentTimestamp], @"Invalid timestamp: %@.", eventTimestamp);
    
    // check revision
    NSString *revision = params[OPTLYEventParameterKeysRevision];
    XCTAssert([revision isEqualToString:kRevision], @"Incorrect revision number.");
    
    // check visitor id
    NSString *visitorId = params[OPTLYEventParameterKeysVisitorId];
    XCTAssert([visitorId isEqualToString:kUserId], @"Incorrect visitor id.");
    
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
    
    // check global holdback
    NSNumber *isGlobalHoldback = params[OPTLYEventParameterKeysIsGlobalHoldback];
    XCTAssert([isGlobalHoldback boolValue] == false, @"Incorrect value for global holdback.");
    
    NSArray *userFeatures = params[OPTLYEventParameterKeysUserFeatures];
    [self checkUserFeatures:userFeatures
             withAttributes:attributes];
}

- (void)checkUserFeatures:(NSArray *)userFeatures
           withAttributes:(NSDictionary *)attributes
{
    NSUInteger numberOfFeatures = [userFeatures count];
    NSUInteger numberOfAttributes = [attributes count];
    
    XCTAssert(numberOfFeatures == numberOfAttributes, @"Incorrect number of user features.");
    
    if (numberOfFeatures == numberOfAttributes) {
        NSSortDescriptor *featureNameDescriptor = [[NSSortDescriptor alloc] initWithKey:OPTLYEventParameterKeysFeaturesName ascending:YES];
        NSArray *sortedUserFeaturesByName = [userFeatures sortedArrayUsingDescriptors:@[featureNameDescriptor]];
        
        NSSortDescriptor *attributeKeyDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
        NSArray *sortedAttributeKeys = [[attributes allKeys] sortedArrayUsingDescriptors:@[attributeKeyDescriptor]];
        
        for (NSUInteger i = 0; i < numberOfAttributes; i++)
        {
            NSDictionary *params = sortedUserFeaturesByName[i];
            
            NSString *anAttributeKey = sortedAttributeKeys[i];
            NSString *anAttributeValue = [attributes objectForKey:anAttributeKey];
            
            NSString *featureName = params[OPTLYEventParameterKeysFeaturesName];
            NSString *featureID = params[OPTLYEventParameterKeysFeaturesId];
            if ([featureName isEqualToString:OptimizelyBucketIdEventParam]) {
                // check id
                XCTAssertNil(featureID, @"There should be no id here.");
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

- (void)checkLayerStates:(OPTLYProjectConfig *)config
             layerStates:(NSArray *)layerStates
           experimentIds:(NSArray *)experimentIds
                  userId:(NSString *)userId
              attributes:(NSDictionary *)attributes
{
    NSUInteger numberOfLayers = [layerStates count];
    NSUInteger numberOfExperiments = [experimentIds count];
    
    XCTAssert(numberOfLayers == numberOfExperiments, @"Incorrect number of layers.");
    
    if (numberOfLayers == numberOfExperiments) {
        // sort layer states
        NSSortDescriptor *layerStatesDecisionExperimentIdDescriptor = [[NSSortDescriptor alloc] initWithKey:@"decision.experimentId" ascending:YES];
        NSArray *sortedLayerStatesByDecisionExperimentId = [layerStates sortedArrayUsingDescriptors:@[layerStatesDecisionExperimentIdDescriptor]];
        
        // sort experiment ids
        NSSortDescriptor *experimentIdDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
        NSArray *sortedExperimentIds = [experimentIds sortedArrayUsingDescriptors:@[experimentIdDescriptor]];
        
        for (NSUInteger i = 0; i < numberOfLayers; i++)
        {
            NSString *experimentId = sortedExperimentIds[i];
            NSDictionary *layerState = sortedLayerStatesByDecisionExperimentId[i];
            
            OPTLYExperiment *experiment = [config getExperimentForId:experimentId];
            XCTAssert(experiment != nil, @"Experiment should be part of the datafile.");
            if (experiment != nil) {
                OPTLYVariation *bucketedVariation = [config getVariationForExperiment:experiment.experimentKey
                                                                               userId:userId
                                                                           attributes:attributes
                                                                             bucketer:self.bucketer];
                
                NSDictionary *decisionParams = layerState[OPTLYEventParameterKeysLayerStateDecision];
                if ([decisionParams count] > 0) {
                    [self checkDecision:decisionParams
                           experimentId:experimentId
                    bucketedVariationId:bucketedVariation.variationId];
                }
                
                NSNumber *actionTriggered = layerState[OPTLYEventParameterKeysLayerStateActionTriggered];
                XCTAssert([actionTriggered boolValue] == false, @"Invalid actionTriggered value.");
                NSString *layerId = layerState[OPTLYEventParameterKeysLayerStateLayerId];
                XCTAssert([layerId isEqualToString:kLayerId], @"Invalid layerId value.");
                NSString *revision = layerState[OPTLYEventParameterKeysLayerStateRevision];
                XCTAssert([revision isEqualToString:kRevision], @"Invalid revision.");
            }
        }
    }
}

- (void)checkEventMetrics:(NSDictionary*)params
                eventTags:(NSDictionary*)eventTags {
    // Check eventMetrics eventTags.
    NSArray *eventMetrics = params[@"eventMetrics"];
    XCTAssert([eventMetrics isKindOfClass:[NSArray class]], @"eventMetrics should be an NSArray .");
    if ([eventMetrics isKindOfClass:[NSArray class]]) {
        // Confirm every eventMetric in eventMetrics is predicted by eventTags .
        for (NSDictionary *eventMetric in eventMetrics) {
            XCTAssert([eventMetric isKindOfClass:[NSDictionary class]], @"eventMetric should be an NSDictionary .");
            if ([eventMetric isKindOfClass:[NSDictionary class]]) {
                XCTAssertEqual(eventMetric.count, 2, @"Two key-value pairs in eventMetric expected.");
                NSString *name = eventMetric[@"name"];
                XCTAssert([name isKindOfClass:[NSString class]], @"eventMetric name '%@' should be an NSString .", name);
                NSNumber *expectedValue = eventTags[name];
                XCTAssertNotNil(expectedValue, @"Not expecting to send eventMetric name '%@'.", name);
                if (expectedValue != nil) {
                    NSNumber *value = eventMetric[@"value"];
                    XCTAssert([value isKindOfClass:[NSNumber class]], @"eventMetric value should be an NSNumber .");
                    if ([value isKindOfClass:[NSNumber class]]) {
                        XCTAssertEqualObjects(value, expectedValue, @"eventMetric value should equal %@ .", expectedValue);
                    }
                }
            }
        }
        // Confirm every key-value pair in eventTags which is an eventMetric appears in eventMetrics .
        // Since eventMetrics arrays is always small size (generally 0-1 and at most 2 elements),
        // and this code is in test, not our SDK, we can afford a small brute force search.
        {
            NSArray *metricNames = @[OPTLYEventMetricNameRevenue, OPTLYEventMetricNameValue];
            for (NSString* name in eventTags) {
                if ([metricNames containsObject:name]) {
                    NSObject *value = eventTags[name];
                    BOOL found = NO;
                    for (NSDictionary *eventMetric in eventMetrics) {
                        if ([eventMetric[@"name"] isEqual:name]
                            && [eventMetric[@"value"] isEqual:value]) {
                            found = YES;
                            break;
                        }
                    }
                    XCTAssert(found, @"Didn't find predicted key-value pair %@:%@ in eventMetrics", name, value);
                }
            }
        }
    }
}

- (void)checkEventFeatures:(NSArray *)eventFeatures
                 eventTags:(NSDictionary *)eventTags
{
    XCTAssert([eventFeatures count] == [eventTags count], @"Invalid number of event feature.");
    
    for (NSDictionary *eventFeature in eventFeatures) {
        
        XCTAssert([eventFeature count] == 4, @"Invalid number of keys in event feature.");
        
        NSString *eventFeatureName = eventFeature[OPTLYEventParameterKeysFeaturesName];
        XCTAssertNotNil(eventFeatureName, @"Event feature name is missing from event feature.");
        XCTAssertNotNil(eventTags[eventFeatureName], @"Invalid event feature name.");
        
        NSNumber *eventFeatureValue = eventFeature[OPTLYEventParameterKeysFeaturesValue];
        XCTAssertNotNil(eventFeatureValue, @"Event feature value is missing from event feature.");
        XCTAssert([eventFeatureValue isEqual: eventTags[eventFeatureName]], @"Invalid event feature value.");
        
        XCTAssertEqual(eventFeature[OPTLYEventParameterKeysFeaturesShouldIndex], @NO, @"Invalid should index value for event feature.");
        
        XCTAssertEqual(eventFeature[OPTLYEventParameterKeysFeaturesType], OPTLYEventFeatureFeatureTypeCustomAttribute, @"Invalid feature type for event feature.");
    }
}

- (void)checkDecision:(NSDictionary *)params
         experimentId:(NSString *)experimentId
  bucketedVariationId:(NSString *)variationId
{
    XCTAssert([experimentId isEqualToString:params[OPTLYEventParameterKeysDecisionExperimentId]], @"Invalid experimentId.");
    XCTAssert([variationId isEqualToString: params[OPTLYEventParameterKeysDecisionVariationId]], @"Invalid variationId.");
    NSNumber *isLayerHoldback = params[OPTLYEventParameterKeysDecisionIsLayerHoldback];
    XCTAssert([isLayerHoldback boolValue] == false, @"Invalid isLayerHoldback value.");
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
