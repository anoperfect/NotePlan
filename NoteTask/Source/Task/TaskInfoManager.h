//
//  TaskGroup.h
//  NoteTask
//
//  Created by Ben on 16/11/1.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskModel.h"





@interface TaskDay : NSObject

@property (nonatomic, strong) NSString          *dayString;
@property (nonatomic, assign) NSString          *finishedAt;
@property (nonatomic, strong) TaskInfo          *taskinfo;


@end


@interface TaskDayList : NSObject

@property (nonatomic, strong) NSString                      *dayName;
@property (nonatomic, strong) NSString                      *dayString;
@property (nonatomic, strong) NSMutableArray<TaskDay*>      *taskDays;


+ (instancetype)taskDayListWithDayName:(NSString*)dayName andDayString:(NSString*)dayString;

@end



@interface TaskInfoManager : NSObject

@property (nonatomic, strong) NSArray<TaskInfo*>* taskinfos; //从本地数据库中读取的全部task.
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString*,NSMutableArray<TaskDay*>*>* taskinfosSortedByDay; //将任务按照day分类.

@property (nonatomic, strong, readonly) NSString *dateStringToday;
@property (nonatomic, strong, readonly) NSString *dateStringTomorrow;

@property (nonatomic, strong, readonly) TaskDayList *taskDayListBefore;
@property (nonatomic, strong, readonly) TaskDayList *taskDayListToday;
@property (nonatomic, strong, readonly) TaskDayList *taskDayListTomorrow;
@property (nonatomic, strong, readonly) TaskDayList *taskDayListComming;


+ (TaskInfoManager*)taskInfoManager;
- (void)reloadTaskInfos;

- (NSString*)dayNameOnSection:(NSInteger)section;
- (TaskDayList*)taskDayListOnSection:(NSInteger)section;

@end
