//
//  NoteDetailCell.h
//  NoteTask
//
//  Created by Ben on 16/10/27.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotePropertyView.h"





@class NoteDetailCell;
@protocol NoteDetailCellDelegate <NSObject>


@end



@interface NoteDetailCell : UITableViewCell


@property (nonatomic, assign, readonly) NSInteger sn;
@property (nonatomic, assign, readonly) CGFloat optumizeHeight;
@property (nonatomic, assign) id<NoteDetailCellDelegate> delegate;

//sn : 0 title. sn > 0 content paragraph.
- (void)setNoteParagraph:(NoteParagraphModel*)noteParagraph sn:(NSInteger)sn onMode:(NSInteger)mode image:(UIImage*)image imageSize:(CGSize)imageSize;

@end

//同时给NoteDetailViewController使用, 以便使编辑控件的布局尽量跟NoteDetailCell匹配.

#define NOTEDETAILCELL_EDGE_CONTAINER   UIEdgeInsetsMake(10, 10, 10, 10)
#define NOTEDETAILCELL_EDGE_TEXTVIEW    UIEdgeInsertMake(0, 0, 0, 0)
#define NOTEDETAILCELL_EDGE_LABEL       UIEdgeInsetsMake(6, 6, 6, 6)




