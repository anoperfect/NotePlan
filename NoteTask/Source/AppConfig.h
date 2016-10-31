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


- (void)configNoteUpdate:(NoteModel*)note;

- (void)configNoteUpdateBynoteIdentifiers:(NSArray<NSString*>*)noteIdentifiers classification:(NSString*)classification;
- (void)configNoteUpdateBynoteIdentifiers:(NSArray<NSString*>*)noteIdentifiers colorString:(NSString*)colorString;













- (NSString*)configSettingGet:(NSString*)key;
- (void)configSettingSetKey:(NSString*)key toValue:(NSString*)value;



- (NSArray<TaskInfo*>*)configTaskInfoGets;
- (BOOL)configTaskInfoAdd:(TaskInfo*)taskinfo;
- (void)configTaskInfoRemoveBySn:(NSArray<NSString*>*)sn;
- (void)configTaskInfoUpdate:(TaskInfo*)taskinfo;


@end
