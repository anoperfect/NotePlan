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
    taskRecord.type = [dict[@"type"] integerValue];
    taskRecord.committedAt = dict[@"committedAt"];
    taskRecord.modifiedAt = dict[@"modifiedAt"];
    taskRecord.record = dict[@"record"];
    
    return taskRecord;
}






@end


@interface TaskRecordManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSMutableArray<TaskRecord*>*> *taskRecords;

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
    
    //依照tasksn为key,分组.
    
    //排序数组.
    
    
}


- (NSArray<TaskRecord*>*)taskRecordsGetAll
{
    
    
    return nil;
}


- (NSArray<TaskRecord*>*)taskRecordsOnSn:(NSString*)sn types:(NSArray<NSNumber*>*)types
{
    
    
    
    return nil;
}


- (NSString*)taskRecordQuery:(NSString*)sn finishedAtOnDay:(NSString*)day
{
    
    
    return nil;
}


- (void)taskRecordAdd:(TaskRecord*)taskRecord
{
    
    
    
}


- (void)taskRecordAddToTaskInfo:(NSString*)snTaskInfo finishedAt:(NSString*)finishedAt
{
    
    
}


- (void)taskRecordAddToTaskInfo:(NSString*)snTaskInfo redoAt:(NSString*)redoAt
{
    
    
}


- (void)taskRecordRemove:(TaskRecord*)taskRecord
{
    
    
    
}

- (void)taskRecordUpdate:(TaskRecord*)taskRecord
{
    
    
    
}

@end

