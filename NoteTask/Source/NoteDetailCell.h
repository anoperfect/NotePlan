//
//  NoteDetailCell.h
//  NoteTask
//
//  Created by Ben on 16/10/27.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotePropertyView.h"
#import "NoteModel.h"




@interface NoteDetailCell : UITableViewCell


@property (nonatomic, assign, readonly) CGFloat optumizeHeight;

- (void)setNoteParagraph:(NoteParagraphModel*)noteParagraph isTitle:(BOOL)isTitle sn:(NSInteger)sn onDisplayMode:(BOOL)displayMode;

@end
//同时给NoteDetailViewController使用, 以便使编辑控件的布局尽量跟NoteDetailCell匹配.
#define NOTEDETAILCELL_EDGE_CONTAINER   UIEdgeInsetsMake(10, 10, 10, 10)
#define NOTEDETAILCELL_EDGE_TEXTVIEW    UIEdgeInsertMake(0, 0, 0, 0)
#define NOTEDETAILCELL_EDGE_LABEL       UIEdgeInsetsMake(6, 6, 6, 6)