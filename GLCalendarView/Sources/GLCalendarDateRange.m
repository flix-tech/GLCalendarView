//
//  GLCalendarDateRange.m
//  GLPeriodCalendar
//
//  Created by ltebean on 15-4-17.
//  Copyright (c) 2015 glow. All rights reserved.
//

#import "GLCalendarDateRange.h"
#import "GLCalendarDayCell.h"
#import "GLDateUtils.h"

@implementation GLCalendarDateRange
- (instancetype)initWithBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    self = [super init];
    if (self) {
        _beginDate = [GLDateUtils cutDate:beginDate];
        _endDate = [GLDateUtils cutDate:endDate];
        _editable = YES;
    }
    return self;
}

+ (instancetype)rangeWithBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    return [[GLCalendarDateRange alloc] initWithBeginDate:beginDate endDate:endDate];
}

- (void)setBeginDate:(NSDate *)beginDate
{
    _beginDate = [GLDateUtils cutDate:beginDate];
}

- (void)setEndDate:(NSDate *)endDate
{
    _endDate = [GLDateUtils cutDate:endDate];
}

- (BOOL)containsDate:(NSDate *)date
{
    if ([date compare:self.beginDate] == NSOrderedAscending) {
        return NO;
    }
    if ([date compare:self.endDate] == NSOrderedDescending) {
        return NO;
    }
    return YES;
}

- (NSInteger) durationDays
{
    NSInteger days = [GLDateUtils daysBetween:self.beginDate and:self.endDate];

    return days;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"Range[begin:%@ end:%@]", [GLDateUtils descriptionForDate:self.beginDate], [GLDateUtils descriptionForDate:self.endDate]];
}

@end
