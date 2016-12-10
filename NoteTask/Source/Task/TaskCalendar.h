//
//  TaskCalendar.h
//  NoteTask
//
//  Created by Ben on 16/11/7.
//  Copyright © 2016年 Ben. All rights reserved.
//


@interface TaskCalendar : UIView





@property (nonatomic, strong, readonly) NSString *dayString;
@property (nonatomic, strong, readonly) NSArray<NSString*> *dayStrings;

- (instancetype)initWithFrame:(CGRect)frame andDayString:(NSString*)dayString;
- (instancetype)initWithFrame:(CGRect)frame andDayStrings:(NSArray<NSString*>*)dayStrings;

@end