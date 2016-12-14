//
//  TaskInfoManager.m
//  NoteTask
//
//  Created by Ben on 16/11/1.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskInfoManager.h"
#import "TaskRecord.h"





@implementation TaskFinishAt

+ (instancetype)taskFinishAtFromDictionary:(NSDictionary*)dict
{
    TaskFinishAt *taskFinishAt = [[TaskFinishAt alloc] init];
    taskFinishAt = [TaskFinishAt mj_objectWithKeyValues:dict];
    return taskFinishAt;
}


+ (NSString*)checkAllFinishAts:(NSArray<TaskFinishAt*>*)finishAts
{
    NSString *dateTimeString = nil;
    
    for(TaskFinishAt *status in finishAts) {
        if(status.finishedAt.length == 0) {
            return nil;
        }
        
        if(!dateTimeString) {
            dateTimeString = status.finishedAt;
        }
        else if([dateTimeString compare:status.finishedAt] == NSOrderedAscending) {
            dateTimeString = status.finishedAt;
        }
    }
    
    return dateTimeString;
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ %@ [%@]", self.snTaskInfo, self.dayString, self.finishedAt];
}

@end



@implementation TaskInfoArrange


@end


@implementation TaskArrangeGroup

+ (instancetype)taskArrangeGroupWithName:(NSString*)name
{
    TaskArrangeGroup *group = [[TaskArrangeGroup alloc] init];
    group.arrangeName = name;
    group.taskInfoArranges = [[NSMutableArray alloc] init];
    
    return group;
}


- (void)addTaskInfo:(TaskInfo*)taskinfo onDays:(NSArray<NSString*>*)days
{
    TaskInfoArrange *add = nil;
    for(TaskInfoArrange *taskinfoArrange in self.taskInfoArranges) {
        if([taskinfo isEqual:taskinfoArrange.taskinfo]) {
            add = taskinfoArrange;
            break;
        }
    }
    
    if(!add) {
        add = [[TaskInfoArrange alloc] init];
        add.taskinfo = taskinfo;
        add.arrangeName = self.arrangeName;
        [self.taskInfoArranges addObject:add];
    }
    
    add.arrangeDays = [NSMutableArray arrayWithArray:days];
}

@end



@interface TaskInfoManager ()

@property (nonatomic, strong) NSString *dateStringToday;
@property (nonatomic, strong) NSString *dateStringTomorrow;

@property (nonatomic, strong) TaskArrangeGroup *taskArrangeGroupBefore;
@property (nonatomic, strong) TaskArrangeGroup *taskArrangeGroupToday;
@property (nonatomic, strong) TaskArrangeGroup *taskArrangeGroupTomorrow;
@property (nonatomic, strong) TaskArrangeGroup *taskArrangeGroupComming;


//@property (nonatomic, strong) NSMutableArray<NSString*> *daysOnTask;

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

- (void)log
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //NSLog(@"%@", self);
        //[self log];
    });
}


- (void)reloadTaskInfos
{
    //从数据库中读取所有taskinfo.
    self.taskinfos = [NSMutableArray arrayWithArray:[[AppConfig sharedAppConfig] configTaskInfoGets]];
}


- (void)reloadTaskFinishAts
{
    self.taskFinishAts = [NSMutableArray arrayWithArray:[[AppConfig sharedAppConfig] configTaskFinishAtGets]];
    self.taskFinishAtDictionary = [[NSMutableDictionary alloc] init];
    for(TaskFinishAt *taskFinishAt in self.taskFinishAts) {
        NSMutableArray<TaskFinishAt*> *snTaskFinishAts = self.taskFinishAtDictionary[taskFinishAt.snTaskInfo];
        if(!snTaskFinishAts) {
            snTaskFinishAts = [[NSMutableArray alloc] init];
            self.taskFinishAtDictionary[taskFinishAt.snTaskInfo] = snTaskFinishAts;
        }
        
        [snTaskFinishAts addObject:taskFinishAt];
    }
}


- (void)reloadTaskRecords
{
//    self.taskRecords = [NSMutableArray arrayWithArray:[[AppConfig sharedAppConfig] configTaskRecordGets]];
    self.taskRecordManager = [TaskRecordManager taskRecordManager];
}


- (void)taskInfoDays:(NSArray<NSString*>*)days
     arrangeToBefore:(NSMutableArray<NSString*>*)daysBefore
      arrangeToToday:(NSMutableArray<NSString*>*)daysToday
   arrangeToTomorrow:(NSMutableArray<NSString*>*)daysTomorrow
    arrangeToComming:(NSMutableArray<NSString*>*)daysComming
{
    for(NSString *day in days) {
        if([day compare:self.dateStringToday] == NSOrderedSame) {
            [daysToday addObject:day];
        }
        else if([day compare:self.dateStringTomorrow] == NSOrderedSame) {
            [daysTomorrow addObject:day];
        }
        else if([day compare:self.dateStringToday] == NSOrderedAscending) {
            [daysBefore addObject:day];
        }
        else {
            [daysComming addObject:day];
        }
    }
}


- (void)reloadTaskArrangeGroups
{
    self.dateStringToday    = [NSString dateStringToday];
    self.dateStringTomorrow = [NSString dateStringTomorrow];
    
    self.taskArrangeGroupBefore = [TaskArrangeGroup taskArrangeGroupWithName:@"之前"];
    self.taskArrangeGroupToday = [TaskArrangeGroup taskArrangeGroupWithName:@"今天"];
    self.taskArrangeGroupTomorrow = [TaskArrangeGroup taskArrangeGroupWithName:@"明天"];
    self.taskArrangeGroupComming = [TaskArrangeGroup taskArrangeGroupWithName:@"之后"];
    
    for(TaskInfo* taskinfo in self.taskinfos) {
        //将taskinfo.daysOnTask解析到这几个days中.
        NSMutableArray<NSString*> *daysBefore   = [[NSMutableArray alloc] init];
        NSMutableArray<NSString*> *daysToday    = [[NSMutableArray alloc] init];
        NSMutableArray<NSString*> *daysTomorrow = [[NSMutableArray alloc] init];
        NSMutableArray<NSString*> *daysComming  = [[NSMutableArray alloc] init];
        [self taskInfoDays:taskinfo.daysOnTask
           arrangeToBefore:daysBefore
            arrangeToToday:daysToday
         arrangeToTomorrow:daysTomorrow
          arrangeToComming:daysComming];
        
        if(daysBefore.count > 0) {
            [self.taskArrangeGroupBefore addTaskInfo:taskinfo onDays:daysBefore];
        }
        
        if(daysToday.count > 0) {
            [self.taskArrangeGroupToday addTaskInfo:taskinfo onDays:daysToday];
        }
        
        if(daysTomorrow.count > 0) {
            [self.taskArrangeGroupTomorrow addTaskInfo:taskinfo onDays:daysTomorrow];
        }
        
        if(daysComming.count > 0) {
            [self.taskArrangeGroupComming addTaskInfo:taskinfo onDays:daysComming];
        }
    }
    
    self.taskArrangeGroups = [@[
                                self.taskArrangeGroupBefore,
                                self.taskArrangeGroupToday,
                                self.taskArrangeGroupTomorrow,
                                self.taskArrangeGroupComming
                                ]
                              mutableCopy];
}


- (void)reloadTaskDayMode
{
    self.tasksDayMode = [[NSMutableDictionary alloc] init];
    
    for(TaskInfo *taskinfo in self.taskinfos) {
        for(NSString *dayString in taskinfo.daysOnTask) {
            NSMutableArray<TaskInfo*> *taskinfosIn1Day = self.tasksDayMode[dayString];
            if(!taskinfosIn1Day) {
                taskinfosIn1Day = [[NSMutableArray alloc] init];
                self.tasksDayMode[dayString] = taskinfosIn1Day;
            }
            
            [taskinfosIn1Day addObject:taskinfo];
        }
    }
    
    self.tasksDay = [self.tasksDayMode.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *s1 = obj1;
        NSString *s2 = obj2;
        return [s1 compare:s2];
    }];
}


- (void)reloadAll
{
    [self reloadTaskInfos];
    [self reloadTaskFinishAts];
    [self reloadTaskRecords];
    [self reloadTaskArrangeGroups];
    [self reloadTaskDayMode];
    
    [self log];
}


#pragma mark - taskinfo
- (BOOL)addTaskInfo:(TaskInfo*)taskinfo
{
    //更新各缓存.
    [self.taskinfos addObject:taskinfo];
    [self reloadTaskArrangeGroups];
    [self reloadTaskDayMode];
    
    [[AppConfig sharedAppConfig] configTaskInfoAdd:taskinfo];
    
    TaskRecord *taskRecord = [[TaskRecord alloc] init];
    taskRecord.snTaskRecord = [NSString randomStringWithLength:6 andType:36];
    taskRecord.snTaskInfo = taskinfo.sn;
    taskRecord.dayString = @"";
    taskRecord.type = TaskRecordTypeCreate;
    taskRecord.record = @"";
    taskRecord.committedAt = taskinfo.committedAt;
    taskRecord.modifiedAt = taskRecord.committedAt;
    taskRecord.deprecatedAt = @"";
    [self.taskRecordManager taskRecordAdd:taskRecord];
    
    return YES;
}


- (BOOL)updateTaskInfo:(TaskInfo*)taskinfo addUpdateDetail:(NSString*)updateDetail;
{
    [[AppConfig sharedAppConfig] configTaskInfoUpdate:taskinfo];
    
    //更新各缓存.
    [self reloadTaskArrangeGroups];
    [self reloadTaskDayMode];
    
    if(updateDetail.length > 0) {
        TaskRecord *taskRecord = [[TaskRecord alloc] init];
        taskRecord.snTaskRecord = [NSString randomStringWithLength:6 andType:36];
        taskRecord.snTaskInfo = taskinfo.sn;
        taskRecord.dayString = @"";
        taskRecord.type = TaskRecordTypeUserModify;
        taskRecord.record = updateDetail;
        taskRecord.committedAt = taskinfo.modifiedAt;
        taskRecord.modifiedAt = taskRecord.committedAt;
        taskRecord.deprecatedAt = @"";
        [self.taskRecordManager taskRecordAdd:taskRecord];
    }
    
    return YES;
}






#pragma mark - record
- (BOOL)addFinishedAtOnTaskInfo:(TaskInfo*)taskinfo on:(NSString*)day committedAt:(NSString*)committedAt
{
    NSString *sn = taskinfo.sn;
    //判断是否已经在完成表中存在.
    BOOL found = NO;
    for(TaskFinishAt *taskFinishAt in self.taskFinishAts) {
        if([sn isEqualToString:taskFinishAt.snTaskInfo]
           && [day isEqualToString:taskFinishAt.dayString]) {
            found = YES;
            break;
        }
    }
    
    if(found) {
        NSLog(@"#error - task(%@) on day(%@) already set to finished.", sn, day);
        return NO;
    }
    
    //增加信息到完成表.
    TaskFinishAt *taskFinishAt = [[TaskFinishAt alloc] init];
    taskFinishAt.snTaskInfo = sn;
    taskFinishAt.dayString = day;
    taskFinishAt.finishedAt = committedAt;
    [[AppConfig sharedAppConfig] configTaskFinishAtAdd:taskFinishAt];
    
    //增加信息到管理缓存.
    [self.taskFinishAts addObject:taskFinishAt];
    NSMutableArray *snTaskFinishAts = self.taskFinishAtDictionary[sn];
    if(!snTaskFinishAts) {
        snTaskFinishAts = [[NSMutableArray alloc] init];
        self.taskFinishAtDictionary[sn] = snTaskFinishAts;
    }
    [snTaskFinishAts addObject:taskFinishAt];
    
    //增加TaskRecord信息到管理缓存.
    [self.taskRecordManager taskRecordAddFinish:sn on:day committedAt:committedAt];
    
//    //判断是否已经完成全部任务.
//    NSArray<TaskFinishAt*> *finishStatus = [self queryFinishedAtsOnTaskInfo:taskinfo onDays:nil];
//    NSString *allFinishedAt = [TaskFinishAt checkAllFinishAts:finishStatus];
//    if(allFinishedAt.length > 0) {
//        taskinfo.finishedAt = committedAt;
//        [self updateTaskInfo:taskinfo addUpdateDetail:@"任务标记为全部完成"];
//    }
    
    return YES;
}


- (BOOL)addRedoAtOnSn:(NSString*)sn on:(NSString*)day committedAt:(NSString*)committedAt
{
    //判断是否已经在完成表中存在.
    TaskFinishAt *taskFinishAtFound = nil;
    for(TaskFinishAt *taskFinishAt in self.taskFinishAts) {
        if([sn isEqualToString:taskFinishAt.snTaskInfo]
           && [day isEqualToString:taskFinishAt.dayString]) {
            taskFinishAtFound = taskFinishAt;
            break;
        }
    }
    
    if(!taskFinishAtFound) {
        NSLog(@"#error - task(%@) on day(%@) not finished.", sn, day);
        return NO;
    }
    
    //删除信息到完成表.
    [[AppConfig sharedAppConfig] configTaskFinishAtRemove:taskFinishAtFound];
    
    //删除信息到管理缓存.
    [self.taskFinishAts removeObject:taskFinishAtFound];
    NSMutableArray *snTaskFinishAts = self.taskFinishAtDictionary[sn];
    [snTaskFinishAts removeObject:taskFinishAtFound];
    if(snTaskFinishAts.count == 0) {
        [self.taskFinishAtDictionary removeObjectForKey:sn];
    }
    
    //增加TaskRecord信息到管理缓存.
    [self.taskRecordManager taskRecordAddRedo:sn on:day committedAt:committedAt];
    
    return YES;
}


- (NSArray<TaskFinishAt*>*)queryFinishedAtsOnTaskInfo:(TaskInfo*)taskinfo onDays:(NSArray<NSString*>*)days
{
    NSMutableArray<TaskFinishAt*> *taskFinishAtsQuery = [[NSMutableArray alloc] init];
    
    NSMutableArray<TaskFinishAt*> *taskFinishAts = self.taskFinishAtDictionary[taskinfo.sn];
    if(days.count == 0) {
        days = [NSArray arrayWithArray:taskinfo.daysOnTask];
    }
    
    NSMutableDictionary<NSString*,NSNumber*> *dayAndIndexs = [[NSMutableDictionary alloc] init];
    
    NSInteger idx = 0;
    for(TaskFinishAt *taskFinishAt in taskFinishAts) {
        dayAndIndexs[taskFinishAt.dayString] = @(idx);
        idx ++;
    }
    
    for(NSString *day in days) {
        NSNumber *indexNumber = dayAndIndexs[day];
        if(indexNumber) {
            [taskFinishAtsQuery addObject:taskFinishAts[[indexNumber integerValue]]];
        }
        else {
            TaskFinishAt *taskFinishAt = [[TaskFinishAt alloc] init];
            taskFinishAt.snTaskInfo = taskinfo.sn;
            taskFinishAt.dayString = day;
            taskFinishAt.finishedAt = @"";
            [taskFinishAtsQuery addObject:taskFinishAt];
         }
    }
    
    return [NSArray arrayWithArray:taskFinishAtsQuery];
}


- (NSString*)queryFinishedAtsOnSn:(NSString*)sn onDay:(NSString*)day
{
    NSMutableArray<TaskFinishAt*> *taskFinishAts = self.taskFinishAtDictionary[sn];
    for(TaskFinishAt *taskFinishAt in taskFinishAts) {
        if([taskFinishAt.dayString isEqualToString:day] && taskFinishAt.dayString.length > 0) {
            return taskFinishAt.dayString;
        }
    }
    
    return @"";
}


#pragma mark - description
- (NSString*)description
{
    NSMutableString *s = [[NSMutableString alloc] init];
    NSString *line = @"---------------------------------------------------------------------------------------";
    
    [s appendString:@"\n"];
    [s appendFormat:@"%@%@%@\n", @"---", @"List mode", line];
    for(TaskInfo *taskinfo in self.taskinfos) {
        [s appendFormat:@"\t%@\n", [taskinfo summaryDescription]];
    }
    [s appendFormat:@"%@%@%@\n", @"---", @"List mode", line];
    
    [s appendFormat:@"%@%@%@\n", @"---", @"Arrange mode", line];
    for(TaskArrangeGroup *group in self.taskArrangeGroups) {
        [s appendFormat:@"\t%@\n", group.arrangeName];
        NSInteger count = group.taskInfoArranges.count;
        for(NSInteger idx = 0; idx < count; idx ++) {
            [s appendFormat:@"\t\t%@ - %@\n", group.taskInfoArranges[idx].taskinfo.sn, group.taskInfoArranges[idx].arrangeDays];
        }
    }
    [s appendFormat:@"%@%@%@\n", @"---", @"Arrange mode", line];
    
    [s appendFormat:@"%@%@%@\n", @"---", @"Day mode", line];
    NSArray *sortedDays = [self.tasksDayMode.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *s1 = obj1;
        NSString *s2 = obj2;
        return [s1 compare:s2];
    }];
    for(NSString *day in sortedDays) {
        [s appendFormat:@"\t%@ : \n", day];
        for(TaskInfo *taskinfo in self.tasksDayMode[day]) {
            [s appendFormat:@"\t\t%@\n", [taskinfo summaryDescription]];
        }
    }
    [s appendFormat:@"%@%@%@\n", @"---", @"Day mode", line];
    
    [s appendFormat:@"%@%@%@\n", @"---", @"Finish At", line];
    for(NSString *sn in self.taskFinishAtDictionary) {
        [s appendFormat:@"\t%@:\n", sn];
        NSMutableArray<TaskFinishAt*> *taskFinishAts = self.taskFinishAtDictionary[sn];
        for(TaskFinishAt *taskFinishAt in taskFinishAts) {
            [s appendFormat:@"\t\t%@:\n", taskFinishAt];
        }
    }
    [s appendFormat:@"%@%@%@\n", @"---", @"Finish At", line];
    static NSInteger ktimes = 0;
    [s appendFormat:@"%@ [%zd] %@", line, ++ktimes, [NSDate date]];
    
    
    
    
    
    return [NSString stringWithString:s];
}


+ (NSDictionary*)taskinfoArrange:(TaskInfo*)taskinfo
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSString *dateStringToday = [NSString dateStringToday];
    NSString *dateStringTomorrow = [NSString dateStringTomorrow];
    
    //将taskinfo.daysOnTask解析到这几个days中.
    NSMutableArray<NSString*> *daysBefore   = [[NSMutableArray alloc] init];
    NSMutableArray<NSString*> *daysToday    = [[NSMutableArray alloc] init];
    NSMutableArray<NSString*> *daysTomorrow = [[NSMutableArray alloc] init];
    NSMutableArray<NSString*> *daysComming  = [[NSMutableArray alloc] init];
    for(NSString *day in taskinfo.daysOnTask) {
        if([day compare:dateStringToday] == NSOrderedSame) {
            [daysToday addObject:day];
        }
        else if([day compare:dateStringTomorrow] == NSOrderedSame) {
            [daysTomorrow addObject:day];
        }
        else if([day compare:dateStringToday] == NSOrderedAscending) {
            [daysBefore addObject:day];
        }
        else {
            [daysComming addObject:day];
        }
    }
    
    if(daysBefore.count > 0) {
        dict[@"之前"] = [NSArray arrayWithArray:daysBefore];
    }
    
    if(daysToday.count > 0) {
        dict[@"今天"] = @[dateStringToday];
    }
    
    if(daysTomorrow.count > 0) {
        dict[@"明天"] = @[dateStringTomorrow];
    }
    
    if(daysComming.count > 0) {
        dict[@"之后"] = [NSArray arrayWithArray:daysComming];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}




@end


