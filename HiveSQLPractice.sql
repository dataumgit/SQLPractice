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

desc formatted student2;
alter table student2 set tblproperties('EXTERNAL' = 'TRUE');
desc formatted students2;

alter table student2 set tblproperties('EXTERNAL' = 'FALSE');
desc formatted student2;


-- ### 修改表
ALTER TABLE table_name RENAME TO new_table_name;
alter table student3 rename to student3rename;

-- ## 增加/修改/替换列信息

-- 增加
 desc dept;
alter table dept add columns(deptdesc string);

-- 更新
alter table dept change column deptdesc desc string;

-- 替换列
alter table dept replace columns(deptno string, dname string, loc string);

---  #######################################

-- # DML数据操作

-- ## 1 数据导入

-- 1.1 向表中装载数据（Load）
-- 建表
create table student(
id string,
name string
)
row format delimited fields terminated by '\t';

--load local
load data local inpath '/opt/module/hive/datas/mydb2' into table mydb2.student;

-- load data on HDFS
truncate table student;

dfs -ls    /mydb2/;
dfs -put    /opt/module/hive/datas/mydb2/student.txt      /mydb2/student;
dfs -cat   /mydb2/student/student.txt;

load data inpath '/mydb2/student/student_copy_1.txt' into table mydb2.student;

load data inpath '/mydb2/student/student_copy_1.txt' overwrite into table mydb2.student;


-- 1.2 通过查询语句向表中插入数据（Insert）
--1) 建表
   create table student_par(
    id int,
    name string
    )
row format delimited fields terminated by '\t';

--2) 插入基本的数据
    insert into table student_par values(1,'wangwu'),(2,'zhaoliu');
    insert into table student_par select id,name from student;
    insert overwrite table student_par select id,name from student;

/*最直接的方式就是更换计算引擎

-- SET hive.execution.engine=mr;
	开启本地mr：
    set hive.exec.mode.local.auto=true; 
**/

-- 1.3 查询语句中创建表并加载数据（As Select）
create table if not exists student3
as select id,name form student;
-- .1.4 创建表时通过Location指定加载数据路径

dfs -mkdir /student
dfs -put    /opt/module/hive/datas/mydb2/student.txt /student;

create external table if not exists student5(
id int,
name string
)

row format delimited fields terminated by '\t'
location '/student';


select  * from  student5;

-- 1.5 Import数据到指定Hive表中

 import table student2  from
 '/user/hive/warehouse/export/student';

-- ## 2 数据导出

-- 2.1 Insert导出

insert overwrite local directory '/opt/module/hive/datas/mydb2/export'
            select * from student5;

-- 结果格式化导出
insert overwrite local directory '/opt/module/hive/datas/mydb2/export/student1'
           ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' 
select * from student;

-- hdfs
 insert overwrite directory '/user/atguigu/student2'
             ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' 
             select * from student;


-- 2.2 Hadoop命令导出到本地
desc formatted student;

dfs -get /mydb2/student/student.txt /opt/module/hive/datas/mydb2/export/student3.txt;


-- 2.3 Hive Shell 命令导出
bin/hive -e 'select * from default.student;' > /opt/module/hive/datas/export/student4.txt;


-- .2.4 Export导出到HDFS上

export table default.student to '/user/hive/warehouse/export/student';


-- 2.5 Sqoop导出

-- 2.6 清除表中数据（Truncate）
truncate table student;