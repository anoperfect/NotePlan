//
//  TaskModel.m
//  NoteTask
//
//  Created by Ben on 16/10/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskModel.h"












#define ARRAY_ADD_ONCE(arrayqwe,objrty)  if([(arrayqwe) indexOfObject:(objrty)] == NSNotFound) { [(arrayqwe) addObject:(objrty)];}







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
    taskinfo = [TaskInfo mj_objectWithKeyValues:dict];
    [taskinfo generateDaysOnTask];
    
    NSLog(@"%@", taskinfo);
    
    return taskinfo;
}


- (NSDictionary*)toDictionary
{
    NSDictionary *dict = [self mj_keyValuesWithIgnoredKeys:@[@"daysOnTask"]];
    return dict;
}


+ (instancetype)taskinfo
{
    TaskInfo *taskinfo = [[TaskInfo alloc] init];
    taskinfo.sn = @"";
    taskinfo.content = @"";
    taskinfo.status = 0;
    taskinfo.committedAt = @"";
    taskinfo.modifiedAt = @"";
    taskinfo.signedAt = @"";
    taskinfo.finishedAt = @""; //全部day的完成后, 赋值此值. 发生redo后, 需清除此值. 可强行标记任务全部完成.
    
    taskinfo.scheduleType = 0;
    taskinfo.dayString = @""; //单天模式.
    taskinfo.dayStringFrom = @"";//连续模式开始日期.
    taskinfo.dayStringTo = @"";//连续模式结束日期.
    taskinfo.dayStrings = @"";//多天模式.
    
    taskinfo.dayRepeat = YES;
    taskinfo.time = @"";
    
    return taskinfo;
}


- (void)daysStringsParseAndGetFinishedAt
{
    [self daysStringsParse];
    
}


//2016-10-24
//2016-10-18 - 2016-10-24
//2016-10-18 - 2016-10-24(workday)
- (void)daysStringsParse
{
    self.daysOnTask = [[NSMutableArray alloc] init];
    NSArray<NSString*> *days1strings = [self.dayStrings componentsSeparatedByString:@";"];
    for(NSString *day in days1strings) {
        if(day.length != 10) {
            
        }
        else {
            [self.daysOnTask addObject:day];
        }
    }
}


- (BOOL)isFinishOnDayString:(NSString*)dayString
{
    return NO;
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


+ (NSString*)dateTimeStringForDisplay:(NSString*)at
{
    NSString *dateTimeString;
    if(at.length > 19) {
        dateTimeString = [at substringToIndex:19];
        
    }
    else if(at.length == 19) {
        dateTimeString = at;
    }
    else {
        NSLog(@"#error - not valid length [%zd][%@].", at.length, at);
        return @"NAN";
    }
    
    NSDate *date = [NSString dateFromString:dateTimeString];
    if(!date) {
        NSLog(@"#error - not valid format [%@].", dateTimeString);
        return @"NAN";
    }
    
    NSDate *dateNow = [NSDate date];
    NSInteger dayNow = [dateNow timeIntervalSince1970];
    dayNow /= 86400;
    NSLog(@"dayNow : %zd ", dayNow);
    
    NSInteger day= [date timeIntervalSince1970];
    day/= 86400;
    NSLog(@"dayNow : %zd ", day);
    
    NSString *additional = nil;
    
    if([NSString date:date isSameDayOfDate:dateNow]) {
        NSInteger secsInteval = [dateNow timeIntervalSinceDate:date];
        if(secsInteval == 0) {
            additional = @"NOW";
        }
        else if(secsInteval > 0) {
            if(secsInteval >= 3600) {
                additional = [NSString stringWithFormat:@"%zd小时前", secsInteval/3600];
            }
            else if(secsInteval >= 60) {
                additional = [NSString stringWithFormat:@"%zd分钟前", secsInteval/60];
            }
            else {
                additional = [NSString stringWithFormat:@"%zd秒前", secsInteval];
            }
        }
        else if(secsInteval < 0) {
            secsInteval = -secsInteval;
            if(secsInteval >= 3600) {
                additional = [NSString stringWithFormat:@"%zd小时后", secsInteval/3600];
            }
            else if(secsInteval >= 60) {
                additional = [NSString stringWithFormat:@"%zd分钟后", secsInteval/60];
            }
            else {
                additional = [NSString stringWithFormat:@"%zd秒后", secsInteval];
            }
        }
    }
    else if([NSString date:date isYestodayOfDate:dateNow]) {
        additional = @"昨天";
    }
    else if([NSString date:date isTomorrowOfDate:dateNow]) {
        additional = @"明天";
    }
    
    if(additional.length > 0) {
        dateTimeString = [NSString stringWithFormat:@"%@(%@)", dateTimeString, additional];
    }
    
    NS0Log(@"from [%@] to [%@].", at, dateTimeString);
    return dateTimeString;
}


- (NSString*)description
{
    NSMutableString *s = [[NSMutableString alloc] init];
    [s appendFormat:@"[task:%@] \n", self.sn];
    [s appendFormat:@"\t\t\tcontent:%@", self.content];
    [s appendFormat:@"\t\t\tschedule type:%@", [TaskInfo scheduleStringWithType:self.scheduleType]];
    [s appendFormat:@"\t\t\tdays: [%@]", [NSString arrayDescriptionConbine:self.daysOnTask seprator:@","]];
    return [NSString stringWithString:s];
}


- (void)generateDaysOnTask
{
    self.daysOnTask = [[NSMutableArray alloc] init];
    [self.daysOnTask addObject:self.dayString];
}


- (NSString*)summaryDescription
{
    NSMutableString *s = [[NSMutableString alloc] init];
    [s appendFormat:@"[task:%@] content:%@, days:%@, finishedAt:%@", self.sn, self.content, self.dayStrings, self.finishedAt];
    if(s.length > 60) {
        [s replaceCharactersInRange:NSMakeRange(60, s.length-60) withString:@"..."];
    }
    return [NSString stringWithString:s];
}


+ (NSArray<NSString*>*)scheduleStrings
{
    return @[
    @"单天",
    @"连续",
    @"多天",
    ];
}


+ (NSString*)scheduleStringWithType:(NSInteger)type
{
    return [self scheduleTypeStringMap][@(type)];
}


+ (NSInteger)scheduleTypeFromString:(NSString*)s
{
    NSDictionary *dict = [self scheduleTypeStringMap];
    NSNumber *number = nil;
    for(NSNumber *key in dict.allKeys) {
        if([dict[key] isEqualToString:s]) {
            number = key;
            break;
        }
    }
    
    if([number isKindOfClass:[NSNumber class]]) {
        return [number integerValue];
    }
    else {
        return NSNotFound;
    }
}


+ (NSDictionary*)scheduleTypeStringMap
{
    return @{
             @(TaskInfoScheduleTypeDay) : @"单天",
             @(TaskInfoScheduleTypeContinues) : @"连续",
             @(TaskInfoScheduleTypeDays) : @"多天",
             @(TaskInfoScheduleTypeRepeat) : @"重复",
             };
}

@end










