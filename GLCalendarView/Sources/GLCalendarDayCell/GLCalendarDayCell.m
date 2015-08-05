//
//  GLCalendarDateCell.m
//  GLPeriodCalendar
//
//  Created by ltebean on 15-4-16.
//  Copyright (c) 2015 glow. All rights reserved.
//

#import "GLCalendarDayCell.h"
#import "GLCalendarDayCellBackgroundCover.h"
#import "GLCalendarDateRange.h"
#import "GLDateUtils.h"
#import "GLCalendarView.h"
#import "GLCalendarDayCell.h"
#import "GLCalendarDate.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface GLCalendarDayCell()
@property (strong, nonatomic) IBOutlet UILabel *dayLabel;
//@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
//@property (weak, nonatomic) IBOutlet UIView *backgroundView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundCoverLeft;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundCoverRight;

@property (nonatomic) CELL_POSITION position;
@property (nonatomic) ENLARGE_POINT enlargePoint;
@property (nonatomic) BOOL inEdit;
@property (nonatomic) CGFloat containerPadding;

@property (strong, nonatomic) IBOutlet UIView *lineLeft;
@property (strong, nonatomic) IBOutlet UIView *lineRight;
@property (strong, nonatomic) IBOutlet UIView *lineBottom;

@property (nonatomic, readwrite) BOOL needsTodayTextUpdate;
@property (nonatomic, readwrite) BOOL needsDayTextUpdate;
@property (nonatomic, readwrite) BOOL needsUIUpdate;
@property (nonatomic, copy) NSString* titleTop;
@property (nonatomic, copy) NSString* titleDate;

@end

@implementation GLCalendarDayCell

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        frame.origin.x = 0;
        frame.origin.y = 0;
        CGFloat width = CGRectGetWidth(frame);
        CGFloat heigh = CGRectGetHeight(frame);
        CGFloat lineWidth = 1.f / [UIScreen mainScreen].scale;
        self.dayLabel = [[UILabel alloc] initWithFrame: frame];
        self.dayLabel.textAlignment = NSTextAlignmentCenter;
        self.dayLabel.numberOfLines = 2;
        [self.contentView addSubview: self.dayLabel];

        CGRect vertical = CGRectMake(0, 0, lineWidth, heigh);

        self.lineLeft = [[UIView alloc] initWithFrame: vertical];

        vertical.origin.x = width - lineWidth;
        self.lineRight =  [[UIView alloc] initWithFrame: vertical];

        self.lineBottom = [[UIView alloc] initWithFrame: CGRectMake(0, heigh - lineWidth, width, lineWidth)];

        [self.contentView addSubview: self.lineLeft];
        [self.contentView addSubview: self.lineRight];
        [self.contentView addSubview: self.lineBottom];
    }
    return self;
}

- (void)layoutSubviews
{
    if (self.needsUIUpdate) {
        [self performUpdateUI];
        self.needsUIUpdate = NO;
    }
    [super layoutSubviews];
}

- (void)setDate:(GLCalendarDate *)date range:(GLCalendarDateRange *)range cellPosition:(CELL_POSITION)cellPosition enlargePoint:(ENLARGE_POINT)enlargePoint disabled: (BOOL) disabled isToday: (BOOL) isToday
{
    _date = date;
    _range = range;
    _disabled = disabled;
    _isToday = isToday;
    if (range) {
        self.inEdit = range.inEdit;
    } else {
        self.inEdit = NO;
    }
    self.position = cellPosition;
    self.enlargePoint = enlargePoint;
    [self updateUI];
}

- (void)updateUI
{
    self.needsUIUpdate = YES;

    [self setNeedsLayout];
}
- (void)performUpdateUI
{
    NSInteger day = self.date.day;
    NSInteger month = self.date.month;

    // month background color
    if (self.range.backgroundColor) {
        self.dayLabel.backgroundColor = self.range.backgroundColor;
    } else if (month % 2 == 0) {
        self.dayLabel.backgroundColor = self.evenMonthBackgroundColor;
    } else {
        self.dayLabel.backgroundColor = self.oddMonthBackgroundColor;
    }

    if (self.date.day > self.date.monthDays - 7) {
        self.lineBottom.backgroundColor = self.gridSeparatorColor;
        if (self.date.day == self.date.monthDays && self.position != POSITION_RIGHT_EDGE) {
            self.lineRight.backgroundColor = self.gridSeparatorColor;
        } else {
            self.lineRight.backgroundColor = self.gridNormalColor;
        }
    } else {
        self.lineBottom.backgroundColor = self.gridNormalColor;
        self.lineRight.backgroundColor = self.gridNormalColor;
    }

    // adjust background position
    if (self.position == POSITION_LEFT_EDGE) {
        self.lineLeft.hidden = NO;
        self.lineLeft.backgroundColor = self.gridNormalColor;
    } else {
        self.lineLeft.hidden = YES;
    }
        
    // day label and month label
    NSString* dayTitle = [NSString stringWithFormat:@"%ld", (long)day];
    if ([self isToday]) {
        [self setDayLabelText:dayTitle withTopLabel: [self today]];
        if (self.todayBackgroundColor && !self.range.backgroundColor) {
            self.dayLabel.backgroundColor = self.todayBackgroundColor;
        }
    } else if(day == 1 || self.range.showMonthTitle) {
        [self setDayLabelText: dayTitle withTopLabel: [self monthText:month]];
    } else {
        [self setDayLabelText:dayTitle withTopLabel: nil];
    }
    
}

- (void)setDayLabelText:(NSString *)text withTopLabel: (NSString*) top
{
    NSDictionary* attributes = self.dayLabelAttributes;
    NSDictionary* topAttributes = self.monthLabelAttributes;

    if (self.disabled) {
        attributes = self.dayDisabledLabelAttributes;
    } else if(self.range) {
        attributes = self.range.selectedDayTitleAttributes;
        topAttributes = self.range.selectedMonthTitleAttributes;
    } else if([self isToday]){
        attributes = self.todayLabelAttributes;
        topAttributes = self.todayTitleAttributes;
    }


    NSMutableAttributedString* dayString = [[NSMutableAttributedString alloc] initWithString:text attributes: attributes];

    if (top) {
        NSString* topNewLine = [top stringByAppendingString:@"\n"];
        NSAttributedString *topString = [[NSAttributedString alloc] initWithString:topNewLine attributes:topAttributes];
        [dayString insertAttributedString:topString atIndex: 0];
    }

    self.dayLabel.attributedText = dayString;
}

static NSArray *months;

- (NSString *)monthText:(NSInteger)month {
    if (!months) {
        months = [[[[NSDateFormatter alloc] init] shortStandaloneMonthSymbols] valueForKeyPath:@"capitalizedString"];
    }
    return [months objectAtIndex:(month - 1)];
}

static NSString* _textToday;

- (NSString*) today
{
    if (!_textToday) {
        NSDateFormatter *todayFormatter = [[NSDateFormatter alloc] init];
        todayFormatter.dateStyle = NSDateFormatterMediumStyle;
        todayFormatter.timeStyle = NSDateFormatterNoStyle;
        todayFormatter.doesRelativeDateFormatting = YES;
        _textToday = [todayFormatter stringFromDate:self.date.date];
    }
    return _textToday;
}

@end
