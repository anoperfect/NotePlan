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
        
        NSLog(@"day:[%@], today:[%@], tomorrow:[%@]", day, self.dateStringToday, self.dateStringTomorrow);
        
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
}


#if 0
+ (instancetype)fromTaskInfos:(NSArray<TaskInfo*>*)taskinfos
{
    TaskGroup *taskGroup = [[TaskGroup alloc] init];
    
    NSDate *date = [NSDate date];
    NSString *dateString = [NSString stringWithFormat:@"%@", date];
    dateString = [dateString substringToIndex:9];
    
    NSDate *dateTomorrow = [date dateByAddingTimeInterval:24*60*60];
    NSString *dateStringTomorrow = [NSString stringWithFormat:@"%@", dateTomorrow];
    dateStringTomorrow = [dateStringTomorrow substringToIndex:9];
    
    taskGroup.dateStringToday = dateString;
    taskGroup.dateStringTomorrow = dateStringTomorrow;
    
    TaskDayList *taskDayListBefore = [[TaskDayList alloc] init];
    taskDayListBefore.dayName = @"之前";
    taskDayListBefore.taskinfos = [[NSMutableArray alloc] init];
    
    TaskDayList *taskDayListToday = [[TaskDayList alloc] init];
    taskDayListToday.dayName = @"今天";
    taskDayListToday.taskinfos = [[NSMutableArray alloc] init];
    
    TaskDayList *taskDayListTomorrow = [[TaskDayList alloc] init];
    taskDayListTomorrow.dayName = @"明天";
    taskDayListTomorrow.taskinfos = [[NSMutableArray alloc] init];
    
    TaskDayList *taskDayListComming = [[TaskDayList alloc] init];
    taskDayListComming.dayName = @"之后";
    taskDayListComming.taskinfos = [[NSMutableArray alloc] init];
    
    for(TaskInfo *taskinfo in taskinfos) {
        NSMutableArray<NSNumber*> *days = [taskinfo daysDetect];
        if(NSNotFound != [days indexOfObject:@(DaysCompareBefore)]) {
            [taskDayListBefore.taskinfos addObject:taskinfo];
            days = nil;
            continue;
        }
        
        if(NSNotFound != [days indexOfObject:@(DaysCompareToday)]) {
            [taskDayListToday.taskinfos addObject:taskinfo];
            days = nil;
            continue;
        }
        
        if(NSNotFound != [days indexOfObject:@(DaysCompareTomorrow)]) {
            [taskDayListTomorrow.taskinfos addObject:taskinfo];
            days = nil;
            continue;
        }
        
        if(NSNotFound != [days indexOfObject:@(DaysCompareComming)]) {
            [taskDayListComming.taskinfos addObject:taskinfo];
            days = nil;
            continue;
        }
        
        NSLog(@"#error - should not excute to here.");
        days = nil;
    }
    
    taskGroup.taskDayListBefore     = taskDayListBefore;
    taskGroup.taskDayListToday      = taskDayListToday;
    taskGroup.taskDayListTomorrow   = taskDayListTomorrow;
    taskGroup.taskDayListComming    = taskDayListComming;
    
    return taskGroup;
}
#endif

- (NSString*)dayNameOnSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.taskDayListToday.dayName;
            break;
            
        case 1:
            return self.taskDayListTomorrow.dayName;
            break;
            
        case 2:
            return self.taskDayListComming.dayName;
            break;
            
        default:
            break;
    }
    
    return @"NAN";
    
}


- (TaskDayList*)taskDayListOnSection:(NSInteger)section;
{
    switch (section) {
        case 0:
            return self.taskDayListToday;
            break;
            
        case 1:
            return self.taskDayListTomorrow;
            break;
            
        case 2:
            return self.taskDayListComming;
            break;
            
        default:
            break;
    }
    
    return nil;
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


