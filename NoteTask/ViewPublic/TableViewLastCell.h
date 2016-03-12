//
//  TableViewLastCell.h
//  NoteTask
//
//  Created by Ben on 16/2/20.
//  Copyright (c) 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableViewLastCell : UIView





typedef NS_ENUM(NSUInteger, TableViewLastCellStatus)
{
    TableViewLastCellStatusNotVisible = 0,
    TableViewLastCellStatusMore,
    TableViewLastCellStatusLoading,
    TableViewLastCellStatusError,
    TableViewLastCellStatusFinished,
    TableViewLastCellStatusEmpty
};

@property (nonatomic, assign) TableViewLastCellStatus status;

- (void)setStatus1:(TableViewLastCellStatus)status;


@end
