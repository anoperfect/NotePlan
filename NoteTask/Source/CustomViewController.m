//
//  CustomViewController.m
//  NoteTask
//
//  Created by Ben on 16/8/20.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "CustomViewController.h"






@interface CustomViewController () <MBProgressHUDDelegate>
@property (nonatomic, strong) MBProgressHUD *messageIndicationHUD;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) MBProgressHUD *popupHUD;

@property (nonatomic, assign) NSTimeInterval messageIndicationTime;
@property (nonatomic, strong) void(^popupViewDismissBlock)(void);
@property (nonatomic, assign) BOOL      hiddenByPush;


@property (nonatomic, strong) NSMutableArray<NSNumber*> *viewControllersWillAppear;
@property (nonatomic, strong) NSMutableArray<NSNumber*> *viewControllersWillDisAppear;

@property (nonatomic, strong) UIView    *contentView;
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
        CGPoint offset = self.messageIndicationHUD.offset;
        self.messageIndicationHUD.offset = CGPointMake(offset.x, 100 - VIEW_HEIGHT / 2);
    }
    
    self.messageIndicationHUD.detailsLabel.font = [UIFont systemFontOfSize:16];
    self.messageIndicationHUD.detailsLabel.text = text;
    [self.messageIndicationHUD showAnimated:YES];
    
    NSTimeInterval secs = self.messageIndicationTime;
    if(secs > 0.0) {
        [self.messageIndicationHUD hideAnimated:YES afterDelay:secs];
    }
}


- (void)dismissIndicationText
{
    [self.messageIndicationHUD hideAnimated:YES];
}


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
    
    self.progressHUD.label.text = text;
    [self.progressHUD showAnimated:YES];
    
    if(secs > 0.0) {
        [self.progressHUD hideAnimated:YES afterDelay:secs];
    }
}


- (void)dismissProgressText
{
    [self.progressHUD hideAnimated:YES];
}


const NSInteger kActionButtonTag = 6000;

/*
 actionMenu dictionary:
 string:
 image:
 */
- (void)showActionMenus:(NSArray<NSDictionary*>*)actionMenus
         selectedHandle:(void(^)(NSInteger idx, NSDictionary* menuData))select
                dismiss:(void(^)(void))dismiss
{
    ActionMenuViewController *vc = [ActionMenuViewController actionMenuViewControllerWithDatas:actionMenus];
    [self presentViewController:vc animated:YES completion:nil];
}

NSInteger const ktagPopupViewContainer = 1000000002;

- (void)showPopupView:(UIView*)view
           commission:(NSDictionary*)commission
       clickToDismiss:(BOOL)clickToDismiss
              dismiss:(void(^)(void))dismiss
{
    UIView *containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    containerView.backgroundColor = [UIColor colorWithName:@"PopupContainerBackground"];
    containerView.alpha = 0.9;
    containerView.tag = ktagPopupViewContainer;
    [[[UIApplication sharedApplication] keyWindow] addSubview:containerView];
    [containerView addSubview:view];
    
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
    
    self.popupViewDismissBlock = dismiss;
}




- (void)dismissPopupView
{
    if(self.popupViewDismissBlock) {
        self.popupViewDismissBlock();
    }
    
    UIView *containerView = [[[UIApplication sharedApplication] keyWindow] viewWithTag:ktagPopupViewContainer];
    for(id obj in containerView.subviews) {
        [obj removeFromSuperview];
    }
    
    [containerView removeFromSuperview];
    containerView = nil;
    
    if(self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)showPopupView1:(UIView*)view
           commission:(NSDictionary*)commission
       clickToDismiss:(BOOL)clickToDismiss
              dismiss:(void(^)(void))dismiss
{
    PopViewController *vc = [[PopViewController alloc] init];
    UIView *containerView = vc.view;
    
    containerView.backgroundColor = [UIColor colorWithName:@"PopupContainerBackground"];
    containerView.alpha = 0.9;
    containerView.tag = ktagPopupViewContainer;
//    [containerView addSubview:view];
    vc.popupView = view;
//    self.popupView_w = view;
    
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
    
    self.popupViewDismissBlock = dismiss;
    

    
    [self presentViewController:vc animated:NO completion:nil];
}


- (void)dismissPopupView1
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
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


- (void)showMenus:(NSArray<NSDictionary*>*)menus
             text:(id)text
     selectAction:(void(^)(NSInteger idx, NSDictionary* menu))selectAction
{
    CustomTableView *customTableView = [[CustomTableView alloc] initWithFrame:CGRectMake(VIEW_WIDTH, 0, VIEW_WIDTH, VIEW_HEIGHT)];
    customTableView.tag = 100045;
    [self addSubview:customTableView];
    
    if([text isKindOfClass:[NSAttributedString class]]) {
        customTableView.sectionAttributedText = [[NSAttributedString alloc] initWithAttributedString:text];
    }
    else if([text isKindOfClass:[NSString class]]) {
        customTableView.sectionText = [NSString stringWithString:text];
    }
    customTableView.menus = menus;
    customTableView.selectAction = selectAction;
    
    
//    [customTableView setMenuDatas:menus selectAction:selectAction];
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
@property (nonatomic, assign) CGFloat sectionHeight;

@end


@implementation CustomTableView


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat widthPercentage = 0.80;
    CGRect frame = self.frame;
    CGRect frameTableView = CGRectMake((1-widthPercentage) * frame.size.width, 0, widthPercentage * frame.size.width, frame.size.height);
    
    BOOL reload = YES;
    if(!_menuTableView) {
        
        _menuTableView = [[UITableView alloc] initWithFrame:frameTableView];
        [self addSubview:_menuTableView];
        _menuTableView.tag = 100045;
        _menuTableView.dataSource = self;
        _menuTableView.delegate = self;
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


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(!self.sectionText && self.sectionAttributedText) return nil;
    
    CGRect frame = tableView.bounds;
    UIEdgeInsets edge = UIEdgeInsetsMake(10, 10, 10, 10);
    frame = UIEdgeInsetsInsetRect(frame, edge);
    
    UILabel *lable = [[UILabel alloc] initWithFrame:frame];
    lable.numberOfLines = 0;
    if(self.sectionAttributedText) {
        lable.attributedText = self.sectionAttributedText;
    }
    else {
        lable.text = self.sectionText;
    }
    
    CGSize size = [lable sizeThatFits:frame.size];
    frame.size.height = size.height;
    lable.frame = frame;
    
    self.sectionHeight = size.height + edge.top + edge.bottom;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, self.sectionHeight)];
    [view addSubview:lable];
    
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(!self.sectionText && self.sectionAttributedText) return 1;
    
    CGRect frame = tableView.bounds;
    frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(10, 10, 10, 10));
    
    UILabel *lable = [[UILabel alloc] initWithFrame:frame];
    lable.numberOfLines = 0;
    if(self.sectionAttributedText) {
        lable.attributedText = self.sectionAttributedText;
    }
    else {
        lable.text = self.sectionText;
    }
    
    CGSize size = [lable sizeThatFits:frame.size];
    frame.size.height = size.height;
    lable.frame = frame;
    
    self.sectionHeight = size.height;
    return self.sectionHeight + 20;
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
    
    if([menu[@"disableSelction"] boolValue]) {
        NSLog(@"disableSelction");
        return ;
    }
    
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


//当前未使用.
@interface ActionMenuViewController ()

@property (nonatomic, strong) NSArray<NSDictionary*>* datas;

@property (nonatomic, strong) NSMutableArray<NSString*> *buttonTexts;
@end


@implementation ActionMenuViewController

+ (ActionMenuViewController*)actionMenuViewControllerWithDatas:(NSArray<NSDictionary*>*)datas
{
    ActionMenuViewController *vc = [[ActionMenuViewController alloc] init];
    vc.datas = datas;
    [vc displayMenus];
    
    return vc;
}


- (void)displayMenus
{
    NSInteger idx = 0;
    CGFloat buttonWidth = 60;
    
    _buttonTexts = [[NSMutableArray alloc] init];
    for(NSDictionary *d in self.datas) {
        if([d[@"string"] isKindOfClass:[NSString class]]) {
            [_buttonTexts addObject:d[@"string"]];
        }
    }
    
    NSInteger count = _buttonTexts.count;
    for(NSString *text in _buttonTexts) {
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(0, 0, buttonWidth, buttonWidth);
        [button setTitle:text forState:UIControlStateNormal];
        button.center = CGPointMake(self.view.frame.size.width - buttonWidth + buttonWidth / 2, buttonWidth / 2);
        
        button.tag = idx + kActionButtonTag;
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
        
        CALayer *borderLayer = [CALayer layer];
        CGFloat padding = buttonWidth * 0.125;
        borderLayer.frame = CGRectMake(padding, padding, buttonWidth - 2 * padding, buttonWidth - 2 * padding);
        borderLayer.borderColor = [UIColor blackColor].CGColor;
        borderLayer.borderWidth = 1;
        borderLayer.cornerRadius = borderLayer.frame.size.width / 2;
        borderLayer.name = @"round";
        [button.layer addSublayer:borderLayer];
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 17, 0, 17);//测试经验值.
        button.hidden = YES;
        
        [self.view addSubview:button];
        
        idx ++;
    }
    
    [UIView animateWithDuration:0.6
                     animations:^{
                         for(NSInteger idx = 0; idx < count ; idx ++) {
                             UIView *view = [self.view viewWithTag:idx+kActionButtonTag];
                             view.center = CGPointMake(self.view.frame.size.width - buttonWidth + buttonWidth / 2, (idx * buttonWidth + buttonWidth / 2) * 1.1);
                             view.hidden = NO;
                         }
                     }
     
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              for(NSInteger idx = 0; idx < count ; idx ++) {
                                                  UIView *view = [self.view viewWithTag:idx+kActionButtonTag];
                                                  view.center = CGPointMake(self.view.frame.size.width - buttonWidth + buttonWidth / 2, (idx * buttonWidth + buttonWidth / 2) * 1.0);
                                              }
                                          }
                          
                                          completion:^(BOOL finished) {
                                              
                                              
                                              
                                          }
                          ];
                         
                         
                         
                     }
     ];
}


- (void)buttonClick:(UIButton*)button
{
    NSInteger index = button.tag - kActionButtonTag;
    if(index >= 0 && index < self.datas.count) {
        [UIView animateWithDuration:0.6
                         animations:^{
                             for(CALayer *layer in button.layer.sublayers) {
                                 if([layer.name isEqualToString:@"round"]) {
                                     layer.borderWidth = 3.6;
                                     //                             button.layer.backgroundColor = [UIColor purpleColor].CGColor;
                                     
                                     layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
                                     layer.shadowOffset = CGSizeMake(4,4);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
                                     layer.shadowOpacity = 0.8;//阴影透明度，默认0
                                     layer.shadowRadius = 4;//阴影半径，默认3
                                     
                                     break;
                                 }
                             }
                         }
                         completion:^(BOOL finished) {
                             //                             button.layer.borderWidth = 1.7;
                             
                         }
         ];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(actionMenuSelected:data:)]) {
                [self.delegate actionMenuSelected:index data:self.datas[index]];
            }
        });
    }
}


@end




@implementation PopViewController

- (void)viewDidLoad
{
    LOG_POSTION
    [super viewDidLoad];
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}


- (void)viewWillLayoutSubviews
{
    LOG_POSTION
    [super viewWillLayoutSubviews];
}


- (void)viewWillAppear:(BOOL)animated
{
    LOG_POSTION
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    LOG_POSTION
    [super viewWillDisappear:animated];
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    LOG_POSTION
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


- (void)viewDidAppear:(BOOL)animated
{
    LOG_POSTION
    [super viewDidAppear:animated];
    
    if(self.popupView) {
        [self.view addSubview:self.popupView];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    LOG_POSTION
    [super viewDidDisappear:animated];
}


- (void)viewDidLayoutSubviews
{
    LOG_POSTION
    [super viewDidLayoutSubviews];
}













@end