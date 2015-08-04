//
//  GLCalendarDate.m
//  GLCalendarView
//
//  Created by Oleg Shanyuk on 04/08/15.
//  Copyright (c) 2015 glow. All rights reserved.
//

#import "GLCalendarDate.h"
#import "GLDateUtils.h"

@implementation GLCalendarDate
- (instancetype)initWithDate:(NSDate *)date
{
    self = [super init];

    if (self == nil) {
        return nil;
    }

    if (date == nil) {
        return self;
    }

    _date = date;
    _cutDate = [GLDateUtils cutDate: date];

    NSDateComponents *components = [[GLDateUtils calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];

    _day = components.day;
    _month = components.month;
    _year = components.year;
    
    _monthDays = [[GLDateUtils calendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;

    return self;
}

- (BOOL) isTheSameDayAs: (GLCalendarDate*) otherDate
{
    return (_day == [otherDate day] &&
            _month == [otherDate month] &&
            _year == [otherDate year]);
}

- (BOOL) isTheSameDayAsDate: (NSDate*) otherDate
{
    NSDateComponents *components = [[GLDateUtils calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate: otherDate];

    return (_day == [components day] &&
            _month == [components month] &&
            _year == [components year]);
}

#pragma mark - copy

- (id)copyWithZone:(NSZone *)zone
{
    GLCalendarDate* date = [[GLCalendarDate alloc] init];

    date->_date = [self.date copy];
    date->_cutDate = [self.cutDate copy];
    date->_day = self.day;
    date->_month = self.month;
    date->_year = self.year;
    date->_monthDays = self.monthDays;

    return date;
}

@end
