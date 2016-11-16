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
@property (nonatomic, strong) TaskDay *taskDay;
@end



@interface TaskRecordView : UIView
@property (nonatomic, strong) TaskInfo* taskinfo;
- (void)setTaskRecordTypes:(NSArray<NSNumber*>*)taskRecordTypes triggerOn:(BOOL)on;
@end