//
//  NoteModel.h
//  NoteTask
//
//  Created by Ben on 16/7/2.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>






@interface NoteParagraphModel : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSMutableDictionary *styleDictionay;


+ (NoteParagraphModel*)noteParagraphFromString:(NSString*)string;
+ (NSString*)noteParagraphToString:(NoteParagraphModel*)noteParagraph;


+ (NSArray<NoteParagraphModel*> *)noteParagraphsFromString:(NSString*)string;
+ (NSString*)noteParagraphsToString:(NSArray<NoteParagraphModel*> *)noteParagraphs;


- (UIFont*)titleFont;
- (UIFont*)textFont;
- (UIColor*)textColor;


- (UIColor*)backgroundColor;


@end


//本地存储时的时候的格式.
@interface NoteModel : NSObject
@property (nonatomic, assign) NSInteger identifier;


@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;

@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *classification;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *thumb;
@property (nonatomic, strong) NSString *audio;


@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *modifiedAt;
@property (nonatomic, strong) NSString *source;


@property (nonatomic, strong) NSString  *synchronize;
@property (nonatomic, assign) NSInteger countCollect;
@property (nonatomic, assign) NSInteger countLike;
@property (nonatomic, assign) NSInteger countDislike;
@property (nonatomic, assign) NSInteger countBrowser;
@property (nonatomic, assign) NSInteger countEdit;


- (BOOL)isEqualToNoteModel:(NoteModel*)note;

- (NSString*)previewTitle;
- (NSString*)previewSummary;

- (instancetype)initWithJsonData:(NSData*)jsonData;
- (NSData*)toJsonData;

+ (NoteModel*)noteFromDictionary:(NSDictionary*)dict;


//颜色标记相关.
+ (NSArray<NSString*> *)colorFilterDisplayStrings;
+ (NSArray<NSString*> *)colorAssignDisplayStrings;

+ (NSArray<NSString *> *)colorStrings;

+ (NSString*)colorDisplayStringToColorString:(NSString*)colorDisplayString;
+ (NSString*)colorStringToColorDisplayString:(NSString*)colorString;




@end



