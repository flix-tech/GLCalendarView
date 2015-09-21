//
//  GLDateUtilsTests.m
//  GLCalendarView
//
//  Created by Oleg Shanyuk on 21/09/15.
//  Copyright © 2015 glow. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GLDateUtils.h"

@interface GLDateUtilsTests : XCTestCase

@end

@implementation GLDateUtilsTests


- (void)testFirstWeekDate {

    NSDateComponents *components = [[NSDateComponents alloc] init];

    /* Sunday, 20 Sep 2015 */
    components.day = 20;
    components.month = 9;
    components.year = 2015;

    NSDate *testDate = [[GLDateUtils calendar] dateFromComponents: components];

    /* should be Monday, 14 Sep 2015 OR Sunday 20 Sep 2015 */
    /* depending on Firs Week Day! */
    NSDate *firstWeek = [GLDateUtils weekFirstDate:testDate];

    NSInteger firstWeekDate = [[GLDateUtils calendar] component:NSCalendarUnitDay fromDate: firstWeek];

    const NSInteger Sunday = 1;
    const NSInteger Monday = 2;

    switch ([GLDateUtils calendar].firstWeekday) {
        case Sunday:
            XCTAssert(firstWeekDate == 20);
            break;
        case Monday:
            XCTAssert(firstWeekDate == 14);
            break;
    } ;
}



@end
