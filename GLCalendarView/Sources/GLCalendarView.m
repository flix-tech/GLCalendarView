//
//  GLPeriodCalendarView.m
//  GLPeriodCalendar
//
//  Created by ltebean on 15-4-16.
//  Copyright (c) 2015 glow. All rights reserved.
//

#import "GLCalendarView.h"
#import "GLCalendarDayCell.h"
#import "GLCalendarMonthCoverView.h"
#import "GLDateUtils.h"
#import "GLCalendarDate.h"

static NSString * const CELL_REUSE_IDENTIFIER = @"DayCell";

#define DEFAULT_PADDING 6;
#define DEFAULT_ROW_HEIGHT 46;

@interface GLCalendarView()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, readwrite) NSCalendar *calendar;
@property (nonatomic, weak) GLCalendarDateRange *rangeUnderEdit;

@property (nonatomic, strong) UILongPressGestureRecognizer *dragBeginDateGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *dragEndDateGesture;

@property (nonatomic) BOOL draggingBeginDate;
@property (nonatomic) BOOL draggingEndDate;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *weekDayTitle;
@property (weak, nonatomic) IBOutlet GLCalendarMonthCoverView *monthCoverView;
@property (strong, nonatomic) NSMutableDictionary *cellDates;
@property (nonatomic, strong, readonly) GLCalendarDate *firstGLDate;
@property (nonatomic, strong, readonly) GLCalendarDate *lastGLDate;
@property (nonatomic, strong, readonly) GLCalendarDate *todayGL;
@end

@implementation GLCalendarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self load];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self load];
    }
    return self;
}

- (void)load
{
    UIView *view = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    view.frame = self.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:view];
    [self setup];
}

- (void)setup
{
    self.today = [NSDate date];

    self.ranges = [NSMutableArray array];
    
    self.calendar = [GLDateUtils calendar];
    
    self.monthCoverView.hidden = YES;

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    [self.collectionView registerClass:[GLCalendarDayCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER];
    
    self.dragBeginDateGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragBeginDate:)];
    self.dragEndDateGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragEndDate:)];
    
    self.dragBeginDateGesture.delegate = self;
    self.dragEndDateGesture.delegate = self;
    
    self.dragBeginDateGesture.minimumPressDuration = 0.05;
    self.dragEndDateGesture.minimumPressDuration = 0.05;
    
    [self.collectionView addGestureRecognizer:self.dragBeginDateGesture];
    [self.collectionView addGestureRecognizer:self.dragEndDateGesture];
    
    [self reloadAppearance];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupWeekDayTitle];
}

- (void)setupWeekDayTitle
{
    [self.weekDayTitle.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat width = (CGRectGetWidth(self.bounds) - self.padding * 2) / 7;
    CGFloat centerY = self.weekDayTitle.bounds.size.height / 2;
    NSArray *titles = self.calendar.veryShortStandaloneWeekdaySymbols;
    if ([self.delegate respondsToSelector:@selector(calendarViewWeekDayTitles)]) {
        titles = self.delegate.calendarViewWeekDayTitles;
    }
    NSInteger firstWeekDayIdx = [self.calendar firstWeekday] - 1;  // Sunday == 1
    if (firstWeekDayIdx > 0) {
        NSArray *post = [titles subarrayWithRange:NSMakeRange(firstWeekDayIdx, 7 - firstWeekDayIdx)];
        NSArray *pre = [titles subarrayWithRange:NSMakeRange(0, firstWeekDayIdx)];
        titles = [post arrayByAddingObjectsFromArray:pre];
    }
    for (int i = 0; i < titles.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.attributedText = [[NSAttributedString alloc] initWithString:titles[i] attributes:self.weekDayTitleAttributes];
        label.center = CGPointMake(self.padding + i * width + width / 2, centerY);
        [self.weekDayTitle addSubview:label];
    }
}

# pragma mark - appearance

- (void)reloadAppearance
{
    GLCalendarView *appearance = [[self class] appearance];
    self.padding = appearance.padding;
    self.weekDayTitleAttributes = appearance.weekDayTitleAttributes ?: @{NSFontAttributeName:[UIFont systemFontOfSize:8], NSForegroundColorAttributeName:[UIColor grayColor]};
    self.monthCoverAttributes = appearance.monthCoverAttributes ?: @{NSFontAttributeName:[UIFont systemFontOfSize:30]};
    self.monthCoverYearAttributes = appearance.monthCoverYearAttributes ?: self.monthCoverAttributes;
    
    self.monthCoverView.textMonthAttributes = self.monthCoverAttributes;
    self.monthCoverView.textYearAttributes = self.monthCoverYearAttributes;
    self.monthCoverView.backgroundColor = appearance.monthCoverBackgroundColor ?: [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.monthCoverView.monthFormat = appearance.monthCoverMonthFormat;
    self.monthCoverView.yearFormat = appearance.monthCoverYearFormat;
    
}

#pragma mark - public api

- (void)reload
{
    [self.collectionView reloadData];
}

- (void)addRange:(GLCalendarDateRange *)range
{
    [self addRange:range reload:YES];
}

- (void)removeRange:(GLCalendarDateRange *)range
{
    [self removeRange:range reload:YES];
}

- (void)addRange:(GLCalendarDateRange *)range reload: (BOOL) reload
{
    [self.ranges addObject:range];
    if (reload) {
        [self reloadFromBeginDate:range.beginDate toDate:range.endDate];
    }
}

- (void)removeRange:(GLCalendarDateRange *)range reload: (BOOL) reload
{
    [self.ranges removeObject:range];
    if (reload) {
        [self reloadFromBeginDate:range.beginDate toDate:range.endDate];
    }
}

- (void)updateRange:(GLCalendarDateRange *)range withBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    NSDate *beginDateToReload = [[GLDateUtils minForDate:range.beginDate andDate:beginDate] copy];
    NSDate *endDateToReload = [[GLDateUtils maxForDate:range.endDate andDate:endDate] copy];
    range.beginDate = beginDate;
    range.endDate = endDate;
    [self reloadFromBeginDate:beginDateToReload toDate:endDateToReload];
}

- (void)forceFinishEdit
{
    self.rangeUnderEdit.inEdit = NO;
    [self reloadFromBeginDate:self.rangeUnderEdit.beginDate toDate:self.rangeUnderEdit.endDate];
    self.rangeUnderEdit = nil;
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;
{
    NSInteger item = [GLDateUtils daysBetween:self.firstDate and:date];

    CGPoint offset = CGPointMake(0, (item/7)*self.cellWidth);

    [self.collectionView setContentOffset: offset animated:animated];
}

#pragma mark - restricted dates range

- (void)setCalendarDisplayRange:(GLCalendarDateRange *)restrictSelectionWithRange
{
    _calendarDisplayRange = restrictSelectionWithRange;

    // how many rows to put in 'inset' area

    if (!_calendarDisplayRange) {
        // we cancelled restrictions
        self.collectionView.contentInset = UIEdgeInsetsZero;
        return;
    }

    NSInteger insetRows = 6; //maximum possible rows to fit one month
    NSInteger weekDays  = 7;

    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        // we have better performance, let's do it :)
        insetRows = 10;
    }

    NSInteger insetDays = insetRows * weekDays;

    // adding extra rows to the date - 10 rows to the top, 10 to the bottom...
    self.firstDate = [GLDateUtils dateByAddingDays:-insetDays toDate:restrictSelectionWithRange.beginDate];
    self.lastDate  = [GLDateUtils dateByAddingDays: insetDays toDate:restrictSelectionWithRange.endDate];

    CGFloat cellHeight = self.cellWidth;
    CGFloat insetHeight = cellHeight * insetRows;

    self.collectionView.contentInset = UIEdgeInsetsMake(-insetHeight, 0, -insetHeight, 0);

    // set up overlay view
    [self.monthCoverView updateWithFirstDate:self.firstGLDate lastDate:self.lastGLDate calendar:self.calendar rowHeight:self.cellWidth];

}

# pragma mark - getter & setter

- (void)setFirstDate:(NSDate *)firstDate
{
    NSDate* newDate = [GLDateUtils weekFirstDate:[GLDateUtils cutDate:firstDate]];
    if (!_firstGLDate || [_firstGLDate.date compare:newDate] != NSOrderedSame) {
        self.cellDates = [NSMutableDictionary dictionaryWithCapacity:366];
    }
    _firstGLDate = [[GLCalendarDate alloc] initWithCutDate: newDate];
}

- (NSDate *)firstDate
{
    if (!_firstGLDate) {
        self.firstDate = [GLDateUtils dateByAddingDays:-365 toDate:self.today];
    }
    return _firstGLDate.date;
}

- (void)setLastDate:(NSDate *)lastDate
{
    NSDate *Date = [GLDateUtils weekLastDate:[GLDateUtils cutDate:lastDate]];
    _lastGLDate = [[GLCalendarDate alloc] initWithCutDate: Date];
}

- (NSDate *)lastDate
{
    if (!_lastGLDate) {
        self.lastDate = [GLDateUtils dateByAddingDays:30 toDate:self.today];
    }
    return _lastGLDate.date;
}

- (void)setToday:(NSDate *)today
{
    _today = today;
    _todayGL = [[GLCalendarDate alloc] initWithDate: today];
}

# pragma mark - UICollectionView data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [GLDateUtils daysBetween:self.firstDate and:self.lastDate] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GLCalendarDayCell *cell = (GLCalendarDayCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER forIndexPath:indexPath];

    [self configureCellAppearance: cell];

    CELL_POSITION cellPosition;
    ENLARGE_POINT enlargePoint;
    
    NSInteger position = indexPath.item % 7;
    if (position == 0) {
        cellPosition = POSITION_LEFT_EDGE;
    } else if (position == 6) {
        cellPosition = POSITION_RIGHT_EDGE;
    } else {
        cellPosition = POSITION_NORMAL;
    }
    
    GLCalendarDate *date = [self dateForCellAtIndexPath:indexPath];

    if (self.draggingBeginDate && [date isTheSameDayAsDate:self.rangeUnderEdit.beginDate]) {
        enlargePoint = ENLARGE_BEGIN_POINT;

    } else if (self.draggingEndDate && [date isTheSameDayAsDate:self.rangeUnderEdit.endDate]) {
        enlargePoint = ENLARGE_END_POINT;
    } else {
        enlargePoint = ENLARGE_NONE;
    }

    BOOL disabled = NO;
    if (self.calendarDisplayRange) {
        disabled = ![self.calendarDisplayRange containsDate: date.date];
    }

    [cell setDate:date range:[self selectedRangeForDate:date.date] cellPosition:cellPosition enlargePoint:enlargePoint disabled: disabled isToday: [self.todayGL isTheSameDayAs: date]];
    
    return cell;
}

- (GLCalendarDate*) dateForCellAtIndexPath:(NSIndexPath *)indexPath
{
    GLCalendarDate* gldate = [self.cellDates objectForKey: indexPath];
    if (!gldate) {
        NSDate* date = [GLDateUtils dateByAddingDays:indexPath.item toDate:self.firstDate];
        gldate = [[GLCalendarDate alloc] initWithCutDate: date];
        [self.cellDates setObject:gldate forKey:indexPath];
    }

    return gldate;
}


- (GLCalendarDateRange *)selectedRangeForDate:(NSDate *)date
{
    for (GLCalendarDateRange *range in self.ranges) {
        if ([range containsDate:date]) {
            return range;
        }
    }
    return nil;
}

# pragma mark - UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GLCalendarDate *date = [self dateForCellAtIndexPath:indexPath];
    GLCalendarDateRange *range = [self selectedRangeForDate:date.date];
    
    // if click in a range
    if (range && range.editable) {
        if (range == self.rangeUnderEdit) {
            return;
        }
        // click a different range
        if (self.rangeUnderEdit && range != self.rangeUnderEdit) {
            [self finishEditRange:self.rangeUnderEdit continueEditing:YES];
        }
        [self beginToEditRange:range];
    } else {
        if (self.rangeUnderEdit) {
            [self finishEditRange:self.rangeUnderEdit continueEditing:NO];
        } else {
            BOOL canAdd = [self.delegate calenderView:self canAddRangeWithBeginDate:date.date];
            if (canAdd) {
                GLCalendarDateRange *rangeToAdd = [self.delegate calenderView:self rangeToAddWithBeginDate:date.date];
                [self addRange:rangeToAdd];
            }
        }
    }
}

# pragma mark - UICollectionView layout

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, self.padding, 0, self.padding); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake( self.cellWidth, self.cellWidth);
}

- (CGFloat)cellWidth
{
    if (self.cellSide) {
        return self.cellSide;
    }
    CGFloat cellSize = [UIScreen mainScreen].bounds.size.width / 7;
    cellSize = (ceilf(cellSize) + floorf(cellSize)) / 2; //(round to 0.5 precision)
    return cellSize;
}

# pragma mark - UIScrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.monthCoverView.hidden = NO;
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.monthCoverView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // update month cover
    self.monthCoverView.contentOffset = self.collectionView.contentOffset;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [UIView animateWithDuration:0.166 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.monthCoverView.alpha = 0.1;
        } completion:^(BOOL finished) {
            if (finished) {
                self.monthCoverView.hidden = YES;
            }
        }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.33 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.monthCoverView.alpha = 0.1;
    } completion:^(BOOL finished) {
        if (finished) {
            self.monthCoverView.hidden = YES;
        }
    }];
}

# pragma mark - Edit range

- (void)beginToEditRange:(GLCalendarDateRange *)range
{
    self.rangeUnderEdit = range;
    self.rangeUnderEdit.inEdit = YES;
    [self reloadFromBeginDate:self.rangeUnderEdit.beginDate toDate:self.rangeUnderEdit.endDate];
    if ([self.delegate respondsToSelector:@selector(calenderView:beginToEditRange:)]) {
        [self.delegate calenderView:self beginToEditRange:range];
    }
}

- (void)finishEditRange:(GLCalendarDateRange *)range continueEditing:(BOOL)continueEditing
{
    self.rangeUnderEdit.inEdit = NO;
    [self reloadFromBeginDate:self.rangeUnderEdit.beginDate toDate:self.rangeUnderEdit.endDate];
    if ([self.delegate respondsToSelector:@selector(calenderView:finishEditRange:continueEditing:)]) {
        [self.delegate calenderView:self finishEditRange:self.rangeUnderEdit continueEditing:continueEditing];
    }

    self.rangeUnderEdit = nil;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    if (!self.rangeUnderEdit) {
        return NO;
    }
    if (recognizer == self.dragBeginDateGesture) {
        CGPoint location = [recognizer locationInView:self.collectionView];
        CGRect rectForBeginDate = [self rectForDate:self.rangeUnderEdit.beginDate];
        rectForBeginDate.origin.x -= self.cellWidth / 2;
        if (CGRectContainsPoint(rectForBeginDate, location)) {
            return YES;
        }
    }
    if (recognizer == self.dragEndDateGesture) {
        CGPoint location = [recognizer locationInView:self.collectionView];
        CGRect rectForEndDate = [self rectForDate:self.rangeUnderEdit.endDate];
        rectForEndDate.origin.x += self.cellWidth / 2;
        if (CGRectContainsPoint(rectForEndDate, location)) {
            return YES;
        }
    }
    return NO;
}


- (void)handleDragBeginDate:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.draggingBeginDate = YES;
        [self reloadCellOnDate:self.rangeUnderEdit.beginDate];
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.draggingBeginDate = NO;
        [self reloadCellOnDate:self.rangeUnderEdit.beginDate];
        return;
    }
    
    CGPoint location = [recognizer locationInView:self.collectionView];
    if (location.y <= self.collectionView.contentOffset.y) {
        return;
    }
    
    GLCalendarDate *date = [self dateAtLocation:location];
    if ([date isTheSameDayAsDate: self.rangeUnderEdit.beginDate]) {
        return;
    }
    
    if ([self.rangeUnderEdit.endDate compare:date.date] == NSOrderedAscending) {
        return;
    }
    
    BOOL canUpdate = NO;

    if ([self.delegate respondsToSelector:@selector(calenderView:canUpdateRange:toBeginDate:endDate:)]) {
        canUpdate = [self.delegate calenderView:self canUpdateRange:self.rangeUnderEdit toBeginDate:date.date endDate:self.rangeUnderEdit.endDate];
    }

    if (canUpdate) {
        NSDate *originalBeginDate = [self.rangeUnderEdit.beginDate copy];
        self.rangeUnderEdit.beginDate = date.date;
        if ([originalBeginDate compare:date.date] == NSOrderedAscending) {
            [self reloadFromBeginDate:originalBeginDate toDate:date.date];
        } else {
            [self reloadFromBeginDate:date.date toDate:originalBeginDate];
        }
        if ([self.delegate respondsToSelector:@selector(calenderView:didUpdateRange:toBeginDate:endDate:)]) {
            [self.delegate calenderView:self didUpdateRange:self.rangeUnderEdit toBeginDate:date.date endDate:self.rangeUnderEdit.endDate];
        }
    }
}

- (void)handleDragEndDate:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.draggingEndDate = YES;
        [self reloadCellOnDate:self.rangeUnderEdit.endDate];
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.draggingEndDate = NO;
        [self reloadCellOnDate:self.rangeUnderEdit.endDate];
        return;
    }

    CGPoint location = [recognizer locationInView:self.collectionView];
    if (location.y <= self.collectionView.contentOffset.y) {
        return;
    }
    
    GLCalendarDate *date = [self dateAtLocation:location];

    if ([date isTheSameDayAsDate: self.rangeUnderEdit.endDate]) {
        return;
    }
    if ([date.date compare:self.rangeUnderEdit.beginDate] == NSOrderedAscending) {
        return;
    }
    
    BOOL canUpdate = [self.delegate calenderView:self canUpdateRange:self.rangeUnderEdit toBeginDate:self.rangeUnderEdit.beginDate endDate:date.date];
    
    if (canUpdate) {
        NSDate *originalEndDate = [self.rangeUnderEdit.endDate copy];
        self.rangeUnderEdit.endDate = date.date;
        if ([originalEndDate compare:date.date] == NSOrderedAscending) {
            [self reloadFromBeginDate:originalEndDate toDate:date.date];
        } else {
            [self reloadFromBeginDate:date.date toDate:originalEndDate];
        }
        [self.delegate calenderView:self didUpdateRange:self.rangeUnderEdit toBeginDate:self.rangeUnderEdit.beginDate endDate:date.date];
    }
}

- (IBAction)backToTodayButtonPressed:(id)sender
{
    [self scrollToDate:self.today animated:YES];
}

# pragma mark - cell styling

- (void) configureCellAppearance: (GLCalendarDayCell*) cell
{
    cell.evenMonthBackgroundColor = self.cellEvenMonthBackgroundColor;
    cell.oddMonthBackgroundColor = self.cellOddMonthBackgroundColor;
    cell.gridNormalColor = self.cellGridNormalColor;
    cell.gridSeparatorColor = self.cellGridSeparatorColor;
    cell.dayLabelAttributes = self.cellDayLabelAttributes;
    cell.monthLabelAttributes = self.cellMonthLabelAttributes;
    cell.todayLabelAttributes = self.cellTodayLabelAttributes;
    cell.todayMonthAttributes = self.cellTodayMonthAttributes;
    cell.dayDisabledLabelAttributes = self.cellDayDisabledLabelAttributes;
    cell.todayBackgroundColor = self.cellTodayBackgroundColor;
    cell.editCoverPadding = self.cellEditCoverPadding;
    cell.editCoverBorderWidth = self.cellEditCoverBorderWidth;
    cell.editCoverBorderColor = self.cellEditCoverBorderColor;
    cell.editCoverPointScale = self.cellEditCoverPointScale;
    cell.editCoverPointSize = self.cellEditCoverPointSize;
    cell.dayDisabledMonthAttributes = self.cellDayDisabledMonthAttributes;
}

# pragma mark - helper

static NSDate *today;

- (GLCalendarDate *)dateAtLocation:(CGPoint)location
{
    return [self dateForCellAtIndexPath:[self indexPathAtLocation:location]];
}

- (NSIndexPath *)indexPathAtLocation:(CGPoint)location
{
    NSInteger row = location.y / self.cellWidth;
    CGFloat col = (location.x - self.padding) / self.cellWidth;
    NSInteger item = row * 7 + floorf(col);
    return [NSIndexPath indexPathForItem:item inSection:0];
}

- (CGRect)rectForDate:(NSDate *)date
{
    NSInteger dayDiff = [GLDateUtils daysBetween:self.firstDate and:date];
    NSInteger row = dayDiff / 7;
    NSInteger col = dayDiff % 7;
    return CGRectMake(self.padding + col * self.cellWidth, row * self.cellWidth, self.cellWidth, self.cellWidth);
}


- (void)reloadCellOnDate:(NSDate *)date
{
    [self reloadFromBeginDate:date toDate:date];
}

- (void)reloadFromBeginDate:(NSDate *)beginDate toDate:(NSDate *)endDate
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSInteger beginIndex = MAX(0, [GLDateUtils daysBetween:self.firstDate and:beginDate]);
    NSInteger endIndex = MIN([self collectionView:self.collectionView numberOfItemsInSection:0] - 1, [GLDateUtils daysBetween:self.firstDate and:endDate]);
    for (NSInteger i = beginIndex; i <= endIndex; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    }];
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date
{
    return [NSIndexPath indexPathForItem:[GLDateUtils daysBetween:self.firstDate and:date] inSection:0];
}
@end