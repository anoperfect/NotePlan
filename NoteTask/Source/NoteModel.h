//
//  NoteModel.h
//  NoteTask
//
//  Created by Ben on 16/7/2.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteParagraph.h"








//本地存储时的时候的格式.
@interface NoteModel : NSObject
@property (nonatomic, strong) NSString* sn;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;

@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *summaryGenerated;
@property (nonatomic, strong) NSString *classification;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *thumb;
@property (nonatomic, strong) NSString *audio;


@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *modifiedAt;
@property (nonatomic, strong) NSString *browseredAt;
@property (nonatomic, strong) NSString *deletedAt;
@property (nonatomic, strong) NSString *source;


@property (nonatomic, strong) NSString  *synchronize; //记录同步时间.
@property (nonatomic, assign) NSInteger countCollect;
@property (nonatomic, assign) NSInteger countLike;
@property (nonatomic, assign) NSInteger countDislike;
@property (nonatomic, assign) NSInteger countBrowser;
@property (nonatomic, assign) NSInteger countEdit;


- (BOOL)isEqualToNoteModel:(NoteModel*)note;

- (NSString*)previewTitle;
- (NSString*)previewSummary;
- (NSString*)summaryGenerateFromNoteParagraphs:(NSArray<NoteParagraphModel*>*)contentNoteParagraphs;


+ (NoteModel*)noteFromDictionary:(NSDictionary*)dict;
- (NSDictionary*)toDictionary;

+ (NSArray<NSString*>*)classificationPreset;

//颜色标记相关.
+ (NSArray<NSString*> *)colorFilterDisplayStrings;
+ (NSArray<NSString*> *)colorAssignDisplayStrings;

+ (NSArray<NSString *> *)colorStrings;

+ (NSString*)colorDisplayStringToColorString:(NSString*)colorDisplayString;
+ (NSString*)colorStringToColorDisplayString:(NSString*)colorString;


- (NSString*)generateWWWPage;

+ (NSString*)randomSnsStringWithLength:(NSInteger)length;


+ (NSData*)imageDataCacheGetWithName:(NSString*)httpAddrString;
+ (void)imageDataCacheSet:(NSData*)data withName:(NSString*)httpAddrString;

+ (NSString*)imageLocalFileNameOfImageName:(NSString*)imageName;
+ (NSData*)imageDataLocalWithName:(NSString*)imageName;
+ (void)imageDataLocalSet:(NSData*)data withName:(NSString*)imageName;
+ (void)imageDataLocalRemoveWithName:(NSString *)imageName;



+ (NSString*)imageNameNewOnSn:(NSString*)sn format:(NSString*)format;

@end





@interface NoteClassification : NSObject

@property (nonatomic, strong) NSString *classificationName;
@property (nonatomic, strong) NSString *createdAt;


@end
