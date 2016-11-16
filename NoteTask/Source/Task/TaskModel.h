//
//  TaskModel.h
//  NoteTask
//
//  Created by Ben on 16/10/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>



//day时间点.         day时间段.              days时间段.    day.                     days.
//repeat.           repeat.                              repeat.
//workday repeat.   workday repeat.                      workday repeat.


#if 0

类型: //1.单天定点. 2.多天定点. 3.时间段. 4.多天时间段. 5.开始时间-结束时间. 6.开始如期－结束日期.

type:
day:[]
duration:[]
fromtime:
totime:
time:
#endif



























@interface TaskInfo : NSObject

@property (nonatomic, strong) NSString          *sn;
@property (nonatomic, strong) NSString          *content;
@property (nonatomic, assign) NSInteger          status;
@property (nonatomic, strong) NSString          *committedAt;
@property (nonatomic, strong) NSString          *modifiedAt;
@property (nonatomic, strong) NSString          *signedAt;
@property (nonatomic, strong) NSString          *finishedAt;

@property (nonatomic, assign) NSInteger          scheduleType;
@property (nonatomic, assign) BOOL               dayRepeat;
@property (nonatomic, strong) NSString          *daysStrings;

@property (nonatomic, strong) NSString          *time; //1.单天定点hh:mm. 2.day repeat 定点. hh:mm 3.单天时间段.hh:mm-hh:mm. 4.day repeat 时间段.hh:mm-hh:mm
@property (nonatomic, strong) NSString          *period; //5.日期段. yyyy.mm.dd-yyyy.mm.dd. 6.时间段. yyyy.mm.dd hh:mm-yyyy.mm.dd hh:mm

@property (nonatomic, strong) NSMutableArray<NSString*> *daysOnTask; //从daysStrings或period中解析出来的.
@property (nonatomic, strong) NSMutableArray<NSString*> *daysFinish;


+ (instancetype)taskinfoFromDictionary:(NSDictionary*)dict;



@end





