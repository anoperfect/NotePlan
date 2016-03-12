//
//  NoteViewController.m
//  TaskNote
//
//  Created by Ben on 16/1/24.
//  Copyright (c) 2016年 Ben. All rights reserved.
//

#import "NoteViewController.h"
#import "UIColor+Util.h"
#import "NSThread+Util.h"
#import "NoteCell.h"
#import "NoteModel.h"


@interface NoteViewController ()

@property (nonatomic, assign) NoteListType  type;


@end

@implementation NoteViewController


- (instancetype)initWithType:(NoteListType)type {
    
    self = [super init];
    
    self.type = type;
    NSLog(@"type:%zd", self.type);
    
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"notecell"];
    
    
    
    
}






- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notecell" forIndexPath:indexPath];
    
    
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 60.0;
    
    
    NSLog(@"height : %f", height);
    
    return height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
}


//implement super method.
- (NSString*)generateURL:(NSInteger)page
{
    NSString *URLString =
            [NSString stringWithFormat:@"%@/noteplan/token=%@&&type=%zd&&page=%zd",
                                        CONFIG_ROOT_SERVER,
                                        @"abc",
                                        self.type,
                                        self.page];
    
    return URLString;
}


//public.
- (void)parseRemoteContent:(NSData*)data
{
    //将内容解析后加载到数据数组objects中.
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", dataString);
    
    //暂时使用测试数据.
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"note" ofType:@"json" inDirectory:@"json"];
    templatePath = @"/Users/Ben/Workspace/NotePlan/TaskNote/Resources/json/note.json";
    NSString *template = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"template : %@", template);
    
    data = [NSData dataWithContentsOfFile:templatePath];
    dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", dataString);
    
    if(nil == data) {
        NSLog(@"data nil.");
        return;
    }
    
    NSArray* arrayNotes =[NoteModel notesFromData:data];
    if(nil != arrayNotes) {
        [self.objects addObjectsFromArray:arrayNotes];
    }
}




@end
