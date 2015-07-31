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

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface GLCalendarDayCell()
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
//@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet GLCalendarDayCellBackgroundCover *backgroundCover;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundCoverLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundCoverRight;

@property (nonatomic) CELL_POSITION position;
@property (nonatomic) ENLARGE_POINT enlargePoint;
@property (nonatomic) BOOL inEdit;
@property (nonatomic) CGFloat containerPadding;

@property (strong, nonatomic) IBOutlet UIView *lineTop;
@property (strong, nonatomic) IBOutlet UIView *lineLeft;
@property (strong, nonatomic) IBOutlet UIView *lineRight;
@property (strong, nonatomic) IBOutlet UIView *lineBottom;

@end

@implementation GLCalendarDayCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self reloadAppearance];
}

- (void)reloadAppearance
{
    GLCalendarDayCell *appearance = [[self class] appearance];
    self.evenMonthBackgroundColor = appearance.evenMonthBackgroundColor ?: UIColorFromRGB(0xf8f8f8);
    self.oddMonthBackgroundColor = appearance.oddMonthBackgroundColor ?: [UIColor whiteColor];
    self.dayLabelAttributes = appearance.dayLabelAttributes ?: @{NSFontAttributeName:[UIFont systemFontOfSize:20]};
    self.dayDisabledLabelAttributes = appearance.dayDisabledLabelAttributes?:@{NSFontAttributeName:[UIFont systemFontOfSize:20]};
    self.futureDayLabelAttributes = appearance.futureDayLabelAttributes ?: self.dayLabelAttributes;
    self.monthLabelAttributes = appearance.monthLabelAttributes ?: @{NSFontAttributeName:[UIFont systemFontOfSize:8]};
    self.todayLabelAttributes = appearance.todayLabelAttributes ?: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:22]};
    
    self.backgroundCover.paddingTop = appearance.editCoverPadding;
    self.backgroundCover.borderWidth = appearance.editCoverBorderWidth;
    self.backgroundCover.strokeColor = appearance.editCoverBorderColor ?: [UIColor darkGrayColor];
    
    self.backgroundCover.pointSize = appearance.editCoverPointSize;
    self.backgroundCover.pointScale = appearance.editCoverPointScale ?: 1.3;
    
    RANGE_DISPLAY_MODE mode = appearance.rangeDisplayMode ?: RANGE_DISPLAY_MODE_SINGLE;
    self.backgroundCover.continuousRangeDisplay = mode == RANGE_DISPLAY_MODE_CONTINUOUS ? YES : NO;
    
    self.todayBackgroundColor = appearance.todayBackgroundColor;
    self.containerPadding = [GLCalendarView appearance].padding;
}

- (void)setDate:(NSDate *)date range:(GLCalendarDateRange *)range cellPosition:(CELL_POSITION)cellPosition enlargePoint:(ENLARGE_POINT)enlargePoint disabled: (BOOL) disabled
{
    _date = [date copy];
    _range = range;
    _disabled = disabled;
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
//    NSLog(@"update ui: %@ %d", [GLDateUtils descriptionForDate:self.date], _enlargePoint);

    NSDateComponents *components = [[GLDateUtils calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth fromDate:self.date];
    
    NSInteger day = components.day;
    NSInteger month = components.month;
    NSInteger monthDays = [[GLDateUtils calendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self.date].length;

    // month background color
    if (month % 2 == 0) {
        self.backgroundCover.backgroundColor = self.evenMonthBackgroundColor;
    } else {
        self.backgroundCover.backgroundColor = self.oddMonthBackgroundColor;
    }

    // default look
    self.lineLeft.hidden = YES;
    self.lineTop.hidden = YES;
    self.lineBottom.backgroundColor = [UIColor lightGrayColor];
    self.lineRight.backgroundColor = [UIColor lightGrayColor];

    if (day > monthDays - 7) {
        self.lineBottom.backgroundColor = [UIColor darkGrayColor];
        if (day == monthDays && self.position != POSITION_RIGHT_EDGE) {
            self.lineRight.backgroundColor = [UIColor darkGrayColor];
        }
    }

    // adjust background position
    if (self.position == POSITION_LEFT_EDGE) {
        self.backgroundCoverRight.constant = 0;
        self.backgroundCoverLeft.constant = -self.containerPadding;
        self.backgroundCover.paddingLeft = self.containerPadding;
        self.backgroundCover.paddingRight = 0;
        self.lineLeft.hidden = NO;
        self.lineLeft.backgroundColor = [UIColor lightGrayColor];
    } else if (self.position == POSITION_RIGHT_EDGE){
        self.backgroundCoverRight.constant = -self.containerPadding;
        self.backgroundCoverLeft.constant = 0;
        self.backgroundCover.paddingLeft = 0;
        self.backgroundCover.paddingRight = self.containerPadding;
    } else {
        self.backgroundCoverRight.constant = 0;
        self.backgroundCoverLeft.constant = 0;
        self.backgroundCover.paddingLeft = 0;
        self.backgroundCover.paddingRight = 0;
    }
        
    // day label and month label
    if ([self isToday]) {
        NSDateFormatter *todayFormatter = [[NSDateFormatter alloc] init];
        todayFormatter.dateStyle = NSDateFormatterMediumStyle;
        todayFormatter.timeStyle = NSDateFormatterNoStyle;
        todayFormatter.doesRelativeDateFormatting = YES;
        [self setTodayLabelText:[NSString stringWithFormat:@"%ld", (long)day] withTopLabel:[todayFormatter stringFromDate:[NSDate date]]];
        self.backgroundCover.isToday = YES;
        if (self.todayBackgroundColor) {
            self.backgroundCover.fillColor = self.todayBackgroundColor;
        } else {
            self.backgroundCover.fillColor = self.backgroundCover.backgroundColor;
        }
    } else if (day == 1) {
        [self setDayLabelText:[NSString stringWithFormat:@"%ld", (long)day] withTopLabel: [self monthText:month]];
        self.backgroundCover.isToday = NO;
    } else {
        [self setDayLabelText:[NSString stringWithFormat:@"%ld", (long)day] withTopLabel: nil];
        self.backgroundCover.isToday = NO;
    }
    
    // background cover
    if (self.range) {
        // configure look when in range
        self.backgroundCover.fillColor = self.range.backgroundColor ?: [UIColor clearColor];
        self.backgroundCover.backgroundImage = self.range.backgroundImage ?: nil;
        UIColor *textColor = self.range.textColor ?: [UIColor whiteColor];
//        self.monthLabel.textColor = textColor;
        self.dayLabel.textColor = textColor;
        
        // check position in range
        BOOL isBeginDate = [GLDateUtils date:self.date isSameDayAsDate:self.range.beginDate];
        BOOL isEndDate = [GLDateUtils date:self.date isSameDayAsDate:self.range.endDate];
        
        if (isBeginDate && isEndDate) {
            self.backgroundCover.rangePosition = RANGE_POSITION_SINGLE;
            [self.superview bringSubviewToFront:self];
        } else if (isBeginDate) {
            self.backgroundCover.rangePosition = RANGE_POSITION_BEGIN;
            [self.superview bringSubviewToFront:self];
        } else if (isEndDate) {
            self.backgroundCover.rangePosition = RANGE_POSITION_END;
            [self.superview bringSubviewToFront:self];
        } else {
            self.backgroundCover.rangePosition = RANGE_POSITION_MIDDLE;
        }
    } else {
        self.backgroundCover.rangePosition = RANGE_POSITION_NONE;
        [self.superview sendSubviewToBack:self];
    }
    
    self.backgroundCover.inEdit = self.inEdit;
    
    if (self.enlargePoint == ENLARGE_BEGIN_POINT) {
        [self.backgroundCover enlargeBeginPoint:YES];
        [self.backgroundCover enlargeEndPoint:NO];
    } else if (self.enlargePoint == ENLARGE_END_POINT) {
        [self.backgroundCover enlargeBeginPoint:NO];
        [self.backgroundCover enlargeEndPoint:YES];
    } else {
        [self.backgroundCover enlargeBeginPoint:NO];
        [self.backgroundCover enlargeEndPoint:NO];
    }
}

- (void)setDayLabelText:(NSString *)text withTopLabel: (NSString*) top
{
    NSDictionary* attributes = self.disabled ? self.dayDisabledLabelAttributes : self.dayLabelAttributes;
    NSAttributedString* dayString = [[NSAttributedString alloc] initWithString:text attributes: attributes];

    NSAttributedString* topString;

    if (top) {
        NSString* topNewLine = [top stringByAppendingString:@"\n"];

        topString = [[NSAttributedString alloc] initWithString:topNewLine attributes:self.monthLabelAttributes];
    }

    NSMutableAttributedString* res = [[NSMutableAttributedString alloc] init];

    if (topString) {
        [res appendAttributedString: topString];
    }

    [res appendAttributedString: dayString];

    self.dayLabel.attributedText = res;
}


- (void)setFutureDayLabelText:(NSString *)text
{
    self.dayLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.futureDayLabelAttributes];
}


- (void)setTodayLabelText:(NSString *)text
{
    self.dayLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.todayLabelAttributes];
}

- (void)setTodayLabelText:(NSString *)text withTopLabel: (NSString*) top
{
    NSString* topNewLine = [top stringByAppendingString:@"\n"];

    NSDictionary *todayTopLabelAttributes = @{
                                              NSFontAttributeName: self.monthLabelAttributes[NSFontAttributeName],
                                              NSForegroundColorAttributeName: self.todayLabelAttributes[NSForegroundColorAttributeName]
                                              };

    NSAttributedString* topString = [[NSAttributedString alloc] initWithString:topNewLine attributes:todayTopLabelAttributes];
    NSAttributedString* dayString = [[NSAttributedString alloc] initWithString:text attributes:self.todayLabelAttributes];

    NSMutableAttributedString* res = [[NSMutableAttributedString alloc] initWithAttributedString: topString];

    [res appendAttributedString: dayString];

    self.dayLabel.attributedText = res;
}

- (BOOL)isToday
{
    return [GLDateUtils date:self.date isSameDayAsDate:[NSDate date]];
}

- (BOOL)isFuture
{
    return [self.date compare:[NSDate date]] == NSOrderedDescending;
}

static NSArray *months;
- (NSString *)monthText:(NSInteger)month {
    if (!months) {
        months = [[[[NSDateFormatter alloc] init] shortStandaloneMonthSymbols] valueForKeyPath:@"capitalizedString"];
    }
    return [months objectAtIndex:(month - 1)];
}

@end
