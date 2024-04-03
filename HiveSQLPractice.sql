HiveSqlPractice
## change to branch dev


create table test (id int);

insert into test values(1001,"lisa");

alter table test add columns (name String);


park-defaults.conf.template


## DDL 数据库定义操作  ##

1、创建数据库
create database db_hive;

create database if not exists mydb2
comment 'my first db2'
Location '/mydb2'
with dbproperties('author' = 'xjy');

2 查询数据库
show databases;
show databases like 'db*';
desc database mydb2;

desc database extended mydb2;

use mydb2;

3.切换当前数据库
use mydb2;
alter database mydb2 set dbproperties('createtime' = '20170830');

desc database extended mydb2;

4.删除数据库
空：
drop database if exists db_hive2;
非空：
 drop database db_hive cascade;


5.创建表

CREATE [EXTERNAL] TABLE [IF NOT EXISTS] table_name 
[(col_name data_type [COMMENT col_comment], ...)] 
[COMMENT table_comment] 
[PARTITIONED BY (col_name data_type [COMMENT col_comment], ...)] 
[CLUSTERED BY (col_name, col_name, ...) 
[SORTED BY (col_name [ASC|DESC], ...)] INTO num_buckets BUCKETS] 
[ROW FORMAT row_format] 
[STORED AS file_format] 
[LOCATION hdfs_path]
[TBLPROPERTIES (property_name=property_value, ...)]
[AS select_statement]


create table if not exists student(
id int,name string
)
row format delimited fields terminated by '\t'
stored as textfile
location '/user/hive/warehouse/mydb2/student';

dfs -mkdir   /user/hive/warehouse/mydb2/student;
dfs -put    /opt/module/hive/datas/mydb2/student.txt   /user/hive/warehouse/mydb2/student;

-- ## 2) 根据查询结果建表
create table if not exists student2 as select id,name from student;

-- ##3)已经存在的表结构建表
create table if not exists student3 like student;

-- 查看表数据的位置：
DESCRIBE FORMATTED student3;
SHOW CREATE TABLE student3;

-- 4） 创建外部表

create external table if not exists dept(
deptno int,
dname string,
loc int
)
row format delimited fields terminated by '\t';


create external table if not exists emp(
empno int,
ename string,
job string,
mgr int,
hiredate string,
sal double,
comm double,
deptno int
)

row format delimited fields terminated by '\t';

show tables;

desc formatted dept;

drop table dept;


dfs -put    /opt/module/hive/datas/mydb2/emp.txt     /mydb2/emp;
dfs -put    /opt/module/hive/datas/mydb2/dept.txt      /mydb2/dept;


drop table dept;


-- 5） 管理表和外部表之间的互换

