//
//  DBData.h
//  Reuse0 
//
//  Created by Ben on 16/7/12.
//  Copyright © 2016年 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DB_EXECUTE_OK                    0
#define DB_EXECUTE_ERROR_SQL            -1
#define DB_EXECUTE_ERROR_EXIST          -2
#define DB_EXECUTE_ERROR_DATA           -3
#define DB_EXECUTE_ERROR_NOT_FOUND      -4


@interface TableObjectProperty : NSObject

@property (nonatomic, strong) NSString              *name; //Class name. 同时会使用为表名.
@property (nonatomic, strong) NSString              *tableName; //table name. 为空时使用object name.
@property (nonatomic, strong) NSDictionary<NSString*, NSString*> *nameAndColumnNameMapping; //object member name 与 column name的mapping.
@property (nonatomic, strong) NSArray<NSString*>    *ignoreItemNames; //类型符合但是不进行存储的.
@property (nonatomic, strong) NSArray<NSString*>    *addItemNames;//类型不符合但是进行存储的.
@property (nonatomic, strong) NSArray<NSString*>    *primaryKeys; //主键.
@property (nonatomic, strong) NSArray<NSString*>    *notNullItemNames; //不许为空的.
@property (nonatomic, strong) NSArray<NSString*>    *autoIncrementItemNames; //自动增长的.
@property (nonatomic, strong) NSDictionary<NSString*,id> *defaultValue; //默认值.
@property (nonatomic, strong) NSString *comment; //描述.
@property (nonatomic, strong) NSArray<NSString*> *dbNames; //属于的数据库名称.

+ (instancetype)tableObjectPropertyByName:(NSString*)name primaryKeys:(NSArray<NSString*>*)primaryKeys dbNames:(NSArray<NSString*>*)dbNames comment:(NSString*)comment;

@end



typedef NS_ENUM(NSInteger, DBDataColumnType) {
    DBDataColumnTypeNumberInteger    = 1,
    DBDataColumnTypeNumberLongLong,
    DBDataColumnTypeString,
    DBDataColumnTypeData
};



@interface DBColumnAttribute : NSObject
@property (nonatomic, strong) NSString          *columnName;
@property (nonatomic, assign) DBDataColumnType  dataType;
@property (nonatomic, assign) BOOL              isNeedForInsert;
@property (nonatomic, assign) BOOL              isAutoIncrement;
@property (nonatomic, strong) id                defaultValue;
@end


@interface DBTableAttribute : NSObject
@property (nonatomic, strong) NSString          *tableName; //表名.
@property (nonatomic, strong) NSArray           *databaseNames;        //是属于全局的, 或者是属于host的.
@property (nonatomic, strong) NSArray           *columnAttributes;       //成员为DBColumnAttribute.
@property (nonatomic, strong) NSArray           *primaryKeys;    //字符串数组.
@property (nonatomic, strong) NSArray           *preset;    //预置数据.
@property (nonatomic, strong) NSString          *comment; //描述.
@end





@interface DBData : NSObject

@property (atomic, strong) NSMutableArray *tableAttributes;//保存所有table属性.成员为DBTableValue.



- (void)DBDataAddTableAttributeFromTableObjectProperty:(TableObjectProperty*)tableObjectProperty;
- (void)DBDataAddTableAttributeByJsonData:(NSData*)data;
- (void)buildTable;

#if 0 //json实例.
{
    "version":111,
    "tables": [
               {
                   "tableName":"color",
                   "databaseNames":["config"],
                   "columnAttributes": [
                                        {"columnName":"name"            , "dataType":"string" , "isNeedForInsert":true , "isAutoIncrement":false },
                                        {"columnName":"title"           , "dataType":"string" , "isNeedForInsert":true , "isAutoIncrement":false },
                                        {"columnName":"enableCustmize"  , "dataType":"integer", "isNeedForInsert":false, "isAutoIncrement":false, "defaultValue":0 },
                                        {"columnName":"colorstring"     , "dataType":"string" , "isNeedForInsert":true , "isAutoIncrement":false },
                                        {"columnName":"colornightstring", "dataType":"string" , "isNeedForInsert":true , "isAutoIncrement":false }
                                        ],
                   "primaryKeys":["name"],
                   "preset":[
                             
                             {
                                 "databaseName":"*",
                                 "content":
                                 {
                                     "COLUMNS":["name", "title", "enableCustmize", "colorstring", "colornightstring"],
                                     "VALUES":[
                                               ["CustomBackground", "", 0,                             "#e1eaeb", "#e1eaeb"],
                                              ]
                                 }
                             }
                             ],
                   "comment":"颜色"
               },
               
               {
                   "tableName":"font",
                   "databaseNames":["config"],
                   "columnAttributes": [
                                        {"columnName":"name"          , "dataType":"string" , "isNeedForInsert":true , "isAutoIncrement":false },
                                        {"columnName":"title"         , "dataType":"string" , "isNeedForInsert":true , "isAutoIncrement":false },
                                        {"columnName":"enableCustmize", "dataType":"integer", "isNeedForInsert":false, "isAutoIncrement":false, "defaultValue":0 },
                                        {"columnName":"fontstring"    , "dataType":"string" , "isNeedForInsert":true , "isAutoIncrement":false }
                                        ],
                   "primaryKeys":["name"],
                   "preset":[
                             
                             {
                                 "databaseName":"*",
                                 "content":
                                 {
                                     "COLUMNS":["name", "title", "enableCustmize", "fontstring"],
                                     "VALUES":[
                                               ["CustomLabel", "", 0,                                    "small"]
                                               ]
                                 }
                             }
                             ],
                   "comment":"字体"
               }
               ]
}
#endif



//创建.
//创建由buildByJsonData依据db.json文件中的数据创建.


#define DBDATA_STRING_COLUMNS @"COLUMNS"
#define DBDATA_STRING_VALUES  @"VALUES"

#define DBDATA_STRING_ORDER   @"ORDERSTRING"


/*
 infoInsert格式.
 {
 DBDATA_STRING_COLUMNS:["column1", "column2"],
 DBDATA_STRING_VALUES :[["stringvalue1", 1234numbervalue1], ["stringvalue2", 1234numbervalue2]]
 }
 */
//增
- (NSInteger)DBDataInsertDBName:(NSString*)databaseName toTable:(NSString*)tableName withInfo:(NSDictionary*)infoInsert;
- (NSInteger)DBDataInsertDBName:(NSString*)databaseName toTable:(NSString*)tableName withInfo:(NSDictionary*)infoInsert orReplace:(BOOL)replace;
- (NSInteger)DBDataInsertDBName:(NSString*)databaseName toTable:(NSString*)tableName withInfo:(NSDictionary*)infoInsert orIgnore:(BOOL)ignore;


//删
- (NSInteger)DBDataDeleteDBName:(NSString*)databaseName toTable:(NSString*)tableName withQuery:(NSDictionary*)infoQuery;


//查
- (NSDictionary*)DBDataQueryDBName:(NSString*)databaseName
                           toTable:(NSString*)tableName
                       columnNames:(NSArray*)columnNames
                         withQuery:(NSDictionary*)infoQuery
                         withLimit:(NSDictionary*)infoLimit;


//改. 暂时不实现.
- (NSInteger)DBDataUpdateDBName:(NSString*)databaseName toTable:(NSString*)tableName withInfoUpdate:(NSDictionary*)infoUpdate withInfoQuery:(NSDictionary*)infoQuery;


//使用事物提供批量改.
- (NSInteger)DBDataUpdatesDBName:(NSString*)databaseName toTable:(NSString*)tableName withInfosUpdate:(NSArray<NSDictionary*> *)infosUpdate withInfosQuery:(NSArray<NSDictionary*> *)infosQuery;


//+1
- (NSInteger)DBDataUpdateAdd1DBName:(NSString*)databaseName toTable:(NSString*)tableName withColumnName:(NSString*)columnName withInfoQuery:(NSDictionary*)infoQuery;


//查询出的NSDictionary数据转为NSArray<NSDictionary*>*, 方便单个NSDictionary转model.
- (NSArray<NSDictionary*>*)queryResultDictionaryToArray:(NSDictionary*)queryResult;


//对Insert, Update的输入数据, Query的输出数据进行检测. 返回行数. 执行时检测所有key对应的value array的个数相同.
//错误时返回 NSNotFound.
- (NSInteger)DBDataCheckRowsInDictionary:(NSDictionary*)dict;

//辅助检测.
- (BOOL)DBDataCheckCountOfArray:(NSArray*)arrays withCount:(NSInteger)count;
- (BOOL)DBDataCheckCount:(NSInteger)count OfArrayObjects:(id)obj, ...;



//直接的sql语句执行表查询. 暂时只用于测试.
- (NSDictionary*)DBDataQueryDBName:(NSString*)databaseName
                     withSqlString:(NSString*)sqlString
               andArgumentsInArray:(NSArray*)arguments;


//直接的sql语句执行表增删改. 暂时只用于测试.
- (NSInteger)DBDataUpdateDBName:(NSString*)databaseName
                  withSqlString:(NSString*)sqlString
            andArgumentsInArray:(NSArray*)arguments;


//清除数据库. 需仅适用于开发者环境.
- (void)removeAll;
- (void)removeDBName:(NSString*)dbname;


@end




