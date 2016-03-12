//
//  NoteCell.h
//  NoteTask
//
//  Created by Ben on 16/2/21.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *commentCount;

@end
