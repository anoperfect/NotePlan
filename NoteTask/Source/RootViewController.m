//
//  RootViewController.m
//  NoteTask
//
//  Created by Ben on 16/6/27.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "RootViewController.h"
#import "SummaryInRoot.h"
#import "FrameSplite.h"
#import "MenuButton.h"



@interface RootViewController ()



//数据
@property (nonatomic, strong) NSMutableArray *menus;
@property (nonatomic, assign) NSInteger selectedIndex;



//UI
@property (nonatomic, strong) SummaryInRoot *summary;

@property (nonatomic, strong) NSMutableArray *buttons;


@property (nonatomic, strong) UIView *settingView;


@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //数据部分.
    [self generateMenus];
    
    //UI.
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = YES;
    
    //上面的简介.
    _summary = [[SummaryInRoot alloc] init];
    [_summary fromMenuName:_menus[_selectedIndex]];
    _summary.tag = 1;
    [self.view addSubview:_summary];
    
    //菜单的数据.
    [self buildMenus];
    
    
    
    [self buildSettingButtons];
    
    
    
    [self buildSubViewController];
}




- (void)viewWillLayoutSubviews
{
    CGSize size = self.view.bounds.size;
    
    FrameSplite *f = [[FrameSplite alloc] initWithSize:size];
    [f frameSplite:FRAMESPLITE_NAME_MAIN
                to:@[@"summary", @"menus", @"settings"]
   withPercentages:@[@(0.36), @(0.54), @(0.1)]];
    
    _summary.frame =[f frameSpliteGet:@"summary"];
    
    [f frameSpliteEqual:@"menus" to:@[@"menusLine1", @"menusLine2", @"menusLine3"]];
    
    [f frameSpliteEqual:@"menusLine1" toVertical:@[@"button1", @"button2", @"button3"]];
    [f frameSpliteEqual:@"menusLine2" toVertical:@[@"button4", @"button5", @"button6"]];
    [f frameSpliteEqual:@"menusLine3" toVertical:@[@"button7", @"button8", @"button9"]];
    
    for(UIButton *button in _buttons) {
        NSString *name = [NSString stringWithFormat:@"button%zd", button.tag - 100 + 1];
        button.frame = [f frameSpliteGet:name];
    }
    
    _settingView.frame = [f frameSpliteGet:@"settings"];
    
//    NSLog(@"f : \n%@", f);
    
    NSMutableArray *layers = [[NSMutableArray alloc] init];
    
    for(CALayer *layer in self.view.layer.sublayers) {
        if([layer valueForKey:@"menuButtonLayer"]) {
            [layers addObject:layer];
        }
    }
    
    [layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    UIColor *layerColor = [UIColor whiteColor];
    CGFloat layerWidth = 0.5;
    
    //add menuButtons border line.
    CGRect frameLayer ;
    CALayer * line;
    
    line = [CALayer layer];
    [line setValue:@100 forKey:@"menuButtonLayer"];
    line.backgroundColor = layerColor.CGColor;
    frameLayer = [f frameSpliteGet:@"menusLine1"];
    frameLayer.size.height = layerWidth;
    line.frame = frameLayer;
    [self.view.layer addSublayer:line];
    
    line = [CALayer layer];
    [line setValue:@100 forKey:@"menuButtonLayer"];
    line.backgroundColor = layerColor.CGColor;
    frameLayer = [f frameSpliteGet:@"menusLine2"];
    frameLayer.size.height = layerWidth;
    line.frame = frameLayer;
    [self.view.layer addSublayer:line];
    
    line = [CALayer layer];
    [line setValue:@100 forKey:@"menuButtonLayer"];
    line.backgroundColor = layerColor.CGColor;
    frameLayer = [f frameSpliteGet:@"menusLine3"];
    frameLayer.size.height = layerWidth;
    line.frame = frameLayer;
    [self.view.layer addSublayer:line];
    
    line = [CALayer layer];
    [line setValue:@100 forKey:@"menuButtonLayer"];
    line.backgroundColor = layerColor.CGColor;
    frameLayer = [f frameSpliteGet:@"menusLine3"];
    frameLayer.origin.y += frameLayer.size.height;
    frameLayer.size.height = layerWidth;
    line.frame = frameLayer;
    [self.view.layer addSublayer:line];
    
    line = [CALayer layer];
    [line setValue:@100 forKey:@"menuButtonLayer"];
    line.backgroundColor = layerColor.CGColor;
    frameLayer = [f frameSpliteGet:@"menus"];
    frameLayer.origin.x = frameLayer.size.width / 3;
    frameLayer.size.width = layerWidth;
    line.frame = frameLayer;
    [self.view.layer addSublayer:line];
    
    line = [CALayer layer];
    [line setValue:@100 forKey:@"menuButtonLayer"];
    line.backgroundColor = layerColor.CGColor;
    frameLayer = [f frameSpliteGet:@"menus"];
    frameLayer.origin.x = frameLayer.size.width / 3 * 2;
    frameLayer.size.width = layerWidth;
    line.frame = frameLayer;
    [self.view.layer addSublayer:line];
    
    
    
    
    
    
    
    
    
    
    
}




- (void)generateMenus
{
    _menus = [[NSMutableArray alloc] init];
    
    MenuButtonData *data;
    data = [[MenuButtonData alloc] initWithDictionary:@{ @"name":@"Note", @"title":@"笔记", @"imageName":@"Note"}];
    [_menus addObject:data];
    
    data = [[MenuButtonData alloc] initWithDictionary:@{ @"name":@"Task", @"title":@"任务", @"imageName":@"Task"}];
    [_menus addObject:data];
    
    data = [[MenuButtonData alloc] initWithDictionary:@{ @"name":@"Diary", @"title":@"日记", @"imageName":@"Diary"}];
    [_menus addObject:data];
    
    data = [[MenuButtonData alloc] initWithDictionary:@{ @"name":@"Square", @"title":@"广场", @"imageName":@"Square"}];
    [_menus addObject:data];
    
    data = [[MenuButtonData alloc] initWithDictionary:@{ @"name":@"City", @"title":@"城市", @"imageName":@"City"}];
    [_menus addObject:data];
    
    data = [[MenuButtonData alloc] initWithDictionary:@{ @"name":@"Joint", @"title":@"协同", @"imageName":@"Joint"}];
    [_menus addObject:data];
    
    data = [[MenuButtonData alloc] initWithDictionary:@{ @"name":@"Twitter", @"title":@"叽喳", @"imageName":@"Twitter"}];
    [_menus addObject:data];
    
    data = [[MenuButtonData alloc] initWithDictionary:@{ @"name":@"Login", @"title":@"登录", @"imageName":@"Login"}];
    [_menus addObject:data];
    
    data = [[MenuButtonData alloc] initWithDictionary:@{ @"name":@"Advertising", @"title":@"广告", @"imageName":@"Advertising"}];
    [_menus addObject:data];
    
    _selectedIndex = 0;
    
    
}


- (void)buildMenus
{
    _buttons = [[NSMutableArray alloc] init];
    
    NSInteger menuCount = _menus.count;
//    NSLog(@"menuCount : %zd", menuCount);
    
    for(NSInteger idx = 0; idx < menuCount; idx ++) {
        MenuButton *button = [[MenuButton alloc] init];
        button.tag = idx + 100;
        [self.view addSubview:button];
        [_buttons addObject:button];
        
        [button setMenuButtonData:_menus[idx]];
        
//        NSLog(@"add button %zd", button.tag);
    }
    
}


- (void)layoutMenus
{

}


- (void)buildSettingButtons
{
    _settingView = [[UIView alloc] init];
    _settingView.tag = 3;
    
    [self.view addSubview:_settingView];
    
    
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
