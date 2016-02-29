//
//  RemoteViewController.h
//  TaskNote
//
//  Created by Ben on 16/2/20.
//  Copyright (c) 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemoteViewController : UITableViewController




@property (nonatomic,strong)NSMutableArray *objects;




//override.
- (NSString*)generateURL:(NSInteger)page;




//public.
- (NSArray*)parseRemoteContent:(NSObject*)content;
- (void)loadMore;
- (void)refresh;



@end
