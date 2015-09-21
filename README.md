## Clone of [GLCalendarView](https://github.com/Glow-Inc/GLCalendarView)

###The clone is designated for the following points:
* date picker (select one date)
* ranges used only to customize look of calendar, no range selection by user
* performace (it works well on iPhone4 & (surprise) up!)
* look - it looks better
* load time - as a consequence of performance it appears much much faster
* customizeability (almost everything now is customizable)

## Installation
This repo is in progress now, have to add it to cocoapods at some point.
if you want to try my version, you have to add the line below:
```
pod "GLCalendarView-Custom", :git => "https://github.com/gelosi/GLCalendarView.git", :tag => 'v1.3.21.square'
```

## Source File
You can copy all the files under the `Sources` folder into your project.

## Usage
* Init the view by placing it in the storyboard or programmatically init it and add it to your view controller.
* In `viewDidLoad`, set the `calendarDisplayRange` (GLCalendarDateRange) of the calendarView, setting this property will refresh calendar

To display some ranges in the calendar view, construct some `GLCalendarDateRange` objects, set them as the model of the calendar view. Mostly designed to display one date, but you can have some fun with it (legacy, thinking on improvement...)
calling `addRange:` will reload calendar, if you want to add several ranges at once use `addRange:reload:`
```objective-c
NSDate *today = [NSDate date];
NSDate *beginDate = [GLDateUtils dateByAddingDays:-23 toDate:today];
NSDate *endDate = [GLDateUtils dateByAddingDays:-18 toDate:today];
GLCalendarDateRange *range = [GLCalendarDateRange rangeWithBeginDate:beginDate endDate:endDate];
range.backgroundColor = [UIColor blueColor];
range.editable = YES;
range.binding = yourModelObject // you can bind your model to the range

[self.calendar addRange: range];
```

For the binding field, it helps in that you can bind the actual model to the range, thus you can easily retrieve the corresponding model from the range later. For example, if you are building a trip app, you probably has a Trip class, you can bind the Trip instance to the range, and if the range gets updated in the calendar view, you can easily get the Trip instance from it and do some further updates.

The calendar view will handle all the user interactions including adding, updating, or deleting a range, you just need to implement the delegate protocol to listen for those events:
```objective-c
@protocol GLCalendarViewDelegate <NSObject>
- (BOOL)calenderView:(GLCalendarView *)calendarView canAddRangeWithBeginDate:(NSDate *)beginDate;
- (GLCalendarDateRange *)calenderView:(GLCalendarView *)calendarView rangeToAddWithBeginDate:(NSDate *)beginDate;
@optional
- (NSArray*) calendarViewWeekDayTitles;
- (void)calenderView:(GLCalendarView *)calendarView beginToEditRange:(GLCalendarDateRange *)range;
- (void)calenderView:(GLCalendarView *)calendarView finishEditRange:(GLCalendarDateRange *)range continueEditing:(BOOL)continueEditing;
- (BOOL)calenderView:(GLCalendarView *)calendarView canUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate;
- (void)calenderView:(GLCalendarView *)calendarView didUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate;
@end
```

Sample implementation:
```objective-c
- (BOOL)calenderView:(GLCalendarView *)calendarView canAddRangeWithBeginDate:(NSDate *)beginDate
{
    // you should check whether user can add a range with the given begin date
    return YES;
}

- (GLCalendarDateRange *)calenderView:(GLCalendarView *)calendarView rangeToAddWithBeginDate:(NSDate *)beginDate
{
    // construct a new range object and return it
    NSDate* endDate = [GLDateUtils dateByAddingDays:2 toDate:beginDate];
    GLCalendarDateRange *range = [GLCalendarDateRange rangeWithBeginDate:beginDate endDate:endDate];
    range.backgroundColor = [UIColor redColor];
    range.editable = YES;
    range.binding = yourModel; // bind your model to the range instance
    return range;
}

- (void)calenderView:(GLCalendarView *)calendarView beginToEditRange:(GLCalendarDateRange *)range
{
    // save the range to a instance variable so that you can make some operation on it
    self.rangeUnderEdit = range;
}

- (void)calenderView:(GLCalendarView *)calendarView finishEditRange:(GLCalendarDateRange *)range continueEditing:(BOOL)continueEditing
{
    // retrieve the model from the range, do some updates to your model
    id yourModel = range.binding;
    self.rangeUnderEdit = nil;
}

- (BOOL)calenderView:(GLCalendarView *)calendarView canUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    // you should check whether the beginDate or the endDate is valid
    return YES;
}

- (void)calenderView:(GLCalendarView *)calendarView didUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    // update your model if necessary
    id yourModel = range.binding;
}

```

## Appearance
`GLCalendarView` 's appearance is mostly customizable, you can adjust its look through the appearance api(generally your should config it in the AppDelegate), check the header file to see all customizable fields:
```objective-c
[GLCalendarView appearance].cellSide = CGRectGetWidth([UIScreen mainScreen].bounds)/7;
    [GLCalendarView appearance].padding = 0;

    [GLCalendarView appearance].weekDayTitleAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:10], NSForegroundColorAttributeName:[UIColor grayColor]};
    [GLCalendarView appearance].monthCoverAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:24],
                                                         NSForegroundColorAttributeName:[UIColor grayColor]};
    [GLCalendarView appearance].monthCoverYearAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:24],
                                                         NSForegroundColorAttributeName:[UIColor grayColor]};
    [GLCalendarView appearance].monthCoverBackgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];

    [GLCalendarView appearance].monthCoverYearFormat = @"''yy";
```

You can clone the project and investigate the demo for more detailed usage~