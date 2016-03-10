//
//  NoteModel.m
//  TaskNote
//
//  Created by Ben on 16/2/21.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NoteModel.h"
#import "NSObject+Util.h"

@interface NoteModel ()

@end


@implementation NoteModel


+ (NoteModel*)noteFromDict:(NSDictionary*)dict
{
    NoteModel *model = [[NoteModel alloc] init];
    
    
    
    
    
    
    
    
    return model;
}


+ (NSArray*)notesFromData:(NSData *)data
{
    NSMutableArray *arrayNotes = [[NSMutableArray alloc] init];
    
    NSError *error;
    id obj;
    NSArray *array;
    NSDictionary *dict;
    obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(nil != error || nil == obj) {
        NSLog(@"1remote data error.");
        goto finish;
    }
    
    if(![obj isKindOfClass:[NSDictionary class]]) {
        NSLog(@"2remote data error.");
        [NSObject objectClassTest:obj];
        goto finish;
    }
    
    dict = (NSDictionary*)obj;
    obj = dict[@"data"];
    if(![obj isKindOfClass:[NSDictionary class]]) {
        NSLog(@"3remote data error.");
        [NSObject objectClassTest:obj];
        goto finish;
    }
    
    dict = (NSDictionary*)obj;
    obj = dict[@"notes"];
    if(![obj isKindOfClass:[NSArray class]]) {
        NSLog(@"3remote data error.");
        [NSObject objectClassTest:obj];
        goto finish;
    }
    
    array = (NSArray*)obj;
    
    NSInteger numberInArray = [array count];
    NSInteger numberAdd = 0;
    for(obj in array) {
        if(![obj isKindOfClass:[NSDictionary class]]) {
            NSLog(@"4remote data error.");
            [NSObject objectClassTest:obj];
            continue;
        }
        
        NoteModel *model = [NoteModel noteFromDict:dict];
        if(nil != model) {
            [arrayNotes addObject:model];
            numberAdd ++;
        }
        else {
            
        }
    }
    
    if(0 == numberInArray) {
        NSLog(@"No note data.");
    }
    else if(numberInArray == numberAdd) {
        NSLog(@"successfully add %zd object.", numberInArray);
    }
    else {
        NSLog(@"%zd total, parsed %zd.", numberInArray, numberAdd);
    }

finish:
    return [NSArray arrayWithArray:arrayNotes];
}

@end

