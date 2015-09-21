//
//  GLDateUtils.m
//  GLPeriodCalendar
//
//  Created by ltebean on 15-4-21.
//  Copyright (c) 2015年 glow. All rights reserved.
//

#import "GLDateUtils.h"

#define CALENDAR_COMPONENTS NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay


@implementation GLDateUtils

+ (BOOL)date:(NSDate *)date1 isSameDayAsDate:(NSDate *)date2 {
    if (date1 == nil || date2 == nil) {
        return NO;
    }
    
    NSCalendar *calendar = [GLDateUtils calendar];
    
    NSDateComponents *day1 = [calendar components:CALENDAR_COMPONENTS fromDate:date1];
    NSDateComponents *day2 = [calendar components:CALENDAR_COMPONENTS fromDate:date2];
    return ([day2 day] == [day1 day] &&
            [day2 month] == [day1 month] &&
            [day2 year] == [day1 year]);
}

+ (NSCalendar *)calendar {
    static dispatch_once_t onceToken;
    static NSCalendar* calendar;
    dispatch_once(&onceToken, ^{
        calendar = [NSCalendar currentCalendar];
        if (![calendar.calendarIdentifier isEqualToString: NSCalendarIdentifierGregorian]) {
            calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            calendar.locale = [NSLocale currentLocale];
        }
    });
    return calendar;
}

+ (NSDate *)weekFirstDate:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:date];
    NSInteger weekday = components.weekday;//1 for Sunday
    if (weekday == calendar.firstWeekday) {
        return date;
    } else {

        NSInteger days = calendar.firstWeekday - weekday;
        if (days > 0) {
            days -= 7;
            // that could happen when we have Mon as a first week day
            // because of day's index are: [Sun,Mon,Tue,...,Sat]
        }

        return [GLDateUtils dateByAddingDays:days toDate:date];
    }
}


+ (NSDate *)weekLastDate:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:date];
    NSInteger weekday = components.weekday;//1 for Sunday, 2 for Monday
    if (weekday == (calendar.firstWeekday + 5) % 7 + 1) {  // firstWeekday + 6 = 7 (Saturday for US)
        return date;
    } else {
        return [GLDateUtils dateByAddingDays:(7 - weekday) toDate:date];
    }
}

+ (NSDate *)monthFirstDate:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDateComponents *result = [[NSDateComponents alloc] init];
    [result setDay:1];
    [result setMonth:[components month]];
    [result setYear:[components year]];
    
    return [calendar dateFromComponents:result];
}

+ (NSDate *)dateByAddingDays:(NSInteger )days toDate:(NSDate *)date {
    NSCalendar *calendar = [GLDateUtils calendar];
    static NSDateComponents *comps = nil;
    if (!comps) {
        comps = [[NSDateComponents alloc] init];
    }
    [comps setDay:days];
    return [calendar dateByAddingComponents:comps toDate:date options:0];
}

+ (NSDate *)dateByAddingMonths:(NSInteger )months toDate:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    static NSDateComponents *comps = nil;
    if (!comps) {
        comps = [[NSDateComponents alloc] init];
    }
    [comps setMonth:months];
    return [calendar dateByAddingComponents:comps toDate:date options:0];
}

+ (NSDate *)cutDate:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *components = [calendar components:CALENDAR_COMPONENTS fromDate:date];
    return [calendar dateFromComponents:components];
}

+ (NSInteger)daysBetween:(NSDate *)beginDate and:(NSDate *)endDate
{
    NSDateComponents *components = [[GLDateUtils calendar] components:NSCalendarUnitDay fromDate:beginDate toDate:endDate options:0];
    return components.day;
}

+ (NSDate *)maxForDate:(NSDate *)date1 andDate:(NSDate *)date2
{
    if ([date1 compare:date2] == NSOrderedAscending) {
        return date2;
    } else {
        return date1;
    }
}

+ (NSDate *)minForDate:(NSDate *)date1 andDate:(NSDate *)date2
{
    if ([date1 compare:date2] == NSOrderedAscending) {
        return date1;
    } else {
        return date2;
    }
}

+ (NSString *)descriptionForDate:(NSDate *)date
{
    NSCalendar *calendar = [GLDateUtils calendar];
    NSDateComponents *components = [calendar components:CALENDAR_COMPONENTS fromDate:date];
    return [NSString stringWithFormat:@"%ld/%ld/%ld", (long)components.year, (long)components.month, (long)components.day];
}

+ (NSString *)titleForMonthAtIndex:(NSInteger)month {
    static NSArray *months;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        months = [[[NSDateFormatter alloc] init] shortStandaloneMonthSymbols];
    });
    return [months objectAtIndex:(month - 1)];
}

@end
