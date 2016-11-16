//
//  TaskGroup.m
//  NoteTask
//
//  Created by Ben on 16/11/1.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskInfoManager.h"
#import "TaskRecord.h"





@interface TaskDay ()
@end

@implementation TaskDay
@end


@interface TaskDayList ()
@end

@implementation TaskDayList

+ (instancetype)taskDayListWithDayName:(NSString*)dayName andDayString:(NSString*)dayString
{
    TaskDayList *taskDayList = [[TaskDayList alloc] init];
    taskDayList.dayName = dayName;
    taskDayList.dayString = dayString;
    taskDayList.taskDays = [[NSMutableArray alloc] init];
    
    return taskDayList;
}


- (void)addTaskDays:(NSArray<TaskDay*>*)taskDays
{
    for(TaskDay *taskDay in taskDays) {
        BOOL existed = NO;
        for(TaskDay *taskDayAdded in self.taskDays) {
            if([taskDayAdded.taskinfo.sn isEqualToString:taskDay.taskinfo.sn]) {
                existed = YES;
                break;
            }
        }
        
        if(!existed) {
            [self.taskDays addObject:taskDay];
        }
    }
}


- (NSString*)description
{
    NSMutableString *s = [[NSMutableString alloc] init];
    [s appendFormat:@"addr:%p, \"%@\", \"%@\" [%zd]\n", self, self.dayName, self.dayString, self.taskDays.count];
    for(TaskDay *taskDay in self.taskDays) {
        [s appendFormat:@"---%@[%zd]:%@\n", taskDay.taskinfo.sn, taskDay.finishedAt?taskDay.finishedAt:@"", taskDay.taskinfo.content];
    }
    
    return [NSString stringWithString:s];
}

@end





@interface TaskInfoManager ()

@property (nonatomic, strong) NSString *dateStringToday;
@property (nonatomic, strong) NSString *dateStringTomorrow;

@property (nonatomic, strong) TaskDayList *taskDayListBefore;
@property (nonatomic, strong) TaskDayList *taskDayListToday;
@property (nonatomic, strong) TaskDayList *taskDayListTomorrow;
@property (nonatomic, strong) TaskDayList *taskDayListComming;
@property (nonatomic, strong) NSMutableArray<TaskDayList *> *taskDayListAtArrangeMode;

@property (nonatomic, strong) NSMutableDictionary<NSString*,NSMutableArray<TaskDay*>*>* taskinfosSortedByDay;
@property (nonatomic, strong) NSMutableArray<NSString*> *daysOnTask;

@end


@implementation TaskInfoManager



+ (TaskInfoManager*)taskInfoManager
{
    static dispatch_once_t once;
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}


- (void)reloadTaskInfos
{
    self.dateStringToday = [NSString dayStringToday];
    self.dateStringTomorrow = [NSString dayStringTomorrow];
    
    //从数据库中读取所有taskinfo.
    self.taskinfos = [[AppConfig sharedAppConfig] configTaskInfoGets];
    
    //按需执行的日期排列.
    [self countDayMode];
    
    //排列显示执行模式需要的列表信息.
    [self countArrangeMode];
}


- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    
    return self;
}


- (void)countDayMode
{
    self.taskinfosSortedByDay = [[NSMutableDictionary alloc] init];
    
    for(TaskInfo *taskinfo in self.taskinfos) {
        for(NSString *dayString in taskinfo.daysOnTask) {
            NSMutableArray *taskinfosIn1Day = self.taskinfosSortedByDay[dayString];
            if(!taskinfosIn1Day) {
                taskinfosIn1Day = [[NSMutableArray alloc] init];
                self.taskinfosSortedByDay[dayString] = taskinfosIn1Day;
            }
            
            TaskDay *taskDay = [[TaskDay alloc] init];
            taskDay.taskinfo = taskinfo;
            taskDay.dayString = dayString;
            taskDay.finishedAt = [[TaskRecordManager taskRecordManager] taskRecordQuery:taskinfo.sn finishedAtOnDay:dayString];
            
            [taskinfosIn1Day addObject:taskDay];
        }
    }
    
    for(NSString *day in self.taskinfosSortedByDay.allKeys) {
        NSLog(@"%@ : \n", day);
        for(TaskDay *taskDay in self.taskinfosSortedByDay[day]) {
            NSLog(@"\t%@", taskDay.taskinfo.sn);
        }
    }
}


- (void)countArrangeMode
{
    NSMutableArray<NSString*> *days = [NSMutableArray arrayWithArray:self.taskinfosSortedByDay.allKeys];
    [days sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *day1 = obj1;
        NSString *day2 = obj2;
        
        return [day1 compare:day2];
    }];
    self.daysOnTask = days;
    
    
    self.taskDayListBefore = [TaskDayList taskDayListWithDayName:@"之前" andDayString:@""];
    self.taskDayListToday = [TaskDayList taskDayListWithDayName:@"今天" andDayString:self.dateStringToday];
    self.taskDayListTomorrow = [TaskDayList taskDayListWithDayName:@"明天" andDayString:self.dateStringTomorrow];
    self.taskDayListComming = [TaskDayList taskDayListWithDayName:@"之后" andDayString:@""];
    
    for(NSString *day in days) {
        NSMutableArray<TaskDay*> *taskDays = self.taskinfosSortedByDay[day];
        
        NS0Log(@"day:[%@], today:[%@], tomorrow:[%@]", day, self.dateStringToday, self.dateStringTomorrow);
        
        if([day compare:self.dateStringToday] == NSOrderedSame) {
            [self.taskDayListToday addTaskDays:taskDays];
        }
        else if([day compare:self.dateStringTomorrow] == NSOrderedSame) {
            [self.taskDayListTomorrow addTaskDays:taskDays];
        }
        else if([day compare:self.dateStringToday] == NSOrderedAscending) {
            [self.taskDayListBefore addTaskDays:taskDays];
        }
        else {
            [self.taskDayListComming addTaskDays:taskDays];
        }
    }
    
    self.taskDayListAtArrangeMode = [@[self.taskDayListBefore, self.taskDayListToday, self.taskDayListTomorrow, self.taskDayListComming] mutableCopy];
}


- (NSString*)description
{
    NSMutableString *s = [[NSMutableString alloc] init];
    [s appendFormat:@"\n%@\n", self.taskDayListBefore];
    [s appendFormat:@"%@\n", self.taskDayListToday];
    [s appendFormat:@"%@\n", self.taskDayListTomorrow];
    [s appendFormat:@"%@\n", self.taskDayListComming];
    
    return [NSString stringWithString:s];
}



@end


