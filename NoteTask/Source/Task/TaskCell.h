//
//  TaskCellTableViewCell.h
//  NoteTask
//
//  Created by Ben on 16/10/18.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TaskModel;
@interface TaskCell : UITableViewCell
@property (nonatomic, strong) TaskModel *task;
@property (nonatomic, assign) BOOL detailedMode;


@property (nonatomic, strong) void(^actionOn)(NSString*);

@end


@interface TaskCellActionMenu : UIView

@end
