//
//  RemoteViewController.m
//  TaskNote
//
//  Created by Ben on 16/2/20.
//  Copyright (c) 2016年 Ben. All rights reserved.
//

#import "RemoteViewController.h"
#import "UIColor+Util.h"
#import "TableViewLastCell.h"
@interface RemoteViewController ()

@property (nonatomic, strong) TableViewLastCell *lastCell;



@end



@implementation RemoteViewController


- (instancetype)init {
    self = [super init];
    
    if(self) {
        self.objects = [[NSMutableArray alloc] init];
        
        
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor themeColor];
    
    _lastCell = [[TableViewLastCell alloc] init];
    [_lastCell setStatus1:TableViewLastCellStatusNotVisible];
    self.tableView.tableFooterView = _lastCell;
}


- (void)viewWillLayoutSubviews {
    [_lastCell setFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    [_lastCell setBackgroundColor:[UIColor yellowColor]];
    
    
    
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    //remove notification.
}










- (NSString*)generateURL:(NSInteger)page {
    NSLog(@"Need override.");
    return @"www";
}


//public.
- (NSArray*)parseRemoteContent:(NSObject*)content {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    
    return array;
}


- (void)loadMore {
    
    
}


- (void)refresh {
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.separatorColor = [UIColor separatorColor];
//    return [self.objects count];
    return 0;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height))) {
        [self loadMore];
    }
}



@end
