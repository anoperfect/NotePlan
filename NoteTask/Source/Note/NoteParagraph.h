//
//  NoteParagraph.h
//  NoteTask
//
//  Created by Ben on 16/7/2.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteParagraphModel : NSObject

@property (nonatomic, assign) BOOL      isTitle;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSMutableDictionary *styleDictionay;


+ (NoteParagraphModel*)noteParagraphFromString:(NSString*)string;
+ (NSString*)noteParagraphToString:(NoteParagraphModel*)noteParagraph;


+ (NSArray<NoteParagraphModel*> *)noteParagraphsFromString:(NSString*)string;
+ (NSString*)noteParagraphsToString:(NSArray<NoteParagraphModel*> *)noteParagraphs;


- (UIFont*)textFont;
- (UIColor*)textColor;


- (UIColor*)backgroundColor;

- (NSMutableAttributedString*)attributedTextGeneratedOnSn:(NSInteger)sn onMode:(NSInteger)mode;


@end






#define NOTEPARAGRAPH_MODE_CREATE 0
#define NOTEPARAGRAPH_MODE_EDIT 1
#define NOTEPARAGRAPH_MODE_DISPLAY 2