//
//  AppConfig.h
//  NoteTask
//
//  Created by Ben on 16/8/2.
//  Copyright © 2016年 Ben. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "NoteModel.h"
#import "TaskModel.h"
#import "TaskRecord.h"
#import "TaskInfoManager.h"



@interface AppConfig : NSObject




+ (AppConfig*)sharedAppConfig;



- (NSArray<NSString*> *)configClassificationGets;
- (void)configClassificationAdd:(NSString*)classification;
- (void)configClassificationRemove:(NSString*)classification;


- (NSArray<NoteModel*> *)configNoteGets;
- (NSArray<NoteModel*> *)configNoteGetsByClassification:(NSString*)classification andColorString:(NSString*)colorString;
- (NoteModel*)configNoteGetByNoteIdentifier:(NSString*)noteIdentifier;


//返回新增note的identifier.
- (BOOL)configNoteAdd:(NoteModel*)note;
- (void)configNoteRemoveById:(NSString*)noteIdentifier;
- (void)configNoteRemoveByIdentifiers:(NSArray<NSString*>*)noteIdentifiers;

//删除.可以到回收站清除或恢复.
- (void)configNoteDeleteByIdentifiers:(NSArray<NSString*>*)noteIdentifiers;

- (NSDictionary*)configNoteUpdateDetect:(NoteModel*)note fromNoteIdentifier:(NSString*)identifier;
- (void)configNoteUpdate:(NoteModel*)note;
- (void)configNoteUpdate:(NoteModel*)note fromNoteIdentifier:(NSString*)identifier;

- (void)configNotesUpdateClassification:(NSString*)classification byNoteIdentifiers:(NSArray<NSString*>*)noteIdentifiers;
- (void)configNotesUpdateColor:(NSString*)color byNoteIdentifiers:(NSArray<NSString*>*)noteIdentifiers;

- (void)configNoteAddPreset;












- (NSString*)configSettingGet:(NSString*)key;
- (void)configSettingSetKey:(NSString*)key toValue:(NSString*)value;



- (NSArray<TaskInfo*>*)configTaskInfoGets;
- (BOOL)configTaskInfoAdd:(TaskInfo*)taskinfo;
- (void)configTaskInfoRemoveBySn:(NSArray<NSString*>*)sn;
- (void)configTaskInfoUpdate:(TaskInfo*)taskinfo;

- (NSArray<TaskRecord*>*)configTaskRecordGets;
- (BOOL)configTaskRecordAdd:(TaskRecord*)taskRecord;
- (void)configTaskRecordRemoveBySn:(NSArray<NSString*>*)sn;
- (void)configTaskRecordUpdate:(TaskRecord*)taskRecord;

- (NSArray<TaskFinishAt*>*)configTaskFinishAtGets;
- (BOOL)configTaskFinishAtAdd:(TaskFinishAt*)taskFinishAt;
- (void)configTaskFinishAtRemove:(TaskFinishAt*)taskFinishAt;




- (AFHTTPSessionManager *)HTTPSessionManager;
#define HTTPMANAGE [[AppConfig sharedAppConfig] HTTPSessionManager]

//一些保存的时间字符串显示的时候, 可能进行一些调整. 统一使用此接口.
+ (NSString*)dateStringToDisplay:(NSString*)at;

@end
