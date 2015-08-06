//
//  GLPeriodCalendarView.h
//  GLPeriodCalendar
//
//  Created by ltebean on 15-4-16.
//  Copyright (c) 2015 glow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLCalendarDateRange.h"

@class GLCalendarView;
enum RANGE_DISPLAY_MODE;

@protocol GLCalendarViewDelegate <NSObject>
- (BOOL)calenderView:(GLCalendarView *)calendarView canAddRangeWithBeginDate:(NSDate *)beginDate;
- (GLCalendarDateRange *)calenderView:(GLCalendarView *)calendarView rangeToAddWithBeginDate:(NSDate *)beginDate;
- (void)calenderView:(GLCalendarView *)calendarView beginToEditRange:(GLCalendarDateRange *)range;
- (void)calenderView:(GLCalendarView *)calendarView finishEditRange:(GLCalendarDateRange *)range continueEditing:(BOOL)continueEditing;
- (BOOL)calenderView:(GLCalendarView *)calendarView canUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate;
- (void)calenderView:(GLCalendarView *)calendarView didUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate;
@optional
- (NSArray*) calendarViewWeekDayTitles;
@end


@interface GLCalendarView : UIView
@property (nonatomic) CGFloat padding UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat rowHeight UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *weekDayTitleAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *monthCoverAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *monthCoverYearAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *selectedDayTitleAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *selectedMonthTitleAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *backToTodayButtonImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *backToTodayButtonColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *backToTodayButtonBorderColor UI_APPEARANCE_SELECTOR;

//cell appearance
@property (nonatomic, strong) UIColor *cellEvenMonthBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cellOddMonthBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cellGridNormalColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cellGridSeparatorColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *cellDayLabelAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *cellMonthLabelAttributes UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) NSDictionary *cellTodayLabelAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *cellTodayTitleAttributes UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) NSDictionary *cellDayDisabledLabelAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cellTodayBackgroundColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGFloat cellEditCoverPadding UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat cellEditCoverBorderWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *cellEditCoverBorderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat cellEditCoverPointSize UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat cellEditCoverPointScale UI_APPEARANCE_SELECTOR;
//@property (nonatomic) RANGE_DISPLAY_MODE cellRangeDisplayMode UI_APPEARANCE_SELECTOR;



@property (weak, nonatomic, readonly) UIView *weekDayTitle;

@property (nonatomic, readonly) NSCalendar *calendar;
@property (nonatomic, copy) NSDate *firstDate;
@property (nonatomic, copy) NSDate *lastDate;
@property (nonatomic, strong) NSMutableArray *ranges;
@property (nonatomic) BOOL showMaginfier;
@property (nonatomic, weak) id<GLCalendarViewDelegate> delegate;
@property (nonatomic, strong) GLCalendarDateRange *restrictSelectionWithRange;
- (void)reload;
- (void)addRange:(GLCalendarDateRange *)range;
- (void)removeRange:(GLCalendarDateRange *)range;
- (void)updateRange:(GLCalendarDateRange *)range withBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate;
- (void)forceFinishEdit;
- (void)beginToEditRange:(GLCalendarDateRange *)range;
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;
@end
