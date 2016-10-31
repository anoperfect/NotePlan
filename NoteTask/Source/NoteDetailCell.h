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




@property (nonatomic, strong, readonly) UIView *container;

@property (nonatomic, strong, readonly) YYLabel *noteParagraphYYLabel;
@property (nonatomic, strong, readonly) UILabel *noteParagraphLabel;
@property (nonatomic, strong, readonly) UITextView *noteParagraphTextView;
@property (nonatomic, strong, readonly) NotePropertyView *notePropertyView;

@property (nonatomic, assign, readonly) UIEdgeInsets edgeContainer;
@property (nonatomic, assign, readonly) UIEdgeInsets edgeLabel;


@property (nonatomic, assign, readonly) CGFloat optumizeHeight;


- (void)setClassification:(NSString*)classification color:(NSString*)color;

- (void)setNoteParagraph:(NoteParagraphModel*)noteParagraph isTitle:(BOOL)isTitle sn:(NSInteger)sn onDisplayMode:(BOOL)displayMode;

- (void)setCellDisplayHeight:(CGFloat)height;

@end
