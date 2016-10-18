//
//  TaskModel.h
//  NoteTask
//
//  Created by Ben on 16/10/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskModel : NSObject




@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *step;
@property (nonatomic, strong) NSString *dateStart;
@property (nonatomic, strong) NSString *dateFinish;
@property (nonatomic, assign) NSInteger status;




@end
