//
//  SettingViewController.h
//  NoteTask
//
//  Created by Ben on 16/11/21.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "CustomViewController.h"

@interface SettingViewController : CustomViewController




@end



@interface SettingKV : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;

@end