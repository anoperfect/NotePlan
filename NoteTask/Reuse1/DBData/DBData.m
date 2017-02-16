//
//  DBData.m
//  Reuse0
//
//  Created by Ben on 16/7/12.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import "DBData.h"
#import "FMDB.h"
#import "NSLogn.h"




#define DISPATCH_ONCE_START     do {static dispatch_once_t once; dispatch_once(&once, ^{
#define DISPATCH_ONCE_FINISH    }); }while(0);

#define ENABLE_LOG_SQLITE   1
#if ENABLE_LOG_SQLITE
#define NSLogSqlite NSLog
#else
#define NSLogSqlite(x...)
#endif



@implementation TableObjectProperty

+ (instancetype)tableObjectPropertyByName:(NSString*)name primaryKeys:(NSArray<NSString*>*)primaryKeys dbNames:(NSArray<NSString*>*)dbNames comment:(NSString*)comment
{
    TableObjectProperty *tableObjectProperty = [[TableObjectProperty alloc] init];
    tableObjectProperty.name = name;
    tableObjectProperty.primaryKeys = primaryKeys;
    tableObjectProperty.dbNames = dbNames;
    tableObjectProperty.comment = comment;
    
    return tableObjectProperty;
}


- (NSString*)columnNameFromKey:(NSString*)key
{
    if([key hasPrefix:@"_"]) {
        key = [key substringFromIndex:1];
    }
    return self.nameAndColumnNameMapping[key]?self.nameAndColumnNameMapping[key]:key;
}

@end



@implementation DBColumnAttribute
- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ description not implemente", [self class]];
}
@end




@implementation DBTableAttribute




+ (DBTableAttribute*)tableAttributeByTableObjectProperty:(TableObjectProperty*)tableObjectProperty
{
    
    DBTableAttribute* tableAttribute = [[DBTableAttribute alloc] init];
    
    tableAttribute.tableName         = tableObjectProperty.tableName.length > 0 ? tableObjectProperty.tableName : tableObjectProperty.name;
    tableAttribute.databaseNames     = tableObjectProperty.dbNames;
    tableAttribute.primaryKeys       = tableObjectProperty.primaryKeys;
    tableAttribute.preset            = nil;// [NSArray arrayWithArray:presetm];
    tableAttribute.comment           = tableObjectProperty.comment;
    
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    
    DBColumnAttribute *columnAttribute;
    YYClassInfo *c = [YYClassInfo classInfoWithClassName:tableObjectProperty.name];
    for(NSString *key in c.ivarInfos.allKeys) {
        YYClassIvarInfo *ivar = c.ivarInfos[key];
        NS0Log(@"key : %@, name : %@, typeEncoding : %@, type : %zd", key, ivar.name, ivar.typeEncoding, ivar.type);
        
        NSString *className = nil;
        switch (ivar.type) {
            case YYEncodingTypeObject:
                if([ivar.typeEncoding hasPrefix:@"@\""] && [ivar.typeEncoding hasSuffix:@"\""]) {
                    className = [ivar.typeEncoding substringWithRange:NSMakeRange(2, ivar.typeEncoding.length - 3)];
                }
                
                if([className isEqualToString:@"NSString"]) {
                    columnAttribute = [[DBColumnAttribute alloc] init];
                    columnAttribute.columnName          = [tableObjectProperty columnNameFromKey:key];
                    columnAttribute.dataType            = DBDataColumnTypeString;
                    columnAttribute.isNeedForInsert     = (NSNotFound != [tableObjectProperty.notNullItemNames indexOfObject:key]);
                    columnAttribute.isAutoIncrement     = (NSNotFound != [tableObjectProperty.autoIncrementItemNames indexOfObject:key]);;
                    columnAttribute.defaultValue        = tableObjectProperty.defaultValue[key];
                    
                    [columns addObject:columnAttribute];
                }
                break;
                
            case YYEncodingTypeBool:
            case YYEncodingTypeInt8:
            case YYEncodingTypeUInt8:
            case YYEncodingTypeInt16:
            case YYEncodingTypeUInt16:
            case YYEncodingTypeInt32:
            case YYEncodingTypeUInt32:
                columnAttribute = [[DBColumnAttribute alloc] init];
                columnAttribute.columnName          = [tableObjectProperty columnNameFromKey:key];
                columnAttribute.dataType            = DBDataColumnTypeNumberInteger;
                columnAttribute.isNeedForInsert     = (NSNotFound != [tableObjectProperty.notNullItemNames indexOfObject:key]);
                columnAttribute.isAutoIncrement     = (NSNotFound != [tableObjectProperty.autoIncrementItemNames indexOfObject:key]);;
                columnAttribute.defaultValue        = tableObjectProperty.defaultValue[key];
                [columns addObject:columnAttribute];
                break;
                
            case YYEncodingTypeInt64:
            case YYEncodingTypeUInt64:
                columnAttribute = [[DBColumnAttribute alloc] init];
                columnAttribute.columnName          = [tableObjectProperty columnNameFromKey:key];
                columnAttribute.dataType            = DBDataColumnTypeNumberLongLong;
                columnAttribute.isNeedForInsert     = (NSNotFound != [tableObjectProperty.notNullItemNames indexOfObject:key]);
                columnAttribute.isAutoIncrement     = (NSNotFound != [tableObjectProperty.autoIncrementItemNames indexOfObject:key]);
                columnAttribute.defaultValue        = tableObjectProperty.defaultValue[key];
                [columns addObject:columnAttribute];
                break;
                
            default:
                break;
        }
    }
    
    tableAttribute.columnAttributes = [NSArray arrayWithArray:columns];
    
#if 0
    for(DBColumnAttribute *column in tableAttribute.columnAttributes) {
        NS0Log(@"mnb : %@", column.columnName);
    }
#endif
    
    return tableAttribute;
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ description not implemente", [self class]];
}
@end


@interface DBData ()

@property (atomic, strong) NSMutableDictionary *dataBases; //name:db


@end

@implementation DBData


- (BOOL)DBDataDetectTableExist:(FMDatabase *)db withTableName:(NSString*)tableName
{
    BOOL isExist = NO;
    FMResultSet *rs = [db executeQuery:@"SELECT COUNT(*) as 'count' FROM sqlite_master WHERE type ='table' AND name = ?", tableName];
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        if(count > 0) {
            isExist = YES;
            break;
        }
    }
    [rs close];
    return isExist;
}


- (DBTableAttribute*)getDBTableAttribute:(NSString*)databaseName withTableName:(NSString*)tableName
{
    NS0Log(@"self.tableAttributess.count : %zd", self.tableAttributes.count);
    
    for(DBTableAttribute *tableAttribute in self.tableAttributes) {
        if([tableAttribute.tableName isEqualToString:tableName]) {
            if([tableAttribute.databaseNames indexOfObject:databaseName] != NSNotFound) {
                NS0Log(@"<%@ : %@> table value found.", databaseName, tableName);
                return tableAttribute;
            }
            else {
                NSLog(@"#error - <%@ : %@> table value not found.", databaseName, tableName);
            }
        }
    }
    
    return nil;
}


- (DBColumnAttribute*)getDBColumnAttributeFromTableAttribute:(DBTableAttribute*)tableAttributes withColumnName:(NSString*)columnName
{
    NSMutableArray *columnAttributeNames = [[NSMutableArray alloc] init];
    for(DBColumnAttribute *columnAttribute in tableAttributes.columnAttributes) {
        [columnAttributeNames addObject:columnAttribute.columnName];
        if([columnAttribute.columnName isEqualToString:columnName]) {
            return columnAttribute;
        }
    }
    
    NSLog(@"#error - <%@> not found in <%@>", columnName, columnAttributeNames);
    
    return nil;
}


-(NSArray*)getColumnNamesFromTableAttribute:(DBTableAttribute*)tableAttributes
{
    NSMutableArray *columnNamesM = [[NSMutableArray alloc] init];
    for(DBColumnAttribute *columnAttribute in tableAttributes.columnAttributes) {
        [columnNamesM addObject:columnAttribute.columnName];
    }
    
    return [NSArray arrayWithArray:columnNamesM];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tableAttributes = [[NSMutableArray alloc] init];
        self.dataBases = [[NSMutableDictionary alloc] init];
        
        DISPATCH_ONCE_START
        //测试阶段一直删除重建数据库.
        BOOL rebuildDB = NO;
        if(rebuildDB) {
            [self removeAll];
        }
        DISPATCH_ONCE_FINISH
    }
    return self;
}


//清除数据库. 需仅适用于开发者环境.
- (void)removeAll
{
    NSString *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *folder = [NSString stringWithFormat:@"%@/%@", documentPath, @"sqlite"];
    NSLog(@"#error - delete database folder.");
    [[NSFileManager defaultManager] removeItemAtPath:folder error:nil];
}


- (void)removeDBName:(NSString*)dbname
{
    NSString *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbFile = [NSString stringWithFormat:@"%@/%@/%@.db", documentPath, @"sqlite", dbname];
    NSLog(@"#error - delete database %@. [%@]", dbname, dbFile);
    [[NSFileManager defaultManager] removeItemAtPath:dbFile error:nil];
}




- (void)DBDataExecuteLog:(NSString*)queryString withArgumentsInArray:(NSArray*)arguments
{
    NSMutableString *s = [NSMutableString stringWithFormat:@"execute[%@] with arguments [%zd][", queryString, arguments.count];
    NSInteger idx = 0;
    for(id obj in arguments) {
        if([obj isKindOfClass:[NSString class]]) {
            [s appendFormat:@"%zd:%@", idx, [NSString truncate:obj length:30 suffix:YES]];
        }
        else if([obj isKindOfClass:[NSData class]]) {
            NSData *data = obj;
            [s appendFormat:@"%zd:data length%zd", idx, data.length];
        }
        else {
            [s appendFormat:@"%zd:%@", idx, obj];
        }
        
        if(idx != arguments.count - 1) {
            [s appendFormat:@", "];
        }
        
        idx ++;
    }
    [s appendFormat:@"]."];
    
    NSLogSqlite(@"%@", s);
}


//增
- (NSInteger)DBDataInsert:(FMDatabase*)db toTable:(DBTableAttribute*)tableAttribute withInfo:(NSDictionary*)infoInsert orReplace:(BOOL)replace orIgnore:(BOOL)ignore
{
    //检查infoInsert.
    //检查columnNames.
    NSArray *columnNames = [infoInsert objectForKey:DBDATA_STRING_COLUMNS];
    BOOL columnNamesChecked = YES;
    if(columnNames && [columnNames isKindOfClass:[NSArray class]]) {
        for(NSString *columnName in columnNames) {
            if([columnName isKindOfClass:[NSString class]]) {
                
            }
            else {
                NSLog(@"#error - columnName (%@) is not string.", columnName);
                columnNamesChecked = NO;
                break;
            }
        }
    }
    else {
        NSLog(@"#error - %@ (%@) is not columnName array.", DBDATA_STRING_COLUMNS, columnNames);
        columnNamesChecked = NO;
    }
    
    if(!columnNamesChecked) {
        NSLog(@"#error - %@ check error. (%@).", DBDATA_STRING_COLUMNS, columnNames);
        return DB_EXECUTE_ERROR_DATA;
    }
    
    //检查values.
    NSArray *values = [infoInsert objectForKey:DBDATA_STRING_VALUES];
    BOOL valuesChecked = YES;
    if(values && [values isKindOfClass:[NSArray class]]) {
        for(NSArray *value in values) {
            if([value isKindOfClass:[NSArray class]]) {
                NSInteger countValue = value.count;
                //＃检查value值个数和属性是否跟对应的ColumnAttribute匹配.
                if(countValue != columnNames.count) {
                    NSLog(@"#error - value count is not fit to %@ count.<%@><%@>", DBDATA_STRING_COLUMNS, value, columnNames);
                    valuesChecked = NO;
                    break;
                }
                
                for(NSInteger index = 0; index < countValue; index ++) {
                    DBColumnAttribute *columnAttribute = [self getDBColumnAttributeFromTableAttribute:tableAttribute withColumnName:columnNames[index]];
                    if(columnAttribute) {
                        if(columnAttribute.dataType == DBDataColumnTypeNumberInteger || columnAttribute.dataType == DBDataColumnTypeNumberLongLong) {
                            if([value[index] isKindOfClass:[NSNumber class]]) {
                                
                            }
                            else {
                                NSLog(@"#error - columnName (%@) value type not checked.", columnNames[index]);
                                valuesChecked = NO;
                                break;
                            }
                        }
                        else if(columnAttribute.dataType == DBDataColumnTypeString) {
                            if([value[index] isKindOfClass:[NSString class]]) {
                                
                            }
                            else {
                                NSLog(@"#error - columnName (%@) value type not checked.", columnNames[index]);
                                valuesChecked = NO;
                                break;
                            }
                        }
                    }
                    else {
                        NSLog(@"#error - columnName (%@) not found.", columnNames[index]);
                        valuesChecked = NO;
                        break;
                    }
                }
                
                if(!valuesChecked) {
                    break;
                }
                
            }
            else {
                NSLog(@"#error - value (%@) is not array.", value);
                valuesChecked = NO;
                break;
                
            }
        }
    }
    else {
        NSLog(@"#error - %@ (%@) is not values array.", DBDATA_STRING_VALUES, values);
        valuesChecked = NO;
    }
    
    if(!valuesChecked) {
        NSLog(@"#error - %@ check error. (%@).", DBDATA_STRING_VALUES, values);
        return DB_EXECUTE_ERROR_DATA;
    }
    
    NS0Log(@"infoInsert checked OK.");
    
    NSMutableArray *infoInsertValuesM = [[NSMutableArray alloc] init];
    
    //获取insert信息值. 组成sql语句.
    //执行.
    NSString *insertOr = @"";
    if(replace) {
        insertOr = @"OR REPLACE";
    }
    else if(ignore) {
        insertOr = @"OR IGNORE";
    }
    
    NSMutableString *insert = [NSMutableString stringWithFormat:@"INSERT %@ INTO %@(%@) VALUES ",
                               insertOr,
                               tableAttribute.tableName,
                               [NSString arrayDescriptionConbine:columnNames seprator:@","]
                               ];
    
    BOOL addJoiner = NO;
    for(NSArray *value in values) {
        //执行语句.
        if(addJoiner) {
            [insert appendString:@", "];
        }
        [insert appendFormat:@"(%@)", [self.class stringPaste:@"?" onTimes:columnNames.count withConnector:@","]];
        
        //?对应的参数.
        [infoInsertValuesM addObjectsFromArray:value];
        
        addJoiner = YES;
    }
    
    [self DBDataExecuteLog:insert withArgumentsInArray:infoInsertValuesM];
    BOOL executeResult = [db executeUpdate:insert withArgumentsInArray:infoInsertValuesM];
    if(executeResult) {
        NS0Log(@"insert table %@ [%zd] OK.", tableAttribute.tableName, values.count);
    }
    else {
        NSLog(@"#error- insert table %@ FAILED (executeUpdate [%@] error).", tableAttribute.tableName, insert);
        return DB_EXECUTE_ERROR_SQL;
    }
    
    return DB_EXECUTE_OK;
}



//增
- (NSInteger)DBDataInsertDBName:(NSString*)databaseName toTable:(NSString*)tableName withInfo:(NSDictionary*)infoInsert
{
    if(![NSThread isMainThread]) {NSLog(@"#error - should excute db in MainThread. <%@:%@>", databaseName, tableName);}
    
    
    FMDatabase *db = [self getDataBaseByName:databaseName];
    if(!db) {
        NSLog(@"#error - not find database <%@>", databaseName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    DBTableAttribute *tableAttribute = [self getDBTableAttribute:databaseName withTableName:tableName];
    if(!tableAttribute) {
        NSLog(@"#error - not find table <%@>", tableName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    return [self DBDataInsert:db toTable:tableAttribute withInfo:infoInsert orReplace:NO orIgnore:NO];
}


- (NSInteger)DBDataInsertDBName:(NSString*)databaseName toTable:(NSString*)tableName withInfo:(NSDictionary*)infoInsert orReplace:(BOOL)replace
{
    if(![NSThread isMainThread]) {NSLog(@"#error - should excute db in MainThread. <%@:%@>", databaseName, tableName);}
    
    
    FMDatabase *db = [self getDataBaseByName:databaseName];
    if(!db) {
        NSLog(@"#error - not find database <%@>", databaseName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    DBTableAttribute *tableAttribute = [self getDBTableAttribute:databaseName withTableName:tableName];
    if(!tableAttribute) {
        NSLog(@"#error - not find table <%@>", tableName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    return [self DBDataInsert:db toTable:tableAttribute withInfo:infoInsert orReplace:YES orIgnore:NO];
}


- (NSInteger)DBDataInsertDBName:(NSString*)databaseName toTable:(NSString*)tableName withInfo:(NSDictionary*)infoInsert orIgnore:(BOOL)ignore
{
    if(![NSThread isMainThread]) {NSLog(@"#error - should excute db in MainThread. <%@:%@>", databaseName, tableName);}
    
    
    FMDatabase *db = [self getDataBaseByName:databaseName];
    if(!db) {
        NSLog(@"#error - not find database <%@>", databaseName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    DBTableAttribute *tableAttribute = [self getDBTableAttribute:databaseName withTableName:tableName];
    if(!tableAttribute) {
        NSLog(@"#error - not find database <%@>", databaseName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    return [self DBDataInsert:db toTable:tableAttribute withInfo:infoInsert orReplace:NO orIgnore:ignore];
}








//删
- (NSInteger)DBDataDelete:(FMDatabase*)db toTable:(DBTableAttribute*)tableAttribute withQuery:(NSDictionary*)infoQuery
{
    
    BOOL executeResult ;
    
#if 0
    if(!infoQuery) {
        deletem = [NSMutableString stringWithFormat:@"DELETE FROM %@", tableAttribute.tableName];
        executeResult = [db executeUpdate:[NSString stringWithString:deletem]];
    }
    else {
        NSArray *infoDeleteKeys = infoQuery.allKeys;
        NSArray *infoDeleteValues = infoQuery.allValues;
        //只支持一个条件的简单query语句.
        deletem = [NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?", tableAttribute.tableName, infoDeleteKeys[0]];
        NSInteger count = infoDeleteKeys.count;
        for(NSInteger index = 1; index < count; index ++) {
            [deletem appendFormat:@" and %@ = ?", infoDeleteKeys[index]];
        }
        executeResult = [db executeUpdate:[NSString stringWithString:deletem] withArgumentsInArray:infoDeleteValues];
        
        NSLog(@"%@", deletem);
        NSLog(@"%@", infoDeleteValues);
    }
#endif
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSString *queryString = [self DBDataGenerateQueryString:infoQuery andArgumentsInArray:arguments];
    NSString *deleteString = [NSString stringWithFormat:@"DELETE FROM %@ %@", tableAttribute.tableName, queryString];
    
    [self DBDataExecuteLog:deleteString withArgumentsInArray:arguments];
    executeResult = [db executeUpdate:deleteString withArgumentsInArray:arguments];
    
    if(executeResult) {
        NSLog(@"delete table %@ OK.", tableAttribute.tableName);
    }
    else {
        NSLog(@"error --- delete table %@ FAILED (executeUpdate [%@] error).", tableAttribute.tableName, deleteString);
        return DB_EXECUTE_ERROR_SQL;
    }
    
    return DB_EXECUTE_OK;
}


//删
- (NSInteger)DBDataDeleteDBName:(NSString*)databaseName toTable:(NSString*)tableName withQuery:(NSDictionary*)infoQuery
{
    if(![NSThread isMainThread]) {NSLog(@"#error - should excute db in MainThread. <%@:%@>", databaseName, tableName);}
    FMDatabase *db = [self getDataBaseByName:databaseName];
    if(!db) {
        NSLog(@"#error - not find database <%@>", databaseName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    DBTableAttribute *tableAttribute = [self getDBTableAttribute:databaseName withTableName:tableName];
    if(!tableAttribute) {
        NSLog(@"#error - not find database <%@>", databaseName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    return [self DBDataDelete:db toTable:tableAttribute withQuery:infoQuery];
}


- (NSString*)DBDataGenerateQueryString:(NSDictionary*)infoQuery andArgumentsInArray:(NSMutableArray*)argumentsM
{
    NSMutableString *strm ;
    
    if(0 == infoQuery.count) {
        strm = [NSMutableString stringWithString:@" "];
    }
    else {
        NSArray *infoQueryKeys = infoQuery.allKeys;
        NSArray *infoQueryValues = infoQuery.allValues;
        
        strm = [NSMutableString stringWithString:@" WHERE"];
        
        for(NSInteger index = 0; index < infoQueryKeys.count; index++) {
            if(index > 0) {
                [strm appendString:@" and"];
            }
            
            if([infoQueryValues[index] isKindOfClass:[NSArray class]]) {
                NSArray *columnValues = infoQueryValues[index];
                [strm appendFormat:@" %@ IN (%@)",
                 infoQueryKeys[index],
                 [self.class stringPaste:@"?" onTimes:columnValues.count withConnector:@","]];
                [argumentsM addObjectsFromArray:columnValues];
            }
            else {
                //
                [strm appendFormat:@" %@ = ?", infoQueryKeys[index]];
                [argumentsM addObject:infoQueryValues[index]];
            }
        }
    }
    
    return [NSString stringWithString:strm];
}






//查

/*
 columnNames : 获取的column名字. 为nil时则查询时使用SELECT *.
 infoQuery : 格式为.
 {@"column1string":"value1string", @"column2number":@10086}
 或者 {@"column1string":"value1string", @"column2number":@10086, @"column3string":["value1string","value1string"]}
 可为nil
 infoLimit : 支持 DBDATA_STRING_ORDER:"ORDER BY ... DESC"
 */
- (NSDictionary*)DBDataQuery:(FMDatabase*)db
                     toTable:(DBTableAttribute*)tableAttribute
                 columnNames:(NSArray*)columnNames
                   withQuery:(NSDictionary*)infoQuery
                   withLimit:(NSDictionary*)infoLimit
{
    NSLogSqlite(@"DBDataQuery : table:%@, columnNames:%@, infoQuery:%@, infoLimit:%@",
                tableAttribute.tableName,
                [NSString arrayDescriptionConbine:columnNames seprator:@","],
                infoQuery,
                infoLimit
                );
    
    
    //获取表信息.
//    NSLog(@"table :%@ , name:%@, %zd.", tableAttribute, tableAttribute.tableName, tableAttribute.primaryKeys.count);
    NSMutableString *querym ;
    NSMutableDictionary *queryResultm = [[NSMutableDictionary alloc] init];
    NSMutableArray *queryColumnsNamesM = [[NSMutableArray alloc] init];
    
    if(!columnNames) {
        [queryColumnsNamesM addObjectsFromArray:[self getColumnNamesFromTableAttribute:tableAttribute]];
        //tableAttribute.primaryKey.count==0?@",row":@""用于在主键缺省的时候使用隐藏主键rowid.
        if(tableAttribute.primaryKeys.count==0) {
            columnNames = @[@"*, rowid"];
            [queryColumnsNamesM addObject:@"rowid"];
        }
        else {
            columnNames = @[@"*"];
        }
    }
    else {
        [queryColumnsNamesM addObjectsFromArray:columnNames];
    }
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSString *queryString = [self DBDataGenerateQueryString:infoQuery andArgumentsInArray:arguments];
    
    querym = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@ %@",
              [NSString arrayDescriptionConbine:columnNames seprator:@","],
              tableAttribute.tableName,
              queryString];
    
    if([infoLimit objectForKey:DBDATA_STRING_ORDER]) {
        [querym appendFormat:@" %@", [infoLimit objectForKey:DBDATA_STRING_ORDER]];
    }
    
    [self DBDataExecuteLog:querym withArgumentsInArray:arguments];
    FMResultSet *rs = [db executeQuery:[NSString stringWithString:querym] withArgumentsInArray:arguments];
    
    for(NSString *columnName in queryColumnsNamesM) {
        [queryResultm setObject:[[NSMutableArray alloc] init] forKey:columnName];
    }
    
    NSInteger rsRows = 0;
    BOOL parseOK = YES;
    NS0Log(@"%@", rs.columnNameToIndexMap);
    while ([rs next]) {
        BOOL parse1OK = YES;
        for(NSString *columnName in queryColumnsNamesM) {
            if(!parse1OK) {
                break;
            }
            
            NSMutableArray *columnValues = [queryResultm objectForKey:columnName];
            if([columnName isEqualToString:@"rowid"]) {
                [columnValues addObject:[NSNumber numberWithInteger:[rs intForColumn:@"rowid"]]];
            }
            else {
                DBColumnAttribute *columnAttribute = [self getDBColumnAttributeFromTableAttribute:tableAttribute withColumnName:columnName];
                if(!columnAttribute) {
                    NSLog(@"#error - [table : %@] can not find column (%@).",  tableAttribute.tableName, columnName);
                    return nil;
                }
                
                NSNumber *objNumber = nil;
                NSString *objString = nil;
                NSData *objData = nil;
                
                switch (columnAttribute.dataType) {
                    case DBDataColumnTypeNumberInteger:
                    case DBDataColumnTypeNumberLongLong:
                        objNumber = [rs objectForColumnName:columnAttribute.columnName];
                        if([objNumber isKindOfClass:[NSNumber class]]) {
                            [columnValues addObject:objNumber];
                        }
                        else {
                            NSLog(@"#error - rs column %@ parse error.", columnAttribute.columnName);
                            [columnValues addObject:@0];
                        }
                        break;
                        
                    case DBDataColumnTypeString:
                        objString = [rs objectForColumnName:columnAttribute.columnName];
                        if([objString isKindOfClass:[NSString class]]) {
                            [columnValues addObject:objString];
                        }
                        else if([objString isKindOfClass:[NSNull class]]){
                            if([columnAttribute.defaultValue isKindOfClass:[NSString class]] && [columnAttribute.defaultValue length] > 0 ) {
                                [columnValues addObject:columnAttribute.defaultValue];
                            }
                            else {
                                [columnValues addObject:@""];
                            }
                        }
                        else if([objString isKindOfClass:[NSNumber class]]) {
                            [columnValues addObject:[NSString stringWithFormat:@"%@", objString]];
                        }
                        else{
                            NSLog(@"#error - rs column [%@] parse failed <%@> <class : %@>.", columnAttribute.columnName, objString, [objString class]);
                            [columnValues addObject:@"NAN-parseerror"];
                        }
                        break;
                        
                    case DBDataColumnTypeData:
                        objData = [rs objectForColumnName:columnAttribute.columnName];
                        if([objData isKindOfClass:[NSData class]]) {
                            [columnValues addObject:objData];
                        }
                        else if([objData isKindOfClass:[NSNull class]]){
                            [columnValues addObject:objData];
                        }
                        else {
                            NSLog(@"#error - rs column %@ parse error.", columnAttribute.columnName);
                            [columnValues addObject:[NSNull null]];
                        }
                        break;
                        
                    default:
                        NSLog(@"#error - not expected default value(%zd)", columnAttribute.dataType);
                        parse1OK = NO;
                        break;
                }
            }
        }
        
        if(!parse1OK) {
            parseOK = NO;
            break;
        }
        
        rsRows ++;
    }
    
    [rs close];
    
    if(!parseOK) {
        NSLog(@"#error - column value parse FAILED.");
        return nil;
    }
    else if(rsRows == 0) {
        NSLog(@"query result NONE.");
        return nil;
    }
    
    NSInteger countValues = 0;
    
    for(NSString *columnName in queryColumnsNamesM) {
        NSMutableArray *columnValues = [queryResultm objectForKey:columnName];
        [queryResultm setObject:[NSArray arrayWithArray:columnValues] forKey:columnName];
        
        if(countValues == 0) {
            countValues = columnValues.count;
        }
        else {
            if(countValues != columnValues.count) {
                NSLog(@"#error - count of values not fit.");
                return nil;
            }
        }
    }
    
    //查询结果为0时, 返回nil.
    NSLog(@"query result count : %zd", countValues);
    if(countValues == 0) {
        NSLog(@"query result count 0, return nil");
        return nil;
    }
    
    return [NSDictionary dictionaryWithDictionary:queryResultm];
}


//查
- (NSDictionary*)DBDataQueryDBName:(NSString*)databaseName
                           toTable:(NSString*)tableName
                       columnNames:(NSArray*)columnNames
                         withQuery:(NSDictionary*)infoQuery
                         withLimit:(NSDictionary*)infoLimit
{
    if(![NSThread isMainThread]) {NSLog(@"#error - should excute db in MainThread. <%@:%@>", databaseName, tableName);}
    
    FMDatabase *db = [self getDataBaseByName:databaseName];
    if(!db) {
        NSLog(@"#error - not find database <%@ : %@>", databaseName, tableName);
        return nil;
    }
    
    DBTableAttribute *tableAttribute = [self getDBTableAttribute:databaseName withTableName:tableName];
    if(!tableAttribute) {
        NSLog(@"#error - not find table <%@ : %@>", databaseName, tableName);
        return nil;
    }
    
    return [self DBDataQuery:db toTable:tableAttribute columnNames:columnNames withQuery:infoQuery withLimit:infoLimit];
}


//改. 暂时不实现.
- (NSInteger)DBDataUpdate:(FMDatabase*)db toTable:(DBTableAttribute*)tableAttribute withInfoUpdate:(NSDictionary*)infoUpdate withInfoQuery:(NSDictionary*)infoQuery
{
    NSMutableString *updatem = nil;
    BOOL retFMDB;
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    
    NSArray *infoUpdateKeys = infoUpdate.allKeys;
    NSArray *infoUpdateValues = infoUpdate.allValues;
    
    updatem = [NSMutableString stringWithFormat:@"UPDATE %@ set ", tableAttribute.tableName];
    
    for(NSInteger index = 0; index < infoUpdateKeys.count; index++) {
        if(index > 0) {
            [updatem appendString:@", "];
        }
        
        [updatem appendFormat:@"%@ = ? ", infoUpdateKeys[index]];
        [arguments addObject:infoUpdateValues[index]];
    }
    
    NSString *queryString = [self DBDataGenerateQueryString:infoQuery andArgumentsInArray:arguments];
    [updatem appendString:queryString];
    
    [self DBDataExecuteLog:updatem withArgumentsInArray:arguments];
    retFMDB = [db executeUpdate:updatem withArgumentsInArray:arguments];
    if(retFMDB) {
        
    }
    else {
        NSLog(@"#error - DBDataUpdate failed.");
        return DB_EXECUTE_ERROR_DATA;
    }
    
    return DB_EXECUTE_OK;
}


- (NSInteger)DBDataUpdateDBName:(NSString*)databaseName toTable:(NSString*)tableName withInfoUpdate:(NSDictionary*)infoUpdate withInfoQuery:(NSDictionary*)infoQuery
{
    if(![NSThread isMainThread]) {NSLog(@"#error - should excute db in MainThread. <%@:%@>", databaseName, tableName);}
    FMDatabase *db = [self getDataBaseByName:databaseName];
    if(!db) {
        NSLog(@"#error - not find database <%@ : %@>", databaseName, tableName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    DBTableAttribute *tableAttribute = [self getDBTableAttribute:databaseName withTableName:tableName];
    if(!tableAttribute) {
        NSLog(@"#error - not find table <%@ : %@>", databaseName, tableName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    return [self DBDataUpdate:db toTable:tableAttribute withInfoUpdate:infoUpdate withInfoQuery:infoQuery];
}


//改. 暂时不实现.
- (NSInteger)DBDataUpdates:(FMDatabase*)db toTable:(DBTableAttribute*)tableAttribute withInfosUpdate:(NSArray<NSDictionary*> *)infosUpdate withInfosQuery:(NSArray<NSDictionary*> *)infosQuery
{
    NSInteger ret = DB_EXECUTE_OK;
    NSMutableString *updatem = nil;
    BOOL retFMDB;
    
    [db beginTransaction];
    
    NSInteger count = infosUpdate.count;
    for(NSInteger index = 0; index < count; index ++) {
        NSDictionary *infoUpdate = infosUpdate[index];
        NSDictionary *infoQuery = infosQuery[index];
        if(!([infoUpdate isKindOfClass:[NSDictionary class]] && [infoQuery isKindOfClass:[NSDictionary class]])) {
            NSLog(@"#error - infosUpdate / infosQuery argument error.");
            continue;
        }
        
        NSMutableArray *arguments = [[NSMutableArray alloc] init];
        
        NSArray *infoUpdateKeys = infoUpdate.allKeys;
        NSArray *infoUpdateValues = infoUpdate.allValues;
        
        updatem = [NSMutableString stringWithFormat:@"UPDATE %@ set ", tableAttribute.tableName];
        
        for(NSInteger index = 0; index < infoUpdateKeys.count; index++) {
            if(index > 0) {
                [updatem appendString:@", "];
            }
            
            [updatem appendFormat:@"%@ = ? ", infoUpdateKeys[index]];
            [arguments addObject:infoUpdateValues[index]];
        }
        
        NSString *queryString = [self DBDataGenerateQueryString:infoQuery andArgumentsInArray:arguments];
        [updatem appendString:queryString];
        
        [self DBDataExecuteLog:updatem withArgumentsInArray:arguments];
        retFMDB = [db executeUpdate:updatem withArgumentsInArray:arguments];
        if(retFMDB) {
            
        }
        else {
            NSLog(@"#error - DBDataUpdate failed.");
            ret = DB_EXECUTE_ERROR_DATA;
        }
    }
    
    [db commit];
    
    return ret;
}


//使用事物提供批量改.
- (NSInteger)DBDataUpdatesDBName:(NSString*)databaseName toTable:(NSString*)tableName withInfosUpdate:(NSArray<NSDictionary*> *)infosUpdate withInfosQuery:(NSArray<NSDictionary*> *)infosQuery;
{
    if(![NSThread isMainThread]) {NSLog(@"#error - should excute db in MainThread. <%@:%@>", databaseName, tableName);}
    FMDatabase *db = [self getDataBaseByName:databaseName];
    if(!db) {
        NSLog(@"#error - not find database <%@ : %@>", databaseName, tableName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    DBTableAttribute *tableAttribute = [self getDBTableAttribute:databaseName withTableName:tableName];
    if(!tableAttribute) {
        NSLog(@"#error - not find table <%@ : %@>", databaseName, tableName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    return [self DBDataUpdates:db toTable:tableAttribute withInfosUpdate:infosUpdate withInfosQuery:infosQuery];
}




- (NSInteger)DBDataUpdateAdd1:(FMDatabase*)db toTable:(DBTableAttribute*)tableAttribute withColumnName:(NSString*)columnName withInfoQuery:(NSDictionary*)infoQuery
{
    NSMutableString *updatem = nil;
    BOOL retFMDB;
    
    updatem = [NSMutableString stringWithFormat:@"UPDATE %@ SET %@ = %@+1 ", tableAttribute.tableName, columnName, columnName];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSString *queryString = [self DBDataGenerateQueryString:infoQuery andArgumentsInArray:arguments];
    [updatem appendString:queryString];
    
    [self DBDataExecuteLog:updatem withArgumentsInArray:arguments];
    retFMDB = [db executeUpdate:updatem withArgumentsInArray:arguments];
    if(retFMDB) {
        
    }
    else {
        NSLog(@"#error - DBDataUpdateAdd1 failed.");
        return DB_EXECUTE_ERROR_DATA;
    }
    
    return DB_EXECUTE_OK;
}


- (NSInteger)DBDataUpdateAdd1DBName:(NSString*)databaseName toTable:(NSString*)tableName withColumnName:(NSString*)columnName withInfoQuery:(NSDictionary*)infoQuery
{
    FMDatabase *db = [self getDataBaseByName:databaseName];
    if(!db) {
        NSLog(@"#error - not find database <%@ : %@>", databaseName, tableName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    DBTableAttribute *tableAttribute = [self getDBTableAttribute:databaseName withTableName:tableName];
    if(!tableAttribute) {
        NSLog(@"#error - not find table <%@ : %@>", databaseName, tableName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    return [self DBDataUpdateAdd1:db toTable:tableAttribute withColumnName:columnName withInfoQuery:infoQuery];
}




//删. 暂时不实现.






- (NSString*)columnTypeToString:(DBDataColumnType)type
{
    switch (type) {
        case DBDataColumnTypeNumberInteger:
            return @"integer";
            break;
            
        case DBDataColumnTypeNumberLongLong:
            return @"longlong";
            break;
            
        case DBDataColumnTypeString:
            return @"var";
            break;
            
        case DBDataColumnTypeData:
            return @"blob";
            break;
            
        default:
            return @"var";
            break;
    }
    
    return @"var";
}


- (DBDataColumnType)columnTypeFromString:(NSString*)typeString
{
    DBDataColumnType type = NSNotFound;
    
    if([typeString isEqualToString:@"integer"]) {
        type = DBDataColumnTypeNumberInteger;
    }
    else if([typeString isEqualToString:@"longlong"]) {
        type = DBDataColumnTypeNumberLongLong;
    }
    else if([typeString isEqualToString:@"string"]) {
        type = DBDataColumnTypeString;
    }
    else {
        type = DBDataColumnTypeData;
    }
    
    return type;
}


- (NSString*)columnDefaultValueToString:(DBColumnAttribute*)column
{
    NSString *defaultString = @"";
    if(column.defaultValue) {
        switch (column.dataType) {
            case DBDataColumnTypeNumberInteger:
                defaultString = @"DEFAULT (0)";
                break;
                
            case DBDataColumnTypeNumberLongLong:
                defaultString = @"DEFAULT (0)";
                break;
                
            case DBDataColumnTypeString:
                defaultString = [NSString stringWithFormat:@"DEFAULT (\'%@\')", column.defaultValue];
                break;
                
            case DBDataColumnTypeData:
                break;
                
            default:
                break;
        }
        
    }
    
    return defaultString;
}



- (NSString*)generateCreateSQLWithTableValue:(DBTableAttribute*)tableAttribute
{
    NSMutableString *strm = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(", tableAttribute.tableName];
    NSInteger count = tableAttribute.columnAttributes.count;
    for(NSInteger index = 0; index < count ; index ++) {
        if(index > 0) {
            [strm appendFormat:@", "];
        }
        
        DBColumnAttribute *columnAttribute = tableAttribute.columnAttributes[index];
        [strm appendFormat:@"%@ %@", columnAttribute.columnName, [self columnTypeToString:columnAttribute.dataType]];
        
        if(index == (count - 1)) {
            [strm appendFormat:@")"];
        }
    }
    
    return [NSString stringWithString:strm];
}


- (void)DBDataAddTableAttributeFromTableObjectProperty:(TableObjectProperty*)tableObjectProperty
{
    DBTableAttribute *tableAttribute = [DBTableAttribute tableAttributeByTableObjectProperty:tableObjectProperty];
    [self.tableAttributes addObject:tableAttribute];
}



- (void)DBDataAddTableAttributeByJsonData:(NSData*)data
{
    NS0Log(@"------\n%@\n-------", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSDictionary *dict;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    //NSLog(@"obj : %@", obj);
    
    if(!obj || ![obj isKindOfClass:[NSDictionary class]]) {
        NSLog(@"#error :");sleep(100);
        return;
    }
    
    NSLog(@"version : %@", [obj objectForKey:@"version"]);
    
    obj = [obj objectForKey:@"tables"];
    if(!obj || ![obj isKindOfClass:[NSArray class]]) {
        NSLog(@"#error :");sleep(100);
        return;
    }
    
    NSArray *arrayTable = obj;
    for(obj in arrayTable) {
        if(!obj || ![obj isKindOfClass:[NSDictionary class]]) {
            NSLog(@"#error :");sleep(100);
            return;
        }
        
        dict = obj;
        
        DBTableAttribute *tableAttribute = [self DBTableAttributeFromDict:dict];
        if(!tableAttribute) {
            NSLog(@"#error :");sleep(100);
        }
        
        NS0Log(@"table : %@, tableName : %@, databaseNames : %@",tableAttribute, tableAttribute.tableName, tableAttribute.databaseNames);
        [self.tableAttributes addObject:tableAttribute];
        
        //detect , checked / add / update .
        [self buildTable:tableAttribute];
    }
}


- (void)buildTable
{
    for(DBTableAttribute *tableAttribute in self.tableAttributes) {
        //detect , checked / add / update .
        [self buildTable:tableAttribute];
    }
}


- (DBTableAttribute*)DBTableAttributeFromDict:(NSDictionary*)dict
{
    DBTableAttribute *tableAttribute = [[DBTableAttribute alloc] init];
    
    NSString *tableName         = [dict objectForKey:@"tableName"];
    NSArray *databaseNames      = [dict objectForKey:@"databaseNames"];
    NSArray *columnAttributes   = [dict objectForKey:@"columnAttributes"];
    NSArray *primaryKeys        = [dict objectForKey:@"primaryKeys"];
    NSArray *preset             = [dict objectForKey:@"preset"];
    NSString *comment           = [dict objectForKey:@"comment"];
    
    if([tableName           isKindOfClass:[NSString class]] &&
       [databaseNames       isKindOfClass:[NSArray class]]  &&
       [columnAttributes    isKindOfClass:[NSArray class]]  &&
       [primaryKeys         isKindOfClass:[NSArray class]]  &&
       [preset              isKindOfClass:[NSArray class]]  &&
       [comment             isKindOfClass:[NSString class]]) {
        NS0Log(@"checked");
        
        NSMutableArray *columnAttributesM = [[NSMutableArray alloc] init];
        for (NSDictionary *dictColumnAttribute in columnAttributes) {
            if(![dictColumnAttribute isKindOfClass:[NSDictionary class]]) {
                NSLog(@"#error-");sleep(100);
                return nil;
            }
            
            DBColumnAttribute *columnAttribute = [self DBColumnAttributeFromDict:dictColumnAttribute];
            if(!columnAttribute) {
                NSLog(@"#error-");sleep(100);
                return nil;
            }
            
            [columnAttributesM addObject:columnAttribute];
        }
        
        tableAttribute.tableName         = tableName;
        tableAttribute.databaseNames     = databaseNames;
        tableAttribute.columnAttributes  = [NSArray arrayWithArray:columnAttributesM];
        tableAttribute.primaryKeys       = primaryKeys;
        tableAttribute.preset            = preset;// [NSArray arrayWithArray:presetm];
        tableAttribute.comment           = comment;
    }
    else {
        NSLog(@"#error- %@[%d %d %d %d %d %d]",
              dict,
              [tableName           isKindOfClass:[NSString class]],
              [databaseNames       isKindOfClass:[NSArray class]],
              [columnAttributes    isKindOfClass:[NSArray class]],
              [primaryKeys         isKindOfClass:[NSArray class]],
              [preset              isKindOfClass:[NSArray class]],
              [comment             isKindOfClass:[NSString class]]
              
              
              
              );
        sleep(100);
        return nil;
    }
    
    return tableAttribute;
}


- (DBColumnAttribute*)DBColumnAttributeFromDict:(NSDictionary*)dict
{
    DBColumnAttribute *columnAttribute = [[DBColumnAttribute alloc] init];
    
    NSString    *columnName             = [dict objectForKey:@"columnName"];
    NSString    *dataTypeString         = [dict objectForKey:@"dataType"];
    NSNumber    *isNeedForInsertNumber  = [dict objectForKey:@"isNeedForInsert"];
    NSNumber    *isAutoIncrementNumber  = [dict objectForKey:@"isAutoIncrement"];
    id          defaultValue            = [dict objectForKey:@"defaultValue"];
    
    //NSLog(@"%@", dict);
    
    //if([columnName isKindOfClass:[NSString class]]){NSLog(@"checked");}else {NSLog(@"#error-");}
    //if(  [dataTypeString isKindOfClass:[NSString class]]){NSLog(@"checked");}else {NSLog(@"#error-");}
    //if(  [isNeedForInsertNumber isKindOfClass:[NSNumber class]]){NSLog(@"checked");}else {NSLog(@"#error-");}
    //if(  [isAutoIncrementNumber isKindOfClass:[NSNumber class]]){NSLog(@"checked");}else {NSLog(@"#error-");}
    //if(   ([defaultValue isKindOfClass:[NSString class]] || [defaultValue isKindOfClass:[NSNumber class]])){NSLog(@"checked");}else {NSLog(@"#error-");}
    
    if([columnName isKindOfClass:[NSString class]] &&
       [dataTypeString isKindOfClass:[NSString class]] &&
       [isNeedForInsertNumber isKindOfClass:[NSNumber class]] &&
       [isAutoIncrementNumber isKindOfClass:[NSNumber class]] ){
        
        columnAttribute.columnName          = columnName;
        columnAttribute.dataType            = [self columnTypeFromString:dataTypeString];
        columnAttribute.isNeedForInsert     = [isNeedForInsertNumber boolValue];
        columnAttribute.isAutoIncrement     = [isAutoIncrementNumber boolValue];
        columnAttribute.defaultValue        = defaultValue;
    }
    else {
        NSLog(@"#error- column value invalid.");
        sleep(100);
        return nil;
    }
    
    return columnAttribute;
}


- (id)getDataBaseByName:(NSString*)databaseName
{
    NSString *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *folder = [NSString stringWithFormat:@"%@/%@", documentPath, @"sqlite"];
    
    NS0Log(@"[%@] getDataBaseByName. dict = %@", databaseName, self.dataBases);
    
    FMDatabase *db = [self.dataBases objectForKey:databaseName];
    if(!db) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *dbName = [NSString stringWithFormat:@"%@.db", databaseName];
        
        NSString *pathConfigDB = [NSString stringWithFormat:@"%@/%@", folder, dbName];
        NSLog(@"[%@] create %@ ", databaseName, pathConfigDB);
        db = [FMDatabase databaseWithPath:pathConfigDB];
        
        if(db) {
            [db open];
            NSLog(@"[%@] add to global FMDatabase dict.", databaseName);
            [self.dataBases setObject:db forKey:databaseName];
        }
    }
    
    return db;
}


- (void)buildTable:(DBTableAttribute*)tableAttribute
{
    NSString *databaseName;
    for(databaseName in tableAttribute.databaseNames) {
        NSLog(@"[%@ : %@] build tableAttribute.", databaseName, tableAttribute.tableName);
        
        FMDatabase *db = [self getDataBaseByName:databaseName];
        if(!db) {
            NSLog(@"#error - ");
            sleep(100);
            continue;
        }
        
        //判断表是否存在.
        if([self DBDataDetectTableExist:db withTableName:tableAttribute.tableName]) {
            NSLog(@"[%@ : %@] table exist.", databaseName, tableAttribute.tableName);
        }
        else {
            
            //        NSMutableString *createStringm = [NSMutableString stringWithFormat:@"create table if not exists %@(", tableAttribute.tableName];
            NSMutableString *createStringm = [NSMutableString stringWithFormat:@"create table %@(", tableAttribute.tableName];
            NSInteger index = 0;
            for(DBColumnAttribute *columnAttribute in tableAttribute.columnAttributes) {
                if(index > 0) {
                    [createStringm appendString:@", "];
                }
                
                //            [createStringm appendFormat:@"%@ %@ %@", columnAttribute.columnName, [self columnTypeToString:columnAttribute.dataType], columnAttribute.isAutoIncrement?@"autoincrement":@""];
                
                NSString *defaultString = [self columnDefaultValueToString:columnAttribute];
                
                [createStringm appendFormat:@"%@ %@ %@ %@"
                 , columnAttribute.columnName
                 , [self columnTypeToString:columnAttribute.dataType]
                 , columnAttribute.isAutoIncrement?@"":@""
                 , defaultString];
                
                index ++;
            }
            
            if(tableAttribute.primaryKeys.count > 0) {
                [createStringm appendFormat:@", PRIMARY KEY(\"%@\")", [NSString arrayDescriptionConbine:tableAttribute.primaryKeys seprator:@"\", \""]];
            }
            
            [createStringm appendString:@")"];
            
            //NSString *createHostsTable = @"create table if not exists hosts(id integer primary key autoincrement, hostname varchar, host varchar, imageHost varchar)";
            BOOL executeResult = [db executeUpdate:[NSString stringWithString:createStringm]];
            if(executeResult) {
                NSLog(@"[%@ : %@] create table OK.", databaseName, tableAttribute.tableName);
            }
            else {
                NSLog(@"#error- [%@ : %@] create table FAILED. <%@>",databaseName, tableAttribute.tableName, createStringm);
                sleep(100);
                continue;
            }
            
            //添加预置数据.
            for(NSDictionary *dict in tableAttribute.preset) {
                NSString *databaseNamePreset = [dict objectForKey:@"databaseName"];
                if(!([databaseNamePreset isEqualToString:databaseName] || [databaseNamePreset isEqualToString:@"*"])) {
                    continue;
                }
                
                //检测. values 的类型为NSArray, array中的成员为NSDictionary.
                BOOL dataChecked = YES;
                NSDictionary *contents = [dict objectForKey:@"content"];
                if([contents isKindOfClass:[NSDictionary class]]) {
                    
                }
                else {
                    dataChecked = NO;
                }
                
                if(!dataChecked) {
                    NSLog(@"#error- [%@ : %@] create table preset FAILED.",databaseNamePreset, tableAttribute.tableName);
                    sleep(100);
                    continue;
                }
                
                NSLog(@"[%@ : %@] insert presets.", databaseName, tableAttribute.tableName);
                
                //根据primary判断是否重复.
                NSInteger retInsert = [self DBDataInsert:db toTable:tableAttribute withInfo:contents orReplace:YES orIgnore:NO];
                if(DB_EXECUTE_OK != retInsert) {
                    NSLog(@"#error- [%@ : %@] insert preset FAILED. <%@>", databaseName, tableAttribute.tableName, contents);
                }
                else {
                    NSLog(@"[%@ : %@] insert presets OK.", databaseName, tableAttribute.tableName);
                }
                
            }
        }
        
        NS0Log(@"---table : %@", tableAttribute.tableName);
        FMResultSet *tableCreateResult = [db getTableSchema:tableAttribute.tableName];
        int count = [tableCreateResult columnCount];
        NSInteger row = 0;
        while (tableCreateResult.next) {
            for(int idx = 0; idx < count; idx ++) {
                NS0Log(@"%zd------%@ : %@", row, [tableCreateResult columnNameForIndex:idx], [tableCreateResult objectForColumnIndex:idx]);
            }
            
            row ++;
            
        }
    }
}


- (NSArray<NSDictionary*>*)queryResultDictionaryToArray:(NSDictionary*)queryResult
{
    if(!queryResult || queryResult.count == 0) {
        return nil;
    }
    
    NSInteger count = [self DBDataCheckRowsInDictionary:queryResult];
    if(count == 0 || count == NSNotFound) {
        return nil;
    }
    
    NSMutableArray *queryResultArrayM = [[NSMutableArray alloc] init];
    NSArray *allkeys = queryResult.allKeys;
    for(NSInteger index = 0; index < count; index ++) {
        NSMutableDictionary *queryResult1 = [[NSMutableDictionary alloc] init];
        for(NSString *key in allkeys) {
            queryResult1[key] = queryResult[key][index];
        }
        
        [queryResultArrayM addObject:[NSDictionary dictionaryWithDictionary:queryResult1]];
    }
    
    return [NSArray arrayWithArray:queryResultArrayM];
}


//对Insert, Update的输入数据, Query的输出数据进行检测. 返回行数. 执行时检测所有key对应的value array的个数相同.
//错误时返回 NSNotFound.
- (NSInteger)DBDataCheckRowsInDictionary:(NSDictionary*)dict
{
    NSInteger rows = 0;
    
    NSArray *columnNames = dict.allKeys;
    for(NSString *columnName in columnNames) {
        if(![columnName isKindOfClass:[NSString class]]) {
            NSLog(@"#error - columns should be NSString.");
            rows = NSNotFound;
            break;
        }
        
        NSArray *values = [dict objectForKey:columnName];
        if(values && [values isKindOfClass:[NSArray class]] && (0 == rows || values.count == rows )) {
            rows = values.count;
        }
        else {
            NSLog(@"#error - rows not fit.");
            rows = NSNotFound;
            break;
        }
    }
    
    return rows;
}


- (BOOL)DBDataCheckCount:(NSInteger)count OfArrayObjects:(id)obj, ...
{
    BOOL result = YES;
    
    NSArray *a = obj;
    
    id argment = nil;
    
    NSInteger idx = 0;
    if([a isKindOfClass:[NSArray class]] && a.count == count) {
        idx = 1;
        
        va_list params;
        va_start(params, obj);
        
        
        
        
        while (nil != (argment=va_arg(params, id))) {
            if([a isKindOfClass:[NSArray class]] && a.count == count) {
                idx ++;
            }
            else {
                NSLog(@"#error : idx %zd invalid", idx);
                result = NO;
            }
        }
        
        va_end(params);
    }
    else {
        NSLog(@"#error : idx %zd invalid", idx);
        result = NO;
    }
    
    return result;
}



- (BOOL)DBDataCheckCountOfArray:(NSArray*)arrays withCount:(NSInteger)count
{
    BOOL result = YES;
    
    for(NSArray *array in arrays) {
        if([array isKindOfClass:[NSArray class]] && array.count == count) {
            
        }
        else {
            result = NO;
            break;
        }
    }
    
    return result;
}





- (NSDictionary*)DBDataQuery:(FMDatabase*)db
               withSqlString:(NSString*)sqlString
         andArgumentsInArray:(NSArray*)arguments
{
    if(![NSThread isMainThread]) {NSLog(@"#error - should excute db in MainThread. <%@>", sqlString);}
    
    NSLog(@"sqlString : %@", sqlString);
    if(arguments.count > 0) {
        NSLog(@"arguments : %@", arguments);
    }
    
    NSLog(@"executeQuery");
    FMResultSet *rs = [db executeQuery:sqlString withArgumentsInArray:arguments];
    
    //怎么取?
    int columnCount = [rs columnCount];
    
    
    NSMutableDictionary *queryResultm = [[NSMutableDictionary alloc] init];
    NSMutableArray *queryColumnsNamesM = [[NSMutableArray alloc] init];
    for(int columnIndex = 0; columnIndex < columnCount; columnIndex ++) {
        [queryResultm setObject:[[NSMutableArray alloc] init] forKey:[rs columnNameForIndex:columnIndex]];
        [queryColumnsNamesM addObject:[rs columnNameForIndex:columnIndex]];
    }
    
    NSInteger rsRows = 0;
    while ([rs next]) {
        
        for(NSString *columnName in queryColumnsNamesM) {
            NSMutableArray *columnValues = [queryResultm objectForKey:columnName];
            id columnValue = [rs objectForColumnName:columnName];
            [columnValues addObject:columnValue];
        }
        
        rsRows ++;
    }
    
    [rs close];
    
    if(rsRows == 0) {
        NSLog(@"query result NONE.");
        return nil;
    }
    
    NSInteger countValues = 0;
    
    for(NSString *columnName in queryColumnsNamesM) {
        NSMutableArray *columnValues = [queryResultm objectForKey:columnName];
        [queryResultm setObject:[NSArray arrayWithArray:columnValues] forKey:columnName];
        
        if(countValues == 0) {
            countValues = columnValues.count;
        }
        else {
            if(countValues != columnValues.count) {
                NSLog(@"#error - count of values not fit.");
                return nil;
            }
        }
    }
    
    //查询结果为0时, 返回nil.
    NSLog(@"query result count : %zd", countValues);
    if(countValues == 0) {
        NSLog(@"query result count 0, return nil");
        return nil;
    }
    
    return [NSDictionary dictionaryWithDictionary:queryResultm];
}


//直接的sql语句执行表查询. 暂时只用于测试.
- (NSDictionary*)DBDataQueryDBName:(NSString*)databaseName
                     withSqlString:(NSString*)sqlString
               andArgumentsInArray:(NSArray*)arguments
{
    FMDatabase *db = [self getDataBaseByName:databaseName];
    if(!db) {
        NSLog(@"#error - not find database <%@>", databaseName);
        return nil;
    }
    
    return [self DBDataQuery:db withSqlString:sqlString andArgumentsInArray:arguments];
}


- (NSInteger)DBDataUpdate:(FMDatabase*)db
            withSqlString:(NSString*)sqlString
      andArgumentsInArray:(NSArray*)arguments
{
    if(![NSThread isMainThread]) {NSLog(@"#error - should excute db in MainThread.");}
    
    NSInteger retDBData = DB_EXECUTE_OK;
    
    NSLog(@"DBDataUpdate sqlString : %@", sqlString);
    if(arguments.count > 0) {
        NSLog(@"arguments : %@", arguments);
    }
    
    NSLog(@"executeUpdate");
    BOOL fmdbResult = [db executeUpdate:sqlString withArgumentsInArray:arguments];
    if(fmdbResult) {
        retDBData = DB_EXECUTE_OK;
    }
    else {
        NSLog(@"#error - executeUpdate failed.")
        retDBData = DB_EXECUTE_ERROR_SQL;
    }
    
    return retDBData;
}


//直接的sql语句执行表增删改. 暂时只用于测试.
- (NSInteger)DBDataUpdateDBName:(NSString*)databaseName
                  withSqlString:(NSString*)sqlString
            andArgumentsInArray:(NSArray*)arguments
{
    FMDatabase *db = [self getDataBaseByName:databaseName];
    if(!db) {
        NSLog(@"#error - not find database <%@>", databaseName);
        return DB_EXECUTE_ERROR_NOT_FOUND;
    }
    
    return [self DBDataUpdate:db withSqlString:sqlString andArgumentsInArray:arguments];
}


- (NSInteger)DBDataQueryCount:(FMDatabase*)db
                      toTable:(DBTableAttribute*)tableAttribute
                    withQuery:(NSDictionary*)infoQuery
{
    NSLogSqlite(@"DBDataQueryCount : table:%@, infoQuery:%@", tableAttribute.tableName, infoQuery);
    NSInteger count = 0;
    
    NSMutableString *querym ;
    NSMutableDictionary *queryResultm = [[NSMutableDictionary alloc] init];
    NSMutableArray *queryColumnsNamesM = [[NSMutableArray alloc] init];
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    NSString *queryString = [self DBDataGenerateQueryString:infoQuery andArgumentsInArray:arguments];
    querym = [NSMutableString stringWithFormat:@"SELECT COUNT(*) FROM %@ %@", tableAttribute.tableName, queryString];
    
    [self DBDataExecuteLog:querym withArgumentsInArray:arguments];
    FMResultSet *rs = [db executeQuery:[NSString stringWithString:querym] withArgumentsInArray:arguments];
    
    for(NSString *columnName in queryColumnsNamesM) {
        [queryResultm setObject:[[NSMutableArray alloc] init] forKey:columnName];
    }
    
    NSArray *queryColumnNames = rs.columnNameToIndexMap.allKeys;
    if(queryColumnNames.count == 1 && [queryColumnNames[0] isKindOfClass:[NSString class]] && [queryColumnNames[0] isEqualToString:@"count(*)"]) {
        while ([rs next]) {
            NSNumber *countNumber = [rs objectForColumnIndex:0];
            if([countNumber isKindOfClass:[NSNumber class]]) {
                count = [countNumber integerValue];
                break;
            }
        }
    }
    else {
        NSLog(@"#error - columnNameToIndexMap not expected.[%@]", rs.columnNameToIndexMap);
    }
    
    [rs close];
    
    return count;
}


- (NSInteger)DBDataQueryCountDBName:(NSString*)databaseName
                            toTable:(NSString*)tableName
                          withQuery:(NSDictionary*)infoQuery
{
    if(![NSThread isMainThread]) {NSLog(@"#error - should excute db in MainThread. <%@:%@>", databaseName, tableName);}
    
    FMDatabase *db = [self getDataBaseByName:databaseName];
    if(!db) {
        NSLog(@"#error - not find database <%@ : %@>", databaseName, tableName);
        return 0;
    }
    
    DBTableAttribute *tableAttribute = [self getDBTableAttribute:databaseName withTableName:tableName];
    if(!tableAttribute) {
        NSLog(@"#error - not find table <%@ : %@>", databaseName, tableName);
        return 0;
    }
    
    return [self DBDataQueryCount:db toTable:tableAttribute withQuery:infoQuery];
}


+ (NSString*)stringPaste:(NSString*)string onTimes:(NSInteger)times withConnector:(NSString*)stringConnector
{
    NSInteger count = times;
    if(count > 0) {
        NSMutableString *retStringm = [NSMutableString stringWithFormat:@"%@", string];
        
        //第一个已经添加, 因此序号从1开始.
        for(NSInteger index = 1; index < count; index ++) {
            [retStringm appendFormat:@"%@%@", stringConnector?stringConnector:@" ", string];
        }
        
        return [NSString stringWithString:retStringm];
    }
    else {
        return nil;
    }
}











@end

























