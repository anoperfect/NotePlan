//
//  TaskCellTableViewCell.h
//  NoteTask
//
//  Created by Ben on 16/10/18.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskModel.h"
@interface TaskCell : UITableViewCell
@property (nonatomic, strong) TaskInfo *task;
@property (nonatomic, assign) BOOL detailedMode;


@property (nonatomic, strong) void(^actionOn)(NSString*);
@property (nonatomic, strong, readonly) UILabel *summayView;
@end


@interface TaskCellActionMenu : UIView

@end
