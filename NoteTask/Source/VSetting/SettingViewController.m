//
//  SettingViewController.m
//  NoteTask
//
//  Created by Ben on 16/11/21.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "SettingViewController.h"






@interface HerizonTableView : UITableView



@end


@interface HerizonTableView ()

@end


@implementation HerizonTableView



@end









@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView1;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView1 = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 60, 180)];
    [self addSubview:self.tableView1];
    self.tableView1.dataSource = self;
    self.tableView1.delegate = self;
    self.tableView1.estimatedRowHeight = 100;
    self.tableView1.backgroundColor = [UIColor blueColor];
    
    self.tableView1.transform=CGAffineTransformMakeRotation(-M_PI/2);
    self.tableView1.frame = CGRectMake(0, 100, self.view.frame.size.width, 60);
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    self.title = @"设置1";
    self.navigationController.navigationBarHidden = NO;
    
    for(UIView *v in self.contentView.subviews) {
        NSLog(@"%@", v);
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 10;
    return rows;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 300;
    return height;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    NSLog(@"%zd : <%@> %@", indexPath.row, cell.textLabel.text, cell);
    
    cell.textLabel.text = [NSString stringWithFormat:@"%zd:1234567890", indexPath.row];
    cell.transform           =CGAffineTransformMakeRotation(-M_PI*1.5);
    cell.textLabel.frame = CGRectMake(0, 0, 100, 36);
    
    if(indexPath.row == 0) {
        cell.backgroundColor = [UIColor cyanColor];
    }
    
    for(UIView *v in cell.subviews) {
        NSLog(@"%@", v);
        
        
        
    }
    
    
    
    
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 36)];
    [cell addSubview:label];
    label.text = [NSString stringWithFormat:@"%zd:1234567890", indexPath.row];
    
    
    LOG_VIEW_RECT(cell, @"---");
    LOG_VIEW_RECT(cell.contentView, @"---");
    LOG_VIEW_RECT(cell.textLabel, @"---");
    
    return cell;
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
