//
//  RemoteViewController.m
//  NoteTask
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
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.backgroundColor = [UIColor themeColor];
    
    _lastCell = [[TableViewLastCell alloc] init];
    [_lastCell setStatus1:TableViewLastCellStatusNotVisible];
    self.tableView.tableFooterView = _lastCell;
    
    [self performSelector:@selector(refresh) withObject:nil afterDelay:1.f];
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
- (void)parseRemoteContent:(NSData*)data
{
    NSLog(@"Need override.");
    return ;
}


- (void)loadMore {
    //获取网络请求地址. 具体实现由继承类重载.
    NSString *URLString = [self generateURL:self.page];
    NSLog(@"URLString : %@", URLString);
    
    //网络请求.
    NSURL *url = [NSURL URLWithString:URLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:0 timeoutInterval:10.f];
    [request setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){
                               if(!connectionError) {
                                   [self parseRemoteContent:data];
                                   [self.tableView reloadData];
                               }
                               else {
                                   
                               }
    }];
    
    
    
    
    
    
}


- (void)refresh {
    self.page = 1;
    [self loadMore];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.separatorColor = [UIColor separatorColor];
    return [self.objects count];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height))) {
        [self loadMore];
    }
}



@end
