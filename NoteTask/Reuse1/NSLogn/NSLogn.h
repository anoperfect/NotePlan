//
//  NSLogn.h
//  Reuse0
//
//  Created by Ben on 16/7/11.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
@interface NSLogn : NSObject






+ (NSLogn *)sharedNSLogn;
- (void)LogContentRaw:(NSString*)content line:(long)line file:(const char*)file function:(const char*)function;

@end



#if ENABLE_NSLOGN

#define NSLog(FORMAT, ...) {\
NSString *contentqwert1y = [NSString stringWithFormat:FORMAT, ##__VA_ARGS__];\
[[NSLogn sharedNSLogn] LogContentRaw:contentqwert1y line:__LINE__ file:__FILE__ function:__FUNCTION__];}

#else

#define NSLog(FORMAT, ...)

#endif

#define LOG_POSTION NSLog(@"postion.");
#define LOG_RECT(rect, name)        NSLog(@"[%@] - %@", [NSString stringWithFormat:@"%3zd.%zd, ""%3zd.%zd, ""%3zd.%zd, ""%3zd.%zd", (NSInteger)rect.origin.x,       (NSInteger)(rect.origin.x       * 10.0) % 10,(NSInteger)rect.origin.y,       (NSInteger)(rect.origin.y       * 10.0) % 10,(NSInteger)rect.size.width,     (NSInteger)(rect.size.width     * 10.0) % 10,(NSInteger)rect.size.height,    (NSInteger)(rect.size.height    * 10.0) % 10], name);
#define LOG_VIEW_RECT(view, name)   {CGRect rect = view.frame; NSLog(@"[%@] - %@", [NSString stringWithFormat:@"%3zd.%zd, ""%3zd.%zd, ""%3zd.%zd, ""%3zd.%zd", (NSInteger)rect.origin.x,       (NSInteger)(rect.origin.x       * 10.0) % 10,(NSInteger)rect.origin.y,       (NSInteger)(rect.origin.y       * 10.0) % 10,(NSInteger)rect.size.width,     (NSInteger)(rect.size.width     * 10.0) % 10,(NSInteger)rect.size.height,    (NSInteger)(rect.size.height    * 10.0) % 10], name);}



#define NS0Log(x...) {}
#define LOG_POSTION0
#define LOG_VIEW_REC0(v, name) {}
#define LOG_REC0(v, name) {}








