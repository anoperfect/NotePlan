//
//  NoteParagraphCustmiseViewController.m
//  NoteTask
//
//  Created by Ben on 16/7/21.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteParagraphCustmiseViewController.h"

@interface NoteParagraphCustmiseViewController ()




/*
 前景色, 
 背景色, 
 字体大小, 
 斜体, 
 下划线, 
 边框, 
 边沿宽度.
 
 
 
 */

@property (nonatomic, strong) RangeValueView *fontsizeView;

@property (nonatomic, strong) UISwitch *fontStyleSwith;


@end

@implementation NoteParagraphCustmiseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"样式设置";
    self.view.backgroundColor = [UIColor colorWithName:@"CustomBackground"];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithName:@"NavigationBackText"]];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.navigationItem.rightBarButtonItem
            = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finish)];
    
    
    
    
    self.fontsizeView = [RangeValueView rangeValueViewWithFrame:CGRectMake(10, 100, Width-20, 0)
                                                           name:@"字体大小 - font-size"
                                                       minValue:8.0
                                                       maxValue:36.0 defaultValue:16];
    [self.view addSubview:self.fontsizeView];
    
    
    
    
    
    
    
}


- (void)finish
{
    CGFloat fontSize = self.fontsizeView.currentValue;
    
    
    
    
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
