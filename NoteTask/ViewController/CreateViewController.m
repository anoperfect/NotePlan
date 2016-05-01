//
//  CreateViewControlelr.m
//  NoteTask
//
//  Created by Ben on 16/1/16.
//  Copyright (c) 2016年 Ben. All rights reserved.
//
#import "TaskItemView.h"
#import "CreateViewController.h"


@interface CreateViewController () //<>

@property (nonatomic, strong) UITextFieldBorderView *durationText;
@property (nonatomic, strong) UISwitch *durationRepeat;

@property (nonatomic, strong) UILabel *taskLabel;
@property (nonatomic, strong) UITextFieldBorderView *taskText;

@property (nonatomic, strong) UILabel *shareToSquareLabel;
@property (nonatomic, strong) UISwitch *shareToSquareEnabael;

@property (nonatomic, strong) UILabel *onlyLacalLabel;
@property (nonatomic, strong) UISwitch *onlyLacalEnabael;

@property (nonatomic, strong) NSArray *arrayButtonStrings;
@property (nonatomic, strong) NSMutableArray *arrayButtons;

@property (nonatomic, strong) NSArray *arrayLabelStrings ;
@property (nonatomic, strong) NSMutableArray *arrayLabels;





@property (nonatomic, strong) TaskItemView *inputItem;

@end


@implementation CreateViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupSubviews];
}


- (void)setupSubviews
{
    self.arrayLabelStrings = @[
                                   @"时    间 : ",
                                   @"任    务 : ",
                                   @"广场分享 : ",
                                   @"只在本地 : ",
                                   ];
    
    self.arrayLabels = [[NSMutableArray alloc] init];
    
    for(NSString *labelString in self.arrayLabelStrings) {
        NSLog(@"%@", labelString);
        UILabel *label = [[UILabel alloc] init];
        label.text = labelString;
        label.textColor = [UIColor blueColor];
        [self.view addSubview:label];
        [self.arrayLabels addObject:label];
    }
    
    self.arrayButtonStrings = @[
                                   @"",
                                   @"",
                                   @"",
                                   @"",
                                   ];
    
    self.arrayButtons = [[NSMutableArray alloc] init];
    
    for(NSString *buttonString in self.arrayButtonStrings) {
        NSLog(@"%@", buttonString);
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:buttonString forState:UIControlStateNormal];
        [self.view addSubview:button];
        [self.arrayButtons addObject:button];
    }
}


- (void)viewWillLayoutSubviews
{
    float width = self.view.frame.size.width;
    CGRect frameLabels = CGRectMake(0.06 * width, 100, 0.30 * width, 36.0);
    
    NSLog(@"count : %zd", [self.arrayLabels count]);
    
    for(UILabel *label in self.arrayLabels) {
        [label setFrame:frameLabels];
        frameLabels.origin.y += 36.0;
    }
}










@end




#if 0
self.tabBarItem.titel = @"Create";
self.tabBarItem.image = [UIImage imageNamed:@"create.png"];
self.tabBarItem.seelctedImage = [UIImage imageNamed:@"create_HL.png"];

UITabelView *tabelView = [[UITabelView alloc] init];
[self.view addSubview:tabelView];
//tabelView.dataSource = self;
//    tabelView.deelgate = self;
#endif
