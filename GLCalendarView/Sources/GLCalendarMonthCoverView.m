//
//  GLCalendarMonthCoverView.m
//  GLPeriodCalendar
//
//  Created by ltebean on 15-4-17.
//  Copyright (c) 2015 glow. All rights reserved.
//

#import "GLCalendarMonthCoverView.h"
#import "GLDateUtils.h"
#import "GLCalendarDate.h"


/*!@
 Idea: growth width by 2 cell sizes (1,3,5,7) unless we will fit
 month text in a way, background will cover exactly certain cells
 underneath
 */
CGFloat closestWidthToFitWidthForRowHeight(CGFloat width, CGFloat rowHeight)
{
    CGFloat res = rowHeight;
    while (res < width) {
        res += rowHeight+rowHeight;
    }
    return res;
}

@interface GLCalendarMonthCoverView()
@property (nonatomic, strong) GLCalendarDate *firstDate;
@property (nonatomic, strong) GLCalendarDate *lastDate;
@property (nonatomic, strong) NSDateFormatter* monthFormatter;
@property (nonatomic, strong) NSDateFormatter* yearFormatter;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic) CGFloat cellSide;
@property (nonatomic) CGRect  lastUsedFrame;
@end

@implementation GLCalendarMonthCoverView

- (NSDateFormatter*) monthFormatter
{
    if (!_monthFormatter) {
        _monthFormatter = [self dateFormatterWithFormat: self.monthFormat?:@"MMMM"];
    }
    return _monthFormatter;
}

- (NSDateFormatter*) yearFormatter
{
    if (!_yearFormatter) {
        _yearFormatter = [self dateFormatterWithFormat: self.yearFormat?:@"yyyy"];
    }
    return _yearFormatter;
}

- (NSDateFormatter*) dateFormatterWithFormat: (NSString*) format
{
    NSDateFormatter* f = [[NSDateFormatter alloc] init];
    f.dateFormat = format;
    return f;
}

- (void) setMonthFormat:(NSString *)monthFormat
{
    _monthFormat = monthFormat;
    self.monthFormatter = nil;
}

- (void) setYearFormat:(NSString *)yearFormat
{
    _yearFormat = yearFormat;
    self.yearFormatter = nil;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self layoutWithFirstDate:self.firstDate.date lastDate:self.lastDate.date calendar:self.calendar rowHeight:self.cellSide];
}

- (void)updateWithFirstDate:(GLCalendarDate *)firstDate lastDate:(GLCalendarDate *)lastDate calendar:(NSCalendar *)calendar rowHeight:(CGFloat)rowHeight
{
    self.firstDate = firstDate;
    self.lastDate = lastDate;
    self.cellSide = rowHeight;
    self.calendar = calendar;

    [self setNeedsLayout];
}

- (void)layoutWithFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate calendar:(NSCalendar *)calendar rowHeight:(CGFloat)rowHeight
{
    // do not redraw with no need
    if ([self.firstDate.date isEqualToDate:firstDate] &&
        [self.lastDate.date isEqualToDate:lastDate] &&
        self.cellSide == rowHeight &&
        [self.calendar.calendarIdentifier isEqualToString: calendar.calendarIdentifier] &&
        CGRectEqualToRect(self.lastUsedFrame, self.frame)) {
        return;
    }

    self.lastUsedFrame = self.frame;

    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSDateComponents *today = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];

    NSInteger previousDayDiff = 0;
    
    for (NSDate *date = [GLDateUtils monthFirstDate:firstDate]; [date compare:lastDate] < 0; date = [GLDateUtils dateByAddingMonths:1 toDate:date]) {
        NSInteger dayDiff = [GLDateUtils daysBetween:firstDate and:date];
        if (dayDiff < 0) {
            continue;
        }

        NSDateComponents *dayOfWeek = [calendar components:NSCalendarUnitWeekday fromDate:date];
        // this strange formula will produce a half of number of lines required to show a month
        CGFloat labelRowsOffset = 1 + ((10*(dayDiff - previousDayDiff - dayOfWeek.weekday - 1)) / 70) / 2.f;

        previousDayDiff = dayDiff;
        
        NSDateComponents *components = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];

        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), rowHeight * 3)];
        monthLabel.backgroundColor = [UIColor clearColor];
        monthLabel.textAlignment = NSTextAlignmentCenter;

        NSString *labelText = [self.monthFormatter stringFromDate:date];

        NSAttributedString* labelTextAttributed = [[NSAttributedString alloc] initWithString:labelText attributes:self.textMonthAttributes];
        if (today.year != components.year) {
            
            NSMutableAttributedString* labelWithYear = [NSMutableAttributedString new];

            [labelWithYear appendAttributedString: labelTextAttributed];

            NSString* textYear = [self.yearFormatter stringFromDate:date];
            NSAttributedString* labelYear = [[NSAttributedString alloc] initWithString:textYear attributes: self.textYearAttributes];

            [labelWithYear appendAttributedString: labelYear];

            labelTextAttributed = labelWithYear;
        }
        
        monthLabel.attributedText = labelTextAttributed;
        [monthLabel sizeToFit];

        CGRect currentLabelRect = monthLabel.frame;
        currentLabelRect.size.width = closestWidthToFitWidthForRowHeight(CGRectGetWidth(monthLabel.frame), rowHeight);
        if (labelRowsOffset - floorf(labelRowsOffset) > 0) {
            // for labels covering date numbers we want certain height
            currentLabelRect.size.height = rowHeight;
        }
        monthLabel.frame = currentLabelRect;
        monthLabel.center = CGPointMake(CGRectGetMidX(self.bounds), ceilf(  rowHeight * (dayDiff / 7 + labelRowsOffset)));
//        monthLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        monthLabel.backgroundColor = self.backgroundColor;

        [self addSubview:monthLabel];
    }
}

@end
