//
//  TaskRecord.m
//  NoteTask
//
//  Created by Ben on 16/11/1.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskRecord.h"
#import "AppConfig.h"





@interface TaskRecord ()


@end



@implementation TaskRecord



+ (instancetype)taskRecordFromDictionary:(NSDictionary*)dict
{
    TaskRecord *taskRecord = [[TaskRecord alloc] init];
    
    taskRecord.snTaskInfo = dict[@"snTaskInfo"];
    taskRecord.snTaskRecord = dict[@"snTaskRecord"];
    taskRecord.dayString = dict[@"dayString"];
    taskRecord.type = [dict[@"type"] integerValue];
    taskRecord.record = dict[@"type"];
    taskRecord.committedAt = dict[@"committedAt"];
    taskRecord.modifiedAt = dict[@"modifiedAt"];
    taskRecord.deprecatedAt = dict[@"deprecatedAt"];
    
    taskRecord = [TaskRecord mj_objectWithKeyValues:dict];
    
    return taskRecord;
}


+ (TaskRecord*)taskRecordWithFinishTaskInfo:(NSString*)snTaskInfo on:(NSString*)dayString committedAt:(NSString*)committedAt
{
    TaskRecord *taskRecord = [[TaskRecord alloc] init];
    taskRecord.snTaskRecord = [NSString randomStringWithLength:6 andType:36];
    taskRecord.snTaskInfo = snTaskInfo;
    taskRecord.dayString = dayString;
    taskRecord.type = 1;
    taskRecord.record = @"";
    taskRecord.committedAt = committedAt;//[NSString stringDateTimeNow];
    taskRecord.modifiedAt = taskRecord.committedAt;
    taskRecord.deprecatedAt = @"";
    
    return taskRecord;
}


+ (TaskRecord*)taskRecordWithRedoTaskInfo:(NSString*)snTaskInfo on:(NSString*)dayString committedAt:(NSString*)committedAt
{
    TaskRecord *taskRecord = [[TaskRecord alloc] init];
    taskRecord.snTaskRecord = [NSString randomStringWithLength:6 andType:36];
    taskRecord.snTaskInfo = snTaskInfo;
    taskRecord.dayString = dayString;
    taskRecord.type = 0;
    taskRecord.record = @"";
    taskRecord.committedAt = committedAt;//[NSString stringDateTimeNow];
    taskRecord.modifiedAt = taskRecord.committedAt;
    taskRecord.deprecatedAt = @"";
    
    return taskRecord;
}






@end


@interface TaskRecordManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSMutableArray<TaskRecord*>*> *taskRecordsGrouped;

@end


@implementation TaskRecordManager

+ (TaskRecordManager*)taskRecordManager
{
    static dispatch_once_t once;
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
        [instance taskRecordReload];
    });
    
    return instance;
}


- (void)taskRecordReload
{
    //从数据库中读取所有的record.
    NSArray<TaskRecord*> *taskRecords = [self taskRecordsGetAll];
    
    //依照tasksn为key,分组.
    self.taskRecordsGrouped = [[NSMutableDictionary alloc] init];
    for(TaskRecord *taskRecord in taskRecords) {
        [self taskRecordAddToManager:taskRecord];
    }
    
    //排序数组.
}


- (void)taskRecordAddToManager:(TaskRecord*)taskRecord
{
    NSMutableArray<TaskRecord*> *taskRecordWith1Sn = self.taskRecordsGrouped[taskRecord.snTaskInfo];
    if(taskRecordWith1Sn) {
        [taskRecordWith1Sn addObject:taskRecord];
    }
    else {
        taskRecordWith1Sn = [NSMutableArray arrayWithObject:taskRecord];
        self.taskRecordsGrouped[taskRecord.snTaskInfo] = taskRecordWith1Sn;
    }
}


- (NSArray<TaskRecord*>*)taskRecordsGetAll
{
    return [[AppConfig sharedAppConfig] configTaskRecordGets];
}


- (NSArray<TaskRecord*>*)taskRecordsOnSn:(NSString*)sn types:(NSArray<NSNumber*>*)types
{
    NSMutableArray<TaskRecord*> *recordsResult = [[NSMutableArray alloc] init];
    NSMutableArray<TaskRecord*> *records = self.taskRecordsGrouped[sn];
    for(TaskRecord *record in records) {
        if(NSNotFound != [types indexOfObject:@(record.type)]) {
            [recordsResult addObject:record];
        }
    }
    
    return [NSArray<TaskRecord*> arrayWithArray:recordsResult];
}


- (NSString*)taskRecordQuery:(NSString*)sn finishedAtOnDay:(NSString*)day
{
    NSMutableArray<TaskRecord*> *records = self.taskRecordsGrouped[sn];
    
    //按照修改的时间先后排序.
    [self taskRecordSort:records byModifiedAtAscend:NO];
    NSString *finishedAt = @"";
    for(TaskRecord *record in records) {
        if(record.type == 1 && record.deprecatedAt.length == 0) {
            finishedAt = record.committedAt;
            break;
        }
        
        //最新一次是redo的纪录, 则返回未完成.
        if(record.type == 0) {
            break;
        }
    }
    
    return finishedAt;
}


- (void)taskRecordAdd:(TaskRecord*)taskRecord
{
    //加入到manager纪录中.
    [self taskRecordAddToManager:taskRecord];
    
    //加入到本地保存中.
    [[AppConfig sharedAppConfig] configTaskRecordAdd:taskRecord];
}


- (void)taskRecordAddFinish:(NSString*)snTaskInfo on:(NSString*)dayString committedAt:(NSString*)committedAt
{
    [self taskRecordAdd:[TaskRecord taskRecordWithFinishTaskInfo:snTaskInfo on:dayString committedAt:committedAt]];
}


- (void)taskRecordAddRedo:(NSString*)snTaskInfo on:(NSString*)dayString committedAt:(NSString*)committedAt
{
    [self taskRecordAdd:[TaskRecord taskRecordWithRedoTaskInfo:snTaskInfo on:dayString committedAt:committedAt]];
}


- (void)taskRecordRemove:(TaskRecord*)taskRecord
{
    
    
    
}

- (void)taskRecordUpdate:(TaskRecord*)taskRecord
{

    
    
}


- (void)taskRecordSort:(NSMutableArray<TaskRecord*>*)taskRecords byModifiedAtAscend:(BOOL)ascend
{
    [taskRecords sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        TaskRecord *taskRecord1 = obj1;
        TaskRecord *taskRecord2 = obj2;
        
        NSComparisonResult result = ascend ? [taskRecord1.modifiedAt compare:taskRecord2.modifiedAt] : [taskRecord2.modifiedAt compare:taskRecord1.modifiedAt];
        return result;
    }];
}



@end

