//
//  TaskDaySelectViewController.h
//  NoteTask
//
//  Created by Ben on 16/11/7.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "CustomViewController.h"

@interface TaskDaySelectViewController : CustomViewController

@end



#if 0
static NSString *kStringSelectorDay = @"单天";
static NSString *kStringSelectorDays = @"多天";
static NSString *kStringSelectorContinuous = @"连续";
static NSString *kStringSelectorRepeat = @"重复";


@interface TaskDaySelector : UIView

@property (nonatomic, strong, readonly) NSString *daysType;
@property (nonatomic, strong, readonly) NSString *dayString;
@property (nonatomic, strong, readonly) NSArray<NSString*> *mutilDays;
@property (nonatomic, strong, readonly) NSString *dayStringFrom;
@property (nonatomic, strong, readonly) NSString *dayStringTo;

@property (nonatomic, assign) CGFloat optumizeHeight;

@end
#endif
























@interface TaskCalendar : UIView





@property (nonatomic, strong, readonly) NSString *dayString;
@property (nonatomic, strong, readonly) NSArray<NSString*> *dayStrings;

- (instancetype)initWithFrame:(CGRect)frame andDayString:(NSString*)dayString;
- (instancetype)initWithFrame:(CGRect)frame andDayStrings:(NSArray<NSString*>*)dayStrings;

@end