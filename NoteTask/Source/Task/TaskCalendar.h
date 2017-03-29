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

@property (nonatomic, strong, readonly) UIButton *buttonOK;
@property (nonatomic, strong, readonly) UIButton *buttonDelete;

- (instancetype)initWithFrame:(CGRect)frame dayString:(NSString*)dayString;
- (instancetype)initWithFrame:(CGRect)frame dayStrings:(NSArray<NSString*>*)dayStrings;

@end

