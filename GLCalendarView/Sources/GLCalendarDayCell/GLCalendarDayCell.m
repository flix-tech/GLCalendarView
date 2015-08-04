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

        self.lineLeft = [[UIView alloc] initWithFrame: CGRectMake(0, 0, lineWidth, width)];
        self.lineBottom = [[UIView alloc] initWithFrame: CGRectMake(0, heigh, width, lineWidth)];
        self.lineRight =  [[UIView alloc] initWithFrame: CGRectMake(width - lineWidth, 0, lineWidth, heigh)];

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

    if (self.needsDayTextUpdate) {
        [self updateDayLabelText:self.titleDate withTopLabel: self.titleTop];
        self.needsDayTextUpdate = NO;
    }

    if (self.needsTodayTextUpdate) {
        [self updateTodayLabelText:self.titleDate withTopLabel: self.titleTop];
        self.needsTodayTextUpdate = NO;
    }

    [super layoutSubviews];
}

- (void)setDate:(GLCalendarDate *)date range:(GLCalendarDateRange *)range cellPosition:(CELL_POSITION)cellPosition enlargePoint:(ENLARGE_POINT)enlargePoint disabled: (BOOL) disabled
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
    self.needsUIUpdate = YES;

    [self setNeedsLayout];
}
- (void)performUpdateUI
{
//    NSLog(@"update ui: %@ %d", [GLDateUtils descriptionForDate:self.date], _enlargePoint);

//    NSDateComponents *components = [[GLDateUtils calendar] components:NSCalendarUnitDay|NSCalendarUnitMonth fromDate:self.date];
//    
    NSInteger day = self.date.day;
    NSInteger month = self.date.month;
//    NSInteger monthDays = [[GLDateUtils calendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self.date].length;

    // month background color
    if (month % 2 == 0) {
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
    if ([self isToday]) {
        [self setTodayLabelText:[NSString stringWithFormat:@"%ld", (long)day] withTopLabel:[self today]];
        if (self.todayBackgroundColor) {
            self.dayLabel.backgroundColor = self.todayBackgroundColor;
        } else {
            self.dayLabel.backgroundColor = [UIColor whiteColor];
        }
    } else if(day == 1) {
        [self setDayLabelText:[NSString stringWithFormat:@"%ld", (long)day] withTopLabel: [self monthText:month]];
    } else if (  self.range && self.range.durationDays < 1 ) {

    } else {
        [self setDayLabelText:[NSString stringWithFormat:@"%ld", (long)day] withTopLabel: nil];
    }
    
    // background cover
    if (self.range) {
        // configure look when in range
        self.dayLabel.backgroundColor = self.range.backgroundColor ?: [UIColor whiteColor];
    }
}

- (void)setDayLabelText:(NSString *)text withTopLabel: (NSString*) top
{
    self.titleTop = top;
    self.titleDate = text;

    self.needsTodayTextUpdate = NO;
    self.needsDayTextUpdate = YES;

    [self setNeedsLayout];
}

- (void)updateDayLabelText:(NSString *)text withTopLabel: (NSString*) top
{

//    if (text) {
//        NSString* title = text;
//        if (top) {
//            title = [title stringByAppendingFormat:@"\n%@",top];
//        }
//        self.dayLabel.text = title;
//        return;
//    } else {
//        return;
//    }

    UIColor* textColor = self.range.textColor;

    NSDictionary* attributes = self.disabled ? self.dayDisabledLabelAttributes : self.dayLabelAttributes;

    if (textColor) {
        attributes = @{
                       NSFontAttributeName: attributes[NSFontAttributeName],
                       NSForegroundColorAttributeName: textColor
                       };
    }

    NSAttributedString* dayString = [[NSAttributedString alloc] initWithString:text attributes: attributes];

    NSAttributedString* topString;

    if (top) {
        NSString* topNewLine = [top stringByAppendingString:@"\n"];

        NSDictionary* topAttributes = self.monthLabelAttributes;

        if (textColor) {
            topAttributes = @{
                              NSFontAttributeName: topAttributes[NSFontAttributeName],
                              NSForegroundColorAttributeName: textColor
                              };
        }

        topString = [[NSAttributedString alloc] initWithString:topNewLine attributes:topAttributes];
    }

    NSMutableAttributedString* res = [[NSMutableAttributedString alloc] init];

    if (topString) {
        [res appendAttributedString: topString];
    }

    [res appendAttributedString: dayString];

    self.dayLabel.attributedText = res;
}


//- (void)setFutureDayLabelText:(NSString *)text
//{
//    self.dayLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.futureDayLabelAttributes];
//}


- (void)setTodayLabelText:(NSString *)text
{
//    self.dayLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.todayLabelAttributes];
    [self setTodayLabelText: text withTopLabel: nil];
}

- (void)setTodayLabelText:(NSString *)text withTopLabel: (NSString*) top
{
    self.titleTop = top;
    self.titleDate = text;

    self.needsTodayTextUpdate = YES;
    self.needsDayTextUpdate = NO;

    [self setNeedsLayout];
}


- (void)updateTodayLabelText:(NSString *)text withTopLabel: (NSString*) top
{
    NSString* topNewLine = [top stringByAppendingString:@"\n"];

    UIColor* todayTextColor = self.todayLabelAttributes[NSForegroundColorAttributeName];

    if (self.disabled) {
        todayTextColor = self.dayDisabledLabelAttributes[NSForegroundColorAttributeName];
    }

    NSDictionary *todayTopLabelAttributes = @{
                                              NSFontAttributeName: self.monthLabelAttributes[NSFontAttributeName],
                                              NSForegroundColorAttributeName: self.todayLabelAttributes[NSForegroundColorAttributeName]
                                              };

    NSDictionary* todayDayLabelAttributes = @{
                                              NSFontAttributeName: self.todayLabelAttributes[NSFontAttributeName],
                                              NSForegroundColorAttributeName: todayTextColor
                                              };

    NSAttributedString* topString = [[NSAttributedString alloc] initWithString:topNewLine attributes:todayTopLabelAttributes];
    NSAttributedString* dayString = [[NSAttributedString alloc] initWithString:text attributes:todayDayLabelAttributes];

    NSMutableAttributedString* res = [[NSMutableAttributedString alloc] initWithAttributedString: topString];

    [res appendAttributedString: dayString];

    self.dayLabel.attributedText = res;
}

- (BOOL)isToday
{
    return [self.date isTheSameDayAsDate:[NSDate date]];
}

//- (BOOL)isFuture
//{
//    return [self.date compare:[NSDate date]] == NSOrderedDescending;
//}

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
        _textToday = [todayFormatter stringFromDate:[NSDate date]];
    }
    return _textToday;
}

@end
