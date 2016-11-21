//
//  TaskDetailViewController.h
//  NoteTask
//
//  Created by Ben on 16/10/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomViewController.h"
#import "TaskInfoManager.h"
@interface TaskDetailViewController : CustomViewController
//@property (nonatomic, strong) TaskDay *taskDay;
@property (nonatomic, strong) TaskInfo *taskinfo;
@property (nonatomic, strong) NSString *arrangeName; //从arrangeMode跳转过来的使用此.
@end



@interface TaskRecordView : UIView
@property (nonatomic, strong) TaskInfo* taskinfo;
- (void)setTaskRecordTypes:(NSArray<NSNumber*>*)taskRecordTypes triggerOn:(BOOL)on;
@end