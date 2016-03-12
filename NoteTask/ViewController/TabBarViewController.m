//
//  TabBarViewController.m
//  NoteTask
//
//  Created by Ben on 16/1/25.
//  Copyright (c) 2016年 Ben. All rights reserved.
//

#import "TabBarViewController.h"
#import "CreateViewController.h"
#import "NoteViewController.h"
#import "SwipableViewController.h"




@implementation TabBarViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
#if 1
    
    //noteViewController.view.backgroundColor = [UIColor yellowColor];
    
#endif
    
    NoteViewController *noteAll = [[NoteViewController alloc] initWithType:NoteListTypeAll];
    NoteViewController *noteThisDay = [[NoteViewController alloc] initWithType:NoteListTypeThisDay];
    NoteViewController *noteNotFinished = [[NoteViewController alloc] initWithType:NoteListTypeNotFinished];
    
    SwipableViewController *noteViewControllers = [[SwipableViewController alloc] initWithTitle:@"Notes"
                                                        andSubTitles:@[@"全部", @"当前", @"未完成"]
                                                        andControllers:@[noteAll, noteThisDay, noteNotFinished]
                                                  underTabbar:NO];
    
    UINavigationController *navNote = [[UINavigationController alloc] initWithRootViewController:noteViewControllers];
    
    UINavigationController *navDiary = [[UINavigationController alloc] initWithRootViewController:[[UIViewController alloc] init]];
    
    UINavigationController *navCreate = [[UINavigationController alloc] initWithRootViewController:[[CreateViewController alloc] init]];
                                        
    self.tabBar.translucent = YES;
    
    self.viewControllers = @[
                                          navNote,
                                          navDiary,
                                          navCreate,
                                          [[UIViewController alloc] init],
                                          [[UIViewController alloc] init],
                                          ];
    
    NSArray *titles = @[@"笔记", @"日记", @"新增", @"广场", @"个人"];
    NSArray *images = @[@"tabbar-news", @"tabbar-tweet", @"", @"tabbar-discover", @"tabbar-me"];
    [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop) {
        [item setTitle:titles[idx]];
        if([images[idx] length]>0) {
            [item setImage:[UIImage imageNamed:images[idx]]];
        }
        [item setSelectedImage:[UIImage imageNamed:[images[idx] stringByAppendingString:@"-selected"]]];
        
    }];
    
}


- (void)viewDidAppear:(BOOL)animated {
    
    
    
    
    
}



@end
