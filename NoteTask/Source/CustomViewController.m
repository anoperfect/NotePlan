//
//  CustomViewController.m
//  NoteTask
//
//  Created by Ben on 16/8/20.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "CustomViewController.h"
#import "MBProgressHUD.h"









@interface CustomViewController () <MBProgressHUDDelegate>
@property (nonatomic, strong) MBProgressHUD *messageIndicationHUD;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) MBProgressHUD *popupHUD;

@property (nonatomic, assign) NSTimeInterval messageIndicationTime;
@property (nonatomic, strong) void(^popupViewDismissBlock)(void);
@property (nonatomic, assign) BOOL      hiddenByPush;


@property (nonatomic, strong) NSMutableArray<NSNumber*> *viewControllersWillAppear;
@property (nonatomic, strong) NSMutableArray<NSNumber*> *viewControllersWillDisAppear;

@end

@implementation CustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithName:@"NavigationBackText"]];
    
    if(self.contentViewScrolled) {
        self.contentView = [[UIScrollView alloc] init];
    }
    else {
        self.contentView = [[UIView alloc] init];
    }
    [self.view addSubview:self.contentView];
    
    self.messageIndicationTime = 1.9;
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.contentView.frame = self.view.bounds;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithName:@"NavigationBarBackground"];
//    self.navigationController.navigationBar.barTintColor = [UIColor colorFromString:@"#7e9ae1@50"];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithName:@"NavigationBackText"]];
    self.navigationController.toolbarHidden = YES;
    self.navigationController.navigationBarHidden = NO;
    
    //返回只有一个箭头.
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    
    _viewControllersWillAppear = [[NSMutableArray alloc] init];
    for(UIViewController *vc in self.navigationController.viewControllers) {
        [_viewControllersWillAppear addObject:[NSNumber numberWithUnsignedLongLong:(unsigned long long)vc]];
    }
    
    NSInteger countVcs = _viewControllersWillAppear.count;
    
    BOOL detectAppearByPopBack = YES;
    if(countVcs > 0 && [_viewControllersWillAppear[countVcs-1] unsignedLongLongValue] == (unsigned long long)self) {
        if(_viewControllersWillDisAppear.count == countVcs + 1) {
            for(NSInteger idx = 0; idx < countVcs; idx ++) {
                if([_viewControllersWillAppear[idx] isEqual:_viewControllersWillDisAppear[idx]]) {
                    
                }
                else {
                    detectAppearByPopBack = NO;
                    break;
                }
            }
        }
        else {
            detectAppearByPopBack = NO;
        }
        
        if(detectAppearByPopBack) {
            [self customViewWillAppearByPopBack];
        }
        else {
            [self customViewWillAppearByPushed];
        }
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _viewControllersWillDisAppear = [[NSMutableArray alloc] init];
    for(UIViewController *vc in self.navigationController.viewControllers) {
        [_viewControllersWillDisAppear addObject:[NSNumber numberWithUnsignedLongLong:(unsigned long long)vc]];
    }
//    
//    NSInteger countVcs = _viewControllersWillDisAppear.count;
//    
//    if(countVcs >= 2 && [_viewControllersWillDisAppear[countVcs-2] unsignedLongLongValue] == (unsigned long long)self) {
//        NSLog(@"****** [%@]detectDisAppearByPushNew ", self.class);
//    }
//    
//    NSNumber *selfAddrNumber = [NSNumber numberWithUnsignedLongLong:(unsigned long long)self];
//    if(_viewControllersWillAppear.count > 0
//       && [_viewControllersWillAppear indexOfObject:selfAddrNumber] == _viewControllersWillAppear.count - 1
//       && NSNotFound == [_viewControllersWillDisAppear indexOfObject:selfAddrNumber]) {
//        NSLog(@"****** [%@]detectDisAppearByPopped", self.class);
//    }
//    
//    
//    
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.hiddenByPush = YES;
    [self.navigationController pushViewController:viewController animated:animated];
}


- (void)addSubview:(UIView*)view
{
    [self.contentView addSubview:view];
}


- (void)addSubviews:(NSArray<UIView*>*)views
{
    for(UIView *view in views) {
        [self.contentView addSubview:view];
    }
}


- (void)showIndicationTextTime:(NSTimeInterval)secs
{
    self.messageIndicationTime = secs;
}


- (void)showIndicationText:(NSString*)text
{
    NSLog(@"---xxx0 : >>>>>>IndicationText : %@", text);
    
    if(!self.messageIndicationHUD) {
        self.messageIndicationHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.messageIndicationHUD.mode = MBProgressHUDModeText;
        self.messageIndicationHUD.userInteractionEnabled = NO;
        self.messageIndicationHUD.delegate = self;
        self.messageIndicationHUD.removeFromSuperViewOnHide = NO; //设置这个.
        self.messageIndicationHUD.yOffset = 100 - VIEW_HEIGHT / 2;
    }
    
    self.messageIndicationHUD.detailsLabelFont = [UIFont systemFontOfSize:16];
    self.messageIndicationHUD.detailsLabelText = text;
    [self.messageIndicationHUD show:YES];
    
    NSTimeInterval secs = self.messageIndicationTime;
    if(secs > 0.0) {
        [self.messageIndicationHUD hide:YES afterDelay:secs];
    }
}



- (void)dismissIndicationText
{
    [self.messageIndicationHUD hide:YES];
}

////一直沿用self.messageIndicationHUD可能导致不能显示. 注意设置self.messageIndicationHUD.removeFromSuperViewOnHide = NO;
//- (void)hudWasHidden:(MBProgressHUD *)hud
//{return ;
//    self.messageIndicationHUD = nil;
//}




- (void)showProgressText:(NSString*)text inTime:(NSTimeInterval)secs
{
    NSLog(@"---xxx0 : >>>>>>ProgressText : %@", text);
    
    if(!self.progressHUD) {
        self.progressHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.progressHUD.mode = MBProgressHUDModeIndeterminate;
        self.progressHUD.userInteractionEnabled = NO;
        self.progressHUD.delegate = self;
        self.progressHUD.removeFromSuperViewOnHide = NO; //设置这个.
    }
    
    self.progressHUD.labelText = text;
    [self.progressHUD show:YES];
    
    if(secs > 0.0) {
        [self.progressHUD hide:YES afterDelay:secs];
    }
}


- (void)dismissProgressText
{
    [self.progressHUD hide:YES];
}


- (void)showPopupView:(UIView*)view
           commission:(NSDictionary*)commission
       clickToDismiss:(BOOL)clickToDismiss
              dismiss:(void(^)(void))dismiss
{
    #define TAG_popupView_container     1000000002
    UIView *containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    containerView.backgroundColor = [UIColor colorWithName:@"PopupContainerBackground"];
    containerView.alpha = 0.9;
    containerView.tag = TAG_popupView_container;
    [[[UIApplication sharedApplication] keyWindow] addSubview:containerView];
    
    if([commission[@"containerBackgroundColor"] isKindOfClass:[UIColor class]]) {
        containerView.backgroundColor = commission[@"containerBackgroundColor"];
    }
    
    if([commission[@"popAnimation"] isKindOfClass:[NSNumber class]]) {
        CGRect frameView = view.frame;
        frameView.origin.y = containerView.frame.size.height;
        view.frame = frameView;
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frameView = view.frame;
            frameView.origin.y = containerView.frame.size.height - frameView.size.height;
            view.frame = frameView;
        }];
    }
    
    if(clickToDismiss) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopupView)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [containerView addGestureRecognizer:tapGestureRecognizer];
    }
    [containerView addSubview:view];
    
    self.popupViewDismissBlock = dismiss;
}




- (void)dismissPopupView
{
    if(self.popupViewDismissBlock) {
        self.popupViewDismissBlock();
    }
    
//    UIView *containerView = [self.view viewWithTag:TAG_popupView_container];
    UIView *containerView = [[[UIApplication sharedApplication] keyWindow] viewWithTag:TAG_popupView_container];
    for(id obj in containerView.subviews) {
        //        [obj removeObserver:self forKeyPath:@"frame"];
        [obj removeFromSuperview];
    }
    
    [containerView removeFromSuperview];
    containerView = nil;
}


- (void)pushViewControllerByName:(NSString*)name
{
    UIViewController *vc = [[NSClassFromString(name) alloc] init];
    if(vc) {
        [self pushViewController:vc animated:YES];
    }
    else {
        NSLog(@"#error - vc not alloced by name (%@).", name);
    }
}


- (void)showMenus:(NSArray<NSDictionary*>*)menus selectAction:(void(^)(NSInteger idx, NSDictionary* menu))selectAction
{
    CustomTableView *customTableView = [[CustomTableView alloc] initWithFrame:CGRectMake(VIEW_WIDTH, 0, VIEW_WIDTH, VIEW_HEIGHT)];
    customTableView.tag = 100045;
    [self addSubview:customTableView];
    [customTableView setMenuDatas:menus selectAction:selectAction];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMenus1:)];
//    [customTableView addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer *swipeGestureToRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(menusSwipeToRight:)];
    //swipeGestureToRight.direction=UISwipeGestureRecognizerDirectionRight;//默认为向右轻扫
    [customTableView addGestureRecognizer:swipeGestureToRight];
    
    [UIView animateWithDuration:0.5 animations:^{
        customTableView.frame = CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT);
    } completion:^(BOOL finished) {
        
    }];
}


- (void)menusSwipeToRight:(UISwipeGestureRecognizer*)recognizer
{
    [self dismissMenus];
}


- (void)dismissMenus1:(id)sender
{
    NSLog(@"%@", sender);
    
}


- (void)dismissMenus
{
    UIView *customTableView = [self.contentView viewWithTag:100045];
    CGRect frame = customTableView.frame;
    frame.origin.x = VIEW_WIDTH;
    [UIView animateWithDuration:0.36 animations:^{
        customTableView.frame = frame;
    } completion:^(BOOL finished) {
        [customTableView removeFromSuperview];
    }];
}

//override.
- (void)customViewWillAppearByPushed
{
    NSLog(@"[%@] customViewWillAppearByPushed", self.class);
}


- (void)customViewWillAppearByPopBack
{
    NSLog(@"[%@] customViewWillAppearByPopBack", self.class);
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





@interface CustomTableView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *menuTableView;
@property (nonatomic, strong) NSArray<NSDictionary*>* menus;
@property (nonatomic, strong) void(^selectAction)(NSInteger idx, NSDictionary* menu);


@end


@implementation CustomTableView

- (void)setMenuDatas:(NSArray<NSDictionary*>*)menus selectAction:(void(^)(NSInteger idx, NSDictionary* menu))selectAction
{
    _menus = menus;
    _selectAction = selectAction;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat widthPercentage = 0.80;
    CGRect frame = self.frame;
    CGRect frameTableView = CGRectMake((1-widthPercentage) * frame.size.width, 0, widthPercentage * frame.size.width, frame.size.height);
    
    BOOL reload = YES;
    if(!_menuTableView) {
        
        _menuTableView = [[UITableView alloc] initWithFrame:frameTableView style:UITableViewStyleGrouped];
        [self addSubview:_menuTableView];
        _menuTableView.tag = 100045;
        _menuTableView.dataSource = self;
        _menuTableView.delegate = self;
        _menuTableView.rowHeight = 45;
    }
    else {
        CGRect framePrev = _menuTableView.frame;
        if(CGRectEqualToRect(framePrev, frameTableView)) {
            reload = NO;
        }
    }
    
    _menuTableView.backgroundColor = [UIColor colorWithName:@"CustomMenu"];
    _menuTableView.frame = frameTableView;
    if(reload) {
        [_menuTableView reloadData];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menus.count;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MenuCell"];
    cell.backgroundColor = [UIColor clearColor];
    NSDictionary *menu = self.menus[indexPath.row];
    
    /*
     text : 
     image : 
     detailText :
     accessoryType :
     
     
     */
    
    if(menu[@"text"]) {
        cell.textLabel.text = menu[@"text"];
    }
    else {
        cell.textLabel.text = nil;
    }
    
    if(menu[@"detailText"]) {
        cell.detailTextLabel.text = menu[@"detailText"];
    }
    else {
        cell.detailTextLabel.text = nil;
    }
    
    if([menu[@"disableSelction"] boolValue]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    UIImage *image = menu[@"image"];
    if([image isKindOfClass:[UIImage class]]) {
         cell.imageView.image = [UIImage imageNamed:@"finish"];
    }
    
    if(menu[@"accessoryType"]) {
        cell.accessoryType = [menu[@"accessoryType"] integerValue];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *menu = self.menus[indexPath.row];
    NSLog(@"menu : %@", menu);
    if([menu[@"deselectRow"] boolValue]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else {
        if(self.selectAction) {
            self.selectAction(indexPath.row, self.menus[indexPath.row]);
        }
        else {
            LOG_POSTION
        }
    }
}



@end