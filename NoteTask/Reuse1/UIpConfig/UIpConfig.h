//
//  UIpConfig.h
//  Reuse0
//
//  Created by Ben on 16/7/11.
//  Copyright © 2016年 Ben. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ColorItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL      enableCustmize;

@property (nonatomic, strong) NSString *colorstring;
@property (nonatomic, strong) NSString *colorstringDefault;

@property (nonatomic, strong) NSString *colornightstring;
@property (nonatomic, strong) NSString *colornightstringDefault;

+ (ColorItem*)colorItemFromDictionay:(NSDictionary*)dict;
- (NSDictionary*)toDictionary;

@end


@interface FontItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL      enableCustmize;

@property (nonatomic, strong) NSString *fontstring;
@property (nonatomic, strong) NSString *fontstringDefault;

@end


@interface BackgroundViewItem : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL      enableCustmize;
@property (nonatomic, assign) BOOL      onUse;

@property (nonatomic, strong) NSData   *imageData;
@property (nonatomic, strong) NSData   *imageDataDefault;

@end


@interface UIColor (UIpConfig)

+ (UIColor*)colorFromString:(NSString*)string;
+ (UIColor*)colorWithName:(NSString*)name;



@end


@interface UIFont (UIpConfig)

+ (UIFont*)fontFromString:(NSString*)string;
+ (UIFont*)fontWithName:(NSString*)name;


@end




@interface UIpConfig : NSObject



+ (UIpConfig*)sharedUIpConfig;


- (NSArray<ColorItem*> *)colorItemsParseFromJsonData:(NSData*)jsonData;
- (void)updateUIpConfigColorItems:(NSArray<ColorItem*> *)colorItems;

#if 0
- (BOOL)addUIpConfigColorItems:(NSArray<ColorItem*> *)colorItems;
- (BOOL)updateUIpConfigColor:(ColorItem*)colorItem;
- (UIColor*)getUIpConfigColorByName:(NSString*)name;


- (NSMutableArray*)getUIpConfigFonts;
- (BOOL)updateUIpConfigFontstring:(NSString*)fontstring toName:(NSString*)name;
- (UIColor*)getUIpConfigFontByName:(NSString*)name;


- (NSMutableArray*)getUIpConfigBackgroundViews;
- (BOOL)updateUIpConfigBackgroundViewData:(NSData*)backgroundViewData toName:(NSString*)name;
- (UIColor*)getUIpConfigBackgroundViewDataByName:(NSString*)name;
#endif

@property (nonatomic, assign) BOOL nightmode;


@end



#define FONT_SMALL      [UIFont systemFontOfSize:[UIFont smallSystemFontSize]]
#define FONT_SMALLW(w)  [UIFont systemFontOfSize:[UIFont smallSystemFontSize] weight:w]

#define FONT_SYSTEM     [UIFont systemFontOfSize:[UIFont systemFontSize]]


#define FONT_MT                 [UIFont fontWithName:@"Menlo-Bold"]
#define FONT_MTSIZE(fontSize)   [UIFont fontWithName:@"Menlo-Bold" size:fontSize];
//@"TimesNewRomanPS-BoldMT"
//        UIFont *font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:fontSize];
//    UIFont *font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:20];
//    UIFont *font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:20];
