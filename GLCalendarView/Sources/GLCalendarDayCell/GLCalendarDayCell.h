//
//  GLCalendarDateCell.h
//  GLPeriodCalendar
//
//  Created by ltebean on 15-4-16.
//  Copyright (c) 2015 glow. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GLCalendarDateRange;
@class GLCalendarDate;

typedef NS_ENUM(NSInteger, CELL_POSITION) {
    POSITION_NORMAL = 0,
    POSITION_LEFT_EDGE = 1,
    POSITION_RIGHT_EDGE = 2,
};

typedef NS_ENUM(NSInteger, ENLARGE_POINT) {
    ENLARGE_NONE = 0,
    ENLARGE_BEGIN_POINT = 1,
    ENLARGE_END_POINT = 2,
};

@interface GLCalendarDayCell : UICollectionViewCell
@property (nonatomic, strong) UIColor *evenMonthBackgroundColor;
@property (nonatomic, strong) UIColor *oddMonthBackgroundColor;
@property (nonatomic, strong) UIColor *gridNormalColor;
@property (nonatomic, strong) UIColor *gridSeparatorColor;
@property (nonatomic, strong) NSDictionary *dayLabelAttributes;
@property (nonatomic, strong) NSDictionary *monthLabelAttributes;

@property (nonatomic, strong) NSDictionary *todayLabelAttributes;
@property (nonatomic, strong) NSDictionary *todayTitleAttributes;

@property (nonatomic, strong) NSDictionary *dayDisabledLabelAttributes;
@property (nonatomic, strong) UIColor *todayBackgroundColor;

@property (nonatomic) CGFloat editCoverPadding;
@property (nonatomic) CGFloat editCoverBorderWidth;
@property (nonatomic, strong) UIColor *editCoverBorderColor;
@property (nonatomic) CGFloat editCoverPointSize;
@property (nonatomic) CGFloat editCoverPointScale;

@property (nonatomic, strong, readonly) GLCalendarDate *date;
@property (nonatomic, weak, readonly) GLCalendarDateRange *range;
@property (nonatomic, readonly) BOOL disabled;
@property (nonatomic, readonly) BOOL isToday;
@property (nonatomic, readwrite) BOOL appearanceConfigured;

- (void)setDate:(GLCalendarDate *)date range:(GLCalendarDateRange *)range cellPosition:(CELL_POSITION)cellPosition enlargePoint:(ENLARGE_POINT)enlargePoint disabled: (BOOL) disabled isToday: (BOOL) isToday;
@end
