//
//  TaskModel.h
//  NoteTask
//
//  Created by Ben on 16/10/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskModel : NSObject




@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *step;
@property (nonatomic, strong) NSString *dateStart;
@property (nonatomic, strong) NSString *dateFinish;
@property (nonatomic, assign) NSInteger status; //0.not finish. 1.finish.

//day时间点.         day时间段.              days时间段.    day.                     days.
//repeat.           repeat.                              repeat.
//workday repeat.   workday repeat.                      workday repeat.

@end


#if 0

类型: //1.单天定点. 2.多天定点. 3.时间段. 4.多天时间段. 5.开始时间-结束时间. 6.开始如期－结束日期.

type:
day:[]
duration:[]
fromtime:
totime:
time:





id,
type,
title,
content,
subtasks:[["","",""],["","",""]]
{
    data: "",
    fromtime:"",
    totime:"",
    status:"",
    note:["system:", "user:", "usernote:"]
},


//存储.
//按日期执行显示.

subtask
{
title:
submmitAt:
}


#endif





@interface TaskListModel : NSObject

@property (nonatomic, strong) NSString                      *detail;
@property (nonatomic, strong) NSMutableArray<TaskModel*>    *tasklist;


@end




















@interface TaskInfo : NSObject

@property (nonatomic, strong) NSString          *sn;
@property (nonatomic, strong) NSString          *content;
@property (nonatomic, assign) NSInteger          status;
@property (nonatomic, strong) NSString          *committedAt;
@property (nonatomic, strong) NSString          *modifiedAt;
@property (nonatomic, strong) NSString          *signedAt;
@property (nonatomic, strong) NSString          *finishedAt;

@property (nonatomic, assign) NSInteger          scheduleType;
@property (nonatomic, assign) BOOL               dayRepeat;
@property (nonatomic, strong) NSString          *daysStrings;

@property (nonatomic, strong) NSString          *time; //1.单天定点hh:mm. 2.day repeat 定点. hh:mm 3.单天时间段.hh:mm-hh:mm. 4.day repeat 时间段.hh:mm-hh:mm
@property (nonatomic, strong) NSString          *period; //5.日期段. yyyy.mm.dd-yyyy.mm.dd. 6.时间段. yyyy.mm.dd hh:mm-yyyy.mm.dd hh:mm

@property (nonatomic, strong) NSMutableArray<NSString*> *daysOnTask; //从daysStrings或period中解析出来的.
@property (nonatomic, strong) NSMutableArray<NSString*> *daysFinish;


+ (instancetype)taskinfoFromDictionary:(NSDictionary*)dict;
+ (NSMutableDictionary<NSString*,NSMutableArray*>*)taskinfosGroupByDay:(NSArray<TaskInfo*>*)taskinfos;

@end





@interface TaskRecord : NSObject

@property (nonatomic, strong) NSString *sn;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *record;
@property (nonatomic, strong) NSString *committedAt;
@property (nonatomic, strong) NSString *modifiedAt;


@end


@interface TaskDayList : NSObject

@property (nonatomic, strong) NSString                      *dayName;
@property (nonatomic, strong) NSString                      *dayString;
@property (nonatomic, strong) NSMutableArray<TaskInfo*>      *taskinfos;


+(instancetype)taskDayListWithDayName:(NSString*)dayName andDayString:(NSString*)dayString;

@end



@interface TaskGroup : NSObject

@property (nonatomic, strong) NSArray<TaskInfo*>* taskinfos;

@property (nonatomic, strong, readonly) NSString *dateStringToday;
@property (nonatomic, strong, readonly) NSString *dateStringTomorrow;

@property (nonatomic, strong, readonly) TaskDayList *taskDayListBefore;
@property (nonatomic, strong, readonly) TaskDayList *taskDayListToday;
@property (nonatomic, strong, readonly) TaskDayList *taskDayListTomorrow;
@property (nonatomic, strong, readonly) TaskDayList *taskDayListComming;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString*,NSMutableArray*>* taskinfosSortedByDay; //将任务按照day分类.

- (NSString*)dayNameOnSection:(NSInteger)section;
- (TaskDayList*)taskDayListOnSection:(NSInteger)section;

@end



