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
@end

@implementation CustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.contentView = [[UIView alloc] init];
    [self.view addSubview:self.contentView];
}


- (void)viewWillLayoutSubviews
{
    self.contentView.frame = self.view.bounds;
}


- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithName:@"NavigationBarBackground"];
    self.navigationController.navigationBar.translucent = NO;
    
    if(self.hiddenByPush) {
        self.hiddenByPush = NO;
        //属于push后返回到此ViewController的Action.
        [self pushBackAction];
    }
    
}


- (void)pushBackAction
{
    
}





- (void)showIndicationText:(NSString*)text inTime:(NSTimeInterval)secs;
{
    NSLog(@"---xxx0 : >>>>>>IndicationText : %@", text);
    
    if(!self.messageIndicationHUD) {
        self.messageIndicationHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.messageIndicationHUD.mode = MBProgressHUDModeText;
        self.messageIndicationHUD.userInteractionEnabled = NO;
        self.messageIndicationHUD.delegate = self;
        self.messageIndicationHUD.removeFromSuperViewOnHide = NO; //设置这个.
        self.messageIndicationHUD.yOffset = 100 - self.view.bounds.size.height / 2;
    }
    
    self.messageIndicationHUD.labelText = text;
    [self.messageIndicationHUD show:YES];
    
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
{
    #define TAG_popupView_container     1000000002
    UIView *containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    containerView.backgroundColor = [UIColor colorWithName:@"PopupContainerBackground"];
    containerView.alpha = 0.9;
    containerView.tag = TAG_popupView_container;
//    [self.view addSubview:containerView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:containerView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopupView)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [containerView addGestureRecognizer:tapGestureRecognizer];
    
    [containerView addSubview:view];
    
    
    //    CustomViewController *pvc = [[CustomViewController alloc] init];
    //    [pvc.view addSubview:view];
    //    pvc.view.backgroundColor = [UIColor colorWithName:@"PopupContainerBackground"];
    //    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:pvc action:@selector(dismissPopupView)];
    //    tapGestureRecognizer.numberOfTapsRequired = 1;
    //    [pvc.view addGestureRecognizer:tapGestureRecognizer];
    //
    //    [self presentViewController:pvc animated:NO completion:^{
    //        [pvc.navigationController setNavigationBarHidden:YES];
    //    }];
    ////    [self.navigationController pushViewController:pvc animated:NO];
    
    
}


- (void)dismissPopupView
{
//    UIView *containerView = [self.view viewWithTag:TAG_popupView_container];
    UIView *containerView = [[[UIApplication sharedApplication] keyWindow] viewWithTag:TAG_popupView_container];
    for(id obj in containerView.subviews) {
        NSLog(@"%@", obj);
        //        [obj removeObserver:self forKeyPath:@"frame"];
        [obj removeFromSuperview];
    }
    
    [containerView removeFromSuperview];
    containerView = nil;
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
