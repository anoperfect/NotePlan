//
//  NoteModel.h
//  TaskNote
//
//  Created by Ben on 16/2/21.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteModel : NSObject




@property (nonatomic, assign) long long taskid;
@property (nonatomic, assign) long long id;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) BOOL isShareTo;
@property (nonatomic, assign) BOOL isLocal;
@property (nonatomic, assign) NSUInteger dailyRepeat; /* 0x0 无repeat.
                                                         0xa123456 当天任务, 指定星期几重复.
                                                       */
@property (nonatomic, assign) NSUInteger dailyRepeatTime; /* 0x08001230 : 8:00 到 12:00 . */

@property (nonatomic, strong) NSString *startDateTime;
@property (nonatomic, strong) NSString *finishDateTime;
@property (nonatomic, strong) NSString *commitDateTime;

@property (nonatomic, strong) NSString *task;





+ (NoteModel*)noteFromDict:(NSDictionary*)dict;
+ (NSArray*)notesFromData:(NSData *)data;

@end
