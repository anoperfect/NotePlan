//
//  TaskCellTableViewCell.h
//  NoteTask
//
//  Created by Ben on 16/10/18.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskModel.h"
#import "TaskInfoManager.h"
@interface TaskCell : UITableViewCell


- (void)setTaskInfo:(TaskInfo*)taskinfo finishedAts:(NSArray<TaskFinishAt*>*)finishedAts; //arrange mode使用此接口赋值.


@end


@interface TaskCellActionMenu : UIView

@end


@interface TaskDetailContentCell : UITableViewCell
@property (nonatomic, strong) TaskInfo *taskinfo;
@property (nonatomic, strong) void(^actionOn)(NSString*);
@end


@interface TaskDetailPropertyCell : UITableViewCell
- (void)setTitle:(NSAttributedString*)titleAttributedString content:(NSAttributedString*)contentAttributedString;
@end

@interface TaskRecordCell : UITableViewCell
@property (nonatomic, strong) TaskRecord *taskRecord;
@end






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





@interface TaskCalendar : UIView





@property (nonatomic, assign) BOOL mutilMode;
@property (nonatomic, strong, readonly) NSString *dayString;
@property (nonatomic, strong, readonly) NSArray<NSString*> *dayStrings;

@end
