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
    
    taskinfo.scheduleType = TaskInfoScheduleTypeNone;
    taskinfo.dayString = @""; //单天模式.
    taskinfo.dayStringFrom = @"";//连续模式开始日期.
    taskinfo.dayStringTo = @"";//连续模式结束日期.
    taskinfo.dayStrings = @"";//多天模式.
    
    taskinfo.dayRepeat = YES;
    taskinfo.time = @"";
    
    return taskinfo;
}



- (void)copyFrom:(TaskInfo*)taskinfo
{
    self.content        = taskinfo.content ;
    self.status         = taskinfo.status ;
    self.committedAt    = taskinfo.committedAt ;
    self.modifiedAt     = taskinfo.modifiedAt ;
    self.signedAt       = taskinfo.signedAt ;
    self.finishedAt     = taskinfo.finishedAt ;
    
    self.scheduleType   = taskinfo.scheduleType ;
    self.dayString      = taskinfo.dayString ;
    self.dayStringFrom  = taskinfo.dayStringFrom ;
    self.dayStringTo    = taskinfo.dayStringTo ;
    self.dayStrings     = taskinfo.dayStrings ;
    
    self.dayRepeat      = taskinfo.dayRepeat ;
    self.time           = taskinfo.time ;
    
    [self generateDaysOnTask];
}


- (NSString*)updateFrom:(TaskInfo*)taskinfo
{
    NSMutableString *s = [[NSMutableString alloc] init];
    if(![self.content isEqualToString:taskinfo.content]) {
        [s appendString:@"任务内容 "];
        self.content = taskinfo.content;
    }
    
    if(self.scheduleType != taskinfo.scheduleType) {
        [s appendString:@"执行日期 "];
        self.scheduleType = taskinfo.scheduleType;
        switch (self.scheduleType) {
            case TaskInfoScheduleTypeDay:
                self.dayString = taskinfo.dayString;
                break;
                
            case TaskInfoScheduleTypeContinues:
                self.dayStringFrom = taskinfo.dayStringFrom;
                self.dayStringTo = taskinfo.dayStringTo;
                break;
                
            case TaskInfoScheduleTypeDays:
                self.dayStrings = taskinfo.dayStrings;
                break;
                
            default:
                break;
        }
    }
    else {
        switch (self.scheduleType) {
            case TaskInfoScheduleTypeDay:
                if(![self.dayString isEqualToString:taskinfo.dayString]) {
                    [s appendString:@"任务执行日期[单天] "];
                    self.dayString = taskinfo.dayString;
                }
                break;
                
            case TaskInfoScheduleTypeContinues:
                if(![self.dayStringFrom isEqualToString:taskinfo.dayStringFrom]) {
                    [s appendString:@"任务开始日期 "];
                    self.dayStringFrom = taskinfo.dayStringFrom;
                }
                
                if(![self.dayStringTo isEqualToString:taskinfo.dayStringTo]) {
                    [s appendString:@"任务结束日期 "];
                    self.dayStringTo = taskinfo.dayStringTo;
                }
                
                break;
                
            case TaskInfoScheduleTypeDays:
                if(![self.dayStrings isEqualToString:taskinfo.dayStrings]) {
                    [s appendString:@"任务执行日期[多天] "];
                    self.dayStrings = taskinfo.dayStrings;
                }
                break;
                
            default:
                break;
        }
    }
    
    [self generateDaysOnTask];
    if(s.length > 0) {
        self.modifiedAt = taskinfo.modifiedAt;
    }
    return [NSString stringWithString:s];
}


/*返回比较的信息.
{
    detail : 文字描述.
    diffKeys: [修改的内容key, 只比较内容.]
    diffAllkeys : [ 修改的所有key];
}
*/
- (NSDictionary*)differentFrom:(TaskInfo*)taskinfo
{
    NSMutableDictionary *diffs      = [[NSMutableDictionary alloc] init];
    NSMutableString *s              = [[NSMutableString alloc] init];
    NSMutableArray *diffKeys        = [[NSMutableArray alloc] init];
    NSMutableArray *diffAllKeys     = [[NSMutableArray alloc] init];
    if(![self.content isEqualToString:taskinfo.content]) {
        [s appendString:@"任务内容 "];
        [diffKeys addObject:@"content"];
        [diffAllKeys addObject:@"content"];
    }
    
    if(self.scheduleType != taskinfo.scheduleType) {
        [s appendFormat:@"执行日期[%@修改为%@]",
         [TaskInfo scheduleStringWithType:taskinfo.scheduleType],
         [TaskInfo scheduleStringWithType:self.scheduleType]
         ];
        [diffKeys addObject:@"scheduleType"];
        [diffAllKeys addObject:@"scheduleType"];
    }
    else {
        switch (self.scheduleType) {
            case TaskInfoScheduleTypeDay:
                if(![self.dayString isEqualToString:taskinfo.dayString]) {
                    [s appendString:@"任务执行日期[单天] "];
                    [diffKeys addObject:@"dayString"];
                    [diffAllKeys addObject:@"dayString"];
                }
                break;
                
            case TaskInfoScheduleTypeContinues:
                if(![self.dayStringFrom isEqualToString:taskinfo.dayStringFrom]) {
                    [s appendString:@"任务开始日期 "];
                    [diffKeys addObject:@"dayStringFrom"];
                    [diffAllKeys addObject:@"dayStringFrom"];
                }
                
                if(![self.dayStringTo isEqualToString:taskinfo.dayStringTo]) {
                    [s appendString:@"任务结束日期 "];
                    [diffKeys addObject:@"dayStringTo"];
                    [diffAllKeys addObject:@"dayStringTo"];
                }
                
                break;
                
            case TaskInfoScheduleTypeDays:
                if(![self.dayStrings isEqualToString:taskinfo.dayStrings]) {
                    [s appendString:@"任务执行日期[多天] "];
                    [diffKeys addObject:@"dayStrings"];
                    [diffAllKeys addObject:@"dayStrings"];
                }
                break;
                
            default:
                break;
        }
    }
    
    if(s.length > 0) {
        diffs[@"detail"] = [NSString stringWithString:s];
    }
    
    if(diffKeys.count > 0) {
        diffs[@"diffKeys"] = [NSArray arrayWithArray:diffKeys];
    }
    
    if(diffAllKeys.count > 0) {
        diffs[@"diffAllKeys"] = [NSArray arrayWithArray:diffAllKeys];
    }
    
    if(diffs.count > 0) {
        diffs[@"sn"] = self.sn;
        return [NSDictionary dictionaryWithDictionary:diffs];
    }
    else {
        return nil;
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
    
    NSString *additional = nil;
    NSDate *dateNow = [NSDate date];
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


+ (NSString*)dateStringForDisplay:(NSString*)dateString
{
    NSString *dateStringDisplay = dateString;
    NSString *additional = nil;
    
    NSInteger compare = [NSString dateStringCountCompareToday:dateString];
    if(compare == 0) {
        additional = @"今天";
    }
    else if(compare == -1) {
        additional = @"昨天";
    }
    else if(compare == 1) {
        additional = @"明天";
    }
    
    if(additional.length > 0) {
        dateStringDisplay = [NSString stringWithFormat:@"%@(%@)", dateString, additional];
    }
    
    NS0Log(@"from [%@] to [%@].", at, dateTimeString);
    return dateStringDisplay;
}


- (NSMutableAttributedString*)scheduleDateAtrributedStringWithIndent:(CGFloat)indent andTextColor:(UIColor*)textColor
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    switch (self.scheduleType) {
        case TaskInfoScheduleTypeDay:
            attributedString = [NSString attributedStringWith:[TaskInfo dateStringForDisplay:self.dayString] font:FONT_SYSTEM indent:indent textColor:textColor];
            break;
            
        case TaskInfoScheduleTypeContinues:
            attributedString = [NSString attributedStringWith:[NSString stringWithFormat:@"从 %@ 到 %@", self.dayStringFrom, self.dayStringTo]
                                                         font:FONT_SYSTEM
                                                       indent:indent
                                                    textColor:textColor];
            break;
            
        case TaskInfoScheduleTypeDays:
            attributedString = [NSString attributedStringWith:[NSString stringWithFormat:@"多天 : %@", self.dayStrings] font:FONT_SYSTEM indent:indent textColor:textColor];
            break;
            
        default:
            break;
    }
    
    return attributedString;
}


- (NSString*)description
{
    NSMutableString *s = [[NSMutableString alloc] init];
    [s appendFormat:@"\n[task:%@ %p] \n", self.sn, self];
    [s appendFormat:@"\t\t\t%@ : %@\n", @"content", self.content];
    [s appendFormat:@"\t\t\t%@ : %zd\n", @"scheduleType", self.scheduleType];
    [s appendFormat:@"\t\t\t%@ : %@\n", @"scheduleType", [TaskInfo scheduleStringWithType:self.scheduleType]];
    
    [s appendFormat:@"\t\t\t%@ : %@\n", @"dayString", self.dayString];
    [s appendFormat:@"\t\t\t%@ : %@\n", @"dayStringFrom", self.dayStringFrom];
    [s appendFormat:@"\t\t\t%@ : %@\n", @"dayStringTo", self.dayStringTo];
    [s appendFormat:@"\t\t\t%@ : %@\n", @"dayStrings", self.dayStrings];

    [s appendFormat:@"\t\t\tdays: [%@]\n", [NSString arrayDescriptionConbine:self.daysOnTask seprator:@","]];
    return [NSString stringWithString:s];
}


- (void)generateDaysOnTask
{
    self.daysOnTask = [[NSMutableArray alloc] init];
    if(self.scheduleType == TaskInfoScheduleTypeDay) {
        [self.daysOnTask addObject:self.dayString];
    }
    else if(self.scheduleType == TaskInfoScheduleTypeContinues) {
        [self.daysOnTask addObjectsFromArray:[NSString dateFrom:self.dayStringFrom to:self.dayStringTo]];
    }
    else if(self.scheduleType == TaskInfoScheduleTypeDays) {
        NSArray *days = [self.dayStrings componentsSeparatedByString:@","];
        for(NSString *day in days) {
            if([NSString dateStringIsValid:day]) {
                [self.daysOnTask addObject:day];
            }
        }
    }
    
    NSLog(@"%@", self);
}


- (NSString*)summaryDescription
{
    NSMutableString *s = [[NSMutableString alloc] init];
    [s appendFormat:@"[task:%@] content:%@, days:[%@].", self.sn, self.content, [NSString arrayDescriptionConbine:self.daysOnTask seprator:@","]];
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
        return TaskInfoScheduleTypeNone;
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










