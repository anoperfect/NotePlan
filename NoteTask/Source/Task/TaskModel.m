//
//  TaskModel.m
//  NoteTask
//
//  Created by Ben on 16/10/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskModel.h"

#define ARRAY_ADD_ONCE(arrayqwe,objrty)  if([(arrayqwe) indexOfObject:(objrty)] == NSNotFound) { [(arrayqwe) addObject:(objrty)];}




@implementation TaskModel

@end




@implementation TaskListModel


@end






typedef NS_ENUM(NSInteger, DaysCompare) {
    DaysCompareBefore = 20,
    DaysCompareToday ,
    DaysCompareTomorrow ,
    DaysCompareComming
};



@interface TaskInfo ()


@end

@implementation TaskInfo

+ (instancetype)taskinfoFromDictionary:(NSDictionary*)dict
{
    TaskInfo *taskinfo = [[TaskInfo alloc] init];
    taskinfo.content = [NSString stringWithFormat:@"%@", [NSDate date]];
    
    taskinfo.sn = dict[@"sn"];
    taskinfo.content = dict[@"content"];
    taskinfo.status = [dict[@"status"] integerValue];
    taskinfo.committedAt = dict[@"committedAt"];
    taskinfo.modifiedAt = dict[@"modifiedAt"];
    taskinfo.signedAt = dict[@"signedAt"];
    taskinfo.finishedAt = dict[@"finishedAt"];
    taskinfo.scheduleType = [dict[@"scheduleType"] integerValue];
    taskinfo.dayRepeat = [dict[@"dayRepeat"] integerValue];
    taskinfo.daysStrings = dict[@"daysStrings"];
    taskinfo.time = dict[@"time"];
    taskinfo.period = dict[@"period"];
    
    [taskinfo daysStringsParse];
    
    return taskinfo;
}



- (NSInteger)days1StringType:(NSString*)days1String
{
    
    
    return 0;
}





//2016-10-24
//2016-10-18 - 2016-10-24
//2016-10-18 - 2016-10-24(workday)




//将以上的格式解析到单个的day的数组.
+ (NSArray<NSString*>*)days1StringToDays:(NSString*)days1String
{
    return nil;
    
    
    
    
    
    
}





- (void)daysStringsParse
{
    self.daysOnTask = [[NSMutableArray alloc] init];
    NSArray<NSString*> *days1strings = [self.daysStrings componentsSeparatedByString:@";"];
    [self.daysOnTask addObjectsFromArray:days1strings];
#if 0
    
    NSString *days1string;
    
    switch (self.scheduleType) {
        case 1:
        days1string = days1strings[0];
        [self.days addObject:days1string];
        break;
            
        default:
            break;
    }
#endif
}


+ (DaysCompare)toCompare:(NSString*)day1String
{
    DaysCompare daysCompare;
    
    NSDate *date = [NSDate date];
    NSString *dateString = [NSString stringWithFormat:@"%@", date];
    dateString = [dateString substringToIndex:9];
    
    NSDate *dateTomorrow = [date dateByAddingTimeInterval:24*60*60];
    NSString *dateStringTomorrow = [NSString stringWithFormat:@"%@", dateTomorrow];
    dateStringTomorrow = [dateStringTomorrow substringToIndex:9];
    
    NSComparisonResult result = [day1String compare:dateString];
    NSComparisonResult resultTomorrow = [day1String compare:dateStringTomorrow];
    if(NSOrderedAscending == result) {
        daysCompare = DaysCompareBefore;
    }
    else if(NSOrderedSame == result) {
        daysCompare = DaysCompareToday;
    }
    else if(NSOrderedSame == resultTomorrow) {
        daysCompare = DaysCompareTomorrow;
    }
    else {
        daysCompare = DaysCompareComming;
    }
    
    return daysCompare;
}


- (NSMutableArray<NSNumber*>*)daysDetect
{
    NSMutableArray<NSNumber*> *daysCompareResult = [[NSMutableArray alloc] init];
    DaysCompare daysCompare;
    
    for(NSString *day1 in self.daysOnTask) {
        daysCompare = [TaskInfo toCompare:day1];
        if(NSNotFound == [daysCompareResult indexOfObject:@(daysCompare)]) {
            [daysCompareResult addObject:@(daysCompare)];
        }
    }
    
    return daysCompareResult;
}


- (BOOL)isFinishOnDayString:(NSString*)dayString
{
    return NSNotFound != [self.daysFinish indexOfObject:dayString];
}




+ (NSMutableDictionary<NSString*,NSMutableArray*>*)taskinfosGroupByDay:(NSArray<TaskInfo*>*)taskinfos
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    for(TaskInfo *taskinfo in taskinfos) {
        for(NSString *dayString in taskinfo.daysOnTask) {
            NSMutableArray *taskinfosIn1Day = result[dayString];
            if(taskinfosIn1Day) {
                [taskinfosIn1Day addObject:taskinfo];
            }
            else {
                result[dayString] = [NSMutableArray arrayWithObject:taskinfo];
            }
        }
    }
    
    return result;
}


+ (void)addTaskInfosUniqued:(NSMutableArray*)taskinfos toArray:(NSMutableArray*)array
{
    for(TaskInfo *taskinfo in taskinfos) {
        ARRAY_ADD_ONCE(array, taskinfo);
    }
}

+ (void)sortTaskInfos:(NSMutableArray<TaskInfo*>*)taskinfos onDay:(NSString*)day
{
    [taskinfos sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        TaskInfo *taskinfo1 = obj1;
        TaskInfo *taskinfo2 = obj2;
        if(day) {
            BOOL finish1 = [taskinfo1 isFinishOnDayString:day];
            BOOL finish2 = [taskinfo2 isFinishOnDayString:day];
            if(!finish1 && finish2) {
                return NSOrderedAscending;
            }
            else if(finish1 && !finish2) {
                return NSOrderedDescending;
            }
            else {
                return [taskinfo1.committedAt compare:taskinfo2.committedAt];
            }
        }
        else {
            return [taskinfo1.committedAt compare:taskinfo2.committedAt];
            
        }
        
        return NSOrderedAscending;
    }];
}


@end







@interface TaskRecord ()



@end


@implementation TaskRecord

@end


@interface TaskDayList ()



@end

@implementation TaskDayList

+(instancetype)taskDayListWithDayName:(NSString*)dayName andDayString:(NSString*)dayString
{
    TaskDayList *taskDayList = [[TaskDayList alloc] init];
    taskDayList.dayName = dayName;
    taskDayList.dayString = dayString;
    taskDayList.taskinfos = [[NSMutableArray alloc] init];
    
    return taskDayList;
}

@end





@interface TaskGroup ()

@property (nonatomic, strong) NSString *dateStringToday;
@property (nonatomic, strong) NSString *dateStringTomorrow;

@property (nonatomic, strong) TaskDayList *taskDayListBefore;
@property (nonatomic, strong) TaskDayList *taskDayListToday;
@property (nonatomic, strong) TaskDayList *taskDayListTomorrow;
@property (nonatomic, strong) TaskDayList *taskDayListComming;

@property (nonatomic, strong) NSMutableDictionary<NSString*,NSMutableArray*>* taskinfosSortedByDay;
@property (nonatomic, strong) NSMutableArray<NSString*> *daysOnTask;

@end


@implementation TaskGroup



- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dateStringToday = [NSString dayStringToday];
        self.dateStringTomorrow = [NSString dayStringTomorrow];
    }
    
    return self;
}


- (void)setTaskinfos:(NSArray<TaskInfo *> *)taskinfos
{
    _taskinfos = taskinfos;
    
    self.taskinfosSortedByDay = [TaskInfo taskinfosGroupByDay:taskinfos];
    
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
        NSMutableArray<TaskInfo*> *taskinfos = self.taskinfosSortedByDay[day];
        if([day compare:self.dateStringToday] == NSOrderedSame) {
            [TaskInfo addTaskInfosUniqued:taskinfos toArray:self.taskDayListToday.taskinfos];
        }
        else if([day compare:self.dateStringTomorrow] == NSOrderedSame) {
            [TaskInfo addTaskInfosUniqued:taskinfos toArray:self.taskDayListTomorrow.taskinfos];
        }
        else if([day compare:self.dateStringToday] == NSOrderedAscending) {
            [TaskInfo addTaskInfosUniqued:taskinfos toArray:self.taskDayListBefore.taskinfos];
        }
        else {
            [TaskInfo addTaskInfosUniqued:taskinfos toArray:self.taskDayListComming.taskinfos];
        }
    }
}


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



@end

