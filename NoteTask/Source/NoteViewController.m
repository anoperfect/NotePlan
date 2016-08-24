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

@interface NoteViewController () <UITableViewDataSource, UITableViewDelegate, JSDropDownMenuDataSource,JSDropDownMenuDelegate> {
    
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
    
    UIImage *rightItemImage = [UIImage imageNamed:@"Note"];
    CGSize itemSize = CGSizeMake(36, 36);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [rightItemImage drawInRect:imageRect];
    rightItemImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:rightItemImage style:UIBarButtonItemStyleDone target:self action:@selector(noteCreate)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //从AppConfig中读取上次保存的类别选项.
    self.currentClassification = @"";
    self.currentColorString = @"*";
    
    //内容筛选栏创建.
    [self filterViewBuild];
    
    //笔记内容栏创建.
    [self notesViewBuild];
    
    //内容加载.
//    [self reloadWithClassification:self.currentClassification andColorString:self.currentColorString];
    [self refreshView];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.noteFilter.frame = CGRectMake(0, 0, self.contentView.frame.size.width, 36);
    
    CGRect frameNotesView = self.contentView.bounds;
    frameNotesView.origin.y += self.heightNoteFilter ;
    frameNotesView.size.height -= self.heightNoteFilter;
    self.notesView.frame = frameNotesView;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //从NoteDetailViewController返回的时候, 需重新刷新下Note. Classification.
    //内容筛选栏创建.
    [self filterViewBuild];
    
    //笔记内容栏创建.
    [self notesViewBuild];
    
    //内容加载.
//    [self reloadWithClassification:self.currentClassification andColorString:self.currentColorString];
    [self refreshView];
}







- (void)notesViewBuild
{
    if(!self.notesView) {
        CGRect frame = self.contentView.bounds;
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
    self.filterDataClassifications = [NSMutableArray arrayWithObjects:@"全部类别", @"个人笔记", nil];
    NSArray<NSString*> *addedClassifications = [[AppConfig sharedAppConfig] configClassificationGets];
    if(addedClassifications.count > 0) {
        [self.filterDataClassifications addObjectsFromArray:addedClassifications];
    }
    
    if(!self.noteFilter) {
        self.heightNoteFilter = 36;
        
        //使用NoteFilter包裹JSDropDownMenu的时候,获取不到点击事件. 暂时使用JSDropDownMenu demo中的方式.
        //    self.noteFilter = [[NoteFilter alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, heightNoteFilter)];
        //    [self.view addSubview:self.noteFilter];
        //    self.noteFilter.backgroundColor = [UIColor yellowColor];
        //
        //    [self.view bringSubviewToFront:self.noteFilter];

        
        self.filterDataColors = [[NSMutableArray alloc] init];//[NSMutableArray arrayWithObjects:nil];
        [self.filterDataColors addObjectsFromArray:[NoteModel colorFilterDisplayStrings]];
        JSDropDownMenu *menu = [[JSDropDownMenu alloc] initWithOrigin:CGPointMake(0, 0) andHeight:self.heightNoteFilter];
        menu.indicatorColor = [UIColor colorWithRed:175.0f/255.0f green:175.0f/255.0f blue:175.0f/255.0f alpha:1.0];
        menu.separatorColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0];
        menu.textColor = [UIColor colorWithRed:83.f/255.0f green:83.f/255.0f blue:83.f/255.0f alpha:1.0f];
        menu.dataSource = self;
        menu.delegate = self;
        
        self.noteFilter = menu;
        
        [self.contentView addSubview:menu];
    }
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


//刷新notes的UITableView和filterView.
- (void)refreshView
{
    NSLog(@"refreshView with classification:%@ color:%@", self.currentClassification, self.currentColorString);
    
    [self notesLoadWithClassification:self.currentClassification andColorString:self.currentColorString];
    [self.notesView reloadData];
    
    NSLog(@"%@", self.noteFilter.superview);
    NSLog(@"%@", self.notesView.superview);
    
    
    
    LOG_VIEW_RECT(self.noteFilter, @"filter")
    LOG_VIEW_RECT(self.notesView, @"notes")
    

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
    
#if 0
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
    
    return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NoteDetailViewController *vc = [[NoteDetailViewController alloc] initWithNoteModel:self.notes[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];

}


- (void)noteCreate
{
    NoteDetailViewController *vc = [[NoteDetailViewController alloc] initWithCreateNoteModel];
    [self.navigationController pushViewController:vc animated:YES];
}


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
