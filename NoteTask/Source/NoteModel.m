//
//  NoteModel.m
//  NoteTask
//
//  Created by Ben on 16/7/2.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteModel.h"






@implementation NoteParagraphModel

@end

@implementation NoteModel

static NSInteger kno = 0;

- (instancetype)initWithJsonData:(NSData*)jsonData
{
    kno ++;
    
    self.title = [NSString stringWithFormat:@"title%zd中文换行布丁中文换行布丁中文换行布丁中文换行布丁中文换行布丁中文换行布丁", kno];
 
    
    
    
    
    
    
    return self;
}


- (NSData*)toJsonData
{
    return nil;
}


- (NSString*)contents
{
    return [NSString stringWithFormat:@"content%zd中文换行布丁中文换行布丁中文换行布丁中文换行布丁中文换行布丁中文换行布丁中文换行布丁", kno];
    
}


- (NSString*)description
{
    NSMutableString *strm = [[NSMutableString alloc] init];
    strm = nil;
    
    return self.title;
}







@end
