//
//  TaskModel.h
//  NoteTask
//
//  Created by Ben on 16/10/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>



//day时间点.         day时间段.              days时间段.    day.                     days.
//repeat.           repeat.                              repeat.
//workday repeat.   workday repeat.                      workday repeat.


#if 0

类型: //1.单天定点. 2.多天定点. 3.时间段. 4.多天时间段. 5.开始时间-结束时间. 6.开始如期－结束日期.

type:
day:[]
duration:[]
fromtime:
totime:
time:
#endif
































typedef NS_ENUM(NSInteger, TaskInfoScheduleType) {
    TaskInfoScheduleTypeNone = 0,
    TaskInfoScheduleTypeDay,
    TaskInfoScheduleTypeContinues,
    TaskInfoScheduleTypeDays,
    TaskInfoScheduleTypeRepeat,
};




@interface TaskInfo : NSObject

@property (nonatomic, strong) NSString          *sn;
@property (nonatomic, strong) NSString          *content;
@property (nonatomic, assign) NSInteger          status;
@property (nonatomic, strong) NSString          *committedAt;
@property (nonatomic, strong) NSString          *modifiedAt;
@property (nonatomic, strong) NSString          *signedAt;
@property (nonatomic, strong) NSString          *finishedAt; //全部day的完成后, 赋值此值. 发生redo后, 需清除此值. 可强行标记任务全部完成.

@property (nonatomic, assign) NSInteger         scheduleType;
@property (nonatomic, strong) NSString          *dayString; //单天模式.
@property (nonatomic, strong) NSString          *dayStringFrom;//连续模式开始日期.
@property (nonatomic, strong) NSString          *dayStringTo;//连续模式结束日期.
@property (nonatomic, strong) NSString          *dayStrings;//多天模式.

@property (nonatomic, strong) NSString          *weekdays;//重复模式星期几. Monday,
@property (nonatomic, strong) NSString          *yearday;//重复模式1年的一天. MM-DD
@property (nonatomic, strong) NSString          *monthday;//重复模式一个月的几日. 01,02

@property (nonatomic, assign) BOOL               dayRepeat; //每天都重复执行此任务.
@property (nonatomic, strong) NSString          *time; //1.单天定点hh:mm. 2.day repeat 定点. hh:mm 3.单天时间段.hh:mm-hh:mm. 4.day repeat 时间段.hh:mm-hh:mm

@property (nonatomic, strong) NSMutableArray<NSString*> *daysOnTask; //从daysStrings中解析出.


+ (instancetype)taskinfo;
+ (instancetype)taskinfoFromDictionary:(NSDictionary*)dict;
- (NSDictionary*)toDictionary;

- (void)copyFrom:(TaskInfo*)taskinfo;
- (NSString*)updateFrom:(TaskInfo*)taskinfo;

- (NSString*)summaryDescription;

+ (NSString*)dateTimeStringForDisplay:(NSString*)at;

- (void)generateDaysOnTask;

+ (NSArray<NSString*>*)scheduleStrings;
+ (NSString*)scheduleStringWithType:(NSInteger)type;
+ (NSInteger)scheduleTypeFromString:(NSString*)s;


@end





