//
//  TaskDetailViewController.h
//  NoteTask
//
//  Created by Ben on 16/10/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomViewController.h"
@interface TaskDetailViewController : CustomViewController
@property (nonatomic, strong) TaskInfo *taskinfo;
@end



@interface TaskRecordView : UIView
@property (nonatomic, strong) TaskInfo* taskinfo;
@end