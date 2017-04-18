//
//  AppConfig.m
//  NoteTask
//
//  Created by Ben on 16/8/2.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "AppConfig.h"








#define DBNAME_CONFIG               @"config"

#define TABLENAME_CLASSIFICATION    @"NoteClassification"
#define TABLENAME_NOTE              @"NoteModel"
#define TABLENAME_TASKINFO          @"TaskInfo"
#define TABLENAME_TASKRECORD        @"TaskRecord"
#define TABLENAME_TASKFINISHAT      @"TaskFinishAt"
#define TABLENAME_SETTING           @"SettingKV"


@interface AppConfig ()

//具体的数据库操作尽量通过DBData.
@property (nonatomic, strong) DBData *dbData;

@property (nonatomic, strong) AFHTTPSessionManager *session;

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
        //[self.dbData DBDataAddTableAttributeByJsonData:data];
    }
    else {
        NSLog(@"#error - resPath content NULL.");
    }
    
    TableObjectProperty *tableObjectProperty ;
    
    tableObjectProperty = [TableObjectProperty tableObjectPropertyByName:@"NoteModel" primaryKeys:@[@"sn"] dbNames:@[@"config"] comment:@"笔记"];
    [self.dbData DBDataAddTableAttributeFromTableObjectProperty:tableObjectProperty];
    
    tableObjectProperty = [TableObjectProperty tableObjectPropertyByName:@"NoteClassification" primaryKeys:@[@"classificationName"] dbNames:@[@"config"] comment:@"笔记类别"];
    [self.dbData DBDataAddTableAttributeFromTableObjectProperty:tableObjectProperty];
    
    tableObjectProperty = [TableObjectProperty tableObjectPropertyByName:@"TaskInfo" primaryKeys:@[@"sn"] dbNames:@[@"config"] comment:@"任务"];
    [self.dbData DBDataAddTableAttributeFromTableObjectProperty:tableObjectProperty];
    
    tableObjectProperty = [TableObjectProperty tableObjectPropertyByName:@"TaskRecord" primaryKeys:@[@"snTaskRecord"] dbNames:@[@"config"] comment:@"任务记录"];
    [self.dbData DBDataAddTableAttributeFromTableObjectProperty:tableObjectProperty];
    
    tableObjectProperty = [TableObjectProperty tableObjectPropertyByName:@"TaskFinishAt" primaryKeys:@[@"snTaskInfo", @"dayString"] dbNames:@[@"config"] comment:@"任务完成情况"];
    [self.dbData DBDataAddTableAttributeFromTableObjectProperty:tableObjectProperty];
    
    tableObjectProperty = [TableObjectProperty tableObjectPropertyByName:@"SettingKV" primaryKeys:@[@"key"] dbNames:@[@"config"] comment:@"设置"];
    [self.dbData DBDataAddTableAttributeFromTableObjectProperty:tableObjectProperty];
    
    [self.dbData buildTable];
}


- (void)configDBInitData
{
    
    
}


#pragma mark - Classification

- (NSArray<NSString*> *)configClassificationGets
{
    NSDictionary *queryResult = [self.dbData DBDataQueryDBName:DBNAME_CONFIG
                                                         table:TABLENAME_CLASSIFICATION
                                                   columnNames:nil
                                                         query:nil
                                                         limit:nil];
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
    
    NoteClassification *noteClassification = [[NoteClassification alloc] init];
    noteClassification.classificationName = classification;
    noteClassification.createdAt = [NSString dateTimeStringNow];
    
    //#如果更新的话, 则click会刷新到0.
    NSDictionary *infoInsert = @{
                                 DBDATA_STRING_COLUMNS:@[@"classificationName", @"createdAt"],
                                 DBDATA_STRING_VALUES:@[@[noteClassification.classificationName,noteClassification.createdAt]]
                                 };
    NSInteger retDBData = [self.dbData DBDataInsertDBName:DBNAME_CONFIG   table:TABLENAME_CLASSIFICATION     info:infoInsert orReplace:YES];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
    }
    
    return ;
}


- (void)configClassificationRemove:(NSString*)classification
{
    BOOL result = YES;
    
    NSInteger retDBData = [self.dbData DBDataDeleteDBName:DBNAME_CONFIG   table:TABLENAME_CLASSIFICATION     query:@{@"classificationName":classification}];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
    }
    
    return ;
}



#pragma mark - Note
- (NSArray<NoteModel*> *)configNoteGetsWithQuery:(NSDictionary*)query
{
    NSMutableArray<NoteModel*> *arrayReturnM = [[NSMutableArray alloc] init];
    
    //默认降序.
    NSDictionary *queryResult = [self.dbData DBDataQueryDBName:DBNAME_CONFIG
                                                         table:TABLENAME_NOTE
                                                   columnNames:nil
                                                         query:query
                                                         limit:@{DBDATA_STRING_ORDER:@"ORDER BY modifiedAt DESC"}];
    NSArray<NSDictionary* >* dicts = [self.dbData queryResultDictionaryToArray:queryResult];
    if(dicts.count > 0) {
        for(NSDictionary *dict in dicts) {
            NoteModel *note = [NoteModel noteFromDictionary:dict];
            NSLog(@"---%@ : %@", note.sn, note.deletedAt);
            if(note && note.deletedAt.length == 0) {
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
 查找所有则classification填*, colorString填*.
 */
- (NSArray<NoteModel*> *)configNoteGetsByClassification:(NSString*)classification colorString:(NSString*)colorString
{
    NSLog(@"configNoteGetsByClassification : [%@], color : [%@]", classification, colorString);
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    
    if(classification.length > 0 && ![classification isEqualToString:@"*"]) {
        query[@"classification"] = classification;
    }
    
    if([colorString isEqualToString:@"*"]) {
        
    }
    else if([colorString isEqualToString:@"-"]) {
        query[@"color"] = [NoteModel colorStrings];
    }
    else if([colorString isEqualToString:@""]) {
        query[@"color"] = @"";
    }
    else if([[NoteModel colorStrings] indexOfObject:colorString] != NSNotFound) {
        query[@"color"] = colorString;
    }
    query[@"deletedAt"] = @"";
    
    return [self configNoteGetsWithQuery:[NSDictionary dictionaryWithDictionary:query]];
}


- (NSInteger)configNoteCountByClassification:(NSString*)classification colorString:(NSString*)colorString
{
    NSLog(@"configNoteCountByClassification : [%@], color : [%@]", classification, colorString);
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    
    if(classification.length > 0 && ![classification isEqualToString:@"*"]) {
        query[@"classification"] = classification;
    }
    
    if([colorString isEqualToString:@"*"]) {
        
    }
    else if([colorString isEqualToString:@"-"]) {
        query[@"color"] = [NoteModel colorStrings];
    }
    else if([colorString isEqualToString:@""]) {
        query[@"color"] = @"";
    }
    else if([[NoteModel colorStrings] indexOfObject:colorString] != NSNotFound) {
        query[@"color"] = colorString;
    }
    
    query[@"deletedAt"] = @"";
    
    return [self.dbData DBDataQueryCountDBName:DBNAME_CONFIG table:TABLENAME_NOTE query:query];
}


- (NoteModel*)configNoteGetBySn:(NSString*)sn
{
    NoteModel *noteResult = nil;
    NSDictionary *query = @{@"sn" : sn};
    NSDictionary *queryResult = [self.dbData DBDataQueryDBName:DBNAME_CONFIG
                                                         table:TABLENAME_NOTE
                                                   columnNames:nil
                                                         query:query
                                                         limit:nil];
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


- (BOOL)configNoteAdd:(NoteModel*)note
{
    if(note.sn.length == 0) {
        note.sn = [NSString randomStringWithLength:6 type:36];
    }
    
    BOOL result = YES;
    NSDictionary *infoInsert = @{
                                 DBDATA_STRING_COLUMNS:
                                        @[
                                         @"sn",
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
                                         @"browseredAt",
                                         @"deletedAt",
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
                                         note.sn,
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
                                         note.browseredAt,
                                         note.deletedAt,
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
    
    NSInteger retDBData = [self.dbData DBDataInsertDBName:DBNAME_CONFIG   table:TABLENAME_NOTE     info:infoInsert];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
    }
    else {

    }
    
    return result;
}


- (void)configNoteRemoveBySn:(NSString*)sn
{
    BOOL result = YES;
    
    NSInteger retDBData = [self.dbData DBDataDeleteDBName:DBNAME_CONFIG   table:TABLENAME_NOTE     query:@{@"sn":sn}];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
    }
    
    //return result;
}


//彻底清除.
- (void)configNoteRemoveBySns:(NSArray<NSString*>*)sns
{
    BOOL result = YES;
    
    NSInteger retDBData = [self.dbData DBDataDeleteDBName:DBNAME_CONFIG   table:TABLENAME_NOTE     query:@{@"sn":sns}];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
    }
    
    //return result;
}


//删除.可以到回收站清除或恢复.
- (void)configNoteDeleteBySns:(NSArray<NSString*>*)sns
{
    BOOL result = YES;
    
    NSInteger retDBData = [self.dbData DBDataUpdateDBName:DBNAME_CONFIG
                                                    table:TABLENAME_NOTE
                                               infoUpdate:@{@"deletedAt":[NSString dateTimeStringNow]}
                                                infoQuery:@{@"sn":sns}];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
    }
}


- (NSDictionary*)configNoteUpdateDetect:(NoteModel*)note fromSn:(NSString*)sn
{
    
#if F
   \[\@"[a-z]+"\][ ]+=
#endif
    
    NoteModel *notePrev = [self configNoteGetBySn:sn];
    NSMutableDictionary *noteDictPrev = [[NSMutableDictionary alloc] init];
    noteDictPrev = [NSMutableDictionary dictionaryWithDictionary:[notePrev toDictionary]];

    
    NSMutableDictionary *noteDict = [[NSMutableDictionary alloc] init];
    noteDict = [NSMutableDictionary dictionaryWithDictionary:[note toDictionary]];
    
    NSArray *keys = noteDict.allKeys;
    
    NSMutableDictionary *updateDict = [[NSMutableDictionary alloc] init];
    for(NSString *key in keys) {
        if([noteDict[key] isEqual:noteDictPrev[key]]) {
            
        }
        else {
            updateDict[key] = noteDict[key];
        }
    }
    
    if(updateDict.count > 0) {
        NSLog(@"//////note update : \n%@", [NSString stringLogFromDictionary:updateDict]);
        return [NSDictionary dictionaryWithDictionary:updateDict];
    }
    else {
        NSLog(@"//////note update none.");
        return nil;
    }
}


- (void)configNoteUpdate:(NoteModel*)note
{
    NSDictionary *updateDict = [self configNoteUpdateDetect:note fromSn:note.sn];
    if(updateDict.count > 0) {
        [self.dbData DBDataUpdateDBName:DBNAME_CONFIG
                                  table:TABLENAME_NOTE
                             infoUpdate:updateDict
                              infoQuery:@{@"sn":note.sn}];
    }
    else {
        NSLog(@"configNoteUpdate : nothing to update.");
    }
}


- (void)configNoteUpdate:(NoteModel*)note fromSn:(NSString*)sn
{
    NSDictionary *updateDict = [self configNoteUpdateDetect:note fromSn:sn];
    if(updateDict.count > 0) {
        [self.dbData DBDataUpdateDBName:DBNAME_CONFIG
                                  table:TABLENAME_NOTE
                             infoUpdate:updateDict
                              infoQuery:@{@"sn":sn}];
    }
    else {
        NSLog(@"configNoteUpdate : nothing to update.");
    }
}


- (void)configNotesUpdateClassification:(NSString*)classification bySns:(NSArray<NSString*>*)sns
{
    NSMutableDictionary *updateDict = [[NSMutableDictionary alloc] init];
    updateDict[@"classification"]   = classification;
    
    [self.dbData DBDataUpdateDBName:DBNAME_CONFIG
                              table:TABLENAME_NOTE
                         infoUpdate:[NSDictionary dictionaryWithDictionary:updateDict]
                          infoQuery:@{@"sn":sns}];
}


- (void)configNotesUpdateClassification:(NSString*)classification byPreviousClassification:(NSString*)previousClassification
{
    NSMutableDictionary *updateDict = [[NSMutableDictionary alloc] init];
    updateDict[@"classification"]   = classification;
    
    [self.dbData DBDataUpdateDBName:DBNAME_CONFIG
                              table:TABLENAME_NOTE
                         infoUpdate:[NSDictionary dictionaryWithDictionary:updateDict]
                          infoQuery:@{@"classification":previousClassification}];
}


- (void)configNotesUpdateColor:(NSString*)color bySns:(NSArray<NSString*>*)sns
{
    NSMutableDictionary *updateDict = [[NSMutableDictionary alloc] init];
    updateDict[@"color"]   = color;
    
    [self.dbData DBDataUpdateDBName:DBNAME_CONFIG
                              table:TABLENAME_NOTE
                         infoUpdate:[NSDictionary dictionaryWithDictionary:updateDict]
                          infoQuery:@{@"sn":sns}];
}







#pragma mark - Setting
#if 0

NoteFilterClassification
NoteFilterColor
NoteTitleFontSizeDefault
NoteParagraphFontSizeDefault
TaskModeDefault

#endif



- (NSString*)configSettingQuery:(NSString*)key
{
    NSString *value = nil;
    
    NSDictionary *queryResult = [self.dbData DBDataQueryDBName:DBNAME_CONFIG   table:TABLENAME_SETTING columnNames:@[@"value"]     query:@{@"key":key}     limit:nil];
    if([queryResult[@"value"] isKindOfClass:[NSArray class]] && ((NSArray*)(queryResult[@"value"])).count == 1 ) {
        value = ((NSArray*)(queryResult[@"value"]))[0];
    }
    
    return value;
}



- (NSString*)configSettingGet:(NSString*)key
{
    NSString *value = [self configSettingQuery:key];
    if(!value) {
        NSLog(@"#error - configSettingGet [%@] : [%@]", key, value);
    }
    else {
        NSLog(@"configSettingGet [%@] : [%@]", key, value);
    }
    
    return value;
}


- (void)configSettingSetKey:(NSString*)key toValue:(NSString*)value replace:(BOOL)replace
{
    //不强制替换时, 如果已经有kv值, 则不写入value.
    if(!replace) {
        NSString *valuePrevious = [self configSettingQuery:key];
        if(valuePrevious) {
            NSLog(@"configSettingSetKey not performed. key[%@] , previous[%@], set[%@]", key, valuePrevious, value);
            return ;
        }
    }
    
    //value为nil时, 表示删除该kv.
    if(!value) {
        [self.dbData DBDataDeleteDBName:DBNAME_CONFIG   table:TABLENAME_SETTING     query:@{@"key":key}];
        return ;
    }
    
    NSDictionary *infoInsert = @{
                                 DBDATA_STRING_COLUMNS:
                                     @[
                                         @"key",
                                         @"value"
                                         ],
                                 DBDATA_STRING_VALUES:
                                     @[
                                         @[
                                             key,
                                             value
                                             ]
                                         ]
                                 };

    [self.dbData DBDataInsertDBName:DBNAME_CONFIG   table:TABLENAME_SETTING     info:infoInsert orReplace:replace];
}

























#pragma mark - TaskInfo
- (NSArray<TaskInfo*>*)configTaskInfoGets
{
    NSMutableArray<TaskInfo*> *arrayReturnM = [[NSMutableArray alloc] init];
    
    //默认降序.
    NSDictionary *queryResult = [self.dbData DBDataQueryDBName:DBNAME_CONFIG
                                                         table:TABLENAME_TASKINFO
                                                   columnNames:nil
                                                         query:nil
                                                         limit:@{DBDATA_STRING_ORDER:@"ORDER BY modifiedAt DESC"}];
    NSArray<NSDictionary* >* dicts = [self.dbData queryResultDictionaryToArray:queryResult];
    if(dicts.count > 0) {
        for(NSDictionary *dict in dicts) {
            TaskInfo *taskinfo = [TaskInfo taskinfoFromDictionary:dict];
            if(taskinfo) {
                [arrayReturnM addObject:taskinfo];
            }
        }
    }
    NSLog(@"All task number : %zd", dicts.count);
    
    return [NSArray arrayWithArray:arrayReturnM];
}


- (BOOL)configTaskInfoAdd:(TaskInfo*)taskinfo
{
    BOOL result = YES;
    
    NSDictionary *dict = [taskinfo toDictionary];
    NSArray *columnStrings = dict.allKeys;
    NSMutableArray *columnValues = [[NSMutableArray alloc] init];
    for(NSString *columnString in columnStrings) {
        [columnValues addObject:dict[columnString]];
    }
    
    NSDictionary *infoInsert = @{
                                 DBDATA_STRING_COLUMNS:columnStrings,
                                 DBDATA_STRING_VALUES: @[[NSArray arrayWithArray:columnValues]]
                                 };
    
    NSInteger retDBData = [self.dbData DBDataInsertDBName:DBNAME_CONFIG   table:TABLENAME_TASKINFO     info:infoInsert];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
        return result;
    }
    
    //tasksub.
    
    
    return result;
}


- (void)configTaskInfoRemoveBySn:(NSArray<NSString*>*)sn
{
    BOOL result = YES;
    NSInteger retDBData = [self.dbData DBDataDeleteDBName:DBNAME_CONFIG   table:TABLENAME_TASKINFO     query:@{@"sn":sn}];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
    }
}


- (void)configTaskInfoUpdate:(TaskInfo*)taskinfo
{
    NSDictionary *updateDict = [taskinfo toDictionary];
    [self.dbData DBDataUpdateDBName:DBNAME_CONFIG   table:TABLENAME_TASKINFO     infoUpdate:updateDict     infoQuery:@{@"sn":taskinfo.sn}];
}


#pragma mark - TaskRecord
- (NSArray<TaskRecord*>*)configTaskRecordGets
{
    NSMutableArray<TaskRecord*> *arrayReturnM = [[NSMutableArray alloc] init];
    
    //默认降序.
    NSDictionary *queryResult = [self.dbData DBDataQueryDBName:DBNAME_CONFIG
                                                         table:TABLENAME_TASKRECORD
                                                   columnNames:nil
                                                         query:nil
                                                         limit:@{DBDATA_STRING_ORDER:@"ORDER BY modifiedAt DESC"}];
    NSArray<NSDictionary* >* dicts = [self.dbData queryResultDictionaryToArray:queryResult];
    if(dicts.count > 0) {
        for(NSDictionary *dict in dicts) {
            TaskRecord *taskRecord = [TaskRecord taskRecordFromDictionary:dict];
            if(taskRecord) {
                [arrayReturnM addObject:taskRecord];
            }
        }
    }
    
    return [NSArray arrayWithArray:arrayReturnM];
}


- (BOOL)configTaskRecordAdd:(TaskRecord*)taskRecord
{
    BOOL result = YES;
    
    NSDictionary *infoInsert = @{
                                 DBDATA_STRING_COLUMNS:
                                     @[
                                         @"snTaskRecord",
                                         @"snTaskInfo",
                                         @"dayString",
                                         @"type",
                                         @"record",
                                         @"committedAt",
                                         @"modifiedAt",
                                         @"deprecatedAt",
                                         ],
                                 DBDATA_STRING_VALUES:
                                     @[
                                         @[
                                             taskRecord.snTaskRecord,
                                             taskRecord.snTaskInfo,
                                             taskRecord.dayString,
                                             @(taskRecord.type),
                                             taskRecord.record,
                                             taskRecord.committedAt,
                                             taskRecord.modifiedAt,
                                             taskRecord.deprecatedAt,
                                             ]
                                         ]
                                 };
    
    NSInteger retDBData = [self.dbData DBDataInsertDBName:DBNAME_CONFIG   table:TABLENAME_TASKRECORD     info:infoInsert];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
        return result;
    }
    
    //tasksub.
    
    
    return result;
}


- (void)configTaskRecordRemoveBySn:(NSArray<NSString*>*)sn
{
    BOOL result = YES;
    NSInteger retDBData = [self.dbData DBDataDeleteDBName:DBNAME_CONFIG   table:TABLENAME_TASKRECORD     query:@{@"snTaskRecord":sn}];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
    }
}


- (void)configTaskRecordUpdate:(TaskRecord*)taskRecord
{
    NSDictionary *updateDict = @{
                                 //@"sn":taskRecord.sn,
                                 @"snTaskInfo":taskRecord.snTaskInfo,
                                 @"dayString":taskRecord.dayString,
                                 @"type":@(taskRecord.type),
                                 @"record":taskRecord.record,
                                 @"committedAt":taskRecord.committedAt,
                                 @"modifiedAt":taskRecord.modifiedAt,
                                 @"deprecatedAt":taskRecord.deprecatedAt,
                                 };
    [self.dbData DBDataUpdateDBName:DBNAME_CONFIG   table:TABLENAME_TASKRECORD     infoUpdate:updateDict     infoQuery:@{@"snTaskRecord":taskRecord.snTaskRecord}];
}


#pragma mark - TaskFinish
- (NSArray<TaskFinishAt*>*)configTaskFinishAtGets
{
    NSMutableArray<TaskFinishAt*> *arrayReturnM = [[NSMutableArray alloc] init];
    
    //默认降序.
    NSDictionary *queryResult = [self.dbData DBDataQueryDBName:DBNAME_CONFIG
                                                         table:TABLENAME_TASKFINISHAT
                                                   columnNames:nil
                                                         query:nil
                                                         limit:nil];
    NSArray<NSDictionary* >* dicts = [self.dbData queryResultDictionaryToArray:queryResult];
    if(dicts.count > 0) {
        for(NSDictionary *dict in dicts) {
            TaskFinishAt *taskFinishAt = [TaskFinishAt taskFinishAtFromDictionary:dict];
            if(taskFinishAt) {
                [arrayReturnM addObject:taskFinishAt];
            }
        }
    }
    
    return [NSArray arrayWithArray:arrayReturnM];
}


- (BOOL)configTaskFinishAtAdd:(TaskFinishAt*)taskFinishAt
{
    BOOL result = YES;
    
    NSDictionary *infoInsert = @{
                                 DBDATA_STRING_COLUMNS:
                                     @[
                                         @"snTaskInfo",
                                         @"dayString",
                                         @"finishedAt",
                                         ],
                                 DBDATA_STRING_VALUES:
                                     @[
                                         @[
                                             taskFinishAt.snTaskInfo,
                                             taskFinishAt.dayString,
                                             taskFinishAt.finishedAt,
                                             ]
                                         ]
                                 };
    
    NSInteger retDBData = [self.dbData DBDataInsertDBName:DBNAME_CONFIG   table:TABLENAME_TASKFINISHAT     info:infoInsert];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
        return result;
    }
    
    return result;
}


- (void)configTaskFinishAtRemove:(TaskFinishAt*)taskFinishAt
{
    BOOL result = YES;
    NSInteger retDBData = [self.dbData DBDataDeleteDBName:DBNAME_CONFIG
                                                    table:TABLENAME_TASKFINISHAT
                                                    query:@{@"snTaskInfo":taskFinishAt.snTaskInfo,@"dayString":taskFinishAt.dayString}];
    if(DB_EXECUTE_OK != retDBData) {
        NSLog(@"#error - ");
        result = NO;
    }
}



#pragma mark - HTTPSessionManager
- (AFHTTPSessionManager *)HTTPSessionManager
{
    if(!self.session) {
        self.session = [AFHTTPSessionManager manager];
        [self.session setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    }
    
    return self.session;
}


#pragma mark - Test
- (void)configNoteAddTest
{
    NoteModel *note = [[NoteModel alloc] init];
    note.sn = @"[test1]";
    note.title = @"<p style=\"FONT-SIZE: 15pt; COLOR: #ffff00; FONT-FAMILY: 黑体\">收购 Twitter 的戏剧大幕拉开，远未散场</p>";
    note.content = @"<p style=\"\">第一段说明1</p> <p style=\"\">cnBeta 报道，多家国外媒体援引知情人111士的消息称，Twitter 董事会周四将召开一次会议，讨论公司所面临的一系列问题，其中包括出售事宜。关于 Twitter 被出售的消息早有传闻，华尔街分析师也认为，Twitter 被出售只是时间早晚的问题。近日，Twitter 联合创始人埃文·威廉姆斯(Evan Williams)的一席话再次将该话题推到风口浪尖。 威廉姆斯上周在接受彭博电视台采访时称：“我们现在的地位很有利，作为董事会成员，我们必须考虑正确的选择。”外界认为，这番话可能暗示 Twitter 将考虑出售选项，从而刺激 Twitter 股价大涨7%。 投资研究公司分析师罗伯特·派克(Robert Peck)称，Twitter 当前估值约为 150 亿美元。按照溢价 20% 的标准计算，收购 Twitter 至少需要 180 亿美元。 有业内人士认为，价格不是问题，谷歌母公司 Alphabet、Facebook、苹果公司、亚马逊和微软等都是 Twitter 的潜在收购方。对于 Alphabet 而言，在其搜索服务中部署 Twitter 的实时推送(feed)功能，可实现成本和营收的协同效应。 对于 Facebook，收购 Twitter 可实现战略匹配。对于苹果公司，收购 Twitter 可将当前的硬件业务拓展到社交领域。对于亚马逊，可拓展实时内容服务，进一步强化广告业务。至于微软，一直都对在线和广告业务感兴趣。 但派克认为，短期内 Twitter 也没有出售的紧迫性。首先，Twitter CEO 杰克·多西(Jack Dorsey)仅上任一年时间。其次，Twitter 正在推出几项新服务。此外，Twitter 董事会将继续支持多西。 等等，派克先生，你确定你计算的收购价是 180 亿美元？ 福布斯可不这么认为 《福布斯》在微软收购 LindkedIn 撰文称，即使在对未来现金流最乐观估计情况下，Alphabet 收购 Twitter 的价格也不应超过 11 亿美元，合每股 1.55 美元，比其股价低近九成。否则在经济上就是不划算的。Twitter 营收增长越快，亏损越大，相当于营收的 38%。 为什么是 Alphabet？ 《福布斯》认为，Alphabet 管理层是公司股东更称职的管家，与 Alphabet 的整合必须大幅度提升 Twitter 核心业务盈利能力。 在证明 Twitter 收购价合理方面，Alphabet 高管需要解决的主要挑战是前者有瑕疵的商业模式。Twitter 商业模式的瑕疵在于，用户的最大利益(例如迅捷、方便地访问他们选择的内容)，与广告客户的最大利益(获得用户更多关注)不一致。在修正这一瑕疵前(我不相信这一瑕疵能被修正)，很难说有公司会认真考虑收购 Twitter。Alphabet 也能增加 Twitter 的营收和税后净营业利润。 除了 Alphabet，Twitter 的潜在买家还包括微软前首席执行官史蒂夫·鲍尔默(Steve Ballmer) 以及沙特王子阿尔瓦利德·本·塔拉尔·沙特（Saudi Prince Alwaleed bin Talal Al Saud ）联合收购 Twitter。 目前 Twitter 没有对出售传闻作出回应，就像《福布斯》说的那样，收购 Twitter 的戏剧大幕拉开，远未散场。</p>";
    note.title = @"<p>英语单词记录</p>";
    note.content = @"<p style=\"\">make a name of oneself 出名，扬名 <br />glimpse of 瞥见，一瞥 <br />glance at 瞥见，一瞥 <br />be on good terms with sb． 与某人友好 <br />entitle sb．(to do)sth． 给予某人(干)某事的权利 <br />beyond one’s power 超出某人的能力 <br />take interest in 对…发生兴趣 <br />be answerable for 应对… hundreds of 数以百计的 <br />be lacking in 缺乏 <br /></p><p style=\"\">break into tears(cheers) 突然哭(欢呼)起来 <br />in correspondence with 与…联系(通信) <br />be advantageous to 对…有利 <br />be beneficial to 对…有益 <br />in debt to sb． 欠某人的债 <br />be it that 即使 <br />assure sb．of sth． 委托某人某事 <br />put(set) right 使恢复正常，纠正错误 <br />on the way 在途中 <br />off the way 远离正道 </p><p style=\"\">have／gain access to 可以获得 <br />take…into account 考虑到，顾及，体谅 <br />take advantage of 占…的便宜，利用 <br />pave the way (for) 铺平道路，为…作准备 <br />pay attention to 注意 <br />do／try one’s best 尽力，努力 <br />get／have the best of 战胜 <br />make the best of 充分利用 <br />get／have the better of 战胜，在…中占上风 <br />catch one’s breath 屏息；喘气，气喘；歇口气 </p>";
    note.summary = @"";
    note.classification = @"英语";
    note.color = @"";
    note.thumb = @"";
    note.audio = @"",
    note.location = @"CHINA";
    note.createdAt = @"2016-08-02 01:23:45";
    note.modifiedAt = @"2017-03-01 01:23:45";
    note.browseredAt = @"2017-03-01 01:23:45";
    note.deletedAt = @"";
    note.source = @"";
    note.synchronize = @"";
    note.countCollect = 0;
    note.countLike = 0;
    note.countDislike = 0;
    note.countBrowser = 0;
    note.countEdit = 0;
    [self configNoteAdd:note];
    
    note.sn = @"[test2]";
    note.title = @"<p style=\"color:blue; text-align:center\">color - red    使用说明1 red使用</p>";
    note.content = @"<p style=\"\">第一段说明2</p> <p style=\"\">另一段说明2</p>";
    note.color = @"red";
//    [self configNoteAdd:note];
    
    //return;
    
    note.sn = @"[test3]";
    note.title = @"<p style=\"color:blue; text-align:center\">color - yellow. 使用说明1 yellow使用说明2使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1</p>";
    note.content = @"<p style=\"\">第一段说明2</p> <p style=\"\">另一段说明2</p>";
    note.color = @"yellow";
//    [self configNoteAdd:note];
    
    note.sn = @"[test4]";
    note.title = @"<p style=\"color:blue; text-align:center\">color - blue 使用说明1 blue使用说明2使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1</p>";
    note.content = @"<p style=\"\">第一段说明2</p> <p style=\"\">另一段说明2</p>";
    note.color = @"blue";
//    [self configNoteAdd:note];
    
    note.sn = @"[test5]";
    note.title = @"<p style=\"color:blue; text-align:center\">color blue, classfication - 新增 使用说明1 blue使用说明2使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1</p>";
    note.content = @"<p style=\"\">第一段说明2</p> <p style=\"\">另一段说明2</p>";
    note.color = @"blue";
    note.classification = @"新增";
//    [self configNoteAdd:note];
    
    note.sn = @"[test6]";
    note.title = @"<p style=\"color:blue; text-align:center\">Twitter 或因员工期权太多形成被收购障碍</p>";
    note.content = @"<p style=\"color:blue;FONT-SIZE: 10pt;\">第一段说明2</p> <p style=\"\">另一段说明2</p> <p style=\"\">本文作者原：新元@ 股书 Kapbook (微信 ID：Kapbook)， 完整的股权激励在线解决方案。 </p> <p style=\"\">在过去的几个季度里，Twitter 每季度都会给员工发放超过 1 亿 5000 万美元价值的期权。这种激进的做法有些不合常理。 </p> <p style=\"\">9 月 28 日，36Kr 的报道就说：Twitter 或因员工期权太多形成被收购障碍。美国知名科技媒体 Business Insider 也曾报道：2011 年，处于快速成长阶段的 Twitter 向投资者总计筹集了 12 亿美元，其中的 8 亿美元被用来回购老员工（不论离职与否）手里的期权，作为对这些“昔日功臣”的奖励。 </p> <p style=\"\">其实在当时，公司里的一些高管曾经筹划，希望 Twitter 在 2011 年就上市。可是 Twitter 的决策层则把融资拿的钱大部分用在了回购员工期权。并表示：让员工等到公司上市才能卖出股权套现，这个过程太漫长了，公司于心不忍。于是在那时，上市最终不了了之。 </p> <p style=\"\">Twitter 在发期权方面过于慷慨的做法，与近日沸沸扬扬的丁香园形成鲜明对比。加拿大皇家银行资本市场部的资深分析师 Mark Mahaney 更直言，Twitter 是在授予员工股权激励方面最为激进的公司之一。 </p> <p style=\"\">Twitter 有多激进呢？2015 年公司毛利润为 5.578 亿美元，发期权就发了 6.82 亿美元。 </p> <p style=\"\">对，你没有看错。这是一家真正称得上是“为员工赚钱的公司”。 </p> <p style=\"\">硅谷中的激进主义 </p> <p style=\"\">事实上，Twitter 在 2014 年每季度都会拿出营业收入的 35%-50% 来做股权激励。其中第二季度达到高峰，当季 Twitter 营业收入是 3.12 亿美元，其中的 51% 用来做股权激励。 </p> <p style=\"\">2015 年 Twitter 有所收敛，拿出了营业收入的 26% 做股权激励。作为横向对比，让我们来看看各大科技巨头 2015 年发期权的情况。 </p> <p style=\"\">Amazon 亚马逊把公司年营业收入的2% 作为股权激励发给了员工； Google 发出7%；Facebook 发出 15%；Linkedin 领英发了 17%；Twitter 的 26% 显然是最多的 。 </p> <p style=\"\">不过，像 Twitter 这样发期权过于激进的，长期来说，对公司的发展未必有利。因为 Twitter 陷入了一个现金流缺失的不良循环中。 </p> <p style=\"\">Twitter 在成立运营之初，缺少现金给员工发工资，于是 Twitter 开始发放期权；等到新一轮融资进来的时候，由于其慷慨的股权激励制度，公司需要拿出新融资的一大笔钱，来回购之前老员工的股票，然后公司会发现手里可用的现金又一次缺少； </p> <p style=\"\">与尴尬的现金流境况相对的是：公司在迅速壮大，为了招募新的得力干将，Twitter 又给新加入的员工发放了大笔期权；最终就这样循环下来。 </p> <p style=\"\">Twitter 处于进退两难的境地。它承诺给员工们可观的薪酬， 股权激励恰恰是其中重要组成。这笔支出是省不下来的。但是持续的股权激励计划，则不断稀释着其他股东的权益。这些期权数目很大，Twitter 的股份每季度增加1% 到2%，每年增加 10% 至 20%。 </p> <p style=\"\">显然，公司即便没有任何开支，每年的营业收入也该增加 10% 以上，可惜 Twitter 达不到 10%，那么老股东的权益其实是逐渐减少。 </p> <p style=\"\">期权计划的内容 </p> <p style=\"\">我们不妨看一下 Twitter 这一系列期权计划的具体形式。 首先，Twitter 只发给员工受限股。而不是发放业界惯常的股票期权，或者直接持股。所谓受限股，即：公司授予的依据受限股授予协议约定的条件和价格，直接或间接购买的相应股东权利受到一定限制的公司股权。受限股和股票期权一样，都是在一定时间后低价拿到公司股权的方法。 </p> ";
    note.color = @"";
    note.classification = @"新增";
    [self configNoteAdd:note];
    
    NSMutableArray *contentParagraphs = [[NSMutableArray alloc] init];
    NoteParagraphModel *noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"设计师心情最平静的时候是熬夜做完案子准备睡觉时，看见天色有些发白，听见一两声鸟。为了更加形象地描述（嘲讽）这个脑细胞平均每天死一万次的职业，《Lean Branding》的作者Laura Busche画了10张图，长这样：";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"1、设计师听到最幸福的情话就是：挺好的，用这稿！如果改到山穷水尽疑无路，设计师真的会想说“kill me，kill me now”。fs fsdfsdkfjs dfsdklfdskjf sdkfjds fsldkflsdfk sdfk sd;lkf s;ldfkdslkfsdl";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"2.直播优化层面";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"其实最难的难点是提高首播时间、服务质量即Qos（Quality of Service，服务质量），如何在丢包率20%的情况下还能保障稳定、流畅的直播体验，需要考虑以下方案：";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"1）为加快首播时间，收流服务器主动推送 GOP :（Group of Pictures:策略影响编码质量)所谓GOP，意思是画面组，一个GOP就是一组连续的画面至边缘节点，边缘节点缓存 GOP，播放端则可以快速加载，减少回源延迟";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"2）GOP丢帧，为解决延时，为什么会有延时，网络抖动、网络拥塞导致的数据发送不出去，丢完之后所有的时间戳都要修改，切记，要不客户端就会卡一个 GOP的时间，是由于 PTS（Presentation Time Stamp，PTS主要用于度量解码后的视频帧什么时候被显示出来） 和 DTS 的原因，或者播放器修正 DTS 和 PTS 也行（推流端丢GOD更复杂，丢 p 帧之前的 i 帧会花屏）";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"3）纯音频丢帧，要解决音视频不同步的问题，要让视频的 delta增量到你丢掉音频的delta之后，再发音频，要不就会音视频不同步";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"4）源站主备切换和断线重连";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"5）根据TCP拥塞窗口做智能调度，当拥塞窗口过大说明节点服务质量不佳，需要切换节点和故障排查";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"6）增加上行、下行带宽探测接口，当带宽不满足时降低视频质量，即降低码率";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"7）定时获取最优的推流、拉流链路IP，尽可能保证提供最好的服务";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"8)监控必须要，监控各个节点的Qos状态，来做整个平台的资源配置优化和调度";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"9）如果产品从推流端、CDN、播放器都是自家的，保障 Qos 优势非常大";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"10）当直播量非常大时，要加入集群管理和调度，保障 Qos";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"11）播放端通过增加延时来减少网络抖动，通过快播来减少延时。（出自知乎宋少东）。";
    [contentParagraphs addObject:noteParagraph];
    
    noteParagraph = [[NoteParagraphModel alloc] init];
    noteParagraph.content = @"7、你不知道排版最难的地方就是一点一点的间距和文字，真的会瞎掉我的狗眼，别说5分钟给我排个版，你以为是ppt？";
    [contentParagraphs addObject:noteParagraph];
    
    note.sn = @"";
    note.classification = @"个人笔记";
    note.color = @"blue";
    note.title = @"<p style=\"color:blue; text-align:center\">平面设计师.</p>";
    note.content = [NoteParagraphModel noteParagraphsToString:contentParagraphs];
    [self configNoteAddTest:@[note]];
    
    note.sn = @"123456";
    note.title = @"<p style=\"color:blue; text-align:center\">上周扎克伯格在位于帕洛奥图的家中接受记者采访。他要给记者展示一个现实版贾维斯的Demo，这是该项目首次接受采访。</p>";
    note.content = @"<p>据Fast Company报道，当新工程师加入Facebook时——无论是初出茅庐的毕业生还是从其他公司转投而来的副总级别的人物——他们都会在名为“Bootcamp”的新人训练营接受为期六个星期的密集培训。此计划旨在帮助他们了解公司庞大的代码库，以及一套不断发展的编程工具。</p><p>作为Facebook的创立者和首任工程师，马克·扎克伯格（Mark Zuckerberg）在早期给代码库贡献了比其他人都多的代码。</p><p>2004年扎克伯格在哈佛宿舍里创办了Facebook，两年后推出Bootcamp计划，然而这位现年32岁的CEO从来没参加过Bootcamp。</p><p>今年一月，扎克伯格宣布了他2016年的年度目标：他要打造一个人工智能系统，使用Facebook软件工具来管理他的家。AI是对Facebook未来至关重要的技术领域，新的开发目标也迫使他更新自己对编程和工作流程的经验。同时这又将他与工程师的日常经验和企业文化重新联系在一起。</p><p>然而Facebook CEO的职位并不允许他拿出六个星期的时间参加“新人再教育”。</p><p>“我没有经历正式的Bootcamp培训。”上周扎克伯格在位于帕洛奥图的家中接受记者采访。他要给记者展示一个现实版贾维斯的Demo，这是该项目首次接受采访。“但是当我问人们问题时，你可以想象他们回复得很快。”</p><p><img src=\"https://imgs.bipush.com/article/cover/201612/20/104033024478.png\"/></p><p><img src=\"https://imgs.bipush.com/article/cover/201612/20/104037011695.png\"/>（扎克伯格指挥他的贾维斯AI助理开灯）</p><p>扎克伯格一直以来喜欢开发所带来的“确定性”，这是打造任何梦想之物所需的基本元素。与此相比，作为企业领导人，指挥着一万五千人的团队服务数十亿用户虽然堪称野心勃勃，但他错过了愉快的确定性。</p><p>也正是这个原因让他在闲暇时间继续从事小型项目的开发。他在2012年给自己立下的年度挑战是每天写代码。多年来他一直参加多个公司的黑客马拉松，并且作为闲暇练手，他曾经写了一个系统，通过配对Facebook组织图和内部社交图查看公司里哪个团体最具社交关系。</p><p>扎克伯格告诉记者，亲自力行参与编码让他重拾初学汉语时的感觉——2010年他将学汉语作为年度目标——大脑感觉到被激活的兴奋。</p><p>Facebook的企业文化要求如果你开发的程序出现毛病，你就得停止手头正在做的事去解决问题。这个要求对于日理万机的大公司CEO来说当然不太实际。“我要么被迫退出会议，要么就得请其他人修改我的代码，后者当然要不得。”他说。以至于很多时候他都是在工作时间修改他私人项目的代码。</p><p>在过去一年，扎克伯格在他的家庭项目上总共投入了大概100～150个小时。</p><p>虽然它被效仿钢铁侠命名为“贾维斯”，但它更像是Alexa那样的高度个人化的东西：他和妻子普莉希拉使用定制的iPhone程序或Facebook Messenger聊天机器人控制电灯开关、根据个人口味播放音乐、为访客开门、烤吐司片、还有提醒他们一岁的女儿Max不要忘了上汉语课。</p><p>扎克伯格的房子坐落在帕洛奥图17000平方英尺的安静地段。当你造访时，贾维斯识别来客，并提醒主人你的到达。当你穿过木门，穿过花园走廊，扎克伯格会亲自出来迎接你。</p><p>不管线上线下，扎克伯格的外表看起来都是同一副打扮：短棕色的头发配上灰色T恤和牛仔裤。你在网络照片和视频中见到太多次这个形象，以至于可能会需要一点时间来确定此时在门口欢迎你的是真人本人。</p><p>最近几个星期扎克伯格工作上的事儿比较忙，他在同时努力解决三个难题：关于Facebook在总统大选前是否是假新闻的主要传播驱动力，与股东交涉在卖出股票的情况下保留对企业的控制权，同时广告客户也在关注Facebook在广告点击观看率上的计算方法。</p><p>相比之下谈论贾维斯是比较轻松的任务。扎克伯格坐在客厅里的一个深绿色沙发上，他的匈牙利牧羊犬卧在一边。扎克伯格轻松自在地向记者讲述过去一年里打造贾维斯系统的经历，它如何让事情变得更简单，当然偶尔也会带来麻烦。</p><ul class=\" list-paddingleft-2\"></ul><p>在他一月份对外宣布贾维斯项目的文章中，扎克伯格写道：他将开始建立一个系统，允许他使用声音控制房子里的一切，包括音乐、灯光和温度。他还想让贾维斯通过人像识别实现访客接待，并且在客人到达时嘱咐对方在小女儿房间里的注意事项。他希望该系统能“用VR可视化数据帮助我打造更好的服务，更有效率地领导我的组织”。</p><p>一年之后的今天，他已经实现了诺言中的绝大部分——VR部分有所保留——而且它整体上运转良好。在他对记者展示这个系统时，还是出现了一些小瑕疵。</p><p>Messenger聊天机器人被作为整个系统的前端。扎克伯格首先打开Messenger，演示开关灯。效果令人满意。</p><p>同时他还建立了响应语音指令的系统。他为此单独开发了一个iOS应用程序。展示结果并不太理想，他不得不反复讲了四次才让系统弄明白他的指令。</p><p>“喔，这应该是它最失败的表现了。”扎克伯格略显尴尬地说。</p><p>让系统播放音乐很成功。“给我们放段音乐吧。”他下达命令。几秒钟后，David Guetta的 &quot;Would I Lie to You&quot; 开始响起来。“把音量调高。”他说了两次，系统都做到了。最后他同样用了两次才让智能管家把音乐停了下来。</p><p>贾维斯最让扎克伯格骄傲的地方在于它能习得主人夫妻俩不同的音乐口味。当妻子要放音乐时，它就会推荐妻子喜欢的而不是男主人的喜好。它还被设计能按音乐风格播放曲子，比如“轻松的”、“适合家庭氛围的”或者“与这位歌手风格相似的歌”。</p><p>“来段红辣椒乐队那种的。”扎克伯格说。几秒钟后，客厅里响起了Nirvana的 &quot;Smells Like Teen Spirit&quot;。</p><p>扎克伯格也希望贾维斯能够在一定程度上理解语言差异。然而理解非常相似的短语对贾维斯比较有难度。比如“Play‘Someone Like You’”和“Play someone like Adele”以及“Play some Adele”虽然表面上相似，但实际含义则大不同。扎克伯格希望系统通过反馈来习得不同用语之间的差别，并称过程相当有趣。</p><p><img src=\"https://imgs.bipush.com/article/cover/201612/20/105528362178.jpeg\"/></p><p label=\"大标题\" class=\"text-big-title\">偶尔惹得老婆发怒</p><p>除了选择正确的音乐进行播放外，还需要确保贾维斯不会惹恼普莉希拉。即使要求系统开灯、关灯、播放音乐等，可能也会产生许多令人感到惊讶的歧义，让贾维斯感到不知所措。</p><p>举例来说，扎克伯格与妻子有时候会使用不同的短语形容相同的东西，扎克伯格称为客厅的房间被普莉希拉称为家庭活动室，因此贾维斯需要学会理解同义词。但扎克伯格不希望贾维斯仅仅记住不同的短语，他还教贾维斯学习理解它们，以及它们在不同情境中的不同含义，显然这都是非常有趣的问题。</p><p><br label=\"大标题\" class=\"text-big-title\"/></p><p><img src=\"https://imgs.bipush.com/article/cover/201612/20/105045908929.jpeg\"/></p><p>（图：贾维斯可以让扎克伯格使用Messenger聊天机器人，来欢迎朋友到访。）</p><p>扎克伯格说：“你会碰到这样的情况：我只会说‘打开房间的灯’，可是房间中的灯光有些刺眼，因此普莉希拉会说‘调暗灯光’。但她不会说调暗哪个房间的灯光，因此贾维斯需要知道我们的位置，否则它就可能执行错误命令。有时候，我会说‘播放音乐’，贾维斯会打开Max所在房间的音乐，因为我们此前就是那样给它下令的。”如果Max碰巧在午睡会如何？扎克伯格说：“这是个巨大的失败，这是惹怒你老婆的绝佳方式！”</p><p>确认位置非常重要的另一个例证：作为创造最佳收视体验方案的组成部分，贾维斯会关掉灯。扎克伯格说：“其中与电视所在房间相邻的另一个房间就是普莉希拉的办公室，为此这就出现一个有趣的问题：当我要去看电视时，贾维斯会关掉楼下所有的灯。而这时普莉希拉正要去工作，这会让她觉得疯狂！”</p><p label=\"大标题\" class=\"text-big-title\">比预期要容易得多</p><p>尽管扎克伯格只会选择一个年度个人挑战，但在2016年时，他选择了两个，第二个就是全年跑步587公里。这意味着，他在继续开发贾维斯的过程中，不能坐得太久。就像他为自己设定的2015年挑战，每两周读一本书。事实上，扎克伯格用于开发贾维斯的时间比跑步时间更少，在很大程度上，这要感谢Facebook的收集工具，他可以经常利用图片和语音识别功能对贾维斯进行测试。</p><p>但扎克伯格没有想到的是，这个项目最难的地方在于如何将贾维斯与家中各种不同的系统相连，包括控制灯、门以及温度的Crestron智能家居系统、安全系统、Sonos流媒体盒以及Spotify音乐等，他想要通过贾维斯控制这些系统。</p><p>严格来说，扎克伯格的家庭网络是Facebook企业基础设施的重要组成部分，拥有严格的保护措施。任何东西要想与这套网络相连，必须获得Facebook的安全证书。从本质上说，这种证书就是数字认证密匙，以确保指定的设备安全。<br/></p><p>而这种安全措施却大大限制了扎克伯格的控制能力。以联网冰箱为例，它没有Facebook的安全证书。对于大多数人来说，这都不是问题。但是这里的大多数人不包括扎克伯格，确保他在家时的安全非常重要。扎克伯格已经找到通过互联网连接交换机安全控制某些电器的方式，这至少可让他能够遥控开关电源。扎克伯格希望贾维斯能够利用他此前留在面包机中面包片制作早餐吐司，但现在还没有任何面包机电源关闭的情况下烤面包。为此，扎克伯格购买了20世纪50年代的低技术产品，以方便他对其进行控制。</p><p>最终，要想实现所有家居物品都能够相连，这需要许多时间对它们采用的产品和服务软件进行逆向工程操作。在开始开发AI之前，扎克伯格就需要做完这些事情。</p><p><img src=\"https://imgs.bipush.com/article/cover/201612/20/105614231761.jpeg\"/></p><p>（图：扎克伯格收到Messenger通知，贾维斯已经打开大门，尽管后者同时也在控制他的Sonos音乐系统。）</p><p label=\"大标题\" class=\"text-big-title\">还未准备好面世</p><p>尽管贾维斯在记者面前的表现不够完美，但这款伯格依然为其目前取得的成就感到骄傲。他表示愿意将贾维斯与当前你能在市场上买到的同类产品进行对比，比如亚马逊Echo（Alexa支持）和Google Home（Google Assistant支持）。</p><p>扎克伯格强调：“贾维斯还未准备好上市供更多人使用。但如果我无法开发出至少可媲美Echo或Google Home的东西，我可能对自己感到相当失望。”</p><p>扎克伯格补充说，与为单栋住宅设计AI系统相比，开发类似亚马逊和谷歌的智能系统，让数以百万计的人们控制多款设备更难。</p><p>为此，他没有将贾维斯当成Facebook产品推出的计划。但扎克伯格表示：“如果我无法围绕音乐推荐或以不同方式使用面部识别、理解屋内情境环境等对AI进行改进，那么我不认为自己真的推动AI大步向前。”</p><p>扎克伯格称，事实上他打算发布自己所从事工作的摘要，如果他的某些结论最终能被整合到可用的公开系统中，他会感到非常高兴。这也反映出Facebook开源其大部分工作的哲学，特别是在AI方面。这样的教训包括我们利用文本和语音进行互动。与贾维斯的对话让播放语音的指令变得有意义。但扎克伯格发现，在很多情况下，文本依然很重要，特别是在有其他人在场的情况下。他说：“如果我允许某人进门，这与我周围的人无关，为此我宁可发短信。”</p><p>即使扎克伯格经常发布语音指令，但他更喜欢贾维斯以文本方式回应他或显示某些信息，而无需大声说出来。扎克伯格说：“当贾维斯讲话时，意味着其会发布许多指令，而这是相当恼人的事情。”但这并非是说语音指令不重要，在特定时候，还是需要语音指令。</p><p>扎克伯格从未幻想过自己只用150小时就能赶上Facebook的AI专家每年投入数千小时以上开发出的AI，而Facebook有许多业内最顶级的AI人才。</p><p>不过，在好奇心驱使下，扎克伯格已经让贾维斯达到非常先进的水平，他已经准备好向世界展示它。扎克伯格说，他每天都在摆弄贾维斯，因为他每天都会使用它，总是要修正小问题或添加新功能。但他很高兴自己和家人可以对贾维斯进行随意调整。</p><p>扎克伯格说：“这种感觉超棒，早上醒来时，你只要对贾维斯说‘早上好’或‘醒来’，整栋房子似乎也随之醒来。与之类似，当你晚上准备上床睡觉时，无需关掉每个房间的灯，只需要说‘晚安’，贾维斯就会帮你关灯，并确保锁好门。”<br/></p><p>当然，扎克伯格不仅是需要更好照顾家人的丈夫和父亲，他还是大科技公司的领导者。这家公司的命运已经注定，需要通过有效的方式促使技术人才创造更伟大的产品。对于扎克伯格来说，参与贾维斯项目最好的地方就是，他重新获得Facebook的工程体验。</p><p>他说：“因为我花了很多时间利用Facebook的工具编码，作为公司首席执行官，我通常不会那样做。我觉得自己好像成为Facebook的新工程师，正帮助Facebook加速扩张。我非常喜欢这些内部工具，它们已经成为企业文化的重要组成部分。”</p>";
    note.modifiedAt = @"2016-12-21 12:00:00";
    [self configNoteAdd:note];
    
    note.sn = @"12345t";
    note.title = @"<p style=\"color:blue; text-align:center\">科技公司都变成了数据公司</p>";
    note.content = @"<p>《美国数据工程概况》，来源 / Stitch Data，译者 / 黄谦、徐勇、王小佛、张耕、王心田、王挺、Raymond Yang。本文来自微信公众号“峰瑞资本”（微信号：freesvc），授权虎嗅发布，转载请联系原作者。推荐人：陈诚，DataPipeline 创始人，前 Yelp 数据工程师。</p><p>在和国内外顶尖公司交流的过程中，我发现他们多数都很骄傲有一支极其专业的数据团队。这些公司花了大量的时间和精力把数据工程这件事情做到了极致，有不小规模的工程师团队，开源了大量数据技术。Linkedin 有 kafka、samza, Facebook 有 hive、presto，Airbnb有airflow、superset，我所熟悉的 Yelp 也有 mrjob…… 这些公司在数据领域的精益求精，为后来的大步前进奠定了基石。</p><p>今天推荐的这篇文章《美国数据工程现状》，从多个维度阐释了数据工程和数据工程师在美国的发展状况。或许你和我一样，都会有一些意想不到的发现。</p><p>我常觉得数据工程之于企业的意义，就好像马斯洛需求理论之于人的意义，从低到高进阶满足，企业对于数据工程的应用应该遵循这个三角原则。</p><blockquote><p>第一层，企业要注意到公司发展过程中，最普世最基础的需求：即让数据可见可得。这需要我们重视数据工程这件事，这是企业做大做强安身立命的根本。</p><p>第二层，进阶需求。有了数据意识，招来了数据工程师，拉开架势开始干吧。这时候企业就需要开始从语义<span class=\"text-remarks\" label=\"备注\">（semantic）</span>的角度去理解跑起来的数据流了。实现从数据到企业战略指导再回到数据。</p><p>第三层，是目前看起来最接近塔尖也是最高级的需求：即建模、更完善的预测性算法、更漂亮的数据可视化、深度学习、AI 等等……</p></blockquote><p>这些更高级的更贴近金字塔尖，也是现在创业的风口。我偶尔也会被风吹的精神抖擞，但吹完风，静下来想想，一个企业没有好的数据工程、数据基础架构逻辑、没有构建数据流的能力，这些金塔尖上的需求是非常难被满足的，很难取得好的结果，也无法实现真正的价值。</p><p>是的，我又被风打下来了，开始站在地上思考问题了。</p><p>当然，对于创业公司来说，打造完整的数据工程、严密数据架构、高效的数据流是件 “正确但不容易的事情”。不好做、效果不直观，但很重要。</p><p>最后，我想引用 Kafka 技术的缔造者 <span class=\"text-remarks\" label=\"备注\">（Kafka，被誉为 LinkedIn 的 “中枢神经系统”）</span>、现 Confluent 的 CEO Jay Kreps 的一句话：</p><blockquote><p>Without a reliable and complete data flow, a Hadoop cluster is little more than a very expensive and difficult-to-assemble space heater。</p><p>如果你的公司没有一个完整可靠的数据流，那么你的 Hadoop 集群其实就像非常贵而且很难组装的暖气片而已。</p></blockquote><p><strong>正文如下：</strong></p><p>目前，LinkedIn 上有 6500 人称自己是数据工程师。而仅在旧金山，就有 6600 个这样的工作机会虚位以待。去年，数据工程师的数量翻了一倍，但工程主管们却仍觉得人才匮乏。</p><p>数据人才的旺盛需求源自一个根本性的变化：<strong>科技公司现如今都成了数据公司。</strong></p><p>像 Uber、Airbnb、Spotify 这些公司都在大力发展数据产品，结果便造成数据系统开发和维护人才的激烈争夺。</p><p>Josh Wills 是 Slack 的数据工程师，在 2016 数据工程大会<span class=\"text-remarks\" label=\"备注\">（DataEngConf 2016）</span>上半开玩笑地说：“我的数据工程师都在会场了，请你们别挖墙角。” 即使 Slack 这样当红的硅谷企业，也在担忧如何留住这些宝贵人才。</p><p>我们的研究着重于说明以下几个方面：</p><blockquote><ul class=\" list-paddingleft-2\"><li><p><strong>目前市场上数据工程师的数量</strong>；</p></li><li><p><strong>数据工程师的背景和核心技能</strong> —— 这些信息对于主管们研究如何将软件工程转换至数据工程特别有用<span class=\"text-remarks\" label=\"备注\">（编者按：以缓解招聘数据工程师的压力）</span>；</p></li><li><p><strong>数据工程师的就业信息 </strong>—— 帮助你说明为什么要投资<span class=\"text-remarks\" label=\"备注\">（时间/精力/金钱）</span>到这项昂贵的技能中来。</p></li></ul></blockquote><p>从 Stripe、MIT、Looker 的工程主管对数据人才的发现、留任和对数据工程师团队项目的开发等一系列策略的分享中，我们找到了这些问题的答案，使得这份报告清晰地呈现出数据工程的现状。</p><p><strong>关键指标：</strong></p><blockquote><ul class=\" list-paddingleft-2\"><li><p><strong>人数</strong>：6500 人在 LinkedIn <span class=\"text-remarks\" label=\"备注\">（领英）</span>上称自己是数据工程师。</p></li><li><p><strong>发展</strong>：2013 到 2015 年，数据工程师的数量至少翻了一倍。</p></li><li><p><strong>分布</strong>：50% 的数据工程师都在美国。</p></li><li><p><strong>之前的职务</strong>：42% 的数据工程师都是软件工程出身。</p></li><li><p><strong>产业</strong>：数据工程师主要供职于信息科技与服务产业。</p></li><li><p><strong>技能</strong>：数据工程师前 5 项主要技能是：SQL、Java、Python、Hadoop和Linux。R语言甚至都没进前 20。</p></li></ul></blockquote><p><strong>分析方法：</strong></p><p>本报告基于 Linkedin 上的用户资料，包括所有公开可见的个人及公司档案、技能与工作经验，数据以 2016 年 3 月份的统计为准。</p><p>我们根据档案上的职业标题和头衔识别出数据工程师，这里只纳入了那些可确认公司的数据工程师档案。</p><p style=\"text-align: center;\"><span class=\"img-center-box\" style=\"display:block;\"><img src=\"https://imgs.bipush.com/article/content/201612/29/181526680719.png\"></span><span class=\"text-remarks\" label=\"备注\">图表：LinkedIn 个人档案总结</span><span class=\"img-center-box\" style=\"display:block;\"><br></span></p><p>截止 2016 年 3 月 1 日，Linkedin 上的个人档案大约 4.3 亿，此次参考了 2.6 亿例档案，其中列有至少一项经历的近 1.9 亿， 有一项已认证经历的超过 1 亿，当前经历已认证的近 8000 多万。</p><p>在这些数据工程师中，我们分析了：</p><blockquote><ul class=\" list-paddingleft-2\"><li><p>3 万项工作经验</p></li><li><p>8.2 万条个人经历</p></li><li><p>3400 个公司</p></li></ul></blockquote><p>分析工具：</p><blockquote><ul class=\" list-paddingleft-2\"><li><p>分析采用 Python、SQL 和 Jupyter。</p></li><li><p>HighCharts 和 HighMaps 中的交互式可视化效果采用 Python 的制图包和 Python-highchairs 实现。</p></li><li><p>数据采用 AWS Redshift 进行存储和处理。</p></li></ul></blockquote><p label=\"大标题\" class=\"text-big-title\">一、数据工程师有多少？</p><p>“数据工程师”<span class=\"text-remarks\" label=\"备注\">（所有以某种方式与数据打交道的软件工程师）</span>的定义仍有很大的模糊性，目前并没有一个完美答案，我们觉得由这些从业者自己来解读是最好的方式。</p><p>我们发现在 Linkedin 上有 6500 人称自己是“数据工程师”。</p><p>6500，这个数目并不大。</p><p>实际上，我们有些惊讶“数据工程师”竟如此之少。而在写这篇报道的时候，Indeed 上有 6600 个 数据工程师的招聘启事，这还仅仅是在旧金山和湾区。</p><p>薪酬数据也证实了数据工程师很受欢迎。据说，在 Facebook、Amazon 和 Google 这样的巨头公司工作的顶级数据工程师工资超 50 万美金。Indeed 的数据分布更保守一些，尽管如此，薪资也达到了 6 位数。</p><p><img src=\"https://imgs.bipush.com/article/content/201612/29/181540297460.png\" style=\"text-align: center;\"><br></p><p style=\"text-align: center;\"><span class=\"text-remarks\" label=\"备注\">图表： 旧金山地区数据工程师的数量和薪酬比</span></p><p>从上图可以看出，薪酬在 10 万美元以上的职位超过 80%, 其中 110k-120k， 120k-130k 和 130k+ 的职位都很多，均超过了 20%。数据工程师成为当下的黄金职业！</p><blockquote><p>专家洞见：Jonathan Coveney，Stripe 数据工程师：“对数据工程师型人才的需求”。</p><p>近十年来，Jonathan 都在数据领域深耕，曾在 Twitter、Spotify 等公司建立数据系统。在他看来，有三种主要趋势在推动着对数据工程师类人才的需求：<br></p><ul class=\" list-paddingleft-2\"><li><p><strong>公司在对数据和管理数据的人的思考上更加精深</strong>。“数据不再是副产品，而是一个公司运作的核心”。</p></li><li><p><strong>对机器学习愈加倚重</strong>。由于机器学习的进步，对专有数据的掌握逐渐成为各个领域的公司最重要的竞争优势。</p></li><li><p><strong>公司开始建造数据产品</strong>。“以地图为例，机器学习主要作用于交通路线的侦测与规划，而地图的基础建设则在于管理和组织大规模的数据，这就是数据工程。”</p></li></ul></blockquote><p label=\"大标题\" class=\"text-big-title\">二、数据工程师的数量随时间的变化</p><p>LinkedIn 的简历显示了一个人声明的自己的职业发展历史，包括了在各个时间段内的职务。这些数据让我可以构建出某个职务的不断演变。</p><p>下图就展示了”数据工程师“这个职务的飞速发展：</p><p style=\"text-align: center;\"><span class=\"img-center-box\" style=\"display:block;\"><img src=\"https://imgs.bipush.com/article/content/201612/29/181524296092.png\"></span><span class=\"text-remarks\" label=\"备注\">【图表】累计数据工程师的数量（单位：千）</span><span class=\"img-center-box\" style=\"display:block;\"><br></span></p><p>数据工程师的数量从 2013 年到 2015 年增长超过了一倍。而且基于上文中相关岗位需求的数据，该增长趋势并不会减慢。<br></p><p>相比之下，数据科学家的数量大约是数据工程师的两倍<span class=\"text-remarks\" label=\"备注\">（大约 11,400 人）</span>，但是数据工程师的增长速度却要更高：在同一时期，数据科学家数量“仅”增长了 50%。</p><p label=\"大标题\" class=\"text-big-title\">三、数据工程师从哪里来？<span class=\"img-center-box\" style=\"display:block;\"><br></span></p><p><img src=\"\" data-rawwidth=\"600\" data-rawheight=\"142\" class=\"content_image\" style=\"\">数据工程师的疯狂增长让人产生了一个疑问：这些人从哪里来？他们之前是什么职业？</p><p>我们通过观察数据，调查了数据工程师这一职业的 DNA —— 他们之前的职业。</p><p>在我们的调查前有以下几个猜测：</p><ul class=\" list-paddingleft-2\"><li><p>数据工程师是软件工程师和数据科学家之间的桥梁：他们编写了生产代码来方便数据科学家们进行大规模的运算实验。因此，我们猜测有很大一部分数据工程师的前身是软件工程师或数据科学家。</p></li><li><p>因为数据工程师很大部分的工作都围绕着运算的规模，他们同时也是软件工程师和运维开发<span class=\"text-remarks\" label=\"备注\"> ( Devops ) </span>的桥梁。因此我们猜测一部分人由运维开发转来。</p></li><li><p>数据库管理员曾在一个企业中扮演类似的角色。因而，不难假设一部分数据库管理员投身到这一更加先进的职业中。</p></li></ul><p>结果显示，我们的猜测部分是正确的，有一点是非常明确的：数据工程师的 DNA 和软件工程师最接近 。</p><p><span class=\"img-center-box\" style=\"display:block;\"><img src=\"https://imgs.bipush.com/article/content/201612/29/181546522724.png\"></span></p><p style=\"text-align: center;\"><span class=\"text-remarks\" label=\"备注\">图表 ：TOP 10 数据工程师的来源</span></p><p><span class=\"img-center-box\" style=\"display:block;\"><br></span></p><p label=\"大标题\"><span class=\"img-center-box\" style=\"display: block; text-align: left;\">数据工程师前职调查，最多依次为软件工程师、分析师、咨询师、商业分析师、数据架构师、数据分析师、数据库管理员、数据科学家、实习生、研究助理等。</span><span class=\"img-center-box\" style=\"display: block; text-align: left;\"><br></span></p><p label=\"大标题\" class=\"text-big-title\">四、数据工程师都在哪儿？<br label=\"大标题\" class=\"text-big-title\"></p><p label=\"大标题\" class=\"text-big-title\"><img src=\"\" data-rawwidth=\"600\" data-rawheight=\"142\" class=\"content_image\" style=\"\"></p><p>50% 的数据工程师在美国。这并不奇怪，因为数据科学家这个称谓的本身和很多基础技术都是来自于美国的科技公司和大学。</p><p><img src=\"https://imgs.bipush.com/article/content/201612/29/181536994647.png\" style=\"text-align: center;\"><br></p><p style=\"text-align: center;\"><span class=\"text-remarks\" label=\"备注\">图表：数据科学家全球化</span></p><p>大部分的数据科技或是来自于一小部分大学——特别是伯克利大学 AMP 实验室，或者是来自于全球最大的网络公司软件工程团队。<br></p><p>谷歌、脸书、领英和亚马逊在领先该产业其他对手很久，就已经开始挑战大数据，并投入了大量资源。他们不仅创造了很多的数据科技，他们成为了数据人才的培育基地。</p><p>然而，这张图有些误导。</p><p>美国至今有着最多的数据工程师，也同样在全球有着最多的数据工程师档案：接近4倍多于排名第二的印度。<br></p><p>为了标准化数据，我们图中排名前十的国家展开详细，看他们各自数据工程师人数与在领英<span class=\"text-remarks\" label=\"备注\">（LinkedIn）</span>档案数的对比，以及与总人口的对比。</p><p><img src=\"https://imgs.bipush.com/article/content/201612/29/181530684511.png\" style=\"text-align: center;\"><br></p><p style=\"text-align: center;\"><span class=\"text-remarks\" label=\"备注\">图表：TOP 10 数据工程师最多的国家</span></p><p>这张统计中没有以色列，以色列是我们此前的参考标准，它曾经在每百万人中的数据科学家占比排名中排名最高。上文提及，以色列长期被认为是数据科学的起源国度，在以色列“硅溪”有着强劲科技展现。但意外的是，这却没能转化为高密度的数据工程师人才。<br></p><p label=\"大标题\" class=\"text-big-title\">五、哪个行业聘用的数据工程师最多？</p><p>在扩大存储、传输和处理数据方面遇到挑战的公司对数据工程人才需求最甚。这些挑战多在科技公司出现，但是像电信、生物科技和保险这些行业呢？难道这些行业不需要数据扩张方面的帮助吗？<br></p><p>当我们考察数据工程师的工作领域时，我们发现一系列的行业都需要数据人才。</p><p><img src=\"https://imgs.bipush.com/article/content/201612/29/181527258949.png\" style=\"text-align: center;\"><br></p><p style=\"text-align: center;\"><span class=\"text-remarks\" label=\"备注\">图表：TOP 20 数据工程师的行业分布</span></p><p>与预期一致，电信和金融服务接近顶端，但是在生物科技中 DNA 的拍字节<span class=\"text-remarks\" label=\"备注\">（Petabytes）</span>的排序却没有朝排名靠前的位置发展。</p><p>从该表格中，我们不应该认为这些行业之外的领域就不需要或者不聘用担任数据工程师功能的人才。相反，尽管“数据工程师”在某一个领域内已经流行开来，互联网科技公司—— 这个特定职位的用法仍处于初始阶段。这个领域内的技术、流程和思维方式正在开始延伸到其它的行业。</p><p label=\"大标题\" class=\"text-big-title\">六、哪些公司聘用的数据工程师最多？</p><p>当我们看到聘用了数据工程师的具体公司时，他们在科技领域的受欢迎程度就更加明显了。在前十的公司里，只有两家公司不是专门从事技术或数据的：一家电信公司<span class=\"text-remarks\" label=\"备注\">（Verizon）</span>和一家金融机构<span class=\"text-remarks\" label=\"备注\">（Capital One）</span>。<br></p><p><img src=\"https://imgs.bipush.com/article/content/201612/29/181533022031.png\" style=\"text-align: center;\"><br></p><p style=\"text-align: center;\"><span class=\"text-remarks\" label=\"备注\">图表：TOP 50 聘用数据工程师的公司</span></p><p>经常在数据大会上分享经验的 Amazon、Facebook、Netflix、CapitalOne 等公司，都是业界数据应用的非常成功的公司，和其雇佣的数据工程师的人数呈正相关。<br></p><p>很有趣的是，一些公司聘用了不成比例的数据工程师。比如 Spotify<span class=\"text-remarks\" label=\"备注\">（1600+ 雇员）</span>比起必能宝<span class=\"text-remarks\" label=\"备注\">（Pitney Bowes，16000 雇员）</span>要小得多，但他们聘用的数据工程师数量相当。</p><p>这些数据清晰显示，现在的一些科技 “独角兽” 高度重视数据工程师一职。同时，考虑到三藩市目前有 6600 家公司在找数据工程师，这个趋势短期内似乎不会改变。</p><p label=\"大标题\" class=\"text-big-title\">七、数据工程师的基础技能</p><p>数据工程师干的活大体分为两个部分：</p><blockquote><ul class=\" list-paddingleft-2\"><li><p>在整个业务流程，让消费者能接触到数据</p></li><li><p>打造 “产品化” 的算法，将其变为数据产品</p></li></ul></blockquote><p>总体而言，直接与数据相关的技能获得了越来越多的重视，另一方面，某些核心的软件技能也为数据工程师所青睐。</p><p style=\"text-align: center;\"><span class=\"img-center-box\" style=\"display:block;\"><img src=\"https://imgs.bipush.com/article/content/201612/29/181543883989.png\"></span><span class=\"text-remarks\" label=\"备注\">图表：TOP 20 数据工程师的基本技能</span><span class=\"img-center-box\" style=\"display:block;\"><br></span></p><p>从图上可以看出用 SQL 来回答分析型的问题、写脚本来做数据集成、清洗这样的 ETL 任务和使用Hadoop生态的工具是数据工程师的主要工作。</p><p><strong>No.1 SQL</strong><span class=\"text-remarks\" label=\"备注\">（Structured Query Language：结构化查询语言）</span><strong>：</strong></p><p>即便在数据技术领域，很多 NoSQL 倡导者 “欲除之而后快”，但 SQL 仍是数据工程师最普遍具备的技能。</p><p><strong>No. 2 Java：</strong></p><p>Java 是最受数据工程师欢迎的编程语言。自从分布式系统基础架构 Hadoop 在 2000 年左右被开发出来后，JVM<span class=\"text-remarks\" label=\"备注\">（Java Virtual Machine：Java 虚拟机）</span>便处于数据处理的中心。</p><p><strong>No.3 Python：</strong></p><p>不仅被应用于数据工程，还能为分析任务服务——相较而言，总是和 Python 一同出现在新闻里的 R 语言，更专精于分析与统计，这应该也是 R 没有上榜的主要原因——在数据科学圈，数据工程和分析二者并重。</p><blockquote><p>专家洞见：Mike Xu, Looker 的数据架构师：“弄明白你想要哪款数据工程师？”</p><p>Mike 的职责之一是倾听开发者的心声：哪些事情让他们开心？哪些让他们不爽？最多的抱怨是什么呢？嗯，不同的数据工程角色间是有细微差别的，但很多公司却不懂行。</p><p>在 Mike 看来，数据工程师主要有 4 种角色——这也是招聘者应该弄明白的事情：</p><ul class=\" list-paddingleft-2\"><li><p>数据仓库：专注于为分析来优化数据仓库，主要是负责数据的读写和管理。</p></li><li><p>工具：总能在一系列数据工具箱里，极其擅长一、两样特定的工具<span class=\"text-remarks\" label=\"备注\">（编者按：类似于 Hive、Hbase、ElasticSearch 等）</span>。</p></li><li><p>架构：才华通透、“端到端” 的思考者，无论是数据收集，还是收集后帮助团队使用数据，他们需要考虑的事情多而杂，贯穿业务的很多环节。</p></li><li><p>运维<span class=\"text-remarks\" label=\"备注\">（Ops）</span>：主要把时间花在建立数据库等事项，还要管理权限、操心数据安全。</p></li></ul></blockquote><p label=\"大标题\" class=\"text-big-title\">八、数据工程师的技能如何随着公司规模的变化而改变？<br label=\"大标题\" class=\"text-big-title\"></p><p>作为数据工程师，同样需要认真应对公司和业务的规模化所带来的挑战——业务更多，数据集 <span class=\"text-remarks\" label=\"备注\">（Dataset）</span>的规模也更大，所需求的数据能力和工作方式也要随之演化。<br></p><p>姑且做个猜测：规模越大的公司，对规模化相关的技能越加看重。是否真的如此？我们先查看查看下面的图表。</p><p><span class=\"img-center-box\" style=\"display:block;\"><img src=\"https://imgs.bipush.com/article/content/201612/29/181548143728.png\"></span></p><p style=\"text-align: center;\"><span class=\"text-remarks\" label=\"备注\">图表：不同公司的数据工程师之间的差别</span></p><p><span class=\"img-center-box\" style=\"display:block;\"><br></span></p><p><span class=\"text-remarks\" label=\"备注\">纵轴表示技能，横轴则表示相对偏差（Relative Difference：某一次测量的绝对偏差占平均值的百分比）。深蓝色、天蓝色、橘色分别代表三种公司规模：1-200人、200-1000人、1000人以上。越接近图表顶部，该技能越应用于较小的公司，反之，位于底部的技能更普遍地出现在 1000 人及以上的公司里。</span></p><p>看完表，我们可以用数据回答先前的猜测：NO。</p><p>真实情况是，在规模更大的公司，数据工程师更在意 “企业级” 相关的技能，比如 ETL<span class=\"text-remarks\" label=\"备注\">（Extract-Transform-Load）</span>、BI<span class=\"text-remarks\" label=\"备注\">（Business Intelligence：商业智能）</span>、数据仓库等，而在较小的公司，数据工程师更多的把心力花在 Python、Java 等编程语言上<span class=\"text-remarks\" label=\"备注\">（编者按：Python 和 Java 作为普通的编程语言，可以用来构建产品，这对于小公司来说属于核心业务）</span>。</p><blockquote><p>专家洞见：Will Smith，MIT 的主数据工程师 / 架构师：“数据工程 @大公司 VS. 初创公司”</p><p>Will 曾为 Nokia、Warner Bros Games 这种大公司打造过数据技术。在他看来，数据工程师所仰赖的技术，不那么取决于公司规模本身，而更应该从这么一种角度出发：你所负责的数据是“写时模式”<span class=\"text-remarks\" label=\"备注\">（schema-on-write）</span>还是“读时模式”<span class=\"text-remarks\" label=\"备注\">（schema-on-read）</span>？</p><p>他认为，大公司往往在处理数据工程的 BI 方面有所积累，Informatica、Oracle、SAP 都会接触和使用。这类公司往往在“写时模式”的环境里工作。</p><p>但现如今，很多打造数据科技的公司实际作业的环境是“读时模式”。“想象一下，公司交给你几个 TB 的日志数据，用的 JSON，是关于广告效果的。数据工程师不知道能从这堆数据中挖掘出什么，所以你需要开发者写代码去做数据发掘，而不是一上来就直接套用 SQL。这和大公司在 ‘写时模式’ 的环境中做事很不一样。”</p><p>2011年时，Will 正效力于诺基亚 <span class=\"text-remarks\" label=\"备注\">（Nokia）</span>。尽管当时主要经手 “企业级的数据”，但团队却选择“读时模式”的思路去开展相关工作。</p><p>“现在很多数据工程师都这么做，比较适合规模化的需求。这样设计和开发出来的东西，可以消化掉来自于各种来源的数据。传统老旧的 BI 系统就没这能耐——主要是因为以’写时模式’为基础吧，这种老技术不知道在一堆数据里都有什么，这么一来我们这些工程师也没啥头绪了。”</p></blockquote><p label=\"大标题\" class=\"text-big-title\">九、数据工程师与数据科学家的技能差异是怎样的？</p><p>这个数据集体现了数据工程师与数据科学家之间的明显的技能差异，由此可以将数据工程师与数据科学家的技能构成看作一个频谱的两个对立面。</p><p>以下这张图表显示了一张数据技能频谱图，频谱图顶端的技能在数据工程师的简历中更为常见，而频谱底端的技能更常出现在数据科学家的简历中。</p><p><img src=\"https://imgs.bipush.com/article/content/201612/29/181554495032.png\" style=\"text-align: center;\"><br></p><p style=\"text-align: center;\"><span class=\"text-remarks\" label=\"备注\">图表：数据工程师与数据科学家的区别</span></p><p>从图表的技能构成可以看出，数据工程师更倾向于掌握 “战术层面” 的具体数据技能，专注于使数据可用并能够在生产环境中对数据进行处理，如具体的编程语言、操作系统与数据库等；而数据科学家更倾向于“战略层面”的数据技能，如数据分析、数据挖掘、统计分析、机器学习等。<br></p><p label=\"大标题\" class=\"text-big-title\">十、数据工程师与软件工程师的技能差异是怎样的？</p><p>数据工程师与数据科学家之间的差异是十分明显的，那么数据工程师与软件工程师之间的技能差异又是怎样的呢？毕竟，正如我们之前所展示的那样，大部分的数据工程师都具有软件工程师的背景。</p><p style=\"text-align: center;\"><span class=\"img-center-box\" style=\"display:block;\"><img src=\"https://imgs.bipush.com/article/content/201612/29/181551546186.png\"></span><span class=\"text-remarks\" label=\"备注\">图表：数据工程师与软件工程师之间的区别</span><span class=\"img-center-box\" style=\"display:block;\"><br></span></p><p>以数据工程师为中心的最多人选择的技能是 Hadoop，数据仓库和 BI——正如你所期望的那样。与之相反，在软件工程师端列出的所有技能几乎都与 web 前端开发相关。最大的两个例外是 C 语言和 C++ 语言，这是在现代大数据技术栈开发中不常用到的编程语言。</p><p>虽然许多数据工程师具有软件工程师背景，但他们并不是简单的为了博取加薪而转换一个新的工作头衔；他们不得不通过学习新的技能来适应新的角色。</p><blockquote><p>专家洞见：Ryan Orban，Galvanize CTO：“在数据工程师和数据科学家之间建立更好的关系”</p><p>“想一想设计师和前端开发工程师之间的关系，” Ryan Orban 说，“一个角色负责通过想法完成工作，而另一个角色负责将想法付诸实施，这之间可能会导致很多的紧张对立情绪。”&nbsp;</p><p>Ryan 认为，数据工程师和数据科学家之间的关系与之类似，因此缓解两者之间的紧张情绪的方法也是相似的。“正如设计师经常被告知需要学习编写一些代码，而前端开发工程师也经常被告知要制作一些原型，我鼓励数据科学家和数据工程师相互学习一些对方所需要掌握的数据技能。”</p><p>那么，数据工程师需要多深入的了解数据科学家的世界呢？</p><p>“数据工程师应该对机器学习有一些基本的了解”，Ryan 说，“他们不需要了解所有的数学理论，但是他们应该能够判断效率和准确性。相反，数据科学家应该了解架构，以及如何对架构进行扩展，并初步了解生产级的编程语言。”</p><p>这种深入了解其他相关学科专业知识的转变也发生在其他领域。公司习惯于聘请数据科学家来负责市场、产品或者业务分析方面的工作，而聘请数据工程师来完成更广泛的工程功能。这造成了目标错位。Ryan 认为这种趋势正在改变：“ ‘数据团队’ 是由数据科学家和数据工程师共同构成的这一概念越来越受欢迎。这一如此简单的改变将很大的改善两组人员之间的关系。”</p></blockquote><p><br label=\"备注\"></p><p><span class=\"text-remarks\">本文来自微信公众号“峰瑞资本”（微信号：freesvc），授权虎嗅发布，转载请联系原作者。</span><span style=\"color: rgb(153, 153, 153);\">推荐人：陈诚，DataPipeline 创始人，前 Yelp 数据工程师。</span><span style=\"color: rgb(153, 153, 153);\">如果你对中国数据工程现状充满兴趣和好奇心，欢迎你和我取得联系 cheng@datapipeline.com。</span></p> <br> <div class=\"neirong-shouquan\"> <span class=\"c2\">*文章为作者独立观点，不代表虎嗅网立场<br></span> </div> <br> </div>";
    note.modifiedAt = @"2016-12-21 12:00:00";
//    [self configNoteAdd:note];
    
    note.sn = @"";
    note.title = @"<p style=\"color:blue; text-align:center\">科技公司都变成了数据公司</p>";
    note.content = @"<p>《美国数据工程概况》，来源 / Stitch Data，译者 / 黄谦、徐勇、王小佛、张耕、王心田、王挺、Raymond Yang。本文来自微信公众号“峰瑞资本”（微信号：freesvc），授权虎嗅发布，转载请联系原作者。推荐人：陈诚，DataPipeline 创始人，前 Yelp 数据工程师。</p><p>在和国内外顶尖公司交流的过程中，我发现他们多数都很骄傲有一支极其专业的数据团队。这些公司花了大量的时间和精力把数据工程这件事情做到了极致，有不小规模的工程师团队，开源了大量数据技术。Linkedin 有 kafka、samza, Facebook 有 hive、presto，Airbnb有airflow、superset，我所熟悉的 Yelp 也有 mrjob…… 这些公司在数据领域的精益求精，为后来的大步前进奠定了基石。</p><p>今天推荐的这篇文章《美国数据工程现状》，从多个维度阐释了数据工程和数据工程师在美国的发展状况。或许你和我一样，都会有一些意想不到的发现。</p><p>我常觉得数据工程之于企业的意义，就好像马斯洛需求理论之于人的意义，从低到高进阶满足，企业对于数据工程的应用应该遵循这个三角原则。</p><blockquote><p>第一层，企业要注意到公司发展过程中，最普世最基础的需求：即让数据可见可得。这需要我们重视数据工程这件事，这是企业做大做强安身立命的根本。</p><p>第二层，进阶需求。有了数据意识，招来了数据工程师，拉开架势开始干吧。这时候企业就需要开始从语义（semantic）的角度去理解跑起来的数据流了。实现从数据到企业战略指导再回到数据。</p><p>第三层，是目前看起来最接近塔尖也是最高级的需求：即建模、更完善的预测性算法、更漂亮的数据可视化、深度学习、AI 等等……</p></blockquote><p>这些更高级的更贴近金字塔尖，也是现在创业的风口。我偶尔也会被风吹的精神抖擞，但吹完风，静下来想想，一个企业没有好的数据工程、数据基础架构逻辑、没有构建数据流的能力，这些金塔尖上的需求是非常难被满足的，很难取得好的结果，也无法实现真正的价值。</p><p>是的，我又被风打下来了，开始站在地上思考问题了。</p><p>当然，对于创业公司来说，打造完整的数据工程、严密数据架构、高效的数据流是件 “正确但不容易的事情”。不好做、效果不直观，但很重要。</p><p>最后，我想引用 Kafka 技术的缔造者 （Kafka，被誉为 LinkedIn 的 “中枢神经系统”）、现 Confluent 的 CEO Jay Kreps 的一句话：</p><blockquote><p>Without a reliable and complete data flow, a Hadoop cluster is little more than a very expensive and difficult-to-assemble space heater。</p><p>如果你的公司没有一个完整可靠的数据流，那么你的 Hadoop 集群其实就像非常贵而且很难组装的暖气片而已。</p></blockquote><p>正文如下：</p><p>目前，LinkedIn 上有 6500 人称自己是数据工程师。而仅在旧金山，就有 6600 个这样的工作机会虚位以待。去年，数据工程师的数量翻了一倍，但工程主管们却仍觉得人才匮乏。</p><p>数据人才的旺盛需求源自一个根本性的变化：科技公司现如今都成了数据公司。</p><p>像 Uber、Airbnb、Spotify 这些公司都在大力发展数据产品，结果便造成数据系统开发和维护人才的激烈争夺。</p><p>Josh Wills 是 Slack 的数据工程师，在 2016 数据工程大会（DataEngConf 2016）上半开玩笑地说：“我的数据工程师都在会场了，请你们别挖墙角。” 即使 Slack 这样当红的硅谷企业，也在担忧如何留住这些宝贵人才。</p><p>我们的研究着重于说明以下几个方面：</p><blockquote><ul class=\" list-paddingleft-2\"><li><p>目前市场上数据工程师的数量；</p></li><li><p>数据工程师的背景和核心技能 —— 这些信息对于主管们研究如何将软件工程转换至数据工程特别有用（编者按：以缓解招聘数据工程师的压力）；</p></li><li><p>数据工程师的就业信息 —— 帮助你说明为什么要投资（时间/精力/金钱）到这项昂贵的技能中来。</p></li></ul></blockquote><p>从 Stripe、MIT、Looker 的工程主管对数据人才的发现、留任和对数据工程师团队项目的开发等一系列策略的分享中，我们找到了这些问题的答案，使得这份报告清晰地呈现出数据工程的现状。</p><p>关键指标：</p><blockquote><ul class=\" list-paddingleft-2\"><li><p>人数：6500 人在 LinkedIn （领英）上称自己是数据工程师。</p></li><li><p>发展：2013 到 2015 年，数据工程师的数量至少翻了一倍。</p></li><li><p>分布：50% 的数据工程师都在美国。</p></li><li><p>之前的职务：42% 的数据工程师都是软件工程出身。</p></li><li><p>产业：数据工程师主要供职于信息科技与服务产业。</p></li><li><p>技能：数据工程师前 5 项主要技能是：SQL、Java、Python、Hadoop和Linux。R语言甚至都没进前 20。</p></li></ul></blockquote><p>分析方法：</p><p>本报告基于 Linkedin 上的用户资料，包括所有公开可见的个人及公司档案、技能与工作经验，数据以 2016 年 3 月份的统计为准。</p><p>我们根据档案上的职业标题和头衔识别出数据工程师，这里只纳入了那些可确认公司的数据工程师档案。</p><p style=\"text-align: center;\"><img src=\"https://imgs.bipush.com/article/content/201612/29/181526680719.png\">图表：LinkedIn 个人档案总结<br></p><p>截止 2016 年 3 月 1 日，Linkedin 上的个人档案大约 4.3 亿，此次参考了 2.6 亿例档案，其中列有至少一项经历的近 1.9 亿， 有一项已认证经历的超过 1 亿，当前经历已认证的近 8000 多万。</p><p>在这些数据工程师中，我们分析了：</p><blockquote><ul class=\" list-paddingleft-2\"><li><p>3 万项工作经验</p></li><li><p>8.2 万条个人经历</p></li><li><p>3400 个公司</p></li></ul></blockquote><p>分析工具：</p><blockquote><ul class=\" list-paddingleft-2\"><li><p>分析采用 Python、SQL 和 Jupyter。</p></li><li><p>HighCharts 和 HighMaps 中的交互式可视化效果采用 Python 的制图包和 Python-highchairs 实现。</p></li><li><p>数据采用 AWS Redshift 进行存储和处理。</p></li></ul></blockquote><p label=\"大标题\" class=\"text-big-title\">一、数据工程师有多少？</p><p>“数据工程师”（所有以某种方式与数据打交道的软件工程师）的定义仍有很大的模糊性，目前并没有一个完美答案，我们觉得由这些从业者自己来解读是最好的方式。</p><p>我们发现在 Linkedin 上有 6500 人称自己是“数据工程师”。</p><p>6500，这个数目并不大。</p><p>实际上，我们有些惊讶“数据工程师”竟如此之少。而在写这篇报道的时候，Indeed 上有 6600 个 数据工程师的招聘启事，这还仅仅是在旧金山和湾区。</p><p>薪酬数据也证实了数据工程师很受欢迎。据说，在 Facebook、Amazon 和 Google 这样的巨头公司工作的顶级数据工程师工资超 50 万美金。Indeed 的数据分布更保守一些，尽管如此，薪资也达到了 6 位数。</p><p><img src=\"https://imgs.bipush.com/article/content/201612/29/181540297460.png\"><br></p><p style=\"text-align: center;\">图表： 旧金山地区数据工程师的数量和薪酬比</p><p>从上图可以看出，薪酬在 10 万美元以上的职位超过 80%, 其中 110k-120k， 120k-130k 和 130k+ 的职位都很多，均超过了 20%。数据工程师成为当下的黄金职业！</p><blockquote><p>专家洞见：Jonathan Coveney，Stripe 数据工程师：“对数据工程师型人才的需求”。</p><p>近十年来，Jonathan 都在数据领域深耕，曾在 Twitter、Spotify 等公司建立数据系统。在他看来，有三种主要趋势在推动着对数据工程师类人才的需求：<br></p><ul class=\" list-paddingleft-2\"><li><p>公司在对数据和管理数据的人的思考上更加精深。“数据不再是副产品，而是一个公司运作的核心”。</p></li><li><p>对机器学习愈加倚重。由于机器学习的进步，对专有数据的掌握逐渐成为各个领域的公司最重要的竞争优势。</p></li><li><p>公司开始建造数据产品。“以地图为例，机器学习主要作用于交通路线的侦测与规划，而地图的基础建设则在于管理和组织大规模的数据，这就是数据工程。”</p></li></ul></blockquote><p label=\"大标题\" class=\"text-big-title\">二、数据工程师的数量随时间的变化</p><p>LinkedIn 的简历显示了一个人声明的自己的职业发展历史，包括了在各个时间段内的职务。这些数据让我可以构建出某个职务的不断演变。</p><p>下图就展示了”数据工程师“这个职务的飞速发展：</p><p style=\"text-align: center;\"><img src=\"https://imgs.bipush.com/article/content/201612/29/181524296092.png\">【图表】累计数据工程师的数量（单位：千）<br></p><p>数据工程师的数量从 2013 年到 2015 年增长超过了一倍。而且基于上文中相关岗位需求的数据，该增长趋势并不会减慢。<br></p><p>相比之下，数据科学家的数量大约是数据工程师的两倍（大约 11,400 人），但是数据工程师的增长速度却要更高：在同一时期，数据科学家数量“仅”增长了 50%。</p><p label=\"大标题\" class=\"text-big-title\">三、数据工程师从哪里来？<br></p><p><img src=\"\">数据工程师的疯狂增长让人产生了一个疑问：这些人从哪里来？他们之前是什么职业？</p><p>我们通过观察数据，调查了数据工程师这一职业的 DNA —— 他们之前的职业。</p><p>在我们的调查前有以下几个猜测：</p><ul class=\" list-paddingleft-2\"><li><p>数据工程师是软件工程师和数据科学家之间的桥梁：他们编写了生产代码来方便数据科学家们进行大规模的运算实验。因此，我们猜测有很大一部分数据工程师的前身是软件工程师或数据科学家。</p></li><li><p>因为数据工程师很大部分的工作都围绕着运算的规模，他们同时也是软件工程师和运维开发 ( Devops ) 的桥梁。因此我们猜测一部分人由运维开发转来。</p></li><li><p>数据库管理员曾在一个企业中扮演类似的角色。因而，不难假设一部分数据库管理员投身到这一更加先进的职业中。</p></li></ul><p>结果显示，我们的猜测部分是正确的，有一点是非常明确的：数据工程师的 DNA 和软件工程师最接近 。</p><p><img src=\"https://imgs.bipush.com/article/content/201612/29/181546522724.png\"></p><p style=\"text-align: center;\">图表 ：TOP 10 数据工程师的来源</p><p label=\"大标题\">数据工程师前职调查，最多依次为软件工程师、分析师、咨询师、商业分析师、数据架构师、数据分析师、数据库管理员、数据科学家、实习生、研究助理等。<br></p><p label=\"大标题\" class=\"text-big-title\">四、数据工程师都在哪儿？<br label=\"大标题\" class=\"text-big-title\"></p><p label=\"大标题\" class=\"text-big-title\"><img src=\"\"></p><p>50% 的数据工程师在美国。这并不奇怪，因为数据科学家这个称谓的本身和很多基础技术都是来自于美国的科技公司和大学。</p><p><img src=\"https://imgs.bipush.com/article/content/201612/29/181536994647.png\"><br></p><p style=\"text-align: center;\">图表：数据科学家全球化</p><p>大部分的数据科技或是来自于一小部分大学——特别是伯克利大学 AMP 实验室，或者是来自于全球最大的网络公司软件工程团队。<br></p><p>谷歌、脸书、领英和亚马逊在领先该产业其他对手很久，就已经开始挑战大数据，并投入了大量资源。他们不仅创造了很多的数据科技，他们成为了数据人才的培育基地。</p><p>然而，这张图有些误导。</p><p>美国至今有着最多的数据工程师，也同样在全球有着最多的数据工程师档案：接近4倍多于排名第二的印度。<br></p><p>为了标准化数据，我们图中排名前十的国家展开详细，看他们各自数据工程师人数与在领英（LinkedIn）档案数的对比，以及与总人口的对比。</p><p><img src=\"https://imgs.bipush.com/article/content/201612/29/181530684511.png\"><br></p><p style=\"text-align: center;\">图表：TOP 10 数据工程师最多的国家</p><p>这张统计中没有以色列，以色列是我们此前的参考标准，它曾经在每百万人中的数据科学家占比排名中排名最高。上文提及，以色列长期被认为是数据科学的起源国度，在以色列“硅溪”有着强劲科技展现。但意外的是，这却没能转化为高密度的数据工程师人才。<br></p><p label=\"大标题\" class=\"text-big-title\">五、哪个行业聘用的数据工程师最多？</p><p>在扩大存储、传输和处理数据方面遇到挑战的公司对数据工程人才需求最甚。这些挑战多在科技公司出现，但是像电信、生物科技和保险这些行业呢？难道这些行业不需要数据扩张方面的帮助吗？<br></p><p>当我们考察数据工程师的工作领域时，我们发现一系列的行业都需要数据人才。</p><p><img src=\"https://imgs.bipush.com/article/content/201612/29/181527258949.png\">图表：TOP 20 数据工程师的行业分布</p><p>与预期一致，电信和金融服务接近顶端，但是在生物科技中 DNA 的拍字节（Petabytes）的排序却没有朝排名靠前的位置发展。</p><p>从该表格中，我们不应该认为这些行业之外的领域就不需要或者不聘用担任数据工程师功能的人才。相反，尽管“数据工程师”在某一个领域内已经流行开来，互联网科技公司—— 这个特定职位的用法仍处于初始阶段。这个领域内的技术、流程和思维方式正在开始延伸到其它的行业。</p><p label=\"大标题\" class=\"text-big-title\">六、哪些公司聘用的数据工程师最多？</p><p>当我们看到聘用了数据工程师的具体公司时，他们在科技领域的受欢迎程度就更加明显了。在前十的公司里，只有两家公司不是专门从事技术或数据的：一家电信公司（Verizon）和一家金融机构（Capital One）。<br></p><p><img src=\"https://imgs.bipush.com/article/content/201612/29/181533022031.png\"><br></p><p style=\"text-align: center;\">图表：TOP 50 聘用数据工程师的公司</p><p>经常在数据大会上分享经验的 Amazon、Facebook、Netflix、CapitalOne 等公司，都是业界数据应用的非常成功的公司，和其雇佣的数据工程师的人数呈正相关。<br></p><p>很有趣的是，一些公司聘用了不成比例的数据工程师。比如 Spotify（1600+ 雇员）比起必能宝（Pitney Bowes，16000 雇员）要小得多，但他们聘用的数据工程师数量相当。</p><p>这些数据清晰显示，现在的一些科技 “独角兽” 高度重视数据工程师一职。同时，考虑到三藩市目前有 6600 家公司在找数据工程师，这个趋势短期内似乎不会改变。</p><p label=\"大标题\" class=\"text-big-title\">七、数据工程师的基础技能</p><p>数据工程师干的活大体分为两个部分：</p><blockquote><ul class=\" list-paddingleft-2\"><li><p>在整个业务流程，让消费者能接触到数据</p></li><li><p>打造 “产品化” 的算法，将其变为数据产品</p></li></ul></blockquote><p>总体而言，直接与数据相关的技能获得了越来越多的重视，另一方面，某些核心的软件技能也为数据工程师所青睐。</p><p style=\"text-align: center;\"><img src=\"https://imgs.bipush.com/article/content/201612/29/181543883989.png\">图表：TOP 20 数据工程师的基本技能<br></p><p>从图上可以看出用 SQL 来回答分析型的问题、写脚本来做数据集成、清洗这样的 ETL 任务和使用Hadoop生态的工具是数据工程师的主要工作。</p><p>No.1 SQL（Structured Query Language：结构化查询语言）：</p><p>即便在数据技术领域，很多 NoSQL 倡导者 “欲除之而后快”，但 SQL 仍是数据工程师最普遍具备的技能。</p><p>No. 2 Java：</p><p>Java 是最受数据工程师欢迎的编程语言。自从分布式系统基础架构 Hadoop 在 2000 年左右被开发出来后，JVM（Java Virtual Machine：Java 虚拟机）便处于数据处理的中心。</p><p>No.3 Python：</p><p>不仅被应用于数据工程，还能为分析任务服务——相较而言，总是和 Python 一同出现在新闻里的 R 语言，更专精于分析与统计，这应该也是 R 没有上榜的主要原因——在数据科学圈，数据工程和分析二者并重。</p><blockquote><p>专家洞见：Mike Xu, Looker 的数据架构师：“弄明白你想要哪款数据工程师？”</p><p>Mike 的职责之一是倾听开发者的心声：哪些事情让他们开心？哪些让他们不爽？最多的抱怨是什么呢？嗯，不同的数据工程角色间是有细微差别的，但很多公司却不懂行。</p><p>在 Mike 看来，数据工程师主要有 4 种角色——这也是招聘者应该弄明白的事情：</p><ul class=\" list-paddingleft-2\"><li><p>数据仓库：专注于为分析来优化数据仓库，主要是负责数据的读写和管理。</p></li><li><p>工具：总能在一系列数据工具箱里，极其擅长一、两样特定的工具（编者按：类似于 Hive、Hbase、ElasticSearch 等）。</p></li><li><p>架构：才华通透、“端到端” 的思考者，无论是数据收集，还是收集后帮助团队使用数据，他们需要考虑的事情多而杂，贯穿业务的很多环节。</p></li><li><p>运维（Ops）：主要把时间花在建立数据库等事项，还要管理权限、操心数据安全。</p></li></ul></blockquote><p label=\"大标题\" class=\"text-big-title\">八、数据工程师的技能如何随着公司规模的变化而改变？<br label=\"大标题\" class=\"text-big-title\"></p><p>作为数据工程师，同样需要认真应对公司和业务的规模化所带来的挑战——业务更多，数据集 （Dataset）的规模也更大，所需求的数据能力和工作方式也要随之演化。<br></p><p>姑且做个猜测：规模越大的公司，对规模化相关的技能越加看重。是否真的如此？我们先查看查看下面的图表。</p><p><img src=\"https://imgs.bipush.com/article/content/201612/29/181548143728.png\"></p><p style=\"text-align: center;\">图表：不同公司的数据工程师之间的差别</p><p>纵轴表示技能，横轴则表示相对偏差（Relative Difference：某一次测量的绝对偏差占平均值的百分比）。深蓝色、天蓝色、橘色分别代表三种公司规模：1-200人、200-1000人、1000人以上。越接近图表顶部，该技能越应用于较小的公司，反之，位于底部的技能更普遍地出现在 1000 人及以上的公司里。</p><p>看完表，我们可以用数据回答先前的猜测：NO。</p><p>真实情况是，在规模更大的公司，数据工程师更在意 “企业级” 相关的技能，比如 ETL（Extract-Transform-Load）、BI（Business Intelligence：商业智能）、数据仓库等，而在较小的公司，数据工程师更多的把心力花在 Python、Java 等编程语言上（编者按：Python 和 Java 作为普通的编程语言，可以用来构建产品，这对于小公司来说属于核心业务）。</p><blockquote><p>专家洞见：Will Smith，MIT 的主数据工程师 / 架构师：“数据工程 @大公司 VS. 初创公司”</p><p>Will 曾为 Nokia、Warner Bros Games 这种大公司打造过数据技术。在他看来，数据工程师所仰赖的技术，不那么取决于公司规模本身，而更应该从这么一种角度出发：你所负责的数据是“写时模式”（schema-on-write）还是“读时模式”（schema-on-read）？</p><p>他认为，大公司往往在处理数据工程的 BI 方面有所积累，Informatica、Oracle、SAP 都会接触和使用。这类公司往往在“写时模式”的环境里工作。</p><p>但现如今，很多打造数据科技的公司实际作业的环境是“读时模式”。“想象一下，公司交给你几个 TB 的日志数据，用的 JSON，是关于广告效果的。数据工程师不知道能从这堆数据中挖掘出什么，所以你需要开发者写代码去做数据发掘，而不是一上来就直接套用 SQL。这和大公司在 ‘写时模式’ 的环境中做事很不一样。”</p><p>2011年时，Will 正效力于诺基亚 （Nokia）。尽管当时主要经手 “企业级的数据”，但团队却选择“读时模式”的思路去开展相关工作。</p><p>“现在很多数据工程师都这么做，比较适合规模化的需求。这样设计和开发出来的东西，可以消化掉来自于各种来源的数据。传统老旧的 BI 系统就没这能耐——主要是因为以’写时模式’为基础吧，这种老技术不知道在一堆数据里都有什么，这么一来我们这些工程师也没啥头绪了。”</p></blockquote><p label=\"大标题\" class=\"text-big-title\">九、数据工程师与数据科学家的技能差异是怎样的？</p><p>这个数据集体现了数据工程师与数据科学家之间的明显的技能差异，由此可以将数据工程师与数据科学家的技能构成看作一个频谱的两个对立面。</p><p>以下这张图表显示了一张数据技能频谱图，频谱图顶端的技能在数据工程师的简历中更为常见，而频谱底端的技能更常出现在数据科学家的简历中。</p><p><img src=\"https://imgs.bipush.com/article/content/201612/29/181554495032.png\"><br></p><p style=\"text-align: center;\">图表：数据工程师与数据科学家的区别</p><p>从图表的技能构成可以看出，数据工程师更倾向于掌握 “战术层面” 的具体数据技能，专注于使数据可用并能够在生产环境中对数据进行处理，如具体的编程语言、操作系统与数据库等；而数据科学家更倾向于“战略层面”的数据技能，如数据分析、数据挖掘、统计分析、机器学习等。<br></p><p label=\"大标题\" class=\"text-big-title\">十、数据工程师与软件工程师的技能差异是怎样的？</p><p>数据工程师与数据科学家之间的差异是十分明显的，那么数据工程师与软件工程师之间的技能差异又是怎样的呢？毕竟，正如我们之前所展示的那样，大部分的数据工程师都具有软件工程师的背景。</p><p style=\"text-align: center;\"><img src=\"https://imgs.bipush.com/article/content/201612/29/181551546186.png\">图表：数据工程师与软件工程师之间的区别<br></p><p>以数据工程师为中心的最多人选择的技能是 Hadoop，数据仓库和 BI——正如你所期望的那样。与之相反，在软件工程师端列出的所有技能几乎都与 web 前端开发相关。最大的两个例外是 C 语言和 C++ 语言，这是在现代大数据技术栈开发中不常用到的编程语言。</p><p>虽然许多数据工程师具有软件工程师背景，但他们并不是简单的为了博取加薪而转换一个新的工作头衔；他们不得不通过学习新的技能来适应新的角色。</p><blockquote><p>专家洞见：Ryan Orban，Galvanize CTO：“在数据工程师和数据科学家之间建立更好的关系”</p><p>“想一想设计师和前端开发工程师之间的关系，” Ryan Orban 说，“一个角色负责通过想法完成工作，而另一个角色负责将想法付诸实施，这之间可能会导致很多的紧张对立情绪。”&nbsp;</p><p>Ryan 认为，数据工程师和数据科学家之间的关系与之类似，因此缓解两者之间的紧张情绪的方法也是相似的。“正如设计师经常被告知需要学习编写一些代码，而前端开发工程师也经常被告知要制作一些原型，我鼓励数据科学家和数据工程师相互学习一些对方所需要掌握的数据技能。”</p><p>那么，数据工程师需要多深入的了解数据科学家的世界呢？</p><p>“数据工程师应该对机器学习有一些基本的了解”，Ryan 说，“他们不需要了解所有的数学理论，但是他们应该能够判断效率和准确性。相反，数据科学家应该了解架构，以及如何对架构进行扩展，并初步了解生产级的编程语言。”</p><p>这种深入了解其他相关学科专业知识的转变也发生在其他领域。公司习惯于聘请数据科学家来负责市场、产品或者业务分析方面的工作，而聘请数据工程师来完成更广泛的工程功能。这造成了目标错位。Ryan 认为这种趋势正在改变：“ ‘数据团队’ 是由数据科学家和数据工程师共同构成的这一概念越来越受欢迎。这一如此简单的改变将很大的改善两组人员之间的关系。”</p></blockquote><p><br label=\"备注\"></p><p>本文来自微信公众号“峰瑞资本”（微信号：freesvc），授权虎嗅发布，转载请联系原作者。推荐人：陈诚，DataPipeline 创始人，前 Yelp 数据工程师。如果你对中国数据工程现状充满兴趣和好奇心，欢迎你和我取得联系 cheng@datapipeline.com。</p> <br> <div class=\"neirong-shouquan\"> *文章为作者独立观点，不代表虎嗅网立场<br> </div> <br> </div>";
    note.modifiedAt = @"2016-12-21 12:00:00";
    [self configNoteAddTest:@[note]];
}




- (void)configTaskAddTest
{
    TaskInfo *task;
    task = [[TaskInfo alloc] init];
    task.sn = @"t1";
    task.content = @"英语单词30个. 更新新单词到Note.";
    task.status = 1;
    task.committedAt = @"2016-11-01 09:10:36";
    task.modifiedAt = @"2016-11-01 09:10:36";
    task.signedAt = @"2016-11-01 09:10:36";
    task.finishedAt = @"";
    task.scheduleType = TaskInfoScheduleTypeDays;
    task.dayRepeat = YES;
    task.dayStrings = @"2016-11-01,2016-11-02,2016-11-03,2016-11-04,2016-11-14,2016-11-15,2016-11-16,2016-11-17,2016-11-18,2016-11-21,2016-12-07,2016-12-08,2016-12-09,2016-12-10,2016-12-11";
    task.time = @"07:00-23:00";
    //    task.period = @"period1";
    //[self configTaskInfoAdd:task];
    task.sn = @"t10";
    task.dayStrings = @"2016-11-01,2016-11-02,2016-11-03,2016-11-04,2016-11-15,2016-11-16,2016-11-18,2016-12-07,2016-12-08,2016-12-09,2016-12-10,2016-12-11";
    [self configTaskInfoAdd:task];
    
    task = [[TaskInfo alloc] init];
    task.sn = @"t2";
    task.content = @"检查NoteTask的功能list.";
    task.status = 1;
    task.committedAt = @"2016-11-01 09:16:36";
    task.modifiedAt = @"2016-11-01 09:16:36";
    task.signedAt = @"2016-11-01 09:16:36";
    task.finishedAt = @"";
    task.scheduleType = TaskInfoScheduleTypeDays;
    task.dayRepeat = YES;
    task.dayStrings = @"2016-11-01,2016-11-02,2016-11-03,2016-11-04,2016-11-05,2016-11-06,2016-11-07,2016-11-09,2016-11-10,2016-11-15,2016-11-16,2016-12-07,2016-12-08,2016-12-09,2016-12-10,2016-12-11";
    task.time = @"07:00-23:00";
    //    task.period = @"period2k";
    [self configTaskInfoAdd:task];
    
    task = [[TaskInfo alloc] init];
    task.sn = @"t3";
    task.content = @"打电话给JR.";
    task.status = 1;
    task.committedAt = @"2016-11-01 09:12:36";
    task.modifiedAt = @"2016-11-01 09:12:36";
    task.signedAt = @"2016-11-01 09:12:36";
    task.finishedAt = @"";
    task.scheduleType = TaskInfoScheduleTypeDays;
    task.dayRepeat = YES;
    task.dayStrings = @"2016-11-01,2016-11-02,2016-11-07,2016-11-08,2016-11-11,2016-11-15,2016-11-16,2016-12-07,2016-12-08,2016-12-09,2016-12-10,2016-12-11";
    task.time = @"07:00-23:00";
    //    task.period = @"period3t";
    [self configTaskInfoAdd:task];
    
    TaskRecord *taskRecord;
    taskRecord = [[TaskRecord alloc] init];
    taskRecord.snTaskInfo = @"t2";
    taskRecord.snTaskRecord = @"t2r0";
    taskRecord.type = TaskRecordTypeSignIn;
    taskRecord.record = @"";
    taskRecord.committedAt = @"2016-11-10 12:34:50";
    taskRecord.dayString = @"";
    taskRecord.modifiedAt = taskRecord.committedAt;
    taskRecord.deprecatedAt = @"";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskInfo = @"t3";
    taskRecord.snTaskRecord = @"t3r0";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskInfo = @"t1";
    taskRecord.snTaskRecord = @"t1r0";
    [self configTaskRecordAdd:taskRecord];
    
    taskRecord = [[TaskRecord alloc] init];
    taskRecord.snTaskInfo = @"t2";
    taskRecord.snTaskRecord = @"t2r1";
    taskRecord.type = TaskRecordTypeSignOut;
    taskRecord.record = @"";
    taskRecord.committedAt = @"2016-11-10 12:34:51";
    taskRecord.dayString = @"";
    taskRecord.modifiedAt = taskRecord.committedAt;
    taskRecord.deprecatedAt = @"";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskInfo = @"t3";
    taskRecord.snTaskRecord = @"t3r1";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskInfo = @"t1";
    taskRecord.snTaskRecord = @"t1r1";
    [self configTaskRecordAdd:taskRecord];
    
    taskRecord = [[TaskRecord alloc] init];
    taskRecord.snTaskInfo = @"t2";
    taskRecord.snTaskRecord = @"t2r2";
    taskRecord.type = TaskRecordTypeFinish;
    taskRecord.record = @"";
    taskRecord.committedAt = @"2016-11-10 12:34:52";
    taskRecord.dayString = @"";
    taskRecord.modifiedAt = taskRecord.committedAt;
    taskRecord.deprecatedAt = @"";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskInfo = @"t3";
    taskRecord.snTaskRecord = @"t3r2";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskInfo = @"t1";
    taskRecord.snTaskRecord = @"t1r2";
    [self configTaskRecordAdd:taskRecord];
    
    taskRecord = [[TaskRecord alloc] init];
    taskRecord.snTaskInfo = @"t2";
    taskRecord.snTaskRecord = @"t2r3";
    taskRecord.type = TaskRecordTypeUserRecord;
    taskRecord.record = @"用户填写的内容用户填写的内容用户填写的内容用户填写的内容用户填写的内容用户填写的内容用户填写的内容用户填写的内容用户填写的内容用户填写的内容";
    taskRecord.committedAt = @"2016-11-10 12:34:53";
    taskRecord.dayString = @"";
    taskRecord.modifiedAt = taskRecord.committedAt;
    taskRecord.deprecatedAt = @"";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskInfo = @"t3";
    taskRecord.snTaskRecord = @"t3r3";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskInfo = @"t1";
    taskRecord.snTaskRecord = @"t1r3";
    [self configTaskRecordAdd:taskRecord];
    
    taskRecord = [[TaskRecord alloc] init];
    taskRecord.snTaskInfo = @"t2";
    taskRecord.snTaskRecord = @"t2r4";
    taskRecord.type = TaskRecordTypeUserModify;
    taskRecord.record = @"";
    taskRecord.committedAt = @"2016-11-10 12:34:54";
    taskRecord.dayString = @"";
    taskRecord.modifiedAt = taskRecord.committedAt;
    taskRecord.deprecatedAt = @"";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskInfo = @"t3";
    taskRecord.snTaskRecord = @"t3r4";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskInfo = @"t1";
    taskRecord.snTaskRecord = @"t1r4";
    [self configTaskRecordAdd:taskRecord];
    
    taskRecord = [[TaskRecord alloc] init];
    taskRecord.snTaskInfo = @"t2";
    taskRecord.snTaskRecord = @"t2r5";
    taskRecord.type = TaskRecordTypeRemoteReminder;
    taskRecord.record = @"";
    taskRecord.committedAt = @"2016-11-10 12:34:55";
    taskRecord.dayString = @"";
    taskRecord.modifiedAt = taskRecord.committedAt;
    taskRecord.deprecatedAt = @"";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskInfo = @"t3";
    taskRecord.snTaskRecord = @"t3r5";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskInfo = @"t1";
    taskRecord.snTaskRecord = @"t1r5";
    [self configTaskRecordAdd:taskRecord];
    
    taskRecord = [[TaskRecord alloc] init];
    taskRecord.snTaskInfo = @"t2";
    taskRecord.snTaskRecord = @"t2r6";
    taskRecord.type = TaskRecordTypeLocalReminder;
    taskRecord.record = @"本地提醒 10:00:00";
    taskRecord.committedAt = @"2016-11-10 12:34:56";
    taskRecord.dayString = @"";
    taskRecord.modifiedAt = taskRecord.committedAt;
    taskRecord.deprecatedAt = @"";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskInfo = @"t3";
    taskRecord.snTaskRecord = @"t3r6";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskInfo = @"t1";
    taskRecord.snTaskRecord = @"t1r6";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskRecord = @"t1r6_1";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskRecord = @"t1r6_2";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskRecord = @"t1r6_3";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskRecord = @"t1r6_4";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskRecord = @"t1r6_5";
    [self configTaskRecordAdd:taskRecord];
    taskRecord.snTaskRecord = @"t1r6_6";
    [self configTaskRecordAdd:taskRecord];
    
}


- (void)configNoteAddTest:(NSArray<NoteModel*>*)noteTests
{
    for(NoteModel *note in noteTests) {
        //使用modifiedAt标记是否存在修改. 有修改才重新增加预制.
        NSArray<NoteModel*> *notesQuery = [self configNoteGetsWithQuery:@{ @"title":note.title, @"modifiedAt":note.modifiedAt, }];
        if(notesQuery.count > 0) {
            NSLog(@"Note test already added.");
        }
        else {
            NSLog(@"Note test add.");
            if(note.sn.length == 0) {
                note.sn = [NSString randomStringWithLength:6 type:36];
            }
            [self configNoteAdd:note];
        }
    }
}


- (void)configNoteAddPreset
{
    NSString *resPath= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"NotePreset.json"];
    NSData *data = [NSData dataWithContentsOfFile:resPath];
    NSArray *notePresets = [NSArray yy_modelArrayWithClass:[NoteModel class] json:data];
    
    for(NoteModel *note in notePresets) {
        //使用modifiedAt标记是否存在修改. 有修改才重新增加预制.
        NSArray<NoteModel*> *notesQuery = [self configNoteGetsWithQuery:@{
                                                                          @"title":note.title,
                                                                          @"modifiedAt":note.modifiedAt,
                                                                          }];
        if(notesQuery.count > 0) {
            NSLog(@"Note preset already added.");
        }
        else {
            NSLog(@"Note preset add.");
            [self configNoteAdd:note];
        }
    }
}


- (void)testBeforeBuild
{
    [self test0];
#if DEBUG
    [self.dbData removeDBName:@"config"];
#endif
}


- (void)testAfterBuild
{
    [self configNoteAddPreset];
#if DEBUG
    [self configNoteAddTest];
    [self configTaskAddTest];
#endif
    [self configSettingSetKey:@"NoteFilterClassification" toValue:@"*" replace:NO];
    [self configSettingSetKey:@"NoteFilterColor" toValue:@"*" replace:NO];
    [self configSettingSetKey:@"NoteTitleFontSizeDefault" toValue:@"18px" replace:NO];
    [self configSettingSetKey:@"NoteParagraphFontSizeDefault" toValue:@"16px" replace:NO];
    [self configSettingSetKey:@"TaskModeDefault" toValue:@"安排" replace:NO];
    
    [self test1];
}

- (void)test0
{

}

- (void)test1
{

}
@end
