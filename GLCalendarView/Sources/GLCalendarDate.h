
//
//  GLCalendarDate.h
//  GLCalendarView
//
//  Created by Oleg Shanyuk on 04/08/15.
//  Copyright (c) 2015 glow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLCalendarDate : NSObject<NSCopying>
@property (nonatomic, strong, readonly) NSDate* date;
@property (nonatomic, strong, readonly) NSDate* cutDate;

@property (nonatomic, readonly) NSInteger day;
@property (nonatomic, readonly) NSInteger month;
@property (nonatomic, readonly) NSInteger year;
@property (nonatomic, readonly) NSInteger monthDays;

- (instancetype) initWithDate: (NSDate*) date NS_DESIGNATED_INITIALIZER;
- (BOOL) isTheSameDayAs: (GLCalendarDate*) otherDate;
- (BOOL) isTheSameDayAsDate: (NSDate*) otherDate;
@end
