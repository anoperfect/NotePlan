//
//  RemoteViewController.h
//  TaskNote
//
//  Created by Ben on 16/2/20.
//  Copyright (c) 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>


#define CONFIG_ROOT_SERVER  @"http://49.51.9.147/noteplan/api"





@interface RemoteViewController : UITableViewController




@property (nonatomic,strong)NSMutableArray *objects;
@property (nonatomic, assign) NSInteger     page;



//override.
- (NSString*)generateURL:(NSInteger)page;




//public.
- (void)parseRemoteContent:(NSData*)data;
- (void)loadMore;
- (void)refresh;



@end
