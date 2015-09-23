//
//  GLDateUtilDeLocaleTests.m
//  GLCalendarView
//
//  Created by Oleg Shanyuk on 23/09/15.
//  Copyright © 2015 glow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GLDateUtils.h"

@interface GLDateUtilsDeLocaleTests : XCTestCase
@property (readonly) NSCalendar *testCalendar;
@end

@implementation GLDateUtilsDeLocaleTests
@synthesize testCalendar = _testCalendar;

- (NSCalendar *)testCalendar
{
    if (!_testCalendar) {
        _testCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        _testCalendar.locale = [NSLocale localeWithLocaleIdentifier:@"de_DE"];
    }
    return _testCalendar;
}

- (void)setUp
{
    [GLDateUtils setCalendar:self.testCalendar];
}

- (NSDate *)dateWithDay:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger)year
{
    return [self dateWithDay:day month:month year:year hour:0 minute:0];
}

- (NSDate *)dateWithDay:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger)year hour:(NSUInteger)hour minute:(NSUInteger)minute
{
    NSDateComponents *components = [[NSDateComponents alloc] init];

    components.day = day;
    components.month = month;
    components.year = year;
    components.hour = hour;
    components.minute = minute;

    NSDate *testDate = [[GLDateUtils calendar] dateFromComponents: components];

    return testDate;
}


- (void)testFirstWeekDate {

    NSDate *Sunday_20_Sept_2015 = [self dateWithDay:20 month:9 year:2015];

    /* should be Monday, 14 Sep 2015 OR Sunday 20 Sep 2015 */
    /* depending on First Weekday! */
    NSDate *firstWeekDayDate = [GLDateUtils weekFirstDate:Sunday_20_Sept_2015];

    NSInteger firstWeekDate = [[GLDateUtils calendar] component:NSCalendarUnitDay fromDate: firstWeekDayDate];

    const NSInteger Sunday = 1;
    const NSInteger Monday = 2;

    switch ([GLDateUtils calendar].firstWeekday) {
        case Sunday:
            XCTAssert(firstWeekDate == 20);
            break;
        case Monday:
            XCTAssert(firstWeekDate == 14);
            break;
    } ;
}

- (void)testLastWeekDate {

    NSDate *Tuesday_15_Sept_2015 = [self dateWithDay:15 month:9 year:2015];

    /* should be Sunday, 20 Sep 2015 OR Saturday 19 Sep 2015 */
    /* depending on First Weekday! */
    NSDate *lastWeekDate = [GLDateUtils weekLastDate:Tuesday_15_Sept_2015];

    NSInteger lastWeekDay = [[GLDateUtils calendar] component:NSCalendarUnitDay fromDate:lastWeekDate];

    const NSInteger Sunday = 1;
    const NSInteger Monday = 2;

    switch ([GLDateUtils calendar].firstWeekday) {
        case Sunday:
            XCTAssert(lastWeekDay == 19);
            break;
        case Monday:
            XCTAssert(lastWeekDay == 20);
            break;
    } ;
}

- (void)testDateByAddingDays
{
    NSDate *startDate = [self dateWithDay:20 month:9 year:2015];
    NSDate *destinationDate = [self dateWithDay:30 month:9 year:2015];

    NSDate *testDate = [GLDateUtils dateByAddingDays:10 toDate:startDate];

    XCTAssert([testDate isEqual:destinationDate]);
}

- (void)testDateByAddingMonths
{
    NSDate *startDate = [self dateWithDay:20 month:9 year:2015];
    NSDate *destinationDate = [self dateWithDay:20 month:10 year:2015];

    NSDate *testDate = [GLDateUtils dateByAddingMonths:1 toDate:startDate];

    XCTAssert([testDate isEqual:destinationDate]);
}

- (void) testDaysBetween
{
    NSDate *startDate = [self dateWithDay:20 month:9 year:2015];
    NSDate *destinationDate = [self dateWithDay:30 month:9 year:2015];

    NSInteger tenDays = [GLDateUtils daysBetween:startDate and:destinationDate];

    XCTAssert(tenDays == 10);
}

- (void) testCutDate
{
    NSDate *startDate = [self dateWithDay:20 month:9 year:2015 hour:12 minute:30];
    NSDate *destinationDate = [self dateWithDay:20 month:9 year:2015];

    XCTAssertFalse([startDate isEqual:destinationDate]);

    NSDate *testDate = [GLDateUtils cutDate:startDate];

    XCTAssert([testDate isEqual:destinationDate]);
}

- (void) testMonthFirstDate
{
    NSDate *Tuesday_15_Sept_2015 = [self dateWithDay:15 month:9 year:2015];
    NSDate *Tuesday_1_Sept_2015 =  [self dateWithDay:1 month:9 year:2015];

    NSDate *testDate = [GLDateUtils monthFirstDate:Tuesday_15_Sept_2015];

    XCTAssert([testDate isEqual:Tuesday_1_Sept_2015]);
}

- (void) testMaxForDate
{
    NSDate *Tuesday_15_Sept_2015 = [self dateWithDay:15 month:9 year:2015];
    NSDate *Tuesday_1_Sept_2015 =  [self dateWithDay:1 month:9 year:2015];

    NSDate *testDate = [GLDateUtils maxForDate:Tuesday_15_Sept_2015 andDate:Tuesday_1_Sept_2015];

    XCTAssert([testDate isEqual:Tuesday_15_Sept_2015]);
}

- (void) testMinForDate
{
    NSDate *Tuesday_15_Sept_2015 = [self dateWithDay:15 month:9 year:2015];
    NSDate *Tuesday_1_Sept_2015 =  [self dateWithDay:1 month:9 year:2015];

    NSDate *testDate = [GLDateUtils minForDate:Tuesday_15_Sept_2015 andDate:Tuesday_1_Sept_2015];
    
    XCTAssert([testDate isEqual:Tuesday_1_Sept_2015]);
}
@end
