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










