//
//  RootViewController.m
//  NoteTask
//
//  Created by Ben on 16/6/27.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "RootViewController.h"
#import "SummaryInRoot.h"

@interface RootViewController ()



//数据
@property (nonatomic, strong) NSMutableArray *menus;
@property (nonatomic, assign) NSInteger selectedIndex;



//UI
@property (nonatomic, strong) SummaryInRoot *summary;
@property (nonatomic, strong) UIView *menuViews;
@property (nonatomic, strong) UIView *settingButtons;


@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //数据部分.
    [self generateMenus];
    
    //UI.
    self.view.backgroundColor = [UIColor blackColor];
    
    //上面的简介.
    _summary = [[SummaryInRoot alloc] init];
    [_summary fromMenuName:_menus[_selectedIndex]];
    [self.view addSubview:_summary];
    
    //菜单的数据.
    [self buildMenus];
    
    
    
    [self buildSettingButtons];
    
    
    
    [self buildSubViewController];
}







+ (void)frameSplite:(NSString*)name to:(NSArray<NSString*> *)names withPercentages:(NSArray<NSNumber*> *)percentages
{
    
    
    
    
}


+ (void)frameSplite:(NSString*)name to:(NSArray<NSString*> *)names withHeights:(NSArray<NSNumber*> *)heights
{
    
    
}



+ (void)frameSplite:(NSString*)name toVertical:(NSArray<NSString*> *)names withPercentages:(NSArray<NSNumber*> *)percentages
{
    
    
    
    
}


+ (void)frameSplite:(NSString*)name toVertical:(NSArray<NSString*> *)names withWidths:(NSArray<NSNumber*> *)heights
{

    
}
















- (void)viewDidLayoutSubviews
{
    CGSize size = self.view.bounds.size;
    
    
    CGRect frameSummary = CGRectMake(0, 0, size.width, size.height * 0.36);
    CGRect frameMenus = CGRectMake(0, frameSummary.origin.y + frameSummary.size.height, size.width, size.height * 0.54);
    CGRect frameSettings = CGRectMake(0, frameMenus.origin.y + frameMenus.size.height, size.width, size.height * 0.1);
    
    _summary.frame = frameSummary;
    _menuViews.frame = frameMenus;
    _settingButtons.frame = frameSettings;
    
    
    
}




- (void)generateMenus
{
    NSArray *menu;
    menu = @[@"笔记"];
    [_menus addObject:menu];
    
    _selectedIndex = 0;
    
    
}


- (void)buildMenus
{
    NSInteger menuCount = _menus.count;
    for(NSInteger idx = 0; idx < menuCount; idx ++) {
        UIButton *button = [[UIButton alloc] init];
        NSString *title = _menus[idx];
        [button setTitle:title forState:UIControlStateNormal];
        button.tag = idx + 100;
        
        [_menuViews addSubview:button];
    }
    
}


- (void)layoutMenus
{
    CGSize sizeMenus = _menuViews.frame.size;
    
    NSInteger menuCount = _menus.count;
    NSInteger numberInLine = 3;
    NSInteger lines = (menuCount + (numberInLine - 1)) / numberInLine;
    CGSize sizeButton = CGSizeMake(sizeMenus.width / numberInLine, sizeMenus.height / lines);
    
    for(NSInteger idx = 0; idx < menuCount; idx ++) {
        UIButton *button = [_menuViews viewWithTag:(idx + 100)];
        button.frame = CGRectMake(idx%3 * sizeButton.width, idx/3 * sizeButton.height, sizeButton.width, sizeButton.height);
    }
}


- (void)buildSettingButtons
{
    
    
    
}


- (void)buildSubViewController
{
    
    
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
