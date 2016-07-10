//
//  NoteViewController.m
//  NoteTask
//
//  Created by Ben on 16/7/2.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteViewController.h"
#import "NoteModel.h"





@interface NoteViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *notesView;



@property (nonatomic, strong) NSMutableArray<NoteModel*> *notes;

@end

@implementation NoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;
    
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"NoteBackground"].CGImage);
    
    
    [self notesViewBuild];
    
    
    
    [self notesLoad];
    
    
    
}


- (void)notesViewBuild
{
    CGRect frame = self.view.bounds;
    frame.origin.y += 20;
    frame.size.height -= 20;
    _notesView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _notesView.dataSource = self;
    _notesView.delegate = self;
    _notesView.backgroundColor = [UIColor clearColor];
    
    
    UIPanGestureRecognizer *panGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(tableViewPan:)];
    //[_notesView addGestureRecognizer:panGesture];
    
    
    /*添加轻扫手势*/
    //注意一个轻扫手势只能控制一个方向，默认向右，通过direction进行方向控制
    UISwipeGestureRecognizer *swipeGestureToRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeToRight:)];
    //swipeGestureToRight.direction=UISwipeGestureRecognizerDirectionRight;//默认为向右轻扫
    [_notesView addGestureRecognizer:swipeGestureToRight];
    
    UISwipeGestureRecognizer *swipeGestureToLeft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeToLeft:)];
    swipeGestureToLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    [_notesView addGestureRecognizer:swipeGestureToLeft];
    
    
    
    
    [self.view addSubview:_notesView];
}


-(void)tableViewPan:(UIPanGestureRecognizer *)gesture{
    NSLog(@"gesture.state = %zd", gesture.state);
    NSLog(@"tableViewPan : %@", gesture);
    
    
    if (gesture.state==UIGestureRecognizerStateChanged) {
        CGPoint translation=[gesture translationInView:_notesView];//利用拖动手势的translationInView:方法取得在相对指定视图（这里是控制器根视图）的移动
        
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







- (void)notesLoad
{
    _notes = [[NSMutableArray alloc] init];
    
    NoteModel *note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
    
    note = [[NoteModel alloc] initWithJsonData:nil];
    [_notes addObject:note];
}




- (NoteModel*)noteOnIndexPath:(NSIndexPath*)indexPath
{
    return _notes[indexPath.row];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 60.0;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"note"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"note"];
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.layer.cornerRadius = 6;
        
        

        
        
    }
    
    NoteModel *note = [self noteOnIndexPath:indexPath];
    
    UIImage *image = [UIImage imageNamed:@"apic321.jpg"];
    //NSLog(@"image : %@", image);
    cell.imageView.image = image;
    
    //缩小显示图片.
#if 1
    CGSize itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
#endif
    cell.textLabel.text = note.title;
    cell.detailTextLabel.text = [note contents];
    
    return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
