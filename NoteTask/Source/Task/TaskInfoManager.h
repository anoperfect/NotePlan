//
//  TaskInfoManager.h
//  NoteTask
//
//  Created by Ben on 16/11/1.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskModel.h"





@interface TaskFinishAt : NSObject

@property (nonatomic, strong) NSString *snTaskInfo;
@property (nonatomic, strong) NSString *dayString;
@property (nonatomic, strong) NSString *finishedAt;

+ (instancetype)taskFinishAtFromDictionary:(NSDictionary*)dict;


@end


@interface TaskInfoArrange : NSObject

@property (nonatomic, strong) TaskInfo *taskinfo;
@property (nonatomic, strong) NSMutableArray<NSString*> *arrangeDays;
@property (nonatomic, strong) NSString *arrangeName;

@end



@interface TaskArrangeGroup : NSObject

@property (nonatomic, strong) NSString                      *arrangeName;
//@property (nonatomic, strong) NSString                      *dayString;

//@property (nonatomic, strong) NSMutableDictionary<TaskInfo*, NSMutableArray<NSString*>*> *taskDays;
@property (nonatomic, strong) NSMutableArray<TaskInfoArrange*>  *taskInfoArranges;

+ (instancetype)taskArrangeGroupWithName:(NSString*)name;
- (void)addTaskInfo:(TaskInfo*)taskinfo onDays:(NSArray<NSString*>*)days;


@end




@interface TaskInfoManager : NSObject

@property (nonatomic, strong) NSMutableArray<TaskInfo*>* taskinfos; //从本地数据库中读取的全部task.
- (void)reloadTaskInfos;


@property (nonatomic, strong) NSMutableArray<TaskFinishAt*>* taskFinishAts; //从本地数据库中读取的全部完成信息.
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSMutableArray<TaskFinishAt*>*>* taskFinishAtDictionary; //转为字典更方便查找.
- (void)reloadTaskFinishAts;


@property (nonatomic, strong) NSMutableArray<TaskRecord*>* taskRecords; //从本地数据库中读取的全部记录信息.
@property (nonatomic, strong) TaskRecordManager *taskRecordManager;
- (void)reloadTaskRecords;


//不将taskFinishAt, taskRecord信息附着到taskinfo.


//分模式组织taskinfo信息.
//taskinfo列表. 直接使用taskinfos信息.


//arrange模式. 将任务分为 之前,今天,明天,之后.
@property (nonatomic, strong, readonly) NSString *dateStringToday;
@property (nonatomic, strong, readonly) NSString *dateStringTomorrow;

@property (nonatomic, strong) NSMutableArray<TaskArrangeGroup*> *taskArrangeGroups;
- (void)reloadTaskArrangeGroups;


//day模式.按照day显示task.
@property (nonatomic, strong) NSMutableDictionary<NSString*,NSMutableArray<TaskInfo*>*>* tasksDayMode; //将任务按照day分类.
@property (nonatomic, strong) NSArray<NSString*> *tasksDay;
- (void)reloadTaskDayMode;








+ (TaskInfoManager*)taskInfoManager;

- (void)reloadAll;


//添加完成信息的统一接口.会同时更新缓存和数据库.
- (BOOL)addFinishedAtOnSn:(NSString*)sn on:(NSString*)day committedAt:(NSString*)committedAt;

//添加重新执行信息的统一接口.会同时更新缓存和数据库.
- (BOOL)addRedoAtOnSn:(NSString*)sn on:(NSString*)day committedAt:(NSString*)committedAt;





//查询多天的完成情况.
- (NSArray<TaskFinishAt*>*)queryFinishedAtsOnSn:(NSString*)sn onDays:(NSArray<NSString*>*)days;


- (NSString*)queryFinishedAtsOnSn:(NSString*)sn onDay:(NSString*)day;

- (BOOL)addTaskInfo:(TaskInfo*)taskinfo;
- (BOOL)updateTaskInfo:(TaskInfo*)taskinfo addUpdateDetail:(NSString*)updateDetail;


@end
