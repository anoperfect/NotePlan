//
//  NoteViewController.h
//  TaskNote
//
//  Created by Ben on 16/1/24.
//  Copyright (c) 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteViewController.h"
typedef NS_ENUM(NSInteger, NoteListType)
{
    NoteListType0 = 0,
    NoteListTypeAll,
    NoteListTypeThisDay,
    NoteListTypeNotFinished
};

@interface NoteViewController : RemoteViewController

- (instancetype)initWithType:(NoteListType)type;

@end
