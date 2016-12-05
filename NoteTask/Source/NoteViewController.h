//
//  NoteViewController.h
//  NoteTask
//
//  Created by Ben on 16/7/2.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
@interface NoteViewController : CustomViewController




@end


@interface NoteArchiveViewController  : CustomViewController

- (void)setFrom:(NSString*)from andNoteIdentifiers:(NSArray<NSString*>*)noteIdentifiers;

@end



