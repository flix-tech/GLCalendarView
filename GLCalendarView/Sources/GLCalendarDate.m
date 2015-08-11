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

@synthesize accessibilityLabel = _accessibilityLabel;

- (instancetype)initWithCutDate:(NSDate *)date
{
    self = [super init];

    if (!self || !date) {
        return self;
    }

    _date = date;
    _cutDate = date;

    NSCalendar* calendar = [GLDateUtils calendar];

    NSDateComponents *components = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];

    _day = components.day;
    _month = components.month;
    _year = components.year;


    // this code will run faster on Gregorian Calendar. Yes, that's it.
    if([calendar.calendarIdentifier isEqualToString: NSCalendarIdentifierGregorian]) {
        static int daysInMonth[] = {0,31,28,31,30,31,30,31,31,30,31,30,31};

        _monthDays = daysInMonth[_month];
        if (_month == 2 && (_year - 2000) % 4 == 0) { // leap year
            _monthDays = 29;
        }
    } else {
        _monthDays = [[GLDateUtils calendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
    }
    
    return self;
}

- (instancetype)initWithDate:(NSDate *)date
{
    self = [self initWithCutDate: date];
    if (self) {
        _cutDate = [GLDateUtils cutDate: date];
    }
    return self;
}


- (BOOL) isTheSameDayAs: (GLCalendarDate*) otherDate
{
    return (_day == otherDate->_day &&
            _month == otherDate->_month &&
            _year == otherDate->_year);
}

- (BOOL) isTheSameDayAsDate: (NSDate*) otherDate
{
    NSDateComponents *components = [[GLDateUtils calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate: otherDate];

    return (_day   == [components day]   &&
            _month == [components month] &&
            _year  == [components year]);
}

#pragma mark - Acceessibility

+ (NSDateFormatter*) accessibilityDateFormatter
{
    static NSDateFormatter* df;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        df.dateStyle = kCFDateFormatterFullStyle;
        df.timeStyle = NSDateFormatterNoStyle;
    });

    return df;
}

- (NSString*) accessibilityLabel
{
    if (!_accessibilityLabel) {
        _accessibilityLabel = [[GLCalendarDate accessibilityDateFormatter] stringFromDate:self.date];
    }
    return _accessibilityLabel;
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
