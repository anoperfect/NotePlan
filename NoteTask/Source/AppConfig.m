//
//  AppConfig.m
//  NoteTask
//
//  Created by Ben on 16/8/2.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "AppConfig.h"
#import "NoteModel.h"







#define DBNAME_CONFIG               @"config"
#define TABLENAME_CLASSIFICATION    @"classification"
#define TABLENAME_NOTE              @"note"


@interface AppConfig ()

//具体的数据库操作尽量通过DBData.
@property (nonatomic, strong) DBData *dbData;


@end



@implementation AppConfig




+ (AppConfig*)sharedAppConfig
{
    static dispatch_once_t once;
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}


- (id)init {
    if (self = [super init]) {
        
        self.dbData = [[DBData alloc] init];
        
        [self testBeforeBuild];

        //建立或者升级数据库.
        [self configDBBuild];
        
        //数据库输入初始数据.
        [self configDBInitData];
        
        //测试.
        [self testAfterBuild];
    }
    
    return self;
}


- (void)configDBBuild
{
    NSString *resPath= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"db.json"];
    
    NSData *data = [NSData dataWithContentsOfFile:resPath];
    NS0Log(@"------\n%@\n-------", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    if(data) {
        [self.dbData buildByJsonData:data];
    }
    else {
        NSLog(@"#error - resPath content NULL.");
    }
}


- (void)configDBInitData
{
    
    
}








- (NSArray<NSString*> *)configClassificationGets
{
    NSDictionary *queryResult = [self.dbData DBDataQueryDBName:DBNAME_CONFIG
                                                       toTable:TABLENAME_CLASSIFICATION
                                                   columnNames:nil
                                                     withQuery:nil
                                                     withLimit:nil];
    NSInteger count = [self.dbData DBDataCheckRowsInDictionary:queryResult];
    if(count > 0) {
        NSArray *classificationNameArray                    = queryResult[@"classificationName"];
        if([self.dbData DBDataCheckCountOfArray:@[classificationNameArray] withCount:count]) {
            return classificationNameArray;
        }
    }
    
    return nil;
}


- (void)configClassificationAdd:(NSString*)classification
{
    BOOL result = YES;
    
    //#如果更新的话, 则click会刷新到0.
    NSDictionary *infoInsert = @{
                                 DBDATA_STRING_COLUMNS:@[@"classificationName"],
                                 DBDATA_STRING_VALUES:@[@[classification]]
                                 };
    NSInteger retDBData = [self.dbData DBDataInsertDBName:DBNAME_CONFIG toTable:TABLENAME_CLASSIFICATION withInfo:infoInsert orReplace:YES];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
    }
    
    return ;
}


- (void)configClassificationRemove:(NSString*)classification
{
    BOOL result = YES;
    
    NSInteger retDBData = [self.dbData DBDataDeleteDBName:DBNAME_CONFIG toTable:TABLENAME_CLASSIFICATION withQuery:@{@"classificationName":classification}];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
    }
    
    return ;
}




- (NSArray<NoteModel*> *)configNoteGets
{
    NSMutableArray<NoteModel*> *arrayReturnM = [[NSMutableArray alloc] init];
    
    //默认降序.
    NSDictionary *queryResult = [self.dbData DBDataQueryDBName:DBNAME_CONFIG
                                                       toTable:TABLENAME_NOTE
                                                   columnNames:nil
                                                     withQuery:nil
                                                     withLimit:@{DBDATA_STRING_ORDER:@"ORDER BY identifier DESC"}];
    NSArray<NSDictionary* >* dicts = [self.dbData queryResultDictionaryToArray:queryResult];
    if(dicts.count > 0) {
        for(NSDictionary *dict in dicts) {
            NoteModel *note = [NoteModel noteFromDictionary:dict];;
            if(note) {
                [arrayReturnM addObject:note];
            }
        }
    }
    NSLog(@"All note number : %zd", dicts.count);
    
    return [NSArray arrayWithArray:arrayReturnM];
}


/*
 colorString :
 red
 yellow
 blue
 - 有任意标记
 * 所有
 ""无标记
 */
- (NSArray<NoteModel*> *)configNoteGetsByClassification:(NSString*)classification andColorString:(NSString*)colorString
{
    NSLog(@"configNoteGetsByClassification : %@, color : %@", classification, colorString);
    
    NSMutableArray<NoteModel*> *arrayReturnM = [[NSMutableArray alloc] init];
    
    NSMutableString *sqlString = [NSMutableString stringWithString:@"SELECT * FROM note "];
    NSMutableString *queryString = [[NSMutableString alloc] init];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    if(classification.length > 0) {
        [queryString appendFormat:@"WHERE classification = ? "];
        [arguments addObject:classification];
    }
    
    if([colorString isEqualToString:@"*"]) {
        
    }
    else if([colorString isEqualToString:@"-"]) {
        if(queryString.length > 0) {
            [queryString appendString:@" AND "];
        }
        else {
            [queryString appendString:@" WHERE "];
        }
        
        [queryString appendString:@"LENGTH(color) > 0"];
    }
    else if([colorString isEqualToString:@""]) {
        if(queryString.length > 0) {
            [queryString appendString:@" AND "];
        }
        else {
            [queryString appendString:@" WHERE "];
        }
        
        [queryString appendString:@"color = ''"];
    }
    else if([[NoteModel colorStrings] indexOfObject:colorString] != NSNotFound) {
        if(queryString.length > 0) {
            [queryString appendString:@" AND "];
        }
        else {
            [queryString appendString:@" WHERE "];
        }
        
        [queryString appendString:@"color = ?"];
        [arguments addObject:colorString];
    }
    
#if 0
    
    
    if(classification.length == 0 && colorString.length == 0) {
        //全部. 无约束.
    }
    else if(classification.length > 0 && colorString.length == 0) {
        //栏目约束.
        query = [[NSMutableDictionary alloc] init];
        query[@"classification"] = classification;
    }
    else if(classification.length == 0 && colorString.length > 0) {
        //颜色标记约束.
        query = [[NSMutableDictionary alloc] init];
        query[@"color"] = colorString;
    }
    else {
        //栏目和颜色标记同时约束.
        query = [[NSMutableDictionary alloc] init];
        query[@"classification"] = classification;
        query[@"color"] = colorString;
    }
    
    NSDictionary *queryResult = [self.dbData DBDataQueryDBName:DBNAME_CONFIG
                                                       toTable:TABLENAME_NOTE
                                                   columnNames:nil
                                                     withQuery:query
                                                     withLimit:@{DBDATA_STRING_ORDER:@"ORDER BY identifier DESC"}];
#endif
    
    if(queryString.length > 0) {
        [sqlString appendString:queryString];
    }
    
    [sqlString appendString:@" ORDER BY identifier DESC"];
    
    NSDictionary *queryResult = [self.dbData DBDataQueryDBName:DBNAME_CONFIG
                                                 withSqlString:sqlString
                                           andArgumentsInArray:arguments];
    
    NSArray<NSDictionary* >* dicts = [self.dbData queryResultDictionaryToArray:queryResult];
    if(dicts.count > 0) {
        for(NSDictionary *dict in dicts) {
            NoteModel *note = [NoteModel noteFromDictionary:dict];;
            if(note) {
                [arrayReturnM addObject:note];
            }
        }
    }
    NSLog(@"query result array count : %zd", dicts.count);
    
    return [NSArray arrayWithArray:arrayReturnM];
}


- (NoteModel*)configNoteGetByNoteIdentifier:(NSInteger)noteIdentifier
{
    NoteModel *noteResult = nil;
    NSDictionary *query = @{@"identifier" : @(noteIdentifier)};
    NSDictionary *queryResult = [self.dbData DBDataQueryDBName:DBNAME_CONFIG
                                                       toTable:TABLENAME_NOTE
                                                   columnNames:nil
                                                     withQuery:query
                                                     withLimit:nil];
    NSArray<NSDictionary* >* dicts = [self.dbData queryResultDictionaryToArray:queryResult];
    if(dicts.count > 0) {
        NSDictionary *dict = dicts[0];
        NoteModel *note = [NoteModel noteFromDictionary:dict];;
        if(note) {
            noteResult = note;
        }
    }
    
    return noteResult;
}


- (NoteModel*)configNoteGetByNewest
{
    NoteModel *noteResult = nil;
    NSDictionary *queryResult = [self.dbData DBDataQueryDBName:DBNAME_CONFIG
                                                 withSqlString:@"SELECT MAX(identifier),* FROM note;"
                                           andArgumentsInArray:nil];
    NSArray<NSDictionary* >* dicts = [self.dbData queryResultDictionaryToArray:queryResult];
    if(dicts.count > 0) {
        NSDictionary *dict = dicts[0];
        NoteModel *note = [NoteModel noteFromDictionary:dict];;
        if(note) {
            noteResult = note;
        }
    }
    
    return noteResult;
}


//返回新增note的identifier.
- (NSInteger)configNoteAdd:(NoteModel*)note
{
    NSInteger noteIdentifier = NSNotFound;
    NSDictionary *infoInsert = @{
                                 DBDATA_STRING_COLUMNS:
                                        @[
                                         @"title",
                                         @"content",
                                         @"summary",
                                         @"classification",
                                         @"color",
                                         @"thumb",
                                         @"audio",
                                         @"location",
                                         @"createdAt",
                                         @"modifiedAt",
                                         @"source",
                                         @"synchronize",
                                         @"countCollect",
                                         @"countLike",
                                         @"countDislike",
                                         @"countBrowser",
                                         @"countEdit"
                                        ],
                                 DBDATA_STRING_VALUES:
                                    @[
                                        @[
                                         note.title,
                                         note.content,
                                         note.summary,
                                         note.classification,
                                         note.color,
                                         note.thumb,
                                         note.audio,
                                         note.location,
                                         note.createdAt,
                                         note.modifiedAt,
                                         note.source,
                                         note.synchronize,
                                         @(note.countCollect),
                                         @(note.countLike),
                                         @(note.countDislike),
                                         @(note.countBrowser),
                                         @(note.countEdit)
                                        ]
                                    ]
                                 };
    
    NSInteger retDBData = [self.dbData DBDataInsertDBName:DBNAME_CONFIG toTable:TABLENAME_NOTE withInfo:infoInsert];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
    }
    else {
        NoteModel *noteNewest = [self configNoteGetByNewest];
        if(noteNewest && noteNewest.identifier > 0) {
            if([noteNewest isEqualToNoteModel:note]) {
                noteIdentifier = noteNewest.identifier;
            }
            else {
                NSLog(@"#error - configNoteGetByNewest not equal to stored.");
            }
        }
        else {
            NSLog(@"#error - configNoteGetByNewest");
            
        }
    }
    
    return noteIdentifier;
}


- (void)configNoteRemoveById:(NSInteger)noteIdentifier
{
    BOOL result = YES;
    
    NSInteger retDBData = [self.dbData DBDataDeleteDBName:DBNAME_CONFIG toTable:TABLENAME_NOTE withQuery:@{@"identifier":@(noteIdentifier)}];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
    }
    
    //return result;
    
    
}


- (void)configNoteUpdate:(NoteModel*)note
{
    NSMutableDictionary *updateDict = [[NSMutableDictionary alloc] init];
    updateDict[@"title"]            = note.title;
    updateDict[@"content"]          = note.content;
    updateDict[@"summary"]          = note.summary;
    updateDict[@"classification"]   = note.classification;
    updateDict[@"color"]            = note.color;
    updateDict[@"thumb"]            = note.thumb;
    updateDict[@"audio"]            = note.audio;
    updateDict[@"location"]         = note.location;
    updateDict[@"createdAt"]        = note.createdAt;
    updateDict[@"modifiedAt"]       = note.modifiedAt;
    updateDict[@"source"]           = note.source;
    updateDict[@"synchronize"]      = note.synchronize;
    updateDict[@"countCollect"]     = @(note.countCollect);
    updateDict[@"countLike"]        = @(note.countLike);
    updateDict[@"countDislike"]     = @(note.countDislike);
    updateDict[@"countBrowser"]     = @(note.countBrowser);
    updateDict[@"countEdit"]        = @(note.countEdit);
    
    [self.dbData DBDataUpdateDBName:DBNAME_CONFIG
                            toTable:TABLENAME_NOTE
                     withInfoUpdate:[NSDictionary dictionaryWithDictionary:updateDict]
                      withInfoQuery:@{@"identifier":@(note.identifier)}];
}


- (void)configNoteUpdateBynoteIdentifier:(NSInteger)noteIdentifier classification:(NSString*)classification
{
    NSMutableDictionary *updateDict = [[NSMutableDictionary alloc] init];
    updateDict[@"classification"]   = classification;
    
    [self.dbData DBDataUpdateDBName:DBNAME_CONFIG
                            toTable:TABLENAME_NOTE
                     withInfoUpdate:[NSDictionary dictionaryWithDictionary:updateDict]
                      withInfoQuery:@{@"identifier":@(noteIdentifier)}];
}


- (void)configNoteUpdateBynoteIdentifier:(NSInteger)noteIdentifier colorString:(NSString*)colorString
{
    NSMutableDictionary *updateDict = [[NSMutableDictionary alloc] init];
    updateDict[@"color"]            = colorString;
    
    [self.dbData DBDataUpdateDBName:DBNAME_CONFIG
                            toTable:TABLENAME_NOTE
                     withInfoUpdate:[NSDictionary dictionaryWithDictionary:updateDict]
                      withInfoQuery:@{@"identifier":@(noteIdentifier)}];
}


- (void)testBeforeBuild
{
    [self.dbData removeDBName:@"config"];
}


- (void)testAfterBuild
{
    NoteModel *note = [[NoteModel alloc] init];
    note.title = @"<p style=\"FONT-SIZE: 15pt; COLOR: #ffffff; FONT-FAMILY: 黑体\">使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1</p>";
    note.content = @"<p style=\"\">第一段说明1</p> <p style=\"\">另一段说明1</p>";
    note.summary = @"";
    note.classification = @"个人笔记";
    note.color = @"";
    note.thumb = @"";
    note.audio = @"",
    note.location = @"CHINA";
    note.createdAt = @"2016-08-02 01:23:45";
    note.modifiedAt = @"2016-08-08 01:23:45";
    note.source = @"";
    note.synchronize = @"";
    note.countCollect = 0;
    note.countLike = 0;
    note.countDislike = 0;
    note.countBrowser = 0;
    note.countEdit = 0;
    [self configNoteAdd:note];
    
    note.title = @"<p style=\"color:blue; text-align:center\">color - red    使用说明1 red使用说明2使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1</p>";
    note.content = @"<p style=\"\">第一段说明2</p> <p style=\"\">另一段说明2</p>";
    note.color = @"red";
    [self configNoteAdd:note];
    
    note.title = @"<p style=\"color:blue; text-align:center\">color - yellow. 使用说明1 yellow使用说明2使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1</p>";
    note.content = @"<p style=\"\">第一段说明2</p> <p style=\"\">另一段说明2</p>";
    note.color = @"yellow";
    [self configNoteAdd:note];
    
    note.title = @"<p style=\"color:blue; text-align:center\">color - blue 使用说明1 blue使用说明2使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1</p>";
    note.content = @"<p style=\"\">第一段说明2</p> <p style=\"\">另一段说明2</p>";
    note.color = @"blue";
    [self configNoteAdd:note];
    
    note.title = @"<p style=\"color:blue; text-align:center\">color blue, classfication - 新增 使用说明1 blue使用说明2使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1</p>";
    note.content = @"<p style=\"\">第一段说明2</p> <p style=\"\">另一段说明2</p>";
    note.color = @"blue";
    note.classification = @"新增";
    [self configNoteAdd:note];
    
    note.title = @"<p style=\"color:blue; text-align:center\">classfication - 新增 使用说明1使用说明2使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1</p>";
    note.content = @"<p style=\"color:blue;FONT-SIZE: 10pt;\">第一段说明2</p> <p style=\"\">另一段说明2</p>";
    note.color = @"";
    note.classification = @"新增";
    [self configNoteAdd:note];
    
    
    
    
    
    
    
}





@end
