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



static NSString *kStringNoteDefaultStyle = @"默认显示格式";
static NSString *kStringNoteDefaultTilteSize = @"笔记默认标题字体大小";
static NSString *kStringNoteDefaultContentSize = @"笔记默认文章字体大小";
static NSString *kStringTaskDefaultMode = @"默认显示模式";
static NSString *kStringAppDetail = @"关于NoteTask";





@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView1;
@property (nonatomic, strong) UITableView *tableView;


@property (nonatomic, strong) NSArray<NSString*> *menuNames;
@property (nonatomic, strong) NSDictionary<NSString*,NSArray<NSString*>*> *menu;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.menuNames =  @[@"笔记", @"任务", @"应用"];
    self.menu = @{
//                  @"笔记":@[kStringNoteDefaultTilteSize, kStringNoteDefaultContentSize],
                  @"笔记":@[kStringNoteDefaultStyle],
                  @"任务":@[kStringTaskDefaultMode],
                  @"应用":@[kStringAppDetail],
                  };
    
    self.tableView1 = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 60, 180)];
    //[self addSubview:self.tableView1];
    self.tableView1.dataSource = self;
    self.tableView1.delegate = self;
    self.tableView1.estimatedRowHeight = 100;
    self.tableView1.backgroundColor = [UIColor blueColor];
    
    self.tableView1.transform=CGAffineTransformMakeRotation(-M_PI/2);
    self.tableView1.frame = CGRectMake(0, 100, self.view.frame.size.width, 60);
    
    
    self.tableView = [[UITableView alloc] init];
    [self addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.separatorColor = [UIColor clearColor];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = VIEW_BOUNDS;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"设置";
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.menuNames.count;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.menuNames[section];
//    return @"";
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 56;
//    return 20;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray<NSString*> *namesBelongToMenu = self.menu[self.menuNames[section]];
    NSInteger rows = namesBelongToMenu.count;
    return rows;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 51;
    return height;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray<NSString*> *namesBelongToMenu = self.menu[self.menuNames[section]];
    NSString *name = namesBelongToMenu[row];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    NSLog(@"%zd : <%@> %@", indexPath.row, cell.textLabel.text, cell);
    
    cell.textLabel.text = name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 36)];
//    label.text = @"111";
//    cell.accessoryView = label;
    
    
    
//    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 36)];
//    [cell addSubview:label];
//    label.text = [NSString stringWithFormat:@"%@", name];
//    
//    LOG_VIEW_RECT(cell, @"---");
//    LOG_VIEW_RECT(cell.contentView, @"---");
//    LOG_VIEW_RECT(cell.textLabel, @"---");
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray<NSString*> *namesBelongToMenu = self.menu[self.menuNames[section]];
    NSString *name = namesBelongToMenu[row];
    
    if([name isEqualToString:kStringNoteDefaultStyle]) {
        [self pushViewControllerByName:@"SettingNoteStyleViewController"];
    }
    else if([name isEqualToString:kStringTaskDefaultMode]) {
        [self pushViewControllerByName:@"SettingTaskModeViewController"];
        
    }
    else if([name isEqualToString:kStringAppDetail]){
        [self pushViewControllerByName:@"SettingAppDetailViewController"];
    }
    
    
}






#if 0
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
#endif





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
