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


//@property (nonatomic, assign) NSInteger type; //0.do/redo. 1.finish. 2.signin. 3.user-record. 4.user-delete. 5.user-modify. 6.system-reminder.
+ (NSDictionary*)taskRecordTypeStringDictionary
{
    return @{
             @(TaskRecordTypeCreate):@"新建",
             @(TaskRecordTypeSignIn):@"签到" ,
             @(TaskRecordTypeSignOut):@"签退" ,
             @(TaskRecordTypeUserModify):@"修改" ,
             @(TaskRecordTypeUserDelete):@"删除" ,
             @(TaskRecordTypeUserRecord):@"任务记录" ,
             @(TaskRecordTypeLocalReminder):@"本地提醒" ,
             @(TaskRecordTypeRemoteReminder):@"消息提醒" ,
             @(TaskRecordTypeFinish):@"完成" ,
             @(TaskRecordTypeRedo):@"重新开启" ,
             };
}


+ (NSString*)stringOfType:(TaskRecordType)type
{
    NSDictionary *dict = [self taskRecordTypeStringDictionary];
    NSString *typeString = nil;
    if([(typeString = dict[@(type)]) isKindOfClass:[NSString class]]) {
        return typeString;
    }
    
    return @"类型NAN";
}


+ (TaskRecordType)typeOfString:(NSString*)typeString
{
    typeString = [typeString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \n"]];
    NSDictionary *dict = [self taskRecordTypeStringDictionary];
    NSNumber *key;
    NSNumber *typeNumber = nil;
    for(key in dict.allKeys) {
        if([typeString isEqualToString:dict[key]]) {
            typeNumber = key;
            break;
        }
    }
    
    if(typeNumber) {
        return [typeNumber integerValue];
    }
    
    return TaskRecordTypeNone;
}


+ (TaskRecord*)taskRecordWithFinishTaskInfo:(NSString*)snTaskInfo on:(NSString*)dayString committedAt:(NSString*)committedAt
{
    TaskRecord *taskRecord = [[TaskRecord alloc] init];
    taskRecord.snTaskRecord = [NSString randomStringWithLength:6 andType:36];
    taskRecord.snTaskInfo = snTaskInfo;
    taskRecord.dayString = dayString;
    taskRecord.type = TaskRecordTypeFinish;
    taskRecord.record = @"";
    taskRecord.committedAt = committedAt;//[NSString dateTimeStringNow];
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
    taskRecord.type = TaskRecordTypeRedo;
    taskRecord.record = @"";
    taskRecord.committedAt = committedAt;//[NSString dateTimeStringNow];
    taskRecord.modifiedAt = taskRecord.committedAt;
    taskRecord.deprecatedAt = @"";
    
    return taskRecord;
}



- (NSMutableAttributedString*)generateAttributedString
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.committedAt];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];

    NSString *content = [TaskRecord stringOfType:self.type];
    NSMutableAttributedString *attributedStringContent = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedString appendAttributedString:attributedStringContent];
    
    return attributedString;
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
    
    NSLog(@"[%@][%@]task record count : %zd", sn, types, recordsResult.count);
    return [NSArray<TaskRecord*> arrayWithArray:recordsResult];
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



