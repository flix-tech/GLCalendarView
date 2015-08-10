//
//  ViewController.m
//  GLPeriodCalendar
//
//  Created by ltebean on 15-4-16.
//  Copyright (c) 2015 glow. All rights reserved.
//

#import "GLCalendarViewDemoController.h"
#import "GLCalendarView.h"
#import "GLCalendarDateRange.h"
#import "GLDateUtils.h"
#import "GLCalendarDayCell.h"

@interface GLCalendarViewDemoController ()<GLCalendarViewDelegate>
@property (weak, nonatomic) IBOutlet GLCalendarView *calendarView;
@property (nonatomic, weak) GLCalendarDateRange *rangeUnderEdit;
@property (nonatomic, strong) NSArray* uppercaseDays;
@end

@implementation GLCalendarViewDemoController

- (void)viewDidLoad {
    [super viewDidLoad];


    NSMutableArray* uppercaseDays = [NSMutableArray arrayWithCapacity: 7];
    [self.calendarView.calendar.shortWeekdaySymbols enumerateObjectsUsingBlock:^(NSString* day, NSUInteger idx, BOOL *stop) {
        [uppercaseDays addObject:[day uppercaseString]];
    }];
    self.uppercaseDays = [NSArray arrayWithArray:uppercaseDays];

    // Do any additional setup after loading the view, typically from a nib.
    self.calendarView.delegate = self;
    self.calendarView.showMaginfier = NO;

    [self setupCellsAppearance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
//    NSDate *today = [NSDate date];
//
//    NSDate *beginDate1 = [GLDateUtils dateByAddingDays:-32 toDate:today];
//    NSDate *endDate1 = [GLDateUtils dateByAddingDays:-26 toDate:today];
//    GLCalendarDateRange *range1 = [GLCalendarDateRange rangeWithBeginDate:beginDate1 endDate:endDate1];
//    range1.backgroundColor = UIColorFromRGB(0x79a9cd);
//    range1.editable = YES;
//    
//    NSDate *beginDate2 = [GLDateUtils dateByAddingDays:-60 toDate:today];
//    NSDate *endDate2 = [GLDateUtils dateByAddingDays:-1 toDate:today];
//    GLCalendarDateRange *range2 = [GLCalendarDateRange rangeWithBeginDate:beginDate2 endDate:endDate2];
////    range2.backgroundColor =;
//    range2.showMonthTitle = NO;
//    range2.editable = NO;
////
//    self.calendarView.ranges = [@[range2] mutableCopy];
//

//    self.calendarView.firstDate = [GLDateUtils dateByAddingDays: -90 toDate:[NSDate date]];
//    self.calendarView.lastDate  = [GLDateUtils dateByAddingDays: 300 toDate: self.calendarView.firstDate];

    GLCalendarDateRange* displayRange = [GLCalendarDateRange rangeWithBeginDate:[GLDateUtils dateByAddingDays:0 toDate:[NSDate date]] endDate:[GLDateUtils dateByAddingDays: 183 toDate: [NSDate date]]];

    self.calendarView.calendarDisplayRange = displayRange;
}

- (BOOL)calenderView:(GLCalendarView *)calendarView canAddRangeWithBeginDate:(NSDate *)beginDate
{
    if ([self.calendarView.calendarDisplayRange containsDate: beginDate]) {
        return YES;
    }
    return NO;
}

- (GLCalendarDateRange *)calenderView:(GLCalendarView *)calendarView rangeToAddWithBeginDate:(NSDate *)beginDate
{
    NSDate* endDate = beginDate;
    GLCalendarDateRange *range = [GLCalendarDateRange rangeWithBeginDate:beginDate endDate:endDate];
    range.backgroundColor = [UIColor blueColor];
    range.selectedMonthTitleAttributes = self.calendarView.selectedMonthTitleAttributes;
    range.selectedDayTitleAttributes = self.calendarView.selectedDayTitleAttributes;
    range.showMonthTitle = YES;
    range.editable = YES;


    [self.calendarView.ranges enumerateObjectsUsingBlock:^(GLCalendarDateRange *obj, NSUInteger idx, BOOL *stop) {
        if (obj.editable) {
            [self.calendarView removeRange:obj];
        }
    }];

    NSLog(@"Selected: %@", range);

    return range;
}

- (void)calenderView:(GLCalendarView *)calendarView beginToEditRange:(GLCalendarDateRange *)range
{
    NSLog(@"begin to edit range: %@", range);
//    self.rangeUnderEdit = range;

    [self.calendarView removeRange: range];
}

- (void)calenderView:(GLCalendarView *)calendarView finishEditRange:(GLCalendarDateRange *)range continueEditing:(BOOL)continueEditing
{
    NSLog(@"finish edit range: %@", range);
    self.rangeUnderEdit = nil;
}

- (BOOL)calenderView:(GLCalendarView *)calendarView canUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    return YES;
}

- (void)calenderView:(GLCalendarView *)calendarView didUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    NSLog(@"did update range: %@", range);
}

- (NSArray*) calendarViewWeekDayTitles
{
    return self.uppercaseDays;
}

- (IBAction)deleteButtonPressed:(id)sender
{
    if (self.rangeUnderEdit) {
        [self.calendarView removeRange:self.rangeUnderEdit];
    }
//    [self.calendarView scrollToDate:[NSDate date] animated:YES];
}

#pragma mark - cell appearance moved to properties

- (void) setupCellsAppearance
{
    GLCalendarView* calendarView = self.calendarView;

    calendarView.cellEvenMonthBackgroundColor = [UIColor whiteColor];
    calendarView.cellOddMonthBackgroundColor = [UIColor whiteColor];

    calendarView.cellEditCoverPadding = 0;

    calendarView.cellDayLabelAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName:[UIColor darkGrayColor]};

    calendarView.cellTodayLabelAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName:[UIColor grayColor]};

    calendarView.cellTodayMonthAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:[UIColor grayColor]};

    calendarView.cellDayDisabledLabelAttributes = @{
                                                                   NSFontAttributeName:[UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName:[UIColor lightGrayColor]
                                                                   };
    calendarView.cellMonthLabelAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12],
                                                             NSForegroundColorAttributeName:[UIColor grayColor]};

    calendarView.cellEditCoverBorderWidth = 0;
    calendarView.cellEditCoverBorderColor = [UIColor yellowColor];
    calendarView.cellEditCoverPointSize = 14;

    calendarView.cellGridNormalColor    = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    calendarView.cellGridSeparatorColor = [UIColor lightGrayColor];
}

@end
