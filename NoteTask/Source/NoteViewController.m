//
//  NoteViewController.m
//  NoteTask
//
//  Created by Ben on 16/7/2.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteViewController.h"
#import "NoteModel.h"
#import "NoteCell.h"
#import "NoteFilter.h"
#import "JSDropDownMenu.h"
#import "NoteDetailViewController.h"

@interface NoteViewController () <UITableViewDataSource, UITableViewDelegate,
                                        UITextFieldDelegate,
                                    JSDropDownMenuDataSource,JSDropDownMenuDelegate>
{
    
    NSMutableArray *_data1;
    NSMutableArray *_data2;
    NSMutableArray *_data3;
    
    NSInteger _currentData1Index;
    NSInteger _currentData2Index;
    NSInteger _currentData3Index;
    
}

@property (nonatomic, strong) UITableView *notesView;



@property (nonatomic, assign) CGFloat heightNoteFilter;
@property (nonatomic, strong) UIView *noteFilter;

@property (nonatomic, strong) NSMutableArray *  filterDataClassifications;
@property (nonatomic, assign) NSInteger         idxClassifications;

@property (nonatomic, strong) NSMutableArray *filterDataColors;
@property (nonatomic, assign) NSInteger         idxColor;

@property (nonatomic, strong) NSString *currentClassification;
@property (nonatomic, strong) NSString *currentColorString;
@property (nonatomic, strong) NSMutableArray<NoteModel*> *notes;

@property (nonatomic, assign) BOOL onSelectedMode;
@property (nonatomic, strong) NSMutableArray *indexPathsSelected;

@end

@implementation NoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //导航栏定制相关.
    self.navigationController.navigationBarHidden = NO;
    
    //self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"NoteBackground"].CGImage);
    self.view.backgroundColor = [UIColor colorWithName:@"CustomBackground"];
    //[self.navigationItem.backBarButtonItem setTintColor:[UIColor blackColor]];
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
//    self.navigationItem.backBarButtonItem = item;
//    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
//    
    //self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithName:@"NavigationBackText"]];
    

    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(fetchDetails)];
    
    //下一个UIViewController的返回的地方文字设置.
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    
    [self navigationItemRightInit];

    //从AppConfig中读取上次保存的类别选项.
    self.currentClassification = @"";
    self.currentColorString = @"*";
    
    //内容筛选栏创建.
    [self filterViewBuild];
    
    //笔记内容栏创建.
    [self notesViewBuild];
    
    //内容加载.
    //[self loadNotesView];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.noteFilter.frame = CGRectMake(0, 0, VIEW_WIDTH, 36);
    
    CGRect frameNotesView = VIEW_BOUNDS;
    frameNotesView.origin.y += self.heightNoteFilter ;
    frameNotesView.size.height -= self.heightNoteFilter;
    self.notesView.frame = frameNotesView;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadNotesView];
    
    return ;
#if 0
    //从NoteDetailViewController返回的时候, 需重新刷新下Note. Classification.
    //内容筛选栏创建.
    [self filterViewBuild];
    
    //笔记内容栏创建.
    [self notesViewBuild];
    
    //内容加载.
//    [self reloadWithClassification:self.currentClassification andColorString:self.currentColorString];
    //[self refreshView];
#endif
}


- (void)navigationItemRightInit
{
    UIImage *rightItemImage = [UIImage imageNamed:@"slider"];
#if 0
    CGSize itemSize = CGSizeMake(36, 36);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [rightItemImage drawInRect:imageRect];
    rightItemImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#endif
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:rightItemImage style:UIBarButtonItemStyleDone target:self action:@selector(actionMore)];
    self.navigationItem.rightBarButtonItem = rightItem;
}


//从NoteDetailViewController返回的时候, 可能修改的.
//1.增加类别. －> 需刷新filter的数据.
//2.note修改到其他类别. ->如果当前有筛选类别, 则删除此条.
//3.note修改到其他颜色. ->如果当前有筛选颜色, 则删除此条.
//4.note修改内容. ->刷新.




- (void)notesViewBuild
{
    if(!self.notesView) {
        CGRect frame = VIEW_BOUNDS;
        frame.origin.y += self.heightNoteFilter ;
        frame.size.height -= self.heightNoteFilter;
        self.notesView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        self.notesView.dataSource = self;
        self.notesView.delegate = self;
        self.notesView.backgroundColor = [UIColor clearColor];
        
        //UIPanGestureRecognizer *panGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(tableViewPan:)];
        //[_notesView addGestureRecognizer:panGesture];
        
        /*添加轻扫手势*/
        //注意一个轻扫手势只能控制一个方向，默认向右，通过direction进行方向控制
        UISwipeGestureRecognizer *swipeGestureToRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeToRight:)];
        //swipeGestureToRight.direction=UISwipeGestureRecognizerDirectionRight;//默认为向右轻扫
        [_notesView addGestureRecognizer:swipeGestureToRight];
        
        UISwipeGestureRecognizer *swipeGestureToLeft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeToLeft:)];
        swipeGestureToLeft.direction=UISwipeGestureRecognizerDirectionLeft;
        [_notesView addGestureRecognizer:swipeGestureToLeft];
        
        //注册UITableViewCell重用.
        [self.notesView registerClass:[NoteCell class] forCellReuseIdentifier:@"note"];
        
        [self.contentView addSubview:_notesView];
    }
    
    //需执行这个. 否则布局有问题.
    [self.view bringSubviewToFront:self.noteFilter];
}


- (void)filterViewBuild
{
    if(self.noteFilter) {
        NSLog(@"filterView already built.");
        [self.view bringSubviewToFront:self.noteFilter];
        return ;
    }
    
    self.heightNoteFilter = 36;
    
    //使用NoteFilter包裹JSDropDownMenu的时候,获取不到点击事件. 暂时使用JSDropDownMenu demo中的方式.
    //    self.noteFilter = [[NoteFilter alloc] initWithFrame:CGRectMake(0, 64, VIEW_WIDTH, heightNoteFilter)];
    //    [self.view addSubview:self.noteFilter];
    //    self.noteFilter.backgroundColor = [UIColor yellowColor];
    //
    //    [self.view bringSubviewToFront:self.noteFilter];
    self.filterDataClassifications = [NSMutableArray arrayWithObjects:@"全部类别", @"个人笔记", nil];
    NSArray<NSString*> *addedClassifications = [[AppConfig sharedAppConfig] configClassificationGets];
    if(addedClassifications.count > 0) {
        [self.filterDataClassifications addObjectsFromArray:addedClassifications];
    }
    [self.filterDataClassifications addObject:@"新增类别"];
    
    self.filterDataColors = [[NSMutableArray alloc] init];//[NSMutableArray arrayWithObjects:nil];
    [self.filterDataColors addObjectsFromArray:[NoteModel colorAssignDisplayStrings]];
    JSDropDownMenu *menu = [[JSDropDownMenu alloc] initWithOrigin:CGPointMake(0, 0) andHeight:self.heightNoteFilter];
    menu.indicatorColor = [UIColor colorWithRed:175.0f/255.0f green:175.0f/255.0f blue:175.0f/255.0f alpha:1.0];
    menu.separatorColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0];
    menu.textColor = [UIColor colorWithRed:83.f/255.0f green:83.f/255.0f blue:83.f/255.0f alpha:1.0f];
    menu.dataSource = self;
    menu.delegate = self;
    
    self.noteFilter = menu;
    
    [self.contentView addSubview:menu];
    
    //[self showPopupView:menu];
}


-(void)tableViewPan:(UIPanGestureRecognizer *)gesture{
    NSLog(@"gesture.state = %zd", gesture.state);
    NSLog(@"tableViewPan : %@", gesture);
    
    
    if (gesture.state==UIGestureRecognizerStateChanged) {
        //CGPoint translation=[gesture translationInView:_notesView];//利用拖动手势的translationInView:方法取得在相对指定视图（这里是控制器根视图）的移动
        
    }else if(gesture.state==UIGestureRecognizerStateEnded){
        
    }
    
}


- (void)swipeToRight:(UISwipeGestureRecognizer*)gesture
{
    NSLog(@"swipeToRight");
     
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)swipeToLeft:(UISwipeGestureRecognizer*)gesture
{
    NSLog(@"swipeToLeft");
    
}







- (void)notesLoadAll
{
    _notes = [[NSMutableArray alloc] init];
    [_notes addObjectsFromArray:[[AppConfig sharedAppConfig] configNoteGets]];
    
    for(NoteModel *note in _notes) {
        NSLog(@"title : %@", note.title);
    }
    
    NSLog(@"notesLoad finish.");
    return ;
}


- (void)notesLoadWithClassification:(NSString*)classification andColorString:(NSString*)colorString
{
    _notes = [[NSMutableArray alloc] init];
    [_notes addObjectsFromArray:[[AppConfig sharedAppConfig] configNoteGetsByClassification:classification andColorString:colorString]];
    
    NSLog(@"notesLoad finish.");
    return ;
}



/*
 colorString :
 red
 yellow
 blue
 - 有任意标记
 * 所有
 ""无标记
 */
#if 0
- (void)reloadWithClassification:(NSString*)classification andColorDisplayString:(NSString*)colorDisplayString
{
    NSString *colorString = [NoteModel colorDisplayStringToColorString:colorDisplayString];
    //与AppConfig约定classification.length <= 0 是为不区分classification条件查询.
    if([classification isEqualToString:@"全部类别"]) {
        classification = @"";
    }
    [self notesLoadWithClassification:classification andColorString:colorString];
    
    [self.notesView reloadData];
}


- (void)reloadWithClassification:(NSString*)classification andColorString:(NSString*)colorString
{
    //与AppConfig约定classification.length <= 0 是为不区分classification条件查询.
    if([classification isEqualToString:@"全部类别"]) {
        classification = @"";
    }
    [self notesLoadWithClassification:classification andColorString:colorString];
    [self.notesView reloadData];
}
#endif

//刷新notes的UITableView和filterView.
- (void)refreshView
{
    NSLog(@"1refreshView with classification:%@ color:%@", self.currentClassification, self.currentColorString);
    
    [self notesLoadWithClassification:self.currentClassification andColorString:self.currentColorString];
    [self.notesView reloadData];
}


//进入NoteViewController的第一次加载.
- (void)loadNotesView
{
    NSLog(@"loadNotesView with classification:%@ color:%@", self.currentClassification, self.currentColorString);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self notesLoadWithClassification:self.currentClassification andColorString:self.currentColorString];
        [self reloadNotesVia:@"load"];
    });
    
}




- (void)reloadNotesVia:(NSString*)via
{
    NSLog(@"reloadNotesVia : %@", via);
    
    if([via isEqualToString:@"load"]) {
        [self.notesView reloadData];
        
        return ;
    }
    
    if([via isEqualToString:@"filter"]) {
        
        
        
        return ;
    }
    
    if([via isEqualToString:@"back"]) {
        
        
        
        return;
    }
    
    
}







- (NoteModel*)noteOnIndexPath:(NSIndexPath*)indexPath
{
    return _notes[indexPath.row];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 100.0;
    return height;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 1;
    return sections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = _notes.count;
    return rows;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"note" forIndexPath:indexPath];
    
    if(indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithName:@"NoteCellBackground0"];
    }
    else {
        cell.backgroundColor = [UIColor colorWithName:@"NoteCellBackground1"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.layer.cornerRadius = 6;
    cell.t = @"";
    
    NoteModel *note = [self noteOnIndexPath:indexPath];
    
#if 0 //显示图片时, 可以使用此方法将图片显示为合适大小.
    UIImage *image = [UIImage imageNamed:@"apic321.jpg"];
    //NSLog(@"image : %@", image);
    cell.imageView.image = image;
    
    //缩小显示图片.

    CGSize itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#endif
    //cell.textLabel.text = note.title;
    //cell.detailTextLabel.text = [note contents];
    

    cell.titleLabel.text = [note previewTitle];
    cell.bodyLabel.text = [note previewSummary];
#if 0
    NSLog(@"%f, %f", cell.titleLabel.layer.position.x, cell.titleLabel.layer.position.y);
    
    cell.titleLabel.layer.position = CGPointMake(cell.bounds.size.width / 2 + cell.bounds.size.width / 2, 44.75);
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"position.x";
    animation.fromValue = @(cell.bounds.size.width / 2 + cell.bounds.size.width / 2);
    animation.toValue = @(cell.bounds.size.width / 2);
    
    animation.duration = 0.4;
    animation.beginTime = CACurrentMediaTime() + indexPath.row * 0.1;
    
    [cell.titleLabel.layer addAnimation:animation forKey:@"basic"];
#endif
    //一个渐渐显示的动画.
    

    
    
    
    return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if(self.onSelectedMode) {
        [self.indexPathsSelected addObject:indexPath];
        if(self.indexPathsSelected.count > 0) {
            self.title = [NSString stringWithFormat:@"已选择 %zd 篇笔记", self.indexPathsSelected.count];
        }
        else {
            self.title = @"选择笔记";
        }
        
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NoteModel *note = self.notes[indexPath.row];
    
    NoteDetailViewController *vc = [[NoteDetailViewController alloc] initWithNoteModel:note];
    [self.navigationController pushViewController:vc animated:YES];
    
    NSLog(@"NoteModel did select.");
    NSLog(@"%@", note);
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if(self.onSelectedMode) {
        [self.indexPathsSelected removeObject:indexPath];
        if(self.indexPathsSelected.count > 0) {
            self.title = [NSString stringWithFormat:@"已选择 %zd 篇笔记", self.indexPathsSelected.count];
        }
        else {
            self.title = @"选择笔记";
        }
        
        return;
    }
    
    
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    
}




#pragma mark - filter
//关于筛选.
- (NSInteger)numberOfColumnsInMenu:(JSDropDownMenu *)menu {
    
    return 2;
}

-(BOOL)displayByCollectionViewInColumn:(NSInteger)column{
    
    if (column==1) {
        
        return YES;
    }
    
    return NO;
}

-(BOOL)haveRightTableViewInColumn:(NSInteger)column{

    return NO;
}

-(CGFloat)widthRatioOfLeftColumn:(NSInteger)column{

    return 1;
}

-(NSInteger)currentLeftSelectedRow:(NSInteger)column{
    
    if (column==0) {
        
        return self.idxClassifications;
        
    }
    if (column==1) {
        
        return self.idxColor;
    }
    
    return 0;
}

- (NSInteger)menu:(JSDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column leftOrRight:(NSInteger)leftOrRight leftRow:(NSInteger)leftRow{
    
    if (column==0) {
        return self.filterDataClassifications.count;

    } else if (column==1){
        return self.filterDataColors.count;
    }
    
    return 0;
}

- (NSString *)menu:(JSDropDownMenu *)menu titleForColumn:(NSInteger)column{
    
    switch (column) {
        case 0: return self.filterDataClassifications[0];
            break;
        case 1: return self.filterDataColors[0];
            break;
        default:
            return nil;
            break;
    }
}

- (NSString *)menu:(JSDropDownMenu *)menu titleForRowAtIndexPath:(JSIndexPath *)indexPath {
    
    if (indexPath.column==0) {
        
        return self.filterDataClassifications[indexPath.row];
        
    } else {
        
        return self.filterDataColors[indexPath.row];
    }
}

- (void)menu:(JSDropDownMenu *)menu didSelectRowAtIndexPath:(JSIndexPath *)indexPath {
    
    if(indexPath.column == 0){
        
        //增加新增功能.
        if(self.filterDataClassifications.count - 1 == indexPath.row) {
            //[self filterViewAddClassification];
            //[self refreshView];
            
            [self showIndicationText:@"not implement" inTime:1.0];
            return ;
        }
        
        self.idxClassifications = indexPath.row;
        self.currentClassification = self.filterDataClassifications[self.idxClassifications];
        if([self.currentClassification isEqualToString:@"全部类别"]) {
            self.currentClassification = @"";
        }
        //#保存classification. 下次自动选择此.
        
    } else{
        self.idxColor = indexPath.row;
        self.currentColorString = [NoteModel colorDisplayStringToColorString:self.filterDataColors[self.idxColor]];
    }
    
    NSLog(@"Classification : %@, color : %@", self.filterDataClassifications[self.idxClassifications], self.filterDataColors[self.idxColor]);
    
    //刷新notes的UITableView和filterView.
    [self refreshView];
}


- (void)filterViewAddClassification
{
    CGRect frame = self.noteFilter.frame;
#if 0
    UIView *container = [[UIView alloc] initWithFrame:frame];
    [self.noteFilter addSubview:container];
    container.backgroundColor = [UIColor whiteColor];
    frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(2, 70, 2, 10));
#endif
    
    frame = CGRectMake(0, 64, VIEW_WIDTH, 36);
    UITextField *classificationInputView = [[UITextField alloc] initWithFrame:frame];
    //[container addSubview:classificationInputView];
    classificationInputView.borderStyle     = UITextBorderStyleLine;
    //    classificationInputView.backgroundColor = [UIColor blueColor];
    classificationInputView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    classificationInputView.placeholder     = @"请输入新增的栏目";
    classificationInputView.clearButtonMode = UITextFieldViewModeAlways;
    classificationInputView.returnKeyType = UIReturnKeyDone;
    classificationInputView.delegate        = self;
    
    UIView *leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, classificationInputView.bounds.size.height / 2, 100)];
    classificationInputView.leftView = leftview;
    classificationInputView.leftViewMode = UITextFieldViewModeAlways;
    
    classificationInputView.layer.cornerRadius = classificationInputView.bounds.size.height / 2;
    classificationInputView.layer.borderWidth = 1.5;
    
    [classificationInputView becomeFirstResponder];
    
    [self showPopupView:classificationInputView];
    
}









#pragma mark - action
- (void)showActionMenu
{
    CGFloat width = 60;
    TextButtonLine *v = [[TextButtonLine alloc] initWithFrame:CGRectMake(VIEW_WIDTH - width, 64, width, VIEW_HEIGHT - 10 * 2)];
    v.layoutMode = TextButtonLineLayoutModeVertical;
    
    NSArray<NSString*> *actionStrings = nil;
    actionStrings = @[@"创建", @"多选", @"恢复预制"];
    [v setTexts:actionStrings];
    
    __weak typeof(self) weakSelf = self;
    [v setButtonActionByText:^(NSString* actionText) {
        NSLog(@"action : %@", actionText);
        [weakSelf dismissPopupView];
        
        if([actionText isEqualToString:@"创建"]) {
            [weakSelf actionCreateNote];
            return ;
        }
        
        if([actionText isEqualToString:@"多选"]) {
            [weakSelf actionMuiltSelect];
            return;
        }
        
        if([actionText isEqualToString:@"恢复预制"]) {

            NSString *resPath= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"note.htm"];
#if 0
            NSData *data = [NSData dataWithContentsOfFile:resPath];
            
            UIActivityViewController *activiryViewController = [[UIActivityViewController alloc] initWithActivityItems:@[data] applicationActivities:nil];
            
            NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                            UIActivityTypePostToWeibo,
                                            UIActivityTypeMessage, UIActivityTypeMail,
                                            UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                            UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                            UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                            UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
            activiryViewController.excludedActivityTypes = excludedActivities;
            
            
            [self presentViewController:activiryViewController animated:YES completion:^(void){
                
            }];
#endif
            NSURL *url = [NSURL fileURLWithPath:resPath];
            NSArray *objectsToShare = @[url];
            
            UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            
            // Exclude all activities except AirDrop.
            NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                            UIActivityTypePostToWeibo,
                                            UIActivityTypeMessage, UIActivityTypeMail,
                                            UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                            UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                            UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                            UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
            controller.excludedActivityTypes = excludedActivities;
            
            // Present the controller
            [self presentViewController:controller animated:YES completion:nil];
            
            
            return;
        }
        
    }];
    
    [self showPopupView:v];
}


- (void)actionMore
{
    [self showActionMenu];
}


- (void)actionCreateNote
{
    NoteDetailViewController *vc = [[NoteDetailViewController alloc] initWithCreateNoteModel];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)actionMuiltSelect
{
    self.onSelectedMode = YES;
    self.indexPathsSelected = [[NSMutableArray alloc] init];
    [self.notesView setEditing:YES animated:YES];
    
    self.title = @"选择笔记";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(actionMuiltSelectDone)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self showMuiltSelectToolBar];
}


- (void)showMuiltSelectToolBar
{
    NSMutableArray *toolDatas = [[NSMutableArray alloc] init];
    
    PushButtonData *actionData = nil;
    
    actionData = [[PushButtonData alloc] init];
    actionData.actionString = @"notesDelete";
    actionData.imageName    = @"Advertising";
    [toolDatas addObject:actionData];
    
    actionData = [[PushButtonData alloc] init];
    actionData.actionString = @"notesUpdateClassification";
    actionData.imageName    = @"City";
    [toolDatas addObject:actionData];
    
    actionData = [[PushButtonData alloc] init];
    actionData.actionString = @"notesShare";
    actionData.imageName    = @"Diary";
    [toolDatas addObject:actionData];
    
    //重新加载按钮.
    NSMutableArray *toolBarItems = [[NSMutableArray alloc] init];
    NSInteger index = 0;
    for(PushButtonData *data in toolDatas) {
        
        if(index > 0) {
            UIBarButtonItem *flexibleitem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemFlexibleSpace) target:self action:nil];
            [toolBarItems addObject:flexibleitem];
        }
        
        NSLog(@"index : %zd, %@ %@", index, data.actionString, data.imageName);
        
        PushButton *button = [[PushButton alloc] init];
        button.actionData = data;
        [button addTarget:self action:@selector(actionMuiltSelectOnPushButton:) forControlEvents:UIControlEventTouchDown];
        [button setFrame:CGRectMake(0, 0, 60, 60)];
        if(data.triggerOn) {
            button.backgroundColor = [UIColor colorWithName:@"CustomButtonTriggerOnBackground"];
        }
        UIBarButtonItem *item = nil;
        if(nil != data.imageName) {
            UIImage *image = [UIImage imageNamed:data.imageName];
            button.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
            [button setImage:image forState:UIControlStateNormal];
            item = [[UIBarButtonItem alloc] initWithCustomView:button];
        }
        else {
            //[button setTitle:data.keyword forState:UIControlStateNormal];
            //[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            item = [[UIBarButtonItem alloc] initWithTitle:data.actionString
                                                    style:UIBarButtonItemStyleDone
                                                   target:self
                                                   action:@selector(actionMuiltSelectOnToolBar:)];
            
        }
        
        item.tintColor = [UIColor yellowColor];
        [toolBarItems addObject:item];
        
        
        
        index ++;
    }
    
    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = [NSArray arrayWithArray:toolBarItems];
}


- (void)actionMuiltSelectOnKeyword:(NSString*)keyword
{
    NSLog(@"actionMuiltSelectOnKeyword : %@", keyword);
    
    if(self.indexPathsSelected.count == 0) {
        [self showIndicationText:@"未选中任何笔记" inTime:1.0];
        return ;
    }
    
    //关闭多选状态.
    [self actionMuiltSelectDone];
    
    if([keyword isEqualToString:@"notesDelete"]) {
        
        
        return;
    }
    
    if([keyword isEqualToString:@"notesUpdateClassification"]) {
        
        
        return;
    }
    
    if([keyword isEqualToString:@"notesShare"]) {
        
        
        return;
    }
    
    
    
    
}


- (void)actionMuiltSelectOnPushButton:(PushButton*)button
{
    [self actionMuiltSelectOnKeyword:button.actionData.actionString];
}


- (void)actionMuiltSelectOnToolBar:(UIBarButtonItem*)sender
{
    [self actionMuiltSelectOnKeyword:sender.title];
}






- (void)actionMuiltSelectDone
{
    self.onSelectedMode = NO;
    self.indexPathsSelected = [[NSMutableArray alloc] init];
    [self.notesView setEditing:NO animated:YES];
    
    self.title = @"笔记";
    
    [self navigationItemRightInit];
    
    self.navigationController.toolbarHidden = YES;
}


- (NSArray<NSString*>*)notesIdentifierOnMutilSelect
{
    NSArray *indexPaths = self.indexPathsSelected;
    NSMutableArray<NSString*> *notesIdentifier = [[NSMutableArray alloc] init];
    for(NSIndexPath* indexPath in indexPaths) {
        [notesIdentifier addObject:[self noteOnIndexPath:indexPath].identifier];
    }
    
    return [NSArray arrayWithArray:notesIdentifier];
}


- (void)actionMuiltSelectedNotesDelete
{
    NSLog(@"actionMuiltSelectedNotesDelete");
    NSArray<NSString*>* notesIdentifier = [self notesIdentifierOnMutilSelect] ;
    [[AppConfig sharedAppConfig] configNoteRemoveByIdentifiers:notesIdentifier];
}


- (void)actionMuiltSelectedNotesChangeClassificationTo:(NSString*)classification
{
    NSLog(@"actionMuiltSelectedNotesChangeClassificationTo");
    NSArray<NSString*>* notesIdentifier = [self notesIdentifierOnMutilSelect] ;
    [[AppConfig sharedAppConfig] configNoteUpdateBynoteIdentifiers:notesIdentifier classification:classification];
}



#pragma mark - w

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
