//
//  NoteDetailViewController.h
//  NoteTask
//
//  Created by Ben on 16/7/19.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "CustomViewController.h"
@class NoteModel;

@interface NoteDetailViewController : CustomViewController



- (instancetype)initWithNoteModel:(NoteModel*)noteModel;
- (instancetype)initWithCreateNoteModel;
+ (instancetype)noteViewControllerCachedWithSn:(NSString*)sn;


@end


@interface KYPrintPageRenderer : UIPrintPageRenderer
@property (nonatomic, assign) BOOL generatingPdf;

- (NSData*) printToPDF;
@end