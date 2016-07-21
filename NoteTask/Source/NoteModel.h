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
@property (nonatomic, strong) NSString *comment;
@end


@interface NoteModel : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *image;
//@property (nonatomic, strong) NSMutableArray *paragraphs;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *modify;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *classification;
@property (nonatomic, strong) NSString *audio;



- (instancetype)initWithJsonData:(NSData*)jsonData;
- (NSData*)toJsonData;
//- (NSString*)contents;

//- (void)storeToLocal;





@end
