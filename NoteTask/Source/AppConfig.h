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
- (NoteModel*)configNoteGetBySn:(NSString*)sn;



- (BOOL)configNoteAdd:(NoteModel*)note;
- (void)configNoteRemoveBySn:(NSArray<NSString*>*)sns;

//删除.可以到回收站清除或恢复.
- (void)configNoteDeleteBySns:(NSArray<NSString*>*)sns;

- (NSDictionary*)configNoteUpdateDetect:(NoteModel*)note fromSn:(NSString*)sn;
- (void)configNoteUpdate:(NoteModel*)note;
- (void)configNoteUpdate:(NoteModel*)note fromSn:(NSString*)sn;

- (void)configNotesUpdateClassification:(NSString*)classification bySns:(NSArray<NSString*>*)sns;
- (void)configNotesUpdateColor:(NSString*)color bySns:(NSArray<NSString*>*)sns;

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


@end
