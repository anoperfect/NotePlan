//
//  NoteDetailViewController.h
//  NoteTask
//
//  Created by Ben on 16/7/19.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
@class NoteModel;



@interface NoteDetailViewController : CustomViewController




- (instancetype)initWithNoteModel:(NoteModel*)noteModel;
- (instancetype)initWithCreateNoteModel;



@end
