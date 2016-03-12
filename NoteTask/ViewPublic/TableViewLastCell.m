//
//  TableViewLastCell.m
//  NoteTask
//
//  Created by Ben on 16/2/20.
//  Copyright (c) 2016年 Ben. All rights reserved.
//

#import "TableViewLastCell.h"
#import "UIColor+Util.h"

@interface TableViewLastCell ()

@property (nonatomic, strong) UILabel *textLable;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end




@implementation TableViewLastCell


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSubviews];
    }
    
    return self;
}


- (void)setupSubviews
{
    _textLable = [[UILabel alloc] init];
    [self addSubview:_textLable];
    
    _textLable.textColor = [UIColor titleColor];
    _textLable.backgroundColor = [UIColor themeColor];
    _textLable.textAlignment = NSTextAlignmentCenter;
    _textLable.font = [UIFont boldSystemFontOfSize:14];
    
        
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:_indicator];
    
    _indicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
            | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _indicator.color = [UIColor colorWithHex:0x363636 alpha:1.0];
}


- (void)layoutSubviews
{
    _textLable.frame = self.bounds;
    _indicator.center = self.center;
}


- (void)setStatus1:(TableViewLastCellStatus)status
{
    if(TableViewLastCellStatusLoading == status) {
        [_indicator startAnimating];
        _indicator.hidden = NO;
    }else {
        [_indicator startAnimating];
        _indicator.hidden = NO;
    }
    
    _textLable.text = @[
                        @"NotVisiable",
                        @"点击加载更多",
                        @"",
                        @"加载数据出错",
                        @"全部加载完毕",
                        @"Empty",
                        ][status];
    
    _status = status;
}



@end
