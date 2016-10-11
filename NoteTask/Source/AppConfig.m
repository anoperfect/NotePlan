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
    //[self.dbData removeDBName:@"config"];
}


- (void)testAfterBuild
{return ;
    NoteModel *note = [[NoteModel alloc] init];
    note.title = @"<p style=\"FONT-SIZE: 15pt; COLOR: #ffff00; FONT-FAMILY: 黑体\">使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1</p>";
    note.content = @"<p style=\"\">第一段说明1</p> <p style=\"\">cnBeta 报道，多家国外媒体援引知情人111士的消息称，Twitter 董事会周四将召开一次会议，讨论公司所面临的一系列问题，其中包括出售事宜。关于 Twitter 被出售的消息早有传闻，华尔街分析师也认为，Twitter 被出售只是时间早晚的问题。近日，Twitter 联合创始人埃文·威廉姆斯(Evan Williams)的一席话再次将该话题推到风口浪尖。 威廉姆斯上周在接受彭博电视台采访时称：“我们现在的地位很有利，作为董事会成员，我们必须考虑正确的选择。”外界认为，这番话可能暗示 Twitter 将考虑出售选项，从而刺激 Twitter 股价大涨7%。 投资研究公司分析师罗伯特·派克(Robert Peck)称，Twitter 当前估值约为 150 亿美元。按照溢价 20% 的标准计算，收购 Twitter 至少需要 180 亿美元。 有业内人士认为，价格不是问题，谷歌母公司 Alphabet、Facebook、苹果公司、亚马逊和微软等都是 Twitter 的潜在收购方。对于 Alphabet 而言，在其搜索服务中部署 Twitter 的实时推送(feed)功能，可实现成本和营收的协同效应。 对于 Facebook，收购 Twitter 可实现战略匹配。对于苹果公司，收购 Twitter 可将当前的硬件业务拓展到社交领域。对于亚马逊，可拓展实时内容服务，进一步强化广告业务。至于微软，一直都对在线和广告业务感兴趣。 但派克认为，短期内 Twitter 也没有出售的紧迫性。首先，Twitter CEO 杰克·多西(Jack Dorsey)仅上任一年时间。其次，Twitter 正在推出几项新服务。此外，Twitter 董事会将继续支持多西。 等等，派克先生，你确定你计算的收购价是 180 亿美元？ 福布斯可不这么认为 《福布斯》在微软收购 LindkedIn 撰文称，即使在对未来现金流最乐观估计情况下，Alphabet 收购 Twitter 的价格也不应超过 11 亿美元，合每股 1.55 美元，比其股价低近九成。否则在经济上就是不划算的。Twitter 营收增长越快，亏损越大，相当于营收的 38%。 为什么是 Alphabet？ 《福布斯》认为，Alphabet 管理层是公司股东更称职的管家，与 Alphabet 的整合必须大幅度提升 Twitter 核心业务盈利能力。 在证明 Twitter 收购价合理方面，Alphabet 高管需要解决的主要挑战是前者有瑕疵的商业模式。Twitter 商业模式的瑕疵在于，用户的最大利益(例如迅捷、方便地访问他们选择的内容)，与广告客户的最大利益(获得用户更多关注)不一致。在修正这一瑕疵前(我不相信这一瑕疵能被修正)，很难说有公司会认真考虑收购 Twitter。Alphabet 也能增加 Twitter 的营收和税后净营业利润。 除了 Alphabet，Twitter 的潜在买家还包括微软前首席执行官史蒂夫·鲍尔默(Steve Ballmer) 以及沙特王子阿尔瓦利德·本·塔拉尔·沙特（Saudi Prince Alwaleed bin Talal Al Saud ）联合收购 Twitter。 目前 Twitter 没有对出售传闻作出回应，就像《福布斯》说的那样，收购 Twitter 的戏剧大幕拉开，远未散场。</p>";
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
    //[self configNoteAdd:note];
    
    note.title = @"<p style=\"color:blue; text-align:center\">color - red    使用说明1 red使用说明2使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1使用说明1</p>";
    note.content = @"<p style=\"\">第一段说明2</p> <p style=\"\">另一段说明2</p>";
    note.color = @"red";
    [self configNoteAdd:note];
    
    return;
    
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
    note.content = @"<p style=\"color:blue;FONT-SIZE: 10pt;\">第一段说明2</p> <p style=\"\">另一段说明2</p> <p style=\"\">本文作者原：新元@ 股书 Kapbook (微信 ID：Kapbook)， 完整的股权激励在线解决方案。 </p> <p style=\"\">在过去的几个季度里，Twitter 每季度都会给员工发放超过 1 亿 5000 万美元价值的期权。这种激进的做法有些不合常理。 </p> <p style=\"\">9 月 28 日，36Kr 的报道就说：Twitter 或因员工期权太多形成被收购障碍。美国知名科技媒体 Business Insider 也曾报道：2011 年，处于快速成长阶段的 Twitter 向投资者总计筹集了 12 亿美元，其中的 8 亿美元被用来回购老员工（不论离职与否）手里的期权，作为对这些“昔日功臣”的奖励。 </p> <p style=\"\">其实在当时，公司里的一些高管曾经筹划，希望 Twitter 在 2011 年就上市。可是 Twitter 的决策层则把融资拿的钱大部分用在了回购员工期权。并表示：让员工等到公司上市才能卖出股权套现，这个过程太漫长了，公司于心不忍。于是在那时，上市最终不了了之。 </p> <p style=\"\">Twitter 在发期权方面过于慷慨的做法，与近日沸沸扬扬的丁香园形成鲜明对比。加拿大皇家银行资本市场部的资深分析师 Mark Mahaney 更直言，Twitter 是在授予员工股权激励方面最为激进的公司之一。 </p> <p style=\"\">Twitter 有多激进呢？2015 年公司毛利润为 5.578 亿美元，发期权就发了 6.82 亿美元。 </p> <p style=\"\">对，你没有看错。这是一家真正称得上是“为员工赚钱的公司”。 </p> <p style=\"\">硅谷中的激进主义 </p> <p style=\"\">事实上，Twitter 在 2014 年每季度都会拿出营业收入的 35%-50% 来做股权激励。其中第二季度达到高峰，当季 Twitter 营业收入是 3.12 亿美元，其中的 51% 用来做股权激励。 </p> <p style=\"\">2015 年 Twitter 有所收敛，拿出了营业收入的 26% 做股权激励。作为横向对比，让我们来看看各大科技巨头 2015 年发期权的情况。 </p> <p style=\"\">Amazon 亚马逊把公司年营业收入的2% 作为股权激励发给了员工； Google 发出7%；Facebook 发出 15%；Linkedin 领英发了 17%；Twitter 的 26% 显然是最多的 。 </p> <p style=\"\">不过，像 Twitter 这样发期权过于激进的，长期来说，对公司的发展未必有利。因为 Twitter 陷入了一个现金流缺失的不良循环中。 </p> <p style=\"\">Twitter 在成立运营之初，缺少现金给员工发工资，于是 Twitter 开始发放期权；等到新一轮融资进来的时候，由于其慷慨的股权激励制度，公司需要拿出新融资的一大笔钱，来回购之前老员工的股票，然后公司会发现手里可用的现金又一次缺少； </p> <p style=\"\">与尴尬的现金流境况相对的是：公司在迅速壮大，为了招募新的得力干将，Twitter 又给新加入的员工发放了大笔期权；最终就这样循环下来。 </p> <p style=\"\">Twitter 处于进退两难的境地。它承诺给员工们可观的薪酬， 股权激励恰恰是其中重要组成。这笔支出是省不下来的。但是持续的股权激励计划，则不断稀释着其他股东的权益。这些期权数目很大，Twitter 的股份每季度增加1% 到2%，每年增加 10% 至 20%。 </p> <p style=\"\">显然，公司即便没有任何开支，每年的营业收入也该增加 10% 以上，可惜 Twitter 达不到 10%，那么老股东的权益其实是逐渐减少。 </p> <p style=\"\">期权计划的内容 </p> <p style=\"\">我们不妨看一下 Twitter 这一系列期权计划的具体形式。 首先，Twitter 只发给员工受限股。而不是发放业界惯常的股票期权，或者直接持股。所谓受限股，即：公司授予的依据受限股授予协议约定的条件和价格，直接或间接购买的相应股东权利受到一定限制的公司股权。受限股和股票期权一样，都是在一定时间后低价拿到公司股权的方法。 </p> ";
    note.color = @"";
    note.classification = @"新增";
    [self configNoteAdd:note];
    
    
    
    
    
    
    
}




@end
