//
//  CLDropDownMenu.m
//  自定制下拉菜单
//
//  Created by hezhijingwei on 16/6/28.
//  Copyright © 2016年 秦传龙. All rights reserved.
//

#import "CLDropDownMenu.h"


#define CL_SCREEN_FRAME [UIScreen mainScreen].bounds
#define CL_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define CL_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface CLDropDownMenu ()<UITableViewDelegate,UITableViewDataSource> {
    
    NSArray *_titleList;
    
}

/**
 *  背景视图暗色的
 */
@property (nonatomic ,strong) UIView *bgView;

@property (nonatomic ,strong) UITableView *tableView;

@property (nonatomic, assign) CGRect BtnPressedFrame;

@property (nonatomic, copy) indexPressedBlock block;

@property (nonatomic ,strong) UIImageView *bgImageView;


@end


@implementation CLDropDownMenu



-(instancetype)initWithBtnPressedByWindowFrame:(CGRect)frame Pressed:(indexPressedBlock)indexPressed{
    
    self = [super initWithFrame:CL_SCREEN_FRAME];
    
    if (self) {
        self.block = indexPressed;
        self.BtnPressedFrame = frame;
        self.direction = CLDirectionTypeBottom;
        [self createWindowBySelf];
        [self addTapGesture];
    }
    
    return self;
}


- (UIImageView *)bgImageView {
    
    if (nil == _bgImageView) {
        
        UIImage *image = [UIImage imageNamed:@"Bottombg"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        image  = [image resizableImageWithCapInsets:UIEdgeInsetsMake(30,30 ,30, 30) resizingMode:UIImageResizingModeStretch];
        imageView.frame = CGRectZero;
        _bgImageView = imageView;
        [self addSubview:imageView];
        _bgImageView.userInteractionEnabled = YES;
    }
    return _bgImageView;
    
}



- (UITableView *)tableView {
    
    if (nil == _tableView) {
        
        
        _tableView = [[UITableView alloc] initWithFrame:self.bgImageView.frame style:UITableViewStylePlain];
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
        _tableView.bounces = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        
        
    }
    
    return _tableView;
    
}

- (NSArray *)titleList {
    
    return _titleList;
    
}


- (void)setTitleList:(NSArray *)titleList {
    
    _titleList = titleList;
    [self.bgImageView addSubview:self.tableView];
    
    [self show];
    
    
    
    [self.tableView reloadData];
    
}


- (void)show {
    CGFloat btnX = self.BtnPressedFrame.origin.x;
    CGFloat btnY = self.BtnPressedFrame.origin.y;
    CGFloat btnW = self.BtnPressedFrame.size.width;
    CGFloat btnH = self.BtnPressedFrame.size.height;
   
    switch (self.direction) {
        case CLDirectionTypeTop:
        {
            
            CGRect tableStartFrame = CGRectMake(0, 0, 1, 1);
            CGRect tableEndFrame   = CGRectMake(0, 0, CL_SCREEN_WIDTH/3.0, self.titleList.count*44);
            CGRect bgStartFrame    = CGRectMake(btnX, btnY - 8, 1, 1);
            CGRect bgEndFrame      = CGRectMake(btnX, btnY -self.titleList.count*44 - 18 , CL_SCREEN_WIDTH/3.0, self.titleList.count*44+10);
            [self allVerShowWithImageName:@"top" initTabelViewStartFrame:tableStartFrame TabelViewEndFrame:tableEndFrame bgStartFrame:bgStartFrame bgEndFrame:bgEndFrame flag:1];
            
            
        }
            
            break;
        case CLDirectionTypeBottom:
        {
            
            CGRect tableStartFrame = CGRectMake(0, 10, 1, 1);
            CGRect tableEndFrame   = CGRectMake(0, 10, CL_SCREEN_WIDTH/3.0, self.titleList.count*44);
            CGRect bgStartFrame    = CGRectMake(btnX + btnW, btnY + btnH + 8, 1, 1);
            CGRect bgEndFrame      = CGRectMake(btnW + btnX - CL_SCREEN_WIDTH/3.0, btnY + btnH + 8, CL_SCREEN_WIDTH/3.0, self.titleList.count*44+10);
            
            [self allVerShowWithImageName:@"Bottombg" initTabelViewStartFrame:tableStartFrame TabelViewEndFrame:tableEndFrame bgStartFrame:bgStartFrame bgEndFrame:bgEndFrame flag:0];
        }
            
            break;
            
        case CLDirectionTypeLeft:
        {
            CGRect startFrame = CGRectMake(btnX - 8 , btnY, 1, 1);
            CGRect endFrame   = CGRectMake(btnX - CL_SCREEN_WIDTH/3.0 - 8, btnY , CL_SCREEN_WIDTH/3.0, self.titleList.count*44);
            [self allHevShowWithImageName:@"left" initFrame:startFrame EndFrame:endFrame];
        }
            
            break;
            
        case CLDirectionTypeRight:
        {
            CGRect startFrame = CGRectMake(btnX + btnW + 8 , btnY, 1, 1);
            CGRect endFrame   = CGRectMake(btnX + btnW + 8 , btnY , CL_SCREEN_WIDTH/3.0, self.titleList.count*44);
            
            [self allHevShowWithImageName:@"right" initFrame:startFrame EndFrame:endFrame];
        
        }
            
            break;
            
        default:
            break;
    }
    
    
    
}

- (void)allHevShowWithImageName:(NSString *)imageName initFrame:(CGRect)frame EndFrame:(CGRect)endFrame {
    
    self.bgImageView.image = [UIImage imageNamed:imageName];
    
    self.bgImageView.frame = frame;
    
    if (self.titleList.count > 5) {
        
        [UIView animateWithDuration:0.15 animations:^{

            
            self.bgImageView.frame = CGRectMake(endFrame.origin.x, endFrame.origin.y, endFrame.size.width, 5*44);
            
            self.bgImageView.alpha = 1;
            self.tableView.frame = CGRectMake(0, 0, CL_SCREEN_WIDTH/3.0 - 10, self.bgImageView.frame.size.height);
        }];
    } else {
        
        [UIView animateWithDuration:0.15 animations:^{
            
            self.bgImageView.frame = endFrame;
            self.tableView.frame = CGRectMake(0, 0, CL_SCREEN_WIDTH/3.0 - 10, self.bgImageView.frame.size.height);
            self.bgImageView.alpha = 1;
        }];
        
        
    }

    
    
}


- (void)allVerShowWithImageName:(NSString *)imageName initTabelViewStartFrame:(CGRect)frame TabelViewEndFrame:(CGRect)endFrame bgStartFrame:(CGRect)bgStartFrame bgEndFrame:(CGRect)bgEndFrame flag:(NSInteger)flag{
    
    self.bgImageView.image = [UIImage imageNamed:imageName];
    
    self.bgImageView.frame = bgStartFrame;
    self.tableView.frame = frame;
    if (self.titleList.count > 5) {
        
        [UIView animateWithDuration:0.15 animations:^{
            
            flag == 1 ?(self.bgImageView.frame = CGRectMake(bgEndFrame.origin.x, self.BtnPressedFrame.origin.y - 44*5 - 18, bgEndFrame.size.width, 44*5+10)):(self.bgImageView.frame = CGRectMake(bgEndFrame.origin.x, bgEndFrame.origin.y, bgEndFrame.size.width, 44*5+10));
            
            self.tableView.frame = CGRectMake(0, endFrame.origin.y, CL_SCREEN_WIDTH/3.0, self.bgImageView.frame.size.height - 10 );
            self.bgImageView.alpha = 1;
        }];
    } else {
        
        [UIView animateWithDuration:0.15 animations:^{
            
            self.bgImageView.frame = bgEndFrame;
            self.tableView.frame = CGRectMake(0, endFrame.origin.y, CL_SCREEN_WIDTH/3.0, self.bgImageView.frame.size.height - 10);
            self.bgImageView.alpha = 1;
        }];
        
        
    }
    
    
    
    

    
}



- (void)addTapGesture {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    [self.bgView addGestureRecognizer:tap];
    
}

- (void)close {
    
    
    CGFloat btnX = self.BtnPressedFrame.origin.x;
    CGFloat btnY = self.BtnPressedFrame.origin.y;
    CGFloat btnW = self.BtnPressedFrame.size.width;
    CGFloat btnH = self.BtnPressedFrame.size.height;
    
    
    switch (self.direction) {
        case CLDirectionTypeTop:
        {
            
            [self allCloseWithFrame:CGRectMake(btnX , btnY - 8, 1, 1)];
            break;
        }
        
        case CLDirectionTypeBottom:
        {
            
            [self allCloseWithFrame:CGRectMake(btnX + btnW, btnY + btnH + 8, 1, 1)];
            break;
        }
            
            
            
       
        case CLDirectionTypeLeft:
        {
        
            [self allCloseWithFrame:CGRectMake(btnX - 8 , btnY, 1, 1)];
             break;
        }
            
           
            
        
        case CLDirectionTypeRight:
        {
            
            [self allCloseWithFrame:CGRectMake(btnX + btnW + 8 , btnY, 1, 1)];
            break;
        }
            
            
        default:
            break;
    }

}




- (void)allCloseWithFrame:(CGRect)frame {

    if (_bgView) {
        
        [UIView animateWithDuration:0.15 animations:^{
            
            self.bgImageView.frame = frame;
            self.tableView.frame = CGRectMake(0, 0, 1, 1);
            
            self.alpha = 0;
            
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
        
        
    }
    
    
}



- (void)createWindowBySelf {

    UIView *view = [[UIView alloc] initWithFrame:CL_SCREEN_FRAME];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.1;
    self.bgView = view;
    
    [self addSubview:view];
    
    
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_block) {
        _block(indexPath.row);
    }
    
    
    [self close];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.titleList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DropDownMenuCell"];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DropDownMenuCell"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = self.titleList[indexPath.row];
    return cell;
}



@end
