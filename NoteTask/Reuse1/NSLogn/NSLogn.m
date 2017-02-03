//
//  NSLogn.m
//  Reuse0
//
//  Created by Ben on 16/7/11.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "NSLogn.h"
/*
 NSLog重新定义.
 此文件中所有接口不能调用NSLog,
 否则触发循环调用.
 调用NSLogo,
 调用NSLog0 取消打印.
 */
#define NSLogo(FORMAT, ...) { NSString *content = [NSString stringWithFormat:FORMAT, ##__VA_ARGS__]; printf("------ %s\n", [content UTF8String]);}
#define NSLog0(FORMAT, ...)


@interface NSLogn ()

@property (nonatomic, strong) NSDate *data0;

@end



@implementation NSLogn




+ (NSLogn *)sharedNSLogn {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.data0 = [NSDate date];
    }
    return self;
}


- (void)dealloc
{
    NSLogo(@"dealloc.");
}


- (NSTimeInterval)timeIntervalCountWithRecount:(BOOL)recount
{
    NSDate *date = [NSDate date];
    return [date timeIntervalSinceDate:self.data0];
}


- (void)LogContentRaw:(NSString*)content line:(long)line file:(const char*)file function:(const char*)function
{
    double interval = [self timeIntervalCountWithRecount:false];
    
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendFormat:@"%90s %6ld %3.6f:%s %@", function, line, interval, [NSThread isMainThread]?" ":"-", content];
    printf("%s\n", [str UTF8String]);
}


@end




