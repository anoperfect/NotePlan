//
//  TaskEditTitleViewController.m
//  NoteTask
//
//  Created by Ben on 16/10/24.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskEditTitleViewController.h"
#import "TaskCell.h"
@interface TaskEditTitleViewController ()

@end

@implementation TaskEditTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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






























































static NSString *kStringStepCreateTitle = @"1. 任务内容";
static NSString *kStringStepScheduleDay = @"2. 执行日期";






@interface TaskCreateViewController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextView  *taskContentInputView;
@property (nonatomic, strong) UIButton  *taskContentButton;
@property (nonatomic, strong) UIPickerView  *picker;
@property (nonatomic, strong) NSArray  *pickerDatas;

@property (nonatomic, strong) TaskSelector  *selector;

@property (nonatomic, strong) TaskDaySelector *taskDaySelector;




@property (nonatomic, strong) NSMutableDictionary *optumizeHeights;
@property (nonatomic, strong) NSMutableArray *steps;
@property (nonatomic, assign) BOOL titleInputed;




@end




@implementation TaskCreateViewController 

- (void)viewDidLoad
{
    LOG_POSTION
    [super viewDidLoad];
    
    //数据.
    self.optumizeHeights = [[NSMutableDictionary alloc] init];
    self.steps = [@[
                    kStringStepCreateTitle,
                    kStringStepScheduleDay,
                    
                    
                    
                    ]
                  mutableCopy];
    
    //UI.
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.tableView registerClass:[TaskDaySelector class] forCellReuseIdentifier:@"TaskDaySelector"];
    
    self.picker = [[UIPickerView alloc] init];
//    self.picker.backgroundColor = [UIColor blueColor];
    self.picker.dataSource = self;
    self.picker.delegate = self;
    self.pickerDatas = @[@"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", @"星期日", ];
    
    self.selector = [[TaskSelector alloc] init];
    self.selector.datas = @[@"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", @"星期日", ];
    

    self.taskDaySelector = [[TaskDaySelector alloc] init];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.taskContentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 36)];
        [self.taskContentButton addTarget:self action:@selector(actionButtonCreateTitle:) forControlEvents:UIControlEventTouchDown];
        self.taskContentButton.titleLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        CALayer *layer = [CALayer layer];
        layer.bounds = CGRectMake(0, 0, 36, 20);
        layer.position = CGPointMake(self.taskContentButton.frame.size.width/2, self.taskContentButton.frame.size.height/2);
        layer.borderWidth = 1.;
        layer.borderColor = [UIColor blackColor].CGColor;
        layer.cornerRadius = 2;
        [self.taskContentButton.layer addSublayer:layer];
        
        self.taskContentInputView = [[UITextView alloc] init];
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        [self.taskContentInputView becomeFirstResponder];
        
    });
    
    [self addSubview:self.tableView];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = VIEW_BOUNDS;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"创建任务";
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}



- (void)navigationItemRightInit
{
    PushButtonData *buttonDataMore = [[PushButtonData alloc] init];
    buttonDataMore.actionString = @"more";
    buttonDataMore.imageName = @"more";
    PushButton *buttonMore = [[PushButton alloc] init];
    buttonMore.frame = CGRectMake(0, 0, 44, 44);
    buttonMore.actionData = buttonDataMore;
    buttonMore.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    [buttonMore setImage:[UIImage imageNamed:buttonDataMore.imageName] forState:UIControlStateNormal];
    [buttonMore addTarget:self action:@selector(actionMore) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *itemMore = [[UIBarButtonItem alloc] initWithCustomView:buttonMore];
    
    self.navigationItem.rightBarButtonItems = @[
                                                itemMore,
                                                ];
    
    
    
    
}













#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat heightHeader = 36;
    CGFloat heightTitle = 36;
    NSString *step = self.steps[section];
    
    if(section == 0 || section == 1) {
        UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, heightHeader)];
        sectionHeaderView.backgroundColor = [UIColor colorWithName:@"TaskDetailRecordHeaderBackground"];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, heightTitle)];
        [sectionHeaderView addSubview:titleLabel];
        titleLabel.text = step;
    
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 60 - 10, 0, 60, heightTitle)];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:@"保存" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(actionClickSectionHeaderButton:) forControlEvents:UIControlEventTouchDown];
        [sectionHeaderView addSubview:button];
        button.tag = section;
        button.titleLabel.font = FONT_SMALL;
        
        CALayer *layer = [CALayer layer];
        layer.bounds = CGRectMake(0, 0, 36, 20);
        layer.position = CGPointMake(button.frame.size.width/2, button.frame.size.height/2);
        layer.borderWidth = 1.;
        layer.borderColor = [UIColor blackColor].CGColor;
        layer.cornerRadius = 2;
        [button.layer addSublayer:layer];
        
        return sectionHeaderView;
    }
#if 0
    if(section == 1) {
        
        UIView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"x"];
        NSLog(@"---%@", sectionHeaderView);
        
        if(!sectionHeaderView) {
            sectionHeaderView = [[UIView alloc] init];
            UILabel *titleLabel = [[UILabel alloc] init];
            [sectionHeaderView addSubview:titleLabel];
            titleLabel.tag = 100;
            
            CGFloat heightSelector = 28;
            self.daysTypeSelector.frame = CGRectMake(127, (heightHeader-heightSelector) / 2, 160, heightSelector);
            self.daysTypeSelector.tintColor = [UIColor blackColor];
            [sectionHeaderView addSubview:self.daysTypeSelector];
        }
        
        
        sectionHeaderView.frame = CGRectMake(0, 0, tableView.frame.size.width, 36.0);
        sectionHeaderView.backgroundColor = [UIColor colorWithName:@"TaskDetailRecordHeaderBackground"];
        UILabel *titleLabel = (UILabel*)[sectionHeaderView viewWithTag:100];
        titleLabel.frame = CGRectMake(10, 0, 100, heightTitle);
        titleLabel.text = step;
        
        
        
        
        
        

        
        
        
        return sectionHeaderView;
    }
#endif
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 36.0;
    NSNumber *heightNumber = [self.optumizeHeights objectForKey:indexPath];
    if([heightNumber isKindOfClass:[NSNumber class]]) {
        height = [heightNumber floatValue];
    }
    
    return height;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections ;
    sections = self.steps.count;
    return sections;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = self.steps[section];
    return title;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowNumber = 0;
    NSString *step = self.steps[section];
    if([step isEqualToString:kStringStepCreateTitle]) {
        rowNumber = 1;
    }
    
    if([step isEqualToString:kStringStepScheduleDay]) {
        rowNumber = 1;
    }
    
    NSLog(@"---section%zd : rows = %zd", section, rowNumber);
    return rowNumber;
}



- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
//    NSInteger row = indexPath.row;
    NSString *step = self.steps[section];
    if([step isEqualToString:kStringStepCreateTitle]) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        CGFloat heightInput = 72;
        if(self.taskContentInputView.text.length > 0) {
            CGSize size = [self.taskContentInputView sizeThatFits:CGSizeMake(cell.frame.size.width, heightInput)];
            if(heightInput < size.height) {
                heightInput = size.height;
            }
        }
        
        CGFloat x = 20;
        self.taskContentInputView.frame = CGRectMake(x, 0, cell.frame.size.width - x, heightInput);
        [cell addSubview:self.taskContentInputView];
        
        if(self.titleInputed) {
            self.taskContentInputView.editable = NO;
        }
        
        self.optumizeHeights[indexPath] = @(heightInput);
        return cell;
    }
    
    if([step isEqualToString:kStringStepScheduleDay]) {
        LOG_POSTION
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        self.taskDaySelector.frame = CGRectMake(0, 0, tableView.frame.size.width, 100);
        [cell addSubview:self.taskDaySelector];
        self.optumizeHeights[indexPath] = @(self.taskDaySelector.optumizeHeight);
        return cell;
    }
    
    
    
    
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    //    NSInteger row = indexPath.row;
    NSString *step = self.steps[section];
    
    if([step isEqualToString:kStringStepCreateTitle]) {
        self.taskContentInputView.editable = YES;
        [self.taskContentInputView becomeFirstResponder];
    }
    
    if([step isEqualToString:kStringStepScheduleDay]) {
        [self actionDisplayCalendar];
    }
    
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}



#pragma mark - action
- (void)actionMore
{
    
}


- (void)actionButtonCreateTitle:(UIButton*)button
{
    if([button.titleLabel.text isEqualToString:@"编辑"]) {
        self.taskContentInputView.editable = YES;
        [self.taskContentInputView becomeFirstResponder];
        [button setTitle:@"保存" forState:UIControlStateNormal];
        return ;
    }
    
    if([button.titleLabel.text isEqualToString:@"保存"]) {
        self.taskContentInputView.editable = NO;
        [self.taskContentInputView resignFirstResponder];
        [button setTitle:@"编辑" forState:UIControlStateNormal];
        return ;
    }
    
    
    LOG_POSTION
}

- (void)actionDisplayCalendar
{
    LOG_POSTION
    
    
}


- (void)actionClickSectionHeaderButton:(UIButton*)button
{
    if(button.tag == 0) {
        NSString *title = button.titleLabel.text;
        NSLog(@"section 0 click . now %@", title);
        if([title isEqualToString:@"保存"]) {
            self.taskContentInputView.editable = NO;
//            [self.taskContentInputView resignFirstResponder];
            [button setTitle:@"编辑" forState:UIControlStateNormal];
        }
        else if([title isEqualToString:@"编辑"]) {
            self.taskContentInputView.editable = YES;
            [self.taskContentInputView becomeFirstResponder];
            [button setTitle:@"保存" forState:UIControlStateNormal];
        }
    }
    if(button.tag == 1) {
        [self actionDateInputOn:nil];
    }
    
    
}


- (void)actionDateInputOn:(id)inputView
{
    TaskCalendar *taskCalendar = [[TaskCalendar alloc] initWithFrame:SCREEN_BOUNDS];
    [self showPopupView:taskCalendar containerAlpha:1 dismiss:^{
        
    }];
    
    
    
    
    
    
    
}



#pragma mark -数据源  nubertOfComponentsInPickerView:
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark - 数据源 pickerView: attributedTitleForRow: forComponent:
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.pickerDatas.count;
    
    
}


#pragma mark - 显示信息方法  delegate
//-(NSString *)pickerView1:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    return self.pickerDatas[row];
//}




//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger) component
//{
//    return [NSString attributedStringWith:self.pickerDatas[row]
//                                     font:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]
//                                textColor:[UIColor purpleColor]
//                          backgroundColor:nil
//                                   indent:0];
//    
//    
//    
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 36)];
    label.attributedText = [NSString attributedStringWith:self.pickerDatas[row]
                                         font:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]
                                       indent:0
                                    textColor:[UIColor purpleColor]
                            ];
    
    return label;
    
}


#pragma mark -选中行的信息
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"did select row : %zd", row);
}



#pragma mark - 行高
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 36.0;
}

@end



@interface TaskSelector () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UITableView *tableView;

@end




@implementation TaskSelector


- (instancetype)init
{
    self = [super init];
    if(self) {
        self.tableView = [[UITableView alloc] init];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self addSubview:self.tableView];
    }
    return self;
}


- (void)layoutSubviews
{
    LOG_POSTION
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}


#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.tableView.frame.size.height;
    return height;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowNumber = self.datas.count;
    return rowNumber;
}



- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:[NSString stringWithFormat:@"%p", tableView]];
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    LOG_POSTION
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
}


@end