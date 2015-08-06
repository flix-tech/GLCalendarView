//
//  AppDelegate.m
//  GLCalendarView
//
//  Created by ltebean on 15-4-29.
//  Copyright (c) 2015 glow. All rights reserved.
//

#import "AppDelegate.h"
#import "GLCalendarView.h"
#import "GLCalendarDayCell.h"


#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [UINavigationBar appearance].barTintColor = UIColorFromRGB(0x79a9cd);
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    
    [GLCalendarView appearance].rowHeight = CGRectGetWidth([UIScreen mainScreen].bounds)/7;
    [GLCalendarView appearance].padding = 0;

    [GLCalendarView appearance].weekDayTitleAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:10], NSForegroundColorAttributeName:[UIColor grayColor]};
    [GLCalendarView appearance].monthCoverAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:24],
                                                         NSForegroundColorAttributeName:[UIColor grayColor]};
    [GLCalendarView appearance].monthCoverYearAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:24],
                                                         NSForegroundColorAttributeName:[UIColor grayColor]};

    [GLCalendarView appearance].cellEvenMonthBackgroundColor = [UIColor whiteColor];
    [GLCalendarView appearance].cellOddMonthBackgroundColor = [UIColor whiteColor];

    [GLCalendarView appearance].cellEditCoverPadding = 0;

//    [GLCalendarView appearance].rangeDisplayMode = RANGE_DISPLAY_MODE_SINGLE;

    [GLCalendarView appearance].cellDayLabelAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName:UIColorFromRGB(0x555555)};

    [GLCalendarView appearance].cellTodayLabelAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName:[UIColor grayColor]};

    [GLCalendarView appearance].cellTodayTitleAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:[UIColor grayColor]};

    [GLCalendarView appearance].cellDayDisabledLabelAttributes = @{
                                                                  NSFontAttributeName:[UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName:UIColorFromRGB(0xEEEEEE)
                                                                  };
    [GLCalendarView appearance].cellMonthLabelAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12],
                                                            NSForegroundColorAttributeName:[UIColor grayColor]};
    
    [GLCalendarView appearance].cellEditCoverBorderWidth = 0;
    [GLCalendarView appearance].cellEditCoverBorderColor = UIColorFromRGB(0x366aac);
    [GLCalendarView appearance].cellEditCoverPointSize = 14;

    [GLCalendarView appearance].cellGridNormalColor    = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    [GLCalendarView appearance].cellGridSeparatorColor = [UIColor lightGrayColor];
    
//    [GLCalendarDayCell appearance].todayBackgroundColor = nil;

    [GLCalendarView appearance].selectedDayTitleAttributes = @{
                                                               NSFontAttributeName:[UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName:UIColorFromRGB(0xFFFFFF)

                                                               };
    [GLCalendarView appearance].selectedMonthTitleAttributes = @{
                                                               NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSForegroundColorAttributeName:UIColorFromRGB(0xFFFFFF)

                                                               };

;

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
