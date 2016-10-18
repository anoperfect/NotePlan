//
//  AppConfig.h
//  NoteTask
//
//  Created by Ben on 16/8/2.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NoteModel;



@interface AppConfig : NSObject




+ (AppConfig*)sharedAppConfig;



- (NSArray<NSString*> *)configClassificationGets;
- (void)configClassificationAdd:(NSString*)classification;
- (void)configClassificationRemove:(NSString*)classification;


- (NSArray<NoteModel*> *)configNoteGets;
- (NSArray<NoteModel*> *)configNoteGetsByClassification:(NSString*)classification andColorString:(NSString*)colorString;
- (NoteModel*)configNoteGetByNoteIdentifier:(NSInteger)noteIdentifier;


//返回新增note的identifier.
- (NSInteger)configNoteAdd:(NoteModel*)note;
- (void)configNoteRemoveById:(NSInteger)noteIdentifier;
- (void)configNoteRemoveByIdentifiers:(NSArray<NSNumber*>*)noteIdentifiers;


- (void)configNoteUpdate:(NoteModel*)note;

- (void)configNoteUpdateBynoteIdentifier:(NSInteger)noteIdentifier classification:(NSString*)classification;
- (void)configNoteUpdateBynoteIdentifiers:(NSArray<NSNumber*>*)noteIdentifiers classification:(NSString*)classification;

- (void)configNoteUpdateBynoteIdentifier:(NSInteger)noteIdentifier colorString:(NSString*)colorString;













- (NSString*)configSettingGet:(NSString*)key;
- (void)configSettingSetKey:(NSString*)key toValue:(NSString*)value;




@end
