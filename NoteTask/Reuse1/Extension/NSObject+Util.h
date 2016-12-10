//
//  NSObject+Util.h
//  Reuse0
//
//  Created by Ben on 16/3/10.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSObject(Uitl)

+ (void)objectClassTest:(NSObject*)obj;

- (void)performSelectorByString:(NSString*)selString;

- (void)memberObjectCreate;
- (void)memberViewSetFrameWith:(NSDictionary*)nameAndFrames;

@end



