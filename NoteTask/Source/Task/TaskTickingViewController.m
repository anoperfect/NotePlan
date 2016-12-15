//
//  TaskTickingViewController.m
//  NoteTask
//
//  Created by Ben on 16/11/21.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "TaskTickingViewController.h"






@interface TaskTickingViewController ()

@property (nonatomic, strong) UILabel *labelTicking;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *prevDate;
@property (nonatomic, assign) NSInteger prevSecs;
@property (nonatomic, strong) GCDTimer           *timer;

@end

@implementation TaskTickingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.labelTicking = [[UILabel alloc] init];
    [self addSubview:self.labelTicking];
    
    UIFont *font = FONT_MTSIZE(36);
    self.labelTicking.font = [UIFont systemFontOfSize:36];
    self.labelTicking.font = font;
    
    self.labelTicking.textAlignment = NSTextAlignmentCenter;
    
    __weak typeof(self) _self = self;
    self.timer = [[GCDTimer alloc] initInQueue:[GCDQueue mainQueue]];
    [self.timer event:^{
        // Start animation.
        [_self ticking];
        
    } timeIntervalWithSecs:0.1f];
    [self.timer start];
    
    
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect frameLabelTicking = CGRectMake(0, 0, VIEW_WIDTH, 100);
    self.labelTicking.frame = frameLabelTicking;
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"嘀嗒";
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)ticking
{
    NSDate *current = [NSDate date];
    if(!self.startDate) {
        self.startDate = current;
        self.prevDate = current;
        self.labelTicking.text = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", 0, 0, 0];
    }
    
    NSTimeInterval tickingTotal = [current timeIntervalSinceDate:self.startDate];
    NSTimeInterval tickingInterval = [current timeIntervalSinceDate:self.prevDate];
    NSLog(@"%f %f", tickingInterval, tickingTotal);
    
    self.prevDate = current;
    
    NSInteger secs = (NSInteger)tickingTotal;
    if(secs == self.prevSecs) {
        return ;
    }
    self.prevSecs = secs;
    
    NSInteger hour = secs / 3600;
    secs -= hour * 3600;
    NSInteger minite = secs / 60;
    NSInteger second = secs % 60;
    
    self.labelTicking.text = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", hour, minite, second];
    
    
    
    
}







- (void)didReceiveMemoryWarning
{
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
