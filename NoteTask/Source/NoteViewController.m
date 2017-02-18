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
#import "AppDelegate.h"
#import "NoteArchiveViewController.h"
@interface NoteViewController () <UITableViewDataSource, UITableViewDelegate,
                                        UITextFieldDelegate,
                                    JSDropDownMenuDataSource,JSDropDownMenuDelegate, UINavigationControllerDelegate>
{
    
    NSMutableArray *_data1;
    NSMutableArray *_data2;
    NSMutableArray *_data3;
    
    NSInteger _currentData1Index;
    NSInteger _currentData2Index;
    NSInteger _currentData3Index;
    
}

@property (nonatomic, strong) UITableView *notesView;
@property (nonatomic, assign) CGFloat topNotesView;

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

@property (nonatomic, strong) NSMutableDictionary *heightOptumize;

@end


@implementation NoteViewController



#pragma mark - view override
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.heightNoteFilter = 36;
    self.topNotesView = 0;
    self.heightOptumize = [[NSMutableDictionary alloc] init];
    
    //导航栏定制相关.
    //self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"NoteBackground"].CGImage);
    
    //下一个UIViewController的返回的地方文字设置.
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
//    backItem.title = @"";
//    self.navigationItem.backBarButtonItem = backItem;
    
    [self navigationItemRightInit];
    
    [self dataFilterRefresh];
    
    //从AppConfig中读取上次保存的类别选项.
    self.currentClassification = @"*";
    self.currentColorString = @"*";
    NSString *noteClassification = [[AppConfig sharedAppConfig] configSettingGet:@"NoteFilterClassification"];
    if(noteClassification) {
        self.currentClassification = noteClassification;
        NSInteger idx = 0;
        if([self.currentClassification isEqualToString:@"*"]) {
            self.idxClassifications = 0;
        }
        else if((idx = [self.filterDataClassifications indexOfObject:self.currentClassification]) != NSNotFound) {
            self.idxClassifications = idx;
        }
        else {
            NSLog(@"#error - ");
        }
        
        NSLog(@"%zd", self.idxClassifications);
    }
    else {
        NSLog(@"%zd", self.idxClassifications);
    }
    
    NSString *noteColor = [[AppConfig sharedAppConfig] configSettingGet:@"NoteFilterColor"];
    if(noteColor) {
        self.currentColorString = noteColor;
        NSInteger idx = 0;
        NSString *currentColorDisplayString = [NoteModel colorStringToColorDisplayString:self.currentColorString];
        if((idx = [self.filterDataColors indexOfObject:currentColorDisplayString]) != NSNotFound) {
            self.idxColor = idx;
        }
        else {
            NSLog(@"#error - ");
        }
        
        NSLog(@"%zd", self.idxColor);
    }
    else {
        NSLog(@"%zd", self.idxColor);
    }
    
    //内容筛选栏创建.
    [self filterViewBuild];
    
    //笔记内容栏创建.
    [self notesViewBuild];
    
    //内容加载.
    //[self loadNotesView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionClassificationsUpdated:) name:@"NotificationClassificationsUpdated" object:nil];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.noteFilter.frame = CGRectMake(0, 0, VIEW_WIDTH, self.heightNoteFilter);
    self.noteFilter.hidden = (self.heightNoteFilter == 0);
    
    CGRect frameNotesView = VIEW_BOUNDS;
    frameNotesView.origin.y += self.topNotesView ;
    frameNotesView.size.height -= self.topNotesView;
    self.notesView.frame = frameNotesView;
    
    //筛选off的时候,可能notefilter覆盖到NotesView.将notefilter放到最下层.
    [self.noteFilter.superview sendSubviewToBack:self.noteFilter];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self navigationTitleRefresh];
    [self loadNotesView];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


#pragma mark - navigation item
- (void)navigationTitleRefresh
{
    self.navigationItem.titleView = nil;
    NSLog(@"current classification [%@], color[%@]", self.currentClassification, self.currentColorString);
    if(self.currentClassification.length == 0 || [self.currentClassification isEqualToString:@"*"]) {
        if(self.currentColorString.length == 0 || [self.currentColorString isEqualToString:@"*"]) {
            self.title = @"笔记";
        }
        else {
            self.title = [NSString stringWithFormat:@"笔记(%@)", [NoteModel colorStringToColorDisplayString:self.currentColorString]];
        }
    }
    else {
        if(self.currentColorString.length == 0 || [self.currentColorString isEqualToString:@"*"]) {
            self.title = [NSString stringWithFormat:@"笔记(%@)", self.currentClassification];
        }
        else {
            self.title = [NSString stringWithFormat:@"(%@,%@)", self.currentClassification, [NoteModel colorStringToColorDisplayString:self.currentColorString]];
        }
    }
}


- (void)navigationItemRightInit
{
//    UIImage *rightItemImage = [UIImage imageNamed:@"more"];
//#if 0
//    CGSize itemSize = CGSizeMake(36, 36);
//    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
//    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
//    [rightItemImage drawInRect:imageRect];
//    rightItemImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//#endif
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:rightItemImage style:UIBarButtonItemStyleDone target:self action:@selector(actionMore)];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    PushButtonData *dataCreate = [[PushButtonData alloc] init];
    dataCreate.imageName = @"NoteAdd";
    dataCreate.actionString = @"NoteAdd";
    PushButton *buttonCreate = [[PushButton alloc] init];
    buttonCreate.frame = CGRectMake(0, 0, 44, 44);
    buttonCreate.actionData = dataCreate;
    buttonCreate.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    [buttonCreate setImage:[UIImage imageNamed:buttonCreate.actionData.imageName] forState:UIControlStateNormal];
    [buttonCreate addTarget:self action:@selector(actionCreateNote) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *itemCreate = [[UIBarButtonItem alloc] initWithCustomView:buttonCreate];
    
    PushButtonData *dataMore = [[PushButtonData alloc] init];
    dataMore.imageName = @"more";
    dataMore.actionString = @"more";
    PushButton *buttonMore = [[PushButton alloc] init];
    buttonMore.frame = CGRectMake(0, 0, 44, 44);
    buttonMore.actionData = dataMore;
    buttonMore.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    [buttonMore setImage:[UIImage imageNamed:buttonMore.actionData.imageName] forState:UIControlStateNormal];
    [buttonMore addTarget:self action:@selector(actionMore) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *itemMore = [[UIBarButtonItem alloc] initWithCustomView:buttonMore];
    
    self.navigationItem.rightBarButtonItems = @[
                                                itemMore,
                                                itemCreate,
                                                
                                                
                                                
                                                ];
    
    
    
    
    
    
    
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
        self.notesView.backgroundColor = [UIColor colorWithName:@"NotesBackground"];
        self.notesView.separatorColor = [UIColor blueColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        self.notesView.separatorEffect = vibrancyEffect;
        
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
    
    //使用NoteFilter包裹JSDropDownMenu的时候,获取不到点击事件. 暂时使用JSDropDownMenu demo中的方式.
    //    self.noteFilter = [[NoteFilter alloc] initWithFrame:CGRectMake(0, 64, VIEW_WIDTH, heightNoteFilter)];
    //    [self.view addSubview:self.noteFilter];
    //    self.noteFilter.backgroundColor = [UIColor yellowColor];
    //
    //    [self.view bringSubviewToFront:self.noteFilter];
    
    JSDropDownMenu *menu = [[JSDropDownMenu alloc] initWithOrigin:CGPointMake(0, 0) andHeight:self.heightNoteFilter];
    menu.indicatorColor = [UIColor colorWithRed:175.0f/255.0f green:175.0f/255.0f blue:175.0f/255.0f alpha:1.0];
    menu.separatorColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0];
    menu.textColor = [UIColor colorWithRed:83.f/255.0f green:83.f/255.0f blue:83.f/255.0f alpha:1.0f];
    menu.dataSource = self;
    menu.delegate = self;
    
    self.noteFilter = menu;
    
    [self.contentView addSubview:menu];
}



#pragma mark - data
- (void)dataFilterRefresh
{
    self.filterDataClassifications = [NSMutableArray arrayWithObjects:@"全部类别", nil];
    NSArray<NSString*> *addedClassifications = [[AppConfig sharedAppConfig] configClassificationGets];
    if(addedClassifications.count > 0) {
        [self.filterDataClassifications addObjectsFromArray:addedClassifications];
    }
    [self.filterDataClassifications addObjectsFromArray:[NoteModel classificationPreset]];
    
    self.filterDataColors = [[NSMutableArray alloc] init];//[NSMutableArray arrayWithObjects:nil];
    [self.filterDataColors addObjectsFromArray:[NoteModel colorFilterDisplayStrings]];
}


- (NoteModel*)dataNoteOnIndexPath:(NSIndexPath*)indexPath
{
    NoteModel *note = _notes[indexPath.row];
    return note;
}


- (NSArray<NSString*>*)dataNotesSnOnIndexPaths:(NSArray<NSIndexPath*>*)indexPaths
{
    NSMutableArray<NSString*> *notesSn = [[NSMutableArray alloc] init];
    for(NSIndexPath* indexPath in indexPaths) {
        [notesSn addObject:[self dataNoteOnIndexPath:indexPath].sn];
    }
    
    return [NSArray arrayWithArray:notesSn];
}


- (void)dataNotesDeleteOnIndexPaths:(NSArray<NSIndexPath*>*)indexPaths
{
    //数据库删除对应note数据.
    NSArray<NSString*>* sns = [self dataNotesSnOnIndexPaths:indexPaths] ;
    [[AppConfig sharedAppConfig] configNoteDeleteBySns:sns];
    
    //表数据源清除.
    NSMutableArray *notesDelete = [[NSMutableArray alloc] init];
    
    NoteModel *note;
    for(NSIndexPath *indexPath in indexPaths) {
        note = [self dataNoteOnIndexPath:indexPath];
        NSLog(@"[row%zd] %@ : %@", indexPath.row, note.sn, note.title);
        [notesDelete addObject:note];
    }
    [self.notes removeObjectsInArray:notesDelete];
    NSLog(@"after delete : %zd", self.notes.count);
}


- (void)dataNotesReload
{
    _notes = [[NSMutableArray alloc] init];
    [_notes addObjectsFromArray:[[AppConfig sharedAppConfig] configNoteGetsByClassification:self.currentClassification andColorString:self.currentColorString]];
    
    NSLog(@"notesLoad finish.");
    return ;
}


- (void)dataDebug
{
    NSLog(@"%p", self.notes);
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



/*
 colorString :
 red
 yellow
 blue
 - 有任意标记
 * 所有
 ""无标记
 */


//刷新notes的UITableView和filterView.
- (void)refreshView
{
    [self navigationTitleRefresh];
    NSLog(@"1refreshView with classification:%@ color:%@", self.currentClassification, self.currentColorString);
    
    [self reloadNotesVia:@"changefilter"];
}


//进入NoteViewController的第一次加载.
- (void)loadNotesView
{
    NSLog(@"loadNotesView with classification:%@ color:%@", self.currentClassification, self.currentColorString);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadNotesVia:@"load"];
    });
    
}


- (void)reloadNotesVia:(NSString*)via
{
    NSLog(@"reloadNotesVia : %@", via);
    [self dataNotesReload];
    [self.notesView reloadData];
}





#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 118.0;
    
    NSNumber *heightNumber = self.heightOptumize[indexPath];
    if(heightNumber) {
        height = [heightNumber floatValue];
    }
    
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
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.layer.cornerRadius = 6;
    
    NoteModel *note = [self dataNoteOnIndexPath:indexPath];
    
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
    

    
    cell.note = note;
    
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
    
    self.heightOptumize[indexPath] = @(cell.optumizeHeight);
    
    
    
    return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSLog(@"NoteModel did select.");
    if(self.onSelectedMode) {
        NSLog(@"onSelectedMode");
        [self.indexPathsSelected addObject:indexPath];
        
        NoteModel *note = [self dataNoteOnIndexPath:indexPath];
        note = nil;
        
        if(self.indexPathsSelected.count > 0) {
            self.title = [NSString stringWithFormat:@"已选择 %zd 篇笔记", self.indexPathsSelected.count];
        }
        else {
            self.title = @"选择笔记";
        }
        
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NoteModel *note = [self dataNoteOnIndexPath:indexPath];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        note.browseredAt = [NSString dateTimeStringNow];
        [[AppConfig sharedAppConfig] configNoteUpdate:note];
    });
    NoteDetailViewController *vc = [[NoteDetailViewController alloc] initWithNoteModel:note];
    [self.navigationController pushViewController:vc animated:YES];
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


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        case 0:
            if(self.idxClassifications < self.filterDataClassifications.count) {
                return self.filterDataClassifications[self.idxClassifications];
            }
            break;
        case 1:
            if(self.idxColor < self.filterDataColors.count) {
                return self.filterDataColors[self.idxColor];
            }
            break;
        default:
            return nil;
            break;
    }
    
    return nil;
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
        self.idxClassifications = indexPath.row;
        self.currentClassification = self.filterDataClassifications[self.idxClassifications];
        if([self.currentClassification isEqualToString:@"全部类别"]) {
            self.currentClassification = @"*";
        }
        //保存classification. 下次自动选择此.
        [[AppConfig sharedAppConfig] configSettingSetKey:@"NoteFilterClassification" toValue:self.currentClassification replace:YES];
    } else{
        self.idxColor = indexPath.row;
        self.currentColorString = [NoteModel colorDisplayStringToColorString:self.filterDataColors[self.idxColor]];
        [[AppConfig sharedAppConfig] configSettingSetKey:@"NoteFilterColor" toValue:self.currentColorString replace:YES];
    }
    
    NSLog(@"Classification : %@, color : %@", self.filterDataClassifications[self.idxClassifications], self.filterDataColors[self.idxColor]);
    
    //刷新notes的UITableView和filterView.
    [self refreshView];
}


#pragma mark - action
- (void)showActionMenu
{
    CGFloat width = 60;
    TextButtonLine *v = [[TextButtonLine alloc] initWithFrame:CGRectMake(VIEW_WIDTH - width, 64, width, VIEW_HEIGHT - 10 * 2)];
    v.layoutMode = TextButtonLineLayoutModeVertical;
    
    NSArray<NSString*> *actionStrings = nil;
    if(self.topNotesView == 0) {
        actionStrings = @[/*@"创建", */@"显示筛选", @"多选", @"类别", @"恢复预制"];
    }
    else {
        actionStrings = @[/*@"创建", */@"隐藏筛选", @"多选", @"类别", @"恢复预制"];
    }
    [v setTexts:actionStrings];
    
    __weak typeof(self) weakSelf = self;
    [v setButtonActionByText:^(NSString* actionText) {
        NSLog(@"action : %@", actionText);
        [weakSelf dismissPopupView];
        [weakSelf actionMenuString:actionText];
        return ;
    }];
    
    [self showPopupView:v commission:nil clickToDismiss:YES dismiss:nil];
}
        

- (void)actionMenuString:(NSString*)menuString
{
    NSLog(@"actionMenuString : %@", menuString);
    NSDictionary *menuStringAndSELStrings = @{
                                              @"创建":@"actionCreateNote",
                                              @"多选":@"actionMuiltSelect",
                                              @"显示筛选":@"actionOpenFilter",
                                              @"隐藏筛选":@"actionCloseFilter",
                                              @"恢复预制":@"actionResumePreset",
                                              @"类别":@"actionEnterArchive",
                                              @"":@"",
                                              };
    
    [self performSelectorByString:menuStringAndSELStrings[menuString]];
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
    self.navigationItem.rightBarButtonItems = @[rightItem];
    
    [self showMuiltSelectToolBar];
}


- (void)actionOpenFilter
{
    [UIView animateWithDuration:0.5 animations:^{
        self.topNotesView = 36;
        [self viewWillLayoutSubviews];
    }];
}


- (void)actionCloseFilter
{
    [UIView animateWithDuration:0.5 animations:^{
        self.topNotesView = 0;
        [self viewWillLayoutSubviews];
    }];
}


- (void)actionResumePreset
{
    [[AppConfig sharedAppConfig] configNoteAddPreset];
    
    [self reloadNotesVia:@"Add Preset"];
}


- (void)actionEnterArchive
{
    NoteArchiveViewController *vc = [[NoteArchiveViewController alloc] init];
    [self pushViewController:vc animated:YES];
}


- (void)showMuiltSelectToolBar
{
    NSMutableArray *toolDatas = [[NSMutableArray alloc] init];
    
    PushButtonData *actionData = nil;
    
    actionData = [[PushButtonData alloc] init];
    actionData.actionString = @"notesDelete";
    actionData.imageName    = @"Delete";
    [toolDatas addObject:actionData];
    
    actionData = [[PushButtonData alloc] init];
    actionData.actionString = @"notesUpdateClassification";
    actionData.imageName    = @"Archive";
    [toolDatas addObject:actionData];
    
    actionData = [[PushButtonData alloc] init];
    actionData.actionString = @"notesShare";
    actionData.imageName    = @"Diary";
//    [toolDatas addObject:actionData];
    
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
        [self showIndicationText:@"未选中任何笔记"];
        return ;
    }
    
    NSArray *indexPathsSelected = [NSArray arrayWithArray:self.indexPathsSelected];
    
    //关闭多选状态.
    [self actionMuiltSelectDone];
    
    if([keyword isEqualToString:@"notesDelete"]) {
        //删除数据库对应数据和self.notes.
        [self dataNotesDeleteOnIndexPaths:indexPathsSelected];
        
        //界面刷新.
        [self.notesView beginUpdates];
        [self.notesView deleteRowsAtIndexPaths:indexPathsSelected withRowAnimation:UITableViewRowAnimationFade];
        [self.notesView endUpdates];
        
        //heightOptumize全失效, 高度有错. 因此重新reload下. 为什么不一开始便使用reload? 直接reload没有挪动的效果.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.notesView reloadData];
        });
        
        return;
    }
    
    if([keyword isEqualToString:@"notesUpdateClassification"]) {
        
#if 0
        UIGraphicsBeginImageContext([UIScreen mainScreen].bounds.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        AppDelegate * app = (AppDelegate *)([UIApplication sharedApplication].delegate); //获取app的appdelegate，便于取到当前的window用来截屏
        [app.window.layer renderInContext:context];
        
        UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
//        self.definesPresentationContext = YES;
        UIViewController *vc = [[UIViewController alloc] init];
//        vc.view.backgroundColor = [UIColor colorFromString:@"#000000@10"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        label.text = @"111";
        label.backgroundColor = [UIColor blueColor];
        
        [vc.view addSubview:label];
        
        [self presentViewController:vc animated:YES completion:^{
            
            for(UIView *v in [[UIApplication sharedApplication] keyWindow].subviews) {
                NSLog(@"%@", v);
            }
            
            NSLog(@"%@", vc.view);
            NSLog(@"%@", vc.view.superview);
            
            vc.view.superview.backgroundColor = [UIColor colorWithPatternImage:img];
            
            for(UIView *v in vc.view.superview.subviews) {
                
                NSLog(@"%@", v);
                
            }
            
//            [[UIApplication sharedApplication] keyWindow].backgroundColor = [UIColor colorFromString:@"#000000@60"];
            
            
            NSLog(@"%@", [[UIApplication sharedApplication] keyWindow].backgroundColor);
            NSLog(@"%@", vc.view.superview.backgroundColor);
            NSLog(@"%@", vc.view.backgroundColor);
            

            
            
            
        }];

        UIViewController *vc = [[UIViewController alloc] init];
        
        
        vc.view.backgroundColor = [UIColor clearColor];
        UIViewController *rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
        rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [rootViewController presentModalViewController:vc animated:YES];
#endif
        
        NoteArchiveViewController *vc = [[NoteArchiveViewController alloc] init];
        [vc setFrom:@"NotesArchiveChange" andSns:[self dataNotesSnOnIndexPaths:indexPathsSelected]];
        [self pushViewController:vc animated:YES];
        
        return;
    }
    
    if([keyword isEqualToString:@"notesShare"]) {
        
        
        return;
    }
    

    
}


- (UIView*)mfilterViewBuild //desprated.
{
    //使用NoteFilter包裹JSDropDownMenu的时候,获取不到点击事件. 暂时使用JSDropDownMenu demo中的方式.
    //    self.noteFilter = [[NoteFilter alloc] initWithFrame:CGRectMake(0, 64, VIEW_WIDTH, heightNoteFilter)];
    //    [self.view addSubview:self.noteFilter];
    //    self.noteFilter.backgroundColor = [UIColor yellowColor];
    //
    //    [self.view bringSubviewToFront:self.noteFilter];
    return nil;
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


- (void)actionClassificationsUpdated:(NSNotification*)notification
{
    [self dataFilterRefresh];
    
    
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

