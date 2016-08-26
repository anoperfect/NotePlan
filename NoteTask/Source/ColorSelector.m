//
//  ColorSelector.m
//  NoteTask
//
//  Created by Ben on 16/8/22.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "ColorSelector.h"

@interface ColorSelector () <UITableViewDataSource, UITableViewDelegate>




@property (nonatomic, assign) CGFloat               cellHeight;
@property (nonatomic, strong) NSArray<NSDictionary*>    *presetColorStrings;
@property (nonatomic, assign) BOOL                  isTextColor;
@property (nonatomic, strong) void (^handle)(NSString* selectedColorString, NSString *selectedColorText);

@property (nonatomic, strong) NSArray<NSDictionary*>    *colorStrings;

@property (nonatomic, strong) UITableView           *colorTable;



@end


@implementation ColorSelector

//行高
//预制颜色NSString组.
//显示前景色/背景色.
//选中的block.
- (instancetype)initWithFrame:(CGRect)frame
                   cellHeight:(CGFloat)cellHeight
                 colorPresets:(NSArray<NSDictionary*>*)presetColorStrings
                  isTextColor:(BOOL)isTextColor
                 selectHandle:(void(^)(NSString* selectedColorString, NSString *selectedColorText))handle
{
    self = [super initWithFrame:frame];
    if (self) {
        self.cellHeight         = cellHeight;
        self.presetColorStrings = presetColorStrings;
        self.isTextColor        = isTextColor;
        self.handle             = handle;
        
        //为按照原排序, 结构为数组成员字典.
        self.colorStrings = [self chromatogram];
        
        //UI元素创建.
        self.colorTable = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.colorTable.dataSource = self;
        self.colorTable.delegate = self;
        [self addSubview:self.colorTable];
        
        
    }
    return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return self.presetColorStrings.count;
    }
    else if(section == 1) {
        return self.colorStrings.count;
    }
    else {
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36.0;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"colorCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"colorCell"];
        CGRect frame = cell.frame;
        frame.size.width = tableView.frame.size.width;
        frame.size.height = 36.0;
        [cell setFrame:frame];
        
        UILabel *colorLabel = [[UILabel alloc] init];
        colorLabel.tag = 111;
        [cell addSubview:colorLabel];
        
        UILabel *colorTextLabel = [[UILabel alloc] init];
        colorTextLabel.tag = 112;
        [cell addSubview:colorTextLabel];
    }
    else {
        CGRect frame = cell.frame;
        frame.size.width = tableView.frame.size.width;
        frame.size.height = 36.0;
        [cell setFrame:frame];
    }
    
    NSString *colorString   = @"orange";
    NSString *colorText     = @"orange";
    if(indexPath.section == 0) {
        NSDictionary *dict = self.presetColorStrings[indexPath.row];
        colorText = [dict allKeys][0];
        colorString = [dict allValues][0];
    }
    else if(indexPath.section == 1) {
        NSDictionary *dict = self.colorStrings[indexPath.row];
        colorText = [dict allKeys][0];
        colorString = [dict allValues][0];
    }
    
    UILabel *colorLabel     = [cell viewWithTag:111];
    UILabel *colorTextLabel = [cell viewWithTag:112];
    colorLabel.frame        = CGRectMake(0, 2, cell.frame.size.width*0.36, cell.frame.size.height - 4);
    colorTextLabel.frame    = CGRectMake(colorLabel.frame.size.width, 2, cell.frame.size.width - colorLabel.frame.size.width, cell.frame.size.height - 4);
    
//    cell.backgroundColor = [UIColor purpleColor];
//    cell.textLabel.text = colorString;
    
    colorLabel.backgroundColor  = [UIColor colorFromString:colorString];
    colorTextLabel.text         = colorText;
    
    NSLog(@"%zd:%zd : %@", indexPath.section, indexPath.row, cell.subviews);
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.handle) {
        NSString *colorString   = @"orange";
        NSString *colorText     = @"orange";
        if(indexPath.section == 0) {
            NSDictionary *dict = self.presetColorStrings[indexPath.row];
            colorText = [dict allKeys][0];
            colorString = [dict allValues][0];
        }
        else if(indexPath.section == 1) {
            NSDictionary *dict = self.colorStrings[indexPath.row];
            colorText = [dict allKeys][0];
            colorString = [dict allValues][0];
        }
        
        self.handle(colorString, colorText);
        
    }
}




- (NSArray<NSDictionary*> *)chromatogram
{
    return
    @[
      @{@"snow  " : @"#fffafa"},
      @{@"ghostwhite  " : @"#f8f8ff"},
      @{@"whitesmoke5  " : @"#f5f5f5"},
      @{@"gainsboro   " : @"#dcdcdc"},
      @{@"floralwhite   " : @"#fffaf0"},
      @{@"oldlace   " : @"#fdf5e6"},
      @{@"linen   " : @"#faf0e6"},
      @{@"antiquewhite   " : @"#faebd7"},
      @{@"papayawhip   " : @"#ffefd5"},
      @{@"blanchedalmond   " : @"#ffebcd"},
      @{@"bisque   " : @"#ffe4c4"},
      @{@"peachpuff   " : @"#ffdab9"},
      @{@"navajowhite   " : @"#ffdead"},
      @{@"moccasin   " : @"#ffe4b5"},
      @{@"cornsilk   " : @"#fff8dc"},
      @{@"ivory   " : @"#fffff0"},
      @{@"lemonchiffon   " : @"#fffacd"},
      @{@"seashell   " : @"#fff5ee"},
      @{@"honeydew   " : @"#f0fff0"},
      @{@"mintcream   " : @"#f5fffa"},
      @{@"azure   " : @"#f0ffff"},
      @{@"aliceblue   " : @"#f0f8ff"},
      @{@"lavender   " : @"#e6e6fa"},
      @{@"lavenderblush   " : @"#fff0f5"},
      @{@"mistyrose   " : @"#ffe4e1"},
      @{@"white   " : @"#ffffff"},
      @{@"black  " : @"#000000"},
      @{@"darkslategray  " : @"#2f4f4f"},
      @{@"dimgrey   " : @"#696969"},
      @{@"slategrey   " : @"#708090"},
      @{@"lightslategray   " : @"#778899"},
      @{@"grey   " : @"#bebebe"},
      @{@"lightgray   " : @"#d3d3d3"},
      @{@"midnightblue  " : @"#191970"},
      @{@"navyblue  " : @"#000080"},
      @{@"cornflowerblue   " : @"#6495ed"},
      @{@"darkslateblue " : @"#483d8b"},
      @{@"slateblue  " : @"#6a5acd"},
      @{@"mediumslateblue   " : @"#7b68ee"},
      @{@"lightslateblue   " : @"#8470ff"},
      @{@"mediumblue " : @"#0000cd"},
      @{@"royalblue  " : @"#4169e1"},
      @{@"blue " : @"#0000ff"},
      @{@"dodgerblue  " : @"#1e90ff"},
      @{@"deepskyblue " : @"#00bfff"},
      @{@"skyblue   " : @"#87ceeb"},
      @{@"lightskyblue   " : @"#87cefa"},
      @{@"steelblue  " : @"#4682b4"},
      @{@"lightsteelblue   " : @"#b0c4de"},
      @{@"lightblue   " : @"#add8e6"},
      @{@"powderblue   " : @"#b0e0e6"},
      @{@"paleturquoise   " : @"#afeeee"},
      @{@"darkturquoise " : @"#00ced1"},
      @{@"mediumturquoise  " : @"#48d1cc"},
      @{@"turquoise  " : @"#40e0d0"},
      @{@"cyan " : @"#00ffff"},
      @{@"lightcyan   " : @"#e0ffff"},
      @{@"cadetblue  " : @"#5f9ea0"},
      @{@"mediumaquamarine   " : @"#66cdaa"},
      @{@"aquamarine   " : @"#7fffd4"},
      @{@"darkgreen " : @"#006400"},
      @{@"darkolivegreen " : @"#556b2f"},
      @{@"darkseagreen   " : @"#8fbc8f"},
      @{@"seagreen " : @"#2e8b57"},
      @{@"mediumseagreen  " : @"#3cb371"},
      @{@"lightseagreen  " : @"#20b2aa"},
      @{@"palegreen   " : @"#98fb98"},
      @{@"springgreen " : @"#00ff7f"},
      @{@"lawngreen " : @"#7cfc00"},
      @{@"green " : @"#00ff00"},
      @{@"chartreuse " : @"#7fff00"},
      @{@"medspringgreen   " : @"#00fa9a"},
      @{@"greenyellow  " : @"#adff2f"},
      @{@"limegreen " : @"#32cd32"},
      @{@"yellowgreen  " : @"#9acd32"},
      @{@"forestgreen" : @"#228b22"},
      @{@"olivedrab  " : @"#6b8e23"},
      @{@"darkkhaki   " : @"#bdb76b"},
      @{@"palegoldenrod   " : @"#eee8aa"},
      @{@"ltgoldenrodyello   " : @"#fafad2"},
      @{@"lightyellow   " : @"#ffffe0"},
      @{@"yellow " : @"#ffff00"},
      @{@"gold " : @"#ffd700"},
      @{@"lightgoldenrod   " : @"#eedd82"},
      @{@"goldenrod  " : @"#daa520"},
      @{@"darkgoldenrod  " : @"#b8860b"},
      @{@"rosybrown   " : @"#bc8f8f"},
      @{@"indianred " : @"#cd5c5c"},
      @{@"saddlebrown " : @"#8b4513"},
      @{@"sienna " : @"#a0522d"},
      @{@"peru  " : @"#cd853f"},
      @{@"burlywood   " : @"#deb887"},
      @{@"beige   " : @"#f5f5dc"},
      @{@"wheat   " : @"#f5deb3"},
      @{@"sandybrown  " : @"#f4a460"},
      @{@"tan   " : @"#d2b48c"},
      @{@"chocolate  " : @"#d2691e"},
      @{@"firebrick " : @"#b22222"},
      @{@"brown " : @"#a52a2a"},
      @{@"darksalmon   " : @"#e9967a"},
      @{@"salmon   " : @"#fa8072"},
      @{@"lightsalmon   " : @"#ffa07a"},
      @{@"orange " : @"#ffa500"},
      @{@"darkorange " : @"#ff8c00"},
      @{@"coral  " : @"#ff7f50"},
      @{@"lightcoral   " : @"#f08080"},
      @{@"tomato " : @"#ff6347"},
      @{@"orangered  " : @"#ff4500"},
      @{@"red " : @"#ff0000"},
      @{@"hotpink   " : @"#ff69b4"},
      @{@"deeppink  " : @"#ff1493"},
      @{@"pink   " : @"#ffc0cb"},
      @{@"lightpink   " : @"#ffb6c1"},
      @{@"palevioletred   " : @"#db7093"},
      @{@"maroon " : @"#b03060"},
      @{@"mediumvioletred  " : @"#c71585"},
      @{@"violetred  " : @"#d02090"},
      @{@"magenta " : @"#ff00ff"},
      @{@"violet   " : @"#ee82ee"},
      @{@"plum   " : @"#dda0dd"},
      @{@"orchid   " : @"#da70d6"},
      @{@"mediumorchid  " : @"#ba55d3"},
      @{@"darkorchid  " : @"#9932cc"},
      @{@"darkviolet " : @"#9400d3"},
      @{@"blueviolet  " : @"#8a2be2"},
      @{@"purple  " : @"#a020f0"},
      @{@"mediumpurple   " : @"#9370db"},
      @{@"thistle   " : @"#d8bfd8"},
      @{@"snow1   " : @"#fffafa"},
      @{@"snow2   " : @"#eee9e9"},
      @{@"snow3   " : @"#cdc9c9"},
      @{@"snow4   " : @"#8b8989"},
      @{@"seashell1   " : @"#fff5ee"},
      @{@"seashell2   " : @"#eee5de"},
      @{@"seashell3   " : @"#cdc5bf"},
      @{@"seashell4   " : @"#8b8682"},
      @{@"antiquewhite1   " : @"#ffefdb"},
      @{@"antiquewhite2   " : @"#eedfcc"},
      @{@"antiquewhite3   " : @"#cdc0b0"},
      @{@"antiquewhite4   " : @"#8b8378"},
      @{@"bisque1   " : @"#ffe4c4"},
      @{@"bisque2   " : @"#eed5b7"},
      @{@"bisque3   " : @"#cdb79e"},
      @{@"bisque4   " : @"#8b7d6b"},
      @{@"peachpuff1   " : @"#ffdab9"},
      @{@"peachpuff2   " : @"#eecbad"},
      @{@"peachpuff3   " : @"#cdaf95"},
      @{@"peachpuff4   " : @"#8b7765"},
      @{@"navajowhite1   " : @"#ffdead"},
      @{@"navajowhite2   " : @"#eecfa1"},
      @{@"navajowhite3   " : @"#cdb38b"},
      @{@"navajowhite4  " : @"#8b795e"},
      @{@"lemonchiffon1   " : @"#fffacd"},
      @{@"lemonchiffon2   " : @"#eee9bf"},
      @{@"lemonchiffon3   " : @"#cdc9a5"},
      @{@"lemonchiffon4   " : @"#8b8970"},
      @{@"cornsilk1   " : @"#fff8dc"},
      @{@"cornsilk2   " : @"#eee8cd"},
      @{@"cornsilk3   " : @"#cdc8b1"},
      @{@"cornsilk4   " : @"#8b8878"},
      @{@"ivory1   " : @"#fffff0"},
      @{@"ivory2   " : @"#eeeee0"},
      @{@"ivory3   " : @"#cdcdc1"},
      @{@"ivory4   " : @"#8b8b83"},
      @{@"honeydew1   " : @"#f0fff0"},
      @{@"honeydew2   " : @"#e0eee0"},
      @{@"honeydew3   " : @"#c1cdc1"},
      @{@"honeydew4   " : @"#838b83"},
      @{@"lavenderblush1   " : @"#fff0f5"},
      @{@"lavenderblush2   " : @"#eee0e5"},
      @{@"lavenderblush3   " : @"#cdc1c5"},
      @{@"lavenderblush4   " : @"#8b8386"},
      @{@"mistyrose1   " : @"#ffe4e1"},
      @{@"mistyrose2   " : @"#eed5d2"},
      @{@"mistyrose3   " : @"#cdb7b5"},
      @{@"mistyrose4   " : @"#8b7d7b"},
      @{@"azure1   " : @"#f0ffff"},
      @{@"azure2   " : @"#e0eeee"},
      @{@"azure3   " : @"#c1cdcd"},
      @{@"azure4   " : @"#838b8b"},
      @{@"slateblue1   " : @"#836fff"},
      @{@"slateblue2   " : @"#7a67ee"},
      @{@"slateblue3  " : @"#6959cd"},
      @{@"slateblue4 " : @"#473c8b"},
      @{@"royalblue1  " : @"#4876ff"},
      @{@"royalblue2  " : @"#436eee"},
      @{@"royalblue3 " : @"#3a5fcd"},
      @{@"royalblue4 " : @"#27408b"},
      @{@"blue1 " : @"#0000ff"},
      @{@"blue2 " : @"#0000ee"},
      @{@"blue3 " : @"#0000cd"},
      @{@"blue4 " : @"#00008b"},
      @{@"dodgerblue1  " : @"#1e90ff"},
      @{@"dodgerblue2  " : @"#1c86ee"},
      @{@"dodgerblue3  " : @"#1874cd"},
      @{@"dodgerblue4 " : @"#104e8b"},
      @{@"steelblue1  " : @"#63b8ff"},
      @{@"steelblue2  " : @"#5cacee"},
      @{@"steelblue3  " : @"#4f94cd"},
      @{@"steelblue4  " : @"#36648b"},
      @{@"deepskyblue1   " : @"#00bfff"},
      @{@"deepskyblue2   " : @"#00b2ee"},
      @{@"deepskyblue3   " : @"#009acd"},
      @{@"deepskyblue4   " : @"#00688b"},
      @{@"skyblue1   " : @"#87ceff"},
      @{@"skyblue2   " : @"#7ec0ee"},
      @{@"skyblue3   " : @"#6ca6cd"},
      @{@"skyblue4  " : @"#4a708b"},
      @{@"lightskyblue1   " : @"#b0e2ff"},
      @{@"lightskyblue2   " : @"#a4d3ee"},
      @{@"lightskyblue3   " : @"#8db6cd"},
      @{@"lightskyblue4  " : @"#607b8b"},
      @{@"slategray1   " : @"#c6e2ff"},
      @{@"slategray2   " : @"#b9d3ee"},
      @{@"slategray3   " : @"#9fb6cd"},
      @{@"slategray4   " : @"#6c7b8b"},
      @{@"lightsteelblue1   " : @"#cae1ff"},
      @{@"lightsteelblue2   " : @"#bcd2ee"},
      @{@"lightsteelblue3   " : @"#a2b5cd"},
      @{@"lightsteelblue4   " : @"#6e7b8b"},
      @{@"lightblue1   " : @"#bfefff"},
      @{@"lightblue2   " : @"#b2dfee"},
      @{@"lightblue3   " : @"#9ac0cd"},
      @{@"lightblue4   " : @"#68838b"},
      @{@"lightcyan1   " : @"#e0ffff"},
      @{@"lightcyan2   " : @"#d1eeee"},
      @{@"lightcyan3   " : @"#b4cdcd"},
      @{@"lightcyan4   " : @"#7a8b8b"},
      @{@"paleturquoise1   " : @"#bbffff"},
      @{@"paleturquoise2   " : @"#aeeeee"},
      @{@"paleturquoise3   " : @"#96cdcd"},
      @{@"paleturquoise4   " : @"#668b8b"},
      @{@"cadetblue1   " : @"#98f5ff"},
      @{@"cadetblue2   " : @"#8ee5ee"},
      @{@"cadetblue3   " : @"#7ac5cd"},
      @{@"cadetblue4  " : @"#53868b"},
      @{@"turquoise1   " : @"#00f5ff"},
      @{@"turquoise2   " : @"#00e5ee"},
      @{@"turquoise3   " : @"#00c5cd"},
      @{@"turquoise4   " : @"#00868b"},
      @{@"cyan1   " : @"#00ffff"},
      @{@"cyan2   " : @"#00eeee"},
      @{@"cyan3   " : @"#00cdcd"},
      @{@"cyan4   " : @"#008b8b"},
      @{@"darkslategray1   " : @"#97ffff"},
      @{@"darkslategray2   " : @"#8deeee"},
      @{@"darkslategray3   " : @"#79cdcd"},
      @{@"darkslategray4  " : @"#528b8b"},
      @{@"aquamarine1   " : @"#7fffd4"},
      @{@"aquamarine2   " : @"#76eec6"},
      @{@"aquamarine3   " : @"#66cdaa"},
      @{@"aquamarine4  " : @"#458b74"},
      @{@"darkseagreen1   " : @"#c1ffc1"},
      @{@"darkseagreen2   " : @"#b4eeb4"},
      @{@"darkseagreen3   " : @"#9bcd9b"},
      @{@"darkseagreen4   " : @"#698b69"},
      @{@"seagreen1  " : @"#54ff9f"},
      @{@"seagreen2  " : @"#4eee94"},
      @{@"seagreen3  " : @"#43cd80"},
      @{@"seagreen4 " : @"#2e8b57"},
      @{@"palegreen1   " : @"#9aff9a"},
      @{@"palegreen2   " : @"#90ee90"},
      @{@"palegreen3   " : @"#7ccd7c"},
      @{@"palegreen4 " : @"#548b54"},
      @{@"springgreen1 " : @"#00ff7f"},
      @{@"springgreen2   " : @"#00ee76"},
      @{@"springgreen3   " : @"#00cd66"},
      @{@"springgreen4  " : @"#008b45"},
      @{@"green1 " : @"#00ff00"},
      @{@"green2 " : @"#00ee00"},
      @{@"green3 " : @"#00cd00"},
      @{@"green4 " : @"#008b00"},
      @{@"chartreuse1   " : @"#7fff00"},
      @{@"chartreuse2   " : @"#76ee00"},
      @{@"chartreuse3   " : @"#66cd00"},
      @{@"chartreuse4  " : @"#458b00"},
      @{@"olivedrab1  " : @"#c0ff3e"},
      @{@"olivedrab2  " : @"#b3ee3a"},
      @{@"olivedrab3  " : @"#9acd32"},
      @{@"olivedrab4  " : @"#698b22"},
      @{@"darkolivegreen1   " : @"#caff70"},
      @{@"darkolivegreen2   " : @"#bcee68"},
      @{@"darkolivegreen3  " : @"#a2cd5a"},
      @{@"darkolivegreen4  " : @"#6e8b3d"},
      @{@"khaki1   " : @"#fff68f"},
      @{@"khaki2   " : @"#eee685"},
      @{@"khaki3   " : @"#cdc673"},
      @{@"khaki4  " : @"#8b864e"},
      @{@"lightgoldenrod1   " : @"#ffec8b"},
      @{@"lightgoldenrod2   " : @"#eedc82"},
      @{@"lightgoldenrod3   " : @"#cdbe70"},
      @{@"lightgoldenrod4  " : @"#8b814c"},
      @{@"lightyellow1   " : @"#ffffe0"},
      @{@"lightyellow2   " : @"#eeeed1"},
      @{@"lightyellow3   " : @"#cdcdb4"},
      @{@"lightyellow4   " : @"#8b8b7a"},
      @{@"yellow1   " : @"#ffff00"},
      @{@"yellow2   " : @"#eeee00"},
      @{@"yellow3   " : @"#cdcd00"},
      @{@"yellow4   " : @"#8b8b00"},
      @{@"gold1   " : @"#ffd700"},
      @{@"gold2   " : @"#eec900"},
      @{@"gold3   " : @"#cdad00"},
      @{@"gold4   " : @"#8b7500"},
      @{@"goldenrod1  " : @"#ffc125"},
      @{@"goldenrod2  " : @"#eeb422"},
      @{@"goldenrod3  " : @"#cd9b1d"},
      @{@"goldenrod4  " : @"#8b6914"},
      @{@"darkgoldenrod1  " : @"#ffb90f"},
      @{@"darkgoldenrod2  " : @"#eead0e"},
      @{@"darkgoldenrod3  " : @"#cd950c"},
      @{@"darkgoldenrod4 " : @"#8b658b"},
      @{@"rosybrown1   " : @"#ffc1c1"},
      @{@"rosybrown2   " : @"#eeb4b4"},
      @{@"rosybrown3   " : @"#cd9b9b"},
      @{@"rosybrown4   " : @"#8b6969"},
      @{@"indianred1   " : @"#ff6a6a"},
      @{@"indianred2" : @"# ee6363"},
      @{@"indianred3" : @"# cd5555"},
      @{@"indianred4" : @"# 8b3a3a"},
      @{@"sienna1  " : @"#ff8247"},
      @{@"sienna2  " : @"#ee7942"},
      @{@"sienna3  " : @"#cd6839"},
      @{@"sienna4 " : @"#8b4726"},
      @{@"burlywood1   " : @"#ffd39b"},
      @{@"burlywood2   " : @"#eec591"},
      @{@"burlywood3   " : @"#cdaa7d"},
      @{@"burlywood4  " : @"#8b7355"},
      @{@"wheat1   " : @"#ffe7ba"},
      @{@"wheat2   " : @"#eed8ae"},
      @{@"wheat3   " : @"#cdba96"},
      @{@"wheat4   " : @"#8b7e66"},
      @{@"tan1  " : @"#ffa54f"},
      @{@"tan2  " : @"#ee9a49"},
      @{@"tan3  " : @"#cd853f"},
      @{@"tan4 " : @"#8b5a2b"},
      @{@"chocolate1  " : @"#ff7f24"},
      @{@"chocolate2  " : @"#ee7621"},
      @{@"chocolate3  " : @"#cd661d"},
      @{@"chocolate4 " : @"#8b4513"},
      @{@"firebrick1 " : @"#ff3030"},
      @{@"firebrick2 " : @"#ee2c2c"},
      @{@"firebrick3 " : @"#cd2626"},
      @{@"firebrick4 " : @"#8b1a1a"},
      @{@"brown1 " : @"#ff4040"},
      @{@"brown2 " : @"#ee3b3b"},
      @{@"brown3 " : @"#cd3333"},
      @{@"brown4 " : @"#8b2323"},
      @{@"salmon1   " : @"#ff8c69"},
      @{@"salmon2  " : @"#ee8262"},
      @{@"salmon3  " : @"#cd7054"},
      @{@"salmon4 " : @"#8b4c39"},
      @{@"lightsalmon1   " : @"#ffa07a"},
      @{@"lightsalmon2   " : @"#ee9572"},
      @{@"lightsalmon3  " : @"#cd8162"},
      @{@"lightsalmon4 " : @"#8b5742"},
      @{@"orange1   " : @"#ffa500"},
      @{@"orange2   " : @"#ee9a00"},
      @{@"orange3   " : @"#cd8500"},
      @{@"orange4  " : @"#8b5a00"},
      @{@"darkorange1 " : @"#ff7f00"},
      @{@"darkorange2 " : @"#ee7600"},
      @{@"darkorange3 " : @"#cd6600"},
      @{@"darkorange4  " : @"#8b4500"},
      @{@"coral1  " : @"#ff7256"},
      @{@"coral2  " : @"#ee6a50"},
      @{@"coral3 " : @"#cd5b45"},
      @{@"coral4 " : @"#8b3e2f"},
      @{@"tomato1 " : @"#ff6347"},
      @{@"tomato2 " : @"#ee5c42"},
      @{@"tomato3 " : @"#cd4f39"},
      @{@"tomato4 " : @"#8b3626"},
      @{@"orangered1  " : @"#ff4500"},
      @{@"orangered2  " : @"#ee4000"},
      @{@"orangered3  " : @"#cd3700"},
      @{@"orangered4  " : @"#8b2500"},
      @{@"red1 " : @"#ff0000"},
      @{@"red2 " : @"#ee0000"},
      @{@"red3 " : @"#cd0000"},
      @{@"red4 " : @"#8b0000"},
      @{@"deeppink1  " : @"#ff1493"},
      @{@"deeppink2  " : @"#ee1289"},
      @{@"deeppink3  " : @"#cd1076"},
      @{@"deeppink4 " : @"#8b0a50"},
      @{@"hotpink1   " : @"#ff6eb4"},
      @{@"hotpink2   " : @"#ee6aa7"},
      @{@"hotpink3  " : @"#cd6090"},
      @{@"hotpink4 " : @"#8b3a62"},
      @{@"pink1   " : @"#ffb5c5"},
      @{@"pink2   " : @"#eea9b8"},
      @{@"pink3   " : @"#cd919e"},
      @{@"pink4  " : @"#8b636c"},
      @{@"lightpink1   " : @"#ffaeb9"},
      @{@"lightpink2   " : @"#eea2ad"},
      @{@"lightpink3   " : @"#cd8c95"},
      @{@"lightpink4  " : @"#8b5f65"},
      @{@"palevioletred1   " : @"#ff82ab"},
      @{@"palevioletred2   " : @"#ee799f"},
      @{@"palevioletred3   " : @"#cd6889"},
      @{@"palevioletred4 " : @"#8b475d"},
      @{@"maroon1  " : @"#ff34b3"},
      @{@"maroon2  " : @"#ee30a7"},
      @{@"maroon3  " : @"#cd2990"},
      @{@"maroon4 " : @"#8b1c62"},
      @{@"violetred1  " : @"#ff3e96"},
      @{@"violetred2  " : @"#ee3a8c"},
      @{@"violetred3  " : @"#cd3278"},
      @{@"violetred4 " : @"#8b2252"},
      @{@"magenta1 " : @"#ff00ff"},
      @{@"magenta2   " : @"#ee00ee"},
      @{@"magenta3   " : @"#cd00cd"},
      @{@"magenta4   " : @"#8b008b"},
      @{@"orchid1   " : @"#ff83fa"},
      @{@"orchid2   " : @"#ee7ae9"},
      @{@"orchid3   " : @"#cd69c9"},
      @{@"orchid4  " : @"#8b4789"},
      @{@"plum1   " : @"#ffbbff"},
      @{@"plum2   " : @"#eeaeee"},
      @{@"plum3   " : @"#cd96cd"},
      @{@"plum4   " : @"#8b668b"},
      @{@"mediumorchid1   " : @"#e066ff"},
      @{@"mediumorchid2  " : @"#d15fee"},
      @{@"mediumorchid3  " : @"#b452cd"},
      @{@"mediumorchid4  " : @"#7a378b"},
      @{@"darkorchid1  " : @"#bf3eff"},
      @{@"darkorchid2  " : @"#b23aee"},
      @{@"darkorchid3  " : @"#9a32cd"},
      @{@"darkorchid4  " : @"#68228b"},
      @{@"mediumpurple1   " : @"#ab82ff"},
      @{@"mediumpurple2   " : @"#9f79ee"},
      @{@"mediumpurple3   " : @"#8968cd"},
      @{@"mediumpurple4   " : @"#5d478b"},
      @{@"thistle1   " : @"#ffe1ff"},
      @{@"thistle2   " : @"#eed2ee"},
      @{@"thistle3   " : @"#cdb5cd"},
      @{@"thistle4   " : @"#8b7b8b"},
      @{@"grey11  " : @"#1c1c1c"},
      @{@"grey21  " : @"#363636"},
      @{@"grey31  " : @"#4f4f4f"},
      @{@"grey41   " : @"#696969"},
      @{@"grey51   " : @"#828282"},
      @{@"grey61   " : @"#9c9c9c"},
      @{@"grey71   " : @"#b5b5b5"},
      @{@"gray81   " : @"#cfcfcf"},
      @{@"gray91   " : @"#e8e8e8"},
      @{@"darkgrey   " : @"#a9a9a9"},
      @{@"darkblue  " : @"#00008b"},
      @{@"darkcyan   " : @"#008b8b"},
      @{@"darkmagenta   " : @"#8b008b"},
      @{@"darkred  " : @"#8b0000"},
      @{@"lightgreen   " : @"#90ee90"},
      @{@"purple1  " : @"#9b30ff"},
      @{@"purple2  " : @"#912cee"},
      @{@"purple3  " : @"#7d26cd"},
      @{@"purple4 " : @"#551a8b"}
      
      ];
    
    
}





@end








