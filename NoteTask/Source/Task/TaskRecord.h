//
//  TaskRecord.h
//  NoteTask
//
//  Created by Ben on 16/11/1.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskRecord : NSObject




@property (nonatomic, strong) NSString *snTaskRecord;
@property (nonatomic, strong) NSString *snTaskInfo;
@property (nonatomic, strong) NSString *dayString;
@property (nonatomic, assign) NSInteger type; //0.do/redo. 1.finish. 2.signin. 3.user-record. 4.user-delete. 5.user-modify. 6.system-reminder.
@property (nonatomic, strong) NSString *record;
@property (nonatomic, strong) NSString *committedAt;
@property (nonatomic, strong) NSString *modifiedAt;
@property (nonatomic, strong) NSString *deprecatedAt;


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


@end






