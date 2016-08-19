//
//  NotePropertyView.h
//  NoteTask
//
//  Created by Ben on 16/7/21.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotePropertyView : UIView




- (void)setClassification:(NSString*)classification color:(NSString*)color;
- (void)setActionPressed:(void(^)(NSString *item))action;

@end
