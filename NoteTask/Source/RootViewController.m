//
//  RootViewController.m
//  NoteTask
//
//  Created by Ben on 16/6/27.
//  Copyright © 2016年 Ben. All rights reserved.
//
#import "NoteViewController.h"
#import "RootViewController.h"
#import "SummaryInRoot.h"

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
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
//    backItem.title = @"";
//    self.navigationItem.backBarButtonItem = backItem;
    
    //上面的简介.
    _summary = [[SummaryInRoot alloc] init];
    [_summary fromMenuName:_menus[_selectedIndex]];
    _summary.tag = 1;
    [self addSubview:_summary];
    
    //菜单的数据.
    [self buildMenus];
    
    [self buildSettingButtons];
    
    [self buildSubViewController];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    
//        NSString *className = @"NoteViewController";
//        Class class = NSClassFromString(className);
//        if (class) {
//            UIViewController *ctrl = class.new;
//            ctrl.title = @"Note";
//            [self.navigationController pushViewController:ctrl animated:YES];
//        }
//
//    });
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGSize size = VIEW_SIZE;
    
    FrameLayout *f = [[FrameLayout alloc] initWithSize:size];
    
    [f frameLayoutHerizon:FRAMELAYOUT_NAME_MAIN
                  toViews:@[
                            @{@"_summary":@"62%"},
                            @{@"menus":@"18%"},
                            @{@"_settings":@"20%"},
                            ]];
    
    _summary.frame =[f frameLayoutGet:@"_summary"];
    
    [f frameLayoutEqual:@"menus" to:@[@"menusLine1"]];
    
    [f frameLayoutEqual:@"menusLine1" toVertical:@[@"button1", @"button2", @"button3"]];

    for(UIButton *button in _buttons) {
        NSString *name = [NSString stringWithFormat:@"button%zd", button.tag - 100 + 1];
        button.frame = [f frameLayoutGet:name];
    }
    
    _settingView.frame = [f frameLayoutGet:@"_settings"];
    
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
    frameLayer = [f frameLayoutGet:@"menusLine1"];
    frameLayer.size.height = layerWidth;
    line.frame = frameLayer;
    [self.view.layer addSublayer:line];
    
    line = [CALayer layer];
    [line setValue:@100 forKey:@"menuButtonLayer"];
    line.backgroundColor = layerColor.CGColor;
    frameLayer = [f frameLayoutGet:@"menusLine1"];
    frameLayer.origin.y += frameLayer.size.height;
    frameLayer.size.height = layerWidth;
    line.frame = frameLayer;
    [self.view.layer addSublayer:line];
    
    line = [CALayer layer];
    [line setValue:@100 forKey:@"menuButtonLayer"];
    line.backgroundColor = layerColor.CGColor;
    frameLayer = [f frameLayoutGet:@"menus"];
    frameLayer.origin.x = frameLayer.size.width / 3;
    frameLayer.size.width = layerWidth;
    line.frame = frameLayer;
    [self.view.layer addSublayer:line];
    
    line = [CALayer layer];
    [line setValue:@100 forKey:@"menuButtonLayer"];
    line.backgroundColor = layerColor.CGColor;
    frameLayer = [f frameLayoutGet:@"menus"];
    frameLayer.origin.x = frameLayer.size.width / 3 * 2;
    frameLayer.size.width = layerWidth;
    line.frame = frameLayer;
    [self.view.layer addSublayer:line];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}


- (void)generateMenus
{
    _menus = [[NSMutableArray alloc] init];
    
    MenuButtonData *data;
    data = [[MenuButtonData alloc] initWithDictionary:@{ @"name":@"Note", @"title":@"笔记", @"imageName":@"Note"}];
    [_menus addObject:data];
    
    data = [[MenuButtonData alloc] initWithDictionary:@{ @"name":@"Task", @"title":@"任务", @"imageName":@"Task"}];
    [_menus addObject:data];
    
#if 0
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
#endif
    
    data = [[MenuButtonData alloc] initWithDictionary:@{ @"name":@"Advertising", @"title":@"广告", @"imageName":@"Advertising"}];
    data = [[MenuButtonData alloc] initWithDictionary:@{ @"name":@"Advertising", @"title":@"设置", @"imageName":@"Setting"}];
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
        [button addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchDown];
        button.tag = idx + 100;
        [self addSubview:button];
        [_buttons addObject:button];
        
        [button setMenuButtonData:_menus[idx]];
    }
    
}


- (void)clickMenu:(MenuButton*)button
{
    NSInteger idx = button.tag - 100;
    MenuButtonData *data = _menus[idx];

    for(MenuButton *buttonTraversal in _buttons) {
        BOOL equal = [buttonTraversal isEqual:button];
        if(equal) {
            buttonTraversal.backgroundColor = [UIColor colorWithName:@"MenuBackgroundHighlighted"];
        }
        else {
            buttonTraversal.backgroundColor = [UIColor colorWithName:@"MenuBackground"];
        }
    }
    
    if([data.title isEqualToString:@"笔记"]) {
        Class class = NSClassFromString(@"NoteViewController");
        if(class) {
            UIViewController *ctrl = class.new;
            ctrl.title = data.title;
            [self.navigationController pushViewController:ctrl animated:YES];
        }
        
        return ;
    }
    
    if([data.title isEqualToString:@"任务"]) {
        Class class = NSClassFromString(@"TaskViewController");
        if(class) {
            UIViewController *ctrl = class.new;
            ctrl.title = data.title;
            [self.navigationController pushViewController:ctrl animated:YES];
        }
        
        return ;
    }
    
    if([data.title isEqualToString:@"设置"]) {
        Class class = NSClassFromString(@"SettingViewController");
        if(class) {
            UIViewController *ctrl = class.new;
            ctrl.title = data.title;
            [self.navigationController pushViewController:ctrl animated:YES];
        }
        
        return ;
    }
    
    
}



- (void)layoutMenus
{

}


- (void)buildSettingButtons
{
    _settingView = [[UIView alloc] init];
    _settingView.tag = 3;
    _settingView.backgroundColor = [UIColor colorWithName:@"MenuUnderBackground"];
    
    [self addSubview:_settingView];
    
    
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








