create database notetask
CHARACTER SET 'utf8'  
COLLATE 'utf8_general_ci';  

use notetask;

DROP TABLE IF EXISTS notetask;
create table notetask(
id      int not null auto_increment,
uid     int not null,
status  int not null default 0,
startDateTime  char(30) CHARACTER SET utf8 COLLATE utf8_unicode_ci not null, 
finishDateTime char(30) CHARACTER SET utf8 COLLATE utf8_unicode_ci not null, 
commitDateTime char(30) CHARACTER SET utf8 COLLATE utf8_unicode_ci not null, 
updateDateTime char(30) CHARACTER SET utf8 COLLATE utf8_unicode_ci not null, 
content text CHARACTER SET utf8 COLLATE utf8_unicode_ci,
isShared       tinyint,
isOnlyLocal    tinyint,
isOnlyWorkday  tinyint, 
isDailyRepeat  tinyint,
isWeeklyRepeat tinyint,
isYearlyRepeat tinyint,
commentNumber  int default 0,
likeNumber     int default 0,
primary key(id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE INDEX pn_uid_status ON notetask (uid,status);


insert into notetask(
uid,
startDateTime, 
finishDateTime, 
commitDateTime, 
content,
isShared,
isOnlyLocal,
isOnlyWorkday, 
isDailyRepeat,
isWeeklyRepeat,
isYearlyRepeat)
values
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容asdkjfksdf kfdsslkfsdsfsh',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容bfjslkdf sfsd',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容cgfjkldj fdkg dfg dfjiigj夫斯基的方式都是十分的第三方杀毒发达省份收到发生的',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容d',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容e',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容f',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容g',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容h',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容i',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容j',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容k',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容l0',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容l1',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容l2',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容l3',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容l4',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容l5',1,0,0,1,0,0), 
    ('1000071','2016-01-02 10:00:00','2016-01-02 18:30:00','2016-01-02 08:01:56','测试内容l6',1,0,0,1,0,0);
