//
//  UIpConfig.m
//  Reuse0
//
//  Created by Ben on 16/7/11.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "UIpConfig.h"
#import "DBData.h"


@interface ColorItem ()

@end


@implementation ColorItem

+ (ColorItem*)colorItemFromDictionay:(NSDictionary*)dict
{
    ColorItem *colorItem = [[ColorItem alloc] init];
    
    colorItem.name                      = dict[@"name"];
    colorItem.title                     = dict[@"title"];
    colorItem.enableCustmize            = [dict[@"enableCustmize"] boolValue];
    
    colorItem.colorstring               = dict[@"colorstring"];
    colorItem.colorstringDefault        = dict[@"colorstringDefault"];
    
    colorItem.colornightstring          = dict[@"colornightstring"];
    colorItem.colornightstringDefault   = dict[@"colornightstringDefault"];
    
    return colorItem;
}


- (NSDictionary*)toDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    dict[@"name"]                       = self.name;
    dict[@"title"]                      = self.title;
    dict[@"enableCustmize"]             = [NSNumber numberWithBool:self.enableCustmize];
    
    dict[@"colorstring"]                = self.colorstring;
    dict[@"colorstringDefault"]         = self.colorstringDefault;
    
    dict[@"colornightstring"]           = self.colornightstring;
    dict[@"colornightstringDefault"]    = self.colornightstringDefault;
    
    return dict;
}


- (BOOL)isEqualToColorItem:(ColorItem*)colorItem
{
    if(!colorItem) {
        return NO;
    }
    
    if(
    ((!self.name && !colorItem.name) || [self.name isEqualToString:colorItem.name])
    && ((!self.title && !colorItem.title) || [self.title isEqualToString:colorItem.title])
    && (self.enableCustmize == colorItem.enableCustmize)
    && ((!self.colorstringDefault && !colorItem.colorstringDefault) || [self.colorstringDefault isEqualToString:colorItem.colorstringDefault])
    && ((!self.colornightstringDefault && !colorItem.colornightstringDefault) || [self.colornightstringDefault isEqualToString:colorItem.colornightstringDefault])
       ) {
        return YES;
    }
    else {
        return NO;
    }
}


- (BOOL)isEqual:(id)object
{
    if(self == object) {
        return YES;
    }
    
    if(![object isKindOfClass:[ColorItem class]]) {
        return NO;
    }
    
    return [self isEqualToColorItem:object];
}


+ (NSArray<ColorItem*> *)arrayDiffFrom:(NSArray<ColorItem*>*)a1 to:(NSArray<ColorItem*>*)a2
{
    //记录相同的. 之后清除.
    NSMutableIndexSet *dup1 = [[NSMutableIndexSet alloc] init];
    NSMutableArray<ColorItem*> *ret = [NSMutableArray arrayWithArray:a1];
    
    for(NSInteger idx = 0; idx < a2.count; idx ++) {
        ColorItem *colorItem2 = a2[idx];
        
        BOOL found = NO;
        for(NSInteger idx1 = 0; idx1 < a1.count; idx1 ++) {
            ColorItem *colorItem1 = a1[idx1];
            if([colorItem1.name isEqualToString:colorItem2.name]) {
                found = YES;
                
                if([colorItem1 isEqualToColorItem:colorItem2]) {
                    [dup1 addIndex:idx1];
                }
                else {
                    [ret replaceObjectAtIndex:idx1 withObject:colorItem2];
                }
                
                break;
            }
        }
        
        if(!found) {
            [ret addObject:colorItem2];
        }
    }
    
    //清除比较后相同的.
    [ret removeObjectsAtIndexes:dup1];
    
    if(ret.count == 0) {
        return nil;
    }
    else {
        return [NSArray arrayWithArray:ret];
    }
}


- (NSString*)description
{
    NSMutableString *strm = [[NSMutableString alloc] init];
    [strm appendFormat:@"name : %@, colorstring : %@, colorstringDefault : %@, colornightstring : %@, colornightstringDefault : %@, enableCustmize : %d",
     self.name, self.colorstring, self.colorstringDefault, self.colornightstring, self.colornightstringDefault, self.enableCustmize];
    
    return [NSString stringWithString:strm];
}


@end



@implementation FontItem
@end


@implementation BackgroundViewItem

- (NSString*)description
{
    NSString *descriptionString = nil;
    
    UIImage *image = self.imageData?[UIImage imageWithData:self.imageData]:nil;
    
    descriptionString = [NSString stringWithFormat:@"%@ : %@ enableCustmize-%zd   onUse-%d  imageName-%@  imageData-%@", self.name, self.title, self.enableCustmize, self.onUse, self.imageData, image];
    
    return descriptionString;
}

@end





#define DBNAME_UIPCONFIG        @"UIpConfig"
#define TABLENAME_COLOR         @"color"
#define TABLENAME_FONT          @"font"


@interface UIpConfig ()

@property (nonatomic, strong) NSMutableArray *colorItems;
@property (nonatomic, strong) NSMutableArray *fontItems;
@property (nonatomic, strong) NSMutableArray *backgroundviewItems;

@property (nonatomic, strong) DBData *dbData;


@end





@implementation UIpConfig





- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"UIpConfig init");
        
        //建立数据库.
        self.dbData = [[DBData alloc] init];
        
        NSString *resPath= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"UIpConfigDB.json"];
        NSData *data = [NSData dataWithContentsOfFile:resPath];
        //NSLog(@"------\n%@\n-------", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if(data) {
            [self.dbData DBDataAddTableAttributeByJsonData:data];
            [self.dbData buildTable];
        }
        else {
            NSLog(@"#error - resPath content NULL.");
        }
        
        //从数据库中读取颜色和字体值.
        self.colorItems = [[NSMutableArray alloc] init];
        self.fontItems = [[NSMutableArray alloc] init];
        [self getUIpConfigColorsFromDB];
    }
    return self;
}


- (NSArray<ColorItem*> *)colorItemsParseFromJsonData:(NSData*)jsonData
{
    NSMutableArray<ColorItem*> *colorItems = [[NSMutableArray alloc] init];
    
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    if([obj isKindOfClass:[NSArray class]]) {
        for(NSDictionary *dict in obj) {
            ColorItem *colorItem = [ColorItem colorItemFromDictionay:dict];
            [colorItems addObject:colorItem];
        }
    }
    
    NSLog(@"colorItemsParseFromJsonData : %zd", colorItems.count);
    return [NSArray arrayWithArray:colorItems];
}




- (void)updateUIpConfigColorItems:(NSArray<ColorItem*> *)colorItems
{
    //记录相同的. 之后清除.
    NSMutableArray<ColorItem*> *updates = [[NSMutableArray alloc] init];
    
    for(NSInteger idx = 0; idx < colorItems.count; idx ++) {
        ColorItem *colorItem = colorItems[idx];
        
        BOOL found = NO;
        for(NSInteger idx1 = 0; idx1 < self.colorItems.count; idx1 ++) {
            ColorItem *colorItem1 = self.colorItems[idx1];
            if([colorItem1.name isEqualToString:colorItem.name]) {
                found = YES;
                
                if([colorItem1 isEqualToColorItem:colorItem]) {
                    
                }
                else {
                    [self.colorItems replaceObjectAtIndex:idx1 withObject:colorItem];
                    [updates addObject:colorItem];
                }
                
                break;
            }
        }
        
        if(!found) {
            [self.colorItems addObject:colorItem];
            [updates addObject:colorItem];
        }
    }
    
    //更新的写入数据库.
    NSLog(@"color update : %zd", updates.count);
    if(updates.count > 0) {
        //NSMutableArray *infosUpdate = [[NSMutableArray alloc] init];
        //NSMutableArray *infosQuery = [[NSMutableArray alloc] init];
        
        NSMutableArray *values = [[NSMutableArray alloc] init];
        
        
        for(ColorItem *colorItem in updates) {
//            [infosUpdate addObject:@{
//                                     @"name"                       : colorItem.name,
//                                     @"title"                      : colorItem.title,
//                                     @"enableCustmize"             : [NSNumber numberWithBool:colorItem.enableCustmize],
//                                     @"colorstringDefault"         : colorItem.colorstringDefault,
//                                     @"colornightstringDefault"    : colorItem.colornightstringDefault
//                                     }];
//            [infosQuery addObject:@{@"name":colorItem.name}];
            
            NSArray *array = @[colorItem.name,colorItem.title,[NSNumber numberWithBool:colorItem.enableCustmize],colorItem.colorstringDefault,colorItem.colornightstringDefault];
            
            [values addObject:array];
        }
        
        [self.dbData DBDataInsertDBName:DBNAME_UIPCONFIG
                                  table:TABLENAME_COLOR
                                   info:@{
                                          DBDATA_STRING_COLUMNS:@[@"name", @"title", @"enableCustmize", @"colorstringDefault", @"colornightstringDefault"],
                                          DBDATA_STRING_VALUES :values
                                          }
                              orReplace:YES
         ];
    }
}


- (BOOL)addUIpConfigColorByJsonData:(NSData*)jsonData
{
    if(!jsonData) {
        NSLog(@"#error - addUIpConfigColorByJsonData jsonData nil.");
        return NO;
    }
    
    //从json中解析出colorItems.
    NSArray<ColorItem*> *colorItems = [self colorItemsParseFromJsonData:jsonData];
    
    //将变化的值存储到DB. 同时会更新 self.colorItems.
    [self updateUIpConfigColorItems:colorItems];
    
    return YES;
}


- (ColorItem*)getUIpConfigColorItemByName:(NSString*)name
{
    for(ColorItem *item in self.colorItems) {
        if([item.name isEqualToString:name]) {
            return item;
        }
    }
    
    return nil;
}


- (NSInteger)getUIpConfigColorItemIndexByName:(NSString*)name
{
    NSInteger idx = 0;
    for(ColorItem *item in self.colorItems) {
        if([item.name isEqualToString:name]) {
            return idx;
        }
        
        idx ++;
    }
    
    return NSNotFound;
}


- (BOOL)updateUIpConfigColorItemToDB:(ColorItem*)colorItem
{
    BOOL result = YES;
    
    NSInteger retDBData = [self.dbData DBDataUpdateDBName:DBNAME_UIPCONFIG
                                                    table:@"color"
                                               infoUpdate:[colorItem toDictionary]
                                                infoQuery:@{@"name":colorItem.name}];
    result = (retDBData == DB_EXECUTE_OK);
    return result;
}


- (UIColor*)getUIpConfigColorByName:(NSString*)name
{
    UIColor *color = [UIColor orangeColor];
    ColorItem *colorItem = [self getUIpConfigColorItemByName:name];
    NS0Log(@"getUIpConfigColorByName : %@ -> %@", name, colorItem);
    
    if(colorItem) {
        if(!self.nightmode) {
            NS0Log(@"colorWithName : %@ (%@)", name, colorItem.colorstring);
            if(colorItem.colorstring.length > 0) {
                color = [UIColor colorFromString:colorItem.colorstring];
            }
            else {
                color = [UIColor colorFromString:colorItem.colorstringDefault];
            }
        }
        else {
            NS0Log(@"colorWithName : %@ (%@)", name, colorItem.colornightstring);
            if(colorItem.colornightstring.length > 0) {
                color = [UIColor colorFromString:colorItem.colornightstring];
            }
            else {
                color = [UIColor colorFromString:colorItem.colornightstringDefault];
            }
        }
    }
    else {
        NSLog(@"#error - colorWithName [%@] not found.", name);
        color = !self.nightmode ? [UIColor orangeColor] : [UIColor blueColor];
    }

    return color;
}


- (void)getUIpConfigColorsFromDB
{
    NSDictionary *dict = [self.dbData DBDataQueryDBName:DBNAME_UIPCONFIG
                                                  table:TABLENAME_COLOR
                                            columnNames:nil
                                                  query:nil
                                                  limit:nil];
    
    NSArray<NSDictionary*> *dicts = [self.dbData queryResultDictionaryToArray:dict];
    
    for(NSDictionary *dict in dicts) {
        ColorItem *colorItem = [ColorItem colorItemFromDictionay:dict];
        if(colorItem) {
            [self.colorItems addObject:colorItem];
        }
        else {
            NSLog(@"#error - ");
        }
    }
}



//- (NSMutableArray*)getUIpConfigFonts;
//- (BOOL)updateUIpConfigFontstring:(NSString*)fontstring toName:(NSString*)name;
//- (UIColor*)getUIpConfigFontByName:(NSString*)name;
//
//
//- (NSMutableArray*)getUIpConfigBackgroundViews;
//- (BOOL)updateUIpConfigBackgroundViewData:(NSData*)backgroundViewData toName:(NSString*)name;
//- (UIColor*)getUIpConfigBackgroundViewDataByName:(NSString*)name;


#if 0
- (void)loadItems
{
    NSArray *colors = [[AppConfig sharedConfigDB] configDBColorGet];
    for(ColorItem *item in colors) {
        item.color = [UIColor colorFromString:item.colorstring];
        if(!item.color) {
            NSLog(@"#error - color null from [%@]", item.colorstring);
            item.color = [UIColor orangeColor];
        }
        
        item.colornight = [UIColor colorFromString:item.colornightstring];
        if(!item.colornight) {
            NSLog(@"#error - color null from [%@]", item.colorstring);
            item.color = [UIColor blueColor];
        }
    }
    
    self.colorItems = [NSMutableArray arrayWithArray:colors];
    
    NSArray *fonts = [[AppConfig sharedConfigDB] configDBFontGet];
    for(FontItem *item in fonts) {
        item.font = [UIFont fontFromString:item.fontstring];
        if(!item.font) {
            NSLog(@"#error - font null from [%@]", item.fontstring);
            item.font = FONT_SMALL;
        }
    }
    
    self.fontItems = [NSMutableArray arrayWithArray:fonts];
    
    self.colorItems = [NSMutableArray arrayWithArray:colors];
    
    NSArray *backgroundviews = [[AppConfig sharedConfigDB] configDBBackgroundViewGet];
    self.backgroundviewItems = [NSMutableArray arrayWithArray:backgroundviews];
}
#endif


+ (UIpConfig*)sharedUIpConfig
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (NSMutableArray*)getUIpConfigColors
{
    return self.colorItems;
}


+ (UIColor*)colorWithName:(NSString*)name
{
    return [[UIpConfig sharedUIpConfig] getUIpConfigColorByName:name];
}





#if 0
- (BOOL)updateUIpConfigColor:(ColorItem*)color
{
    //根据colorstring更新color.
    color.color = [UIColor colorFromString:color.colorstring];
    if(!color.color) {
        NSLog(@"#error - color null from [%@]", color.colorstring);
        color.color = [UIColor orangeColor];
    }
    
    if(!color.colornight) {
        NSLog(@"#error - color null from [%@]", color.colorstring);
        color.colornight = [UIColor blueColor];
    }
    
    BOOL result = [[AppConfig sharedConfigDB] configDBColorUpdate:color];
    if(result) {
        for(NSInteger index = 0; index < self.colorItems.count; index ++) {
            ColorItem* colorUpdate = self.colorItems[index];
            if([color.name isEqualToString:colorUpdate.name]) {
                [self.colorItems replaceObjectAtIndex:index withObject:color];
            }
        }
    }
    else {
        NSLog(@"#error - ");
    }
    
    return result;
}
#endif





- (NSMutableArray*)getUIpConfigFonts
{
    return self.fontItems;
}


#if 0
- (BOOL)updateUIpConfigFont:(FontItem*)font
{
    //根据fontstring更新font.
    font.font = [UIFont fontFromString:font.fontstring];
    if(!font.font) {
        NSLog(@"#error - font null from [%@]", font.fontstring);
        font.font = FONT_SMALL;
    }
    
    BOOL result = [[AppConfig sharedConfigDB] configDBFontUpdate:font];
    if(result) {
        for(NSInteger index = 0; index < self.fontItems.count; index ++) {
            FontItem* fontUpdate = self.fontItems[index];
            if([font.name isEqualToString:fontUpdate.name]) {
                [self.fontItems replaceObjectAtIndex:index withObject:font];
            }
        }
    }
    else {
        NSLog(@"#error - ");
    }
    
    return result;
}
#endif



- (NSMutableArray*)getUIpConfigBackgroundViews
{
    return self.backgroundviewItems;
}


#if 0
- (BOOL)updateUIpConfigBackgroundView:(BackgroundViewItem *)backgroundview
{
    //根据标记值更新imageData.
    //imageData直接存数据库. 不用更新.
    
    BOOL result = [[AppConfig sharedConfigDB] configDBBackgroundViewUpdate:backgroundview];
    if(result) {
        for(NSInteger index = 0; index < self.backgroundviewItems.count; index ++) {
            BackgroundViewItem* backgroundviewUpdate = self.backgroundviewItems[index];
            if([backgroundview.name isEqualToString:backgroundviewUpdate.name]) {
                [self.backgroundviewItems replaceObjectAtIndex:index withObject:backgroundview];
            }
        }
    }
    else {
        NSLog(@"#error - ");
    }
    
    return result;
}
#endif





@end



@implementation UIColor (UIpConfig)

//if use url. it can not running on main thread.
+(UIColor*)colorFromString:(NSString*)string
{
    if(!string || string.length == 0) {
        NSLog(@"#error - invlid color string [%@].", string);
        return [UIColor orangeColor];
    }
    
    NSDictionary *ksystemColors = @{
                                    @"red"       :[UIColor redColor],
                                    @"purple"    :[UIColor purpleColor],
                                    @"black"     :[UIColor blackColor],
                                    @"white"     :[UIColor whiteColor],
                                    @"orange"    :[UIColor orangeColor],
                                    @"blue"      :[UIColor blueColor],
                                    @"cyan"      :[UIColor cyanColor],
                                    @"lightGray" :[UIColor lightGrayColor],
                                    @"clear"     :[UIColor clearColor],
                                    
                                    };
    
    UIColor *systemColor = [ksystemColors objectForKey:string];
    if(nil != systemColor) {
        NS0Log(@"system color : %@", systemColor);
        return systemColor;
    }
    
    if([string hasPrefix:@">>"]) {
        return [self colorWithName:[string substringFromIndex:@">>".length]];
    }
    
    if([string characterAtIndex:0] != '#') {
        NSLog(@"#error - invlid color string [%@].", string);
        return [UIColor orangeColor];
    }
    
    NSInteger colorValue = 0;
    CGFloat alpha = 1.0;
    if(string.length == 7 || (string.length == 10 && '@' == [string characterAtIndex:7])) {
        colorValue = [[string substringWithRange:NSMakeRange(1, 6)] integerValue];
        
        char ch;
        int v;
        int vs[6];
        NSInteger r = 0;
        NSInteger g = 0;
        NSInteger b = 0;
        
#define HEXCHAR_TO_INT(ch, v) \
if(ch >= '0' && ch <= '9')      { v = ch - '0'; } \
else if(ch >= 'A' && ch <= 'F') { v = ch - 'A' + 10; } \
else if(ch >= 'a' && ch <= 'f') { v = ch - 'a' + 10; } \
else { v = -1; }
        
#define DECCHAR_TO_INT(ch, v) \
if(ch >= '0' && ch <= '9')      { v = ch - '0'; }   \
else { v = -1; }
        
        
        for(NSInteger index = 1; index <= 6; index++ ) {
            ch = [string characterAtIndex:index];
            HEXCHAR_TO_INT(ch, v);
            if(-1 == v) {
                NSLog(@"#error - invlid color string [%@].", string);
                return [UIColor orangeColor];
            }
            
            vs[index-1] = v;
        }
        
        r = (vs[0] << 4) + vs[1];
        g = (vs[2] << 4) + vs[3];
        b = (vs[4] << 4) + vs[5];
        
        if(string.length == 10) {
            for(NSInteger index = 8; index <= 9; index++ ) {
                ch = [string characterAtIndex:index];
                DECCHAR_TO_INT(ch, v);
                if(-1 == v) {
                    NSLog(@"#error - invlid color string [%@].", string);
                    return [UIColor orangeColor];
                }
                
                vs[index-8] = v;
            }
            
            alpha = (CGFloat)(vs[0]*10 + vs[1]) / 100.0;
        }
        
        NS0Log(@"%zd %zd %zd %f", r, g, b, alpha);
        return [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:alpha];
    }
    else if([string hasPrefix:@"url"]) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[string substringFromIndex:3]]]];
        if(image) {
            NSLog(@"colorWithPatternImage");
            return [UIColor colorWithPatternImage:image];
        }
        else {
            NSLog(@"#error - invlid color string [%@].", string);
            return [UIColor orangeColor];
        }
    }
    else {
        NSLog(@"#error - invlid color string [%@].", string);
        return [UIColor orangeColor];
    }
}


+ (UIColor*)colorWithName:(NSString*)name
{
    return [[UIpConfig sharedUIpConfig] getUIpConfigColorByName:name];
}



@end




@implementation UIFont (UIpConfig)



+ (UIFont*)fontFromString:(NSString*)string
{
    UIFont *font = FONT_SMALL;
    CGFloat size = [UIFont smallSystemFontSize];
    
    if([string hasPrefix:@"wp"]) {
        CGRect frameMain = [[UIScreen mainScreen] bounds];
        CGFloat width = MIN(frameMain.size.width, frameMain.size.height);
        size = [[string substringFromIndex:2] floatValue] * width;
    }
    else if([string hasPrefix:@"px"]) {
        size = [[string substringFromIndex:2] floatValue];
    }
    else if([string hasPrefix:@"small"]) {
        size = [UIFont smallSystemFontSize];
    }
    else if([string hasPrefix:@"system"]) {
        size = [UIFont systemFontSize];
    }
    else {
        NSLog(@"#error - invlid font string [%@].", string);
    }
    
    NSRange range = [string rangeOfString:@"bold"];
    if(range.location != NSNotFound && range.length > 0) {
        font = [UIFont boldSystemFontOfSize:size];
    }
    else {
        font = [UIFont systemFontOfSize:size];
    }
    
    return font;
}


+ (UIFont*)fontWithName:(NSString*)name
{
    UIFont *font;
    NSDictionary *nameAndFont = @{
                                  @"TaskDetailTitle":@"px36",
                                  @"TaskDetailContent":@"px20",
                                  @"TaskPropertyTitleLabel":@"px17.9",
                                  @"TaskPropertyContentLabel":@"px14.5",
                                  @"NoteRecordCommittedAt":@"px12",
                                  @"NoteRecordType":@"px14.5",
                                  @"NoteRecordContent":@"px14.5",
                                  @"NoteCustomSectionHeader":@"px20 bold",
                                  @"TaskSectionHeader":@"px18 bold",
                                  @"small":@"small",
                                  };
    
    
    NSString *fontString = nameAndFont[name];
    if(!fontString) {
        NSLog(@"fontWithName not assign (%@).", name);
        font = FONT_SMALL;
    }
    else {
        font = [UIFont fontFromString:fontString];
    }
    
    NS0Log(@"FONT [%@] : %@", name, font);
    return font;
    
#if 0
    for(FontItem *item in [[UIpConfig sharedUIpConfig] getUIpConfigFonts]) {
        if([item.name isEqualToString:name]) {
            return [UIFont fontFromString:item.fontstring];
        }
    }
    
    NSLog(@"#error - fontWithName [%@] not found.", name);
    return FONT_SMALL;
#endif
}


@end
