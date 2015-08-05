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

@interface GLCalendarMonthCoverView()
@property (nonatomic, strong) GLCalendarDate *firstDate;
@property (nonatomic, strong) GLCalendarDate *lastDate;
@property (nonatomic, strong) NSDateFormatter* monthFormatter;
@end

@implementation GLCalendarMonthCoverView

- (NSDateFormatter*) monthFormatter
{
    if (!_monthFormatter) {
        _monthFormatter = [[NSDateFormatter alloc] init];
        _monthFormatter.dateFormat = @"MMMM";
    }
    return _monthFormatter;
}

- (void)updateWithFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate calendar:(NSCalendar *)calendar rowHeight:(CGFloat)rowHeight
{
    if ([self.firstDate isTheSameDayAsDate:firstDate] &&
        [self.lastDate isTheSameDayAsDate:lastDate]) {
        return;
    }


    self.firstDate = [[GLCalendarDate alloc] initWithDate:firstDate];
    self.lastDate = [[GLCalendarDate alloc] initWithDate:lastDate];
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSDateComponents *today = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    for (NSDate *date = [GLDateUtils monthFirstDate:firstDate]; [date compare:lastDate] < 0; date = [GLDateUtils dateByAddingMonths:1 toDate:date]) {
        NSInteger dayDiff = [GLDateUtils daysBetween:firstDate and:date];
        if (dayDiff < 0) {
            continue;
        }
        
        NSDateComponents *components = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];

        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), rowHeight * 3)];
        monthLabel.backgroundColor = [UIColor clearColor];
        monthLabel.textAlignment = NSTextAlignmentCenter;

        NSString *labelText = [self.monthFormatter stringFromDate:date];

        NSAttributedString* labelTextAttributed = [[NSAttributedString alloc] initWithString:labelText attributes:self.textMonthAttributes];
        if (today.year != components.year) {
            
            NSMutableAttributedString* labelWithYear = [NSMutableAttributedString new];

            [labelWithYear appendAttributedString: labelTextAttributed];

            NSString* textYear = [NSString stringWithFormat: @"%ld",(long)components.year];

            NSAttributedString* labelYear = [[NSAttributedString alloc] initWithString:textYear attributes: self.textYearAttributes];

            [labelWithYear appendAttributedString: labelYear];

            labelTextAttributed = labelWithYear;
        }
        
        monthLabel.attributedText = labelTextAttributed;
        monthLabel.center = CGPointMake(CGRectGetMidX(self.bounds), ceilf(rowHeight * (dayDiff / 7 + 2)));
        monthLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        [self addSubview:monthLabel];
    }
}

@end
