//
//  TaskRecord.h
//  NoteTask
//
//  Created by Ben on 16/11/1.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>









@interface TaskRecord : NSObject




typedef NS_ENUM (NSUInteger, TaskRecordType) {
    TaskRecordTypeNone = 0,
    TaskRecordTypeCreate ,
    TaskRecordTypeSignIn ,
    TaskRecordTypeSignOut ,
    TaskRecordTypeUserModify ,
    TaskRecordTypeUserDelete ,
    TaskRecordTypeUserRecord ,
    TaskRecordTypeLocalReminder ,
    TaskRecordTypeRemoteReminder ,
    TaskRecordTypeFinish ,
    TaskRecordTypeRedo ,
};


@property (nonatomic, strong) NSString *snTaskRecord;
@property (nonatomic, strong) NSString *snTaskInfo;
@property (nonatomic, strong) NSString *dayString;
@property (nonatomic, assign) TaskRecordType type;
@property (nonatomic, strong) NSString *record;
@property (nonatomic, strong) NSString *committedAt;
@property (nonatomic, strong) NSString *modifiedAt;
@property (nonatomic, strong) NSString *deprecatedAt;

+ (NSString*)stringOfType:(TaskRecordType)type;
+ (TaskRecordType)typeOfString:(NSString*)typeString;

+ (instancetype)taskRecordFromDictionary:(NSDictionary*)dict;

- (NSMutableAttributedString*)generateAttributedString;


@end


@interface TaskRecordManager : NSObject

+ (TaskRecordManager*)taskRecordManager;

- (void)taskRecordReload;

- (NSArray<TaskRecord*>*)taskRecordsGetAll;
- (NSArray<TaskRecord*>*)taskRecordsOnSn:(NSString*)sn types:(NSArray<NSNumber*>*)types;
- (NSString*)taskRecordQuery:(NSString*)sn finishedAtOnDay:(NSString*)day;

- (void)taskRecordAdd:(TaskRecord*)taskRecord;







- (void)taskRecordAddFinish:(NSString*)snTaskInfo on:(NSString*)dayString committedAt:(NSString*)committedAt;
- (void)taskRecordAddRedo:(NSString*)snTaskInfo on:(NSString*)dayString committedAt:(NSString*)committedAt;

- (void)taskRecordRemove:(TaskRecord*)taskRecord;
- (void)taskRecordUpdate:(TaskRecord*)taskRecord;


- (void)taskRecordSort:(NSMutableArray<TaskRecord*>*)taskRecords byModifiedAtAscend:(BOOL)ascend;

@end






