//
//  NotePCustmiseViewController.h
//  NoteTask
//
//  Created by Ben on 16/7/21.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
@class NoteParagraphModel;
@interface NoteParagraphCustmiseViewController : CustomViewController

- (instancetype)initWithStyleDictionary:(NSDictionary*)styleDictionary;
- (instancetype)initWithNoteParagraph:(NoteParagraphModel*)noteParagraph sn:(NSInteger)sn;

- (void)setStyleFinishHandle:(void(^)(NSDictionary *styleDictionary))handle;

@end



