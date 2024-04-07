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



尚硅谷大数据111门技术+43个项目20240219.docx
尚硅谷嵌入式技术资料20240403.docx

-- ### 第六章 查询

--DataRecource  : G:\Hadoopecologicalsystem\Hive\HiveSQL\SQLPractice\DataSource\datatoquery  -- -- /opt/module/hive/datas/mydb2/datatoquery

-- 6.1 基本查询（Select…From）
-- 1 全表和特定列查询
-- 1） 创建部门表
create table if not exists dept(
deptno int,
dname string,
loc int

)
row format delimited fields terminated by '\t';

+--------------+-------------+-----------+
| dept.deptno  | dept.dname  | dept.loc  |
+--------------+-------------+-----------+
| 10           | ACCOUNTING  | 1700      |
| 20           | RESEARCH    | 1800      |
| 30           | SALES       | 1900      |
| 40           | OPERATIONS  | 1700      |
| 10           | ACCOUNTING  | 1700      |
| 20           | RESEARCH    | 1800      |
| 30           | SALES       | 1900      |
| 40           | OPERATIONS  | 1700      |
+--------------+-------------+-----------+
部门号  部门名称   


create table if not exists emp(
empno int,
ename string,
job string,
mgr int,
hiredate string,
dal double,
comm double,
deptno int

)
row format delimited fields terminated by  '\t';

+------------+------------+-----------+----------+---------------+----------+-----------+-------------+
| emp.empno  | emp.ename  |  emp.job  | emp.mgr  | emp.hiredate  | emp.sal  | emp.comm  | emp.deptno  |
+------------+------------+-----------+----------+---------------+----------+-----------+-------------+
| 7369       | SMITH      | CLERK     | 7902     | 1980-12-17    | 800.0    | NULL      | 20          |
| 7499       | ALLEN      | SALESMAN  | 7698     | 1981-2-20     | 1600.0   | 300.0     | 30          |
| 7521       | WARD       | SALESMAN  | 7698     | 1981-2-22     | 1250.0   | 500.0     | 30          |
+------------+------------+-----------+----------+---------------+----------+-----------+-------------+
    员工号		员工姓名	员工职位				入职时间	  薪资						部门编号

--2) 导入数据

alter table dept set tblproperties ('EXTERNAL'='FALSE');
alter table emp set tblproperties ('EXTERNAL'='FALSE');


truncate table  dept;
truncate table  emp;

load data local inpath '/opt/module/hive/datas/mydb2/datatoquery/dept.txt' into table dept;
load data local inpath  '/opt/module/hive/datas/mydb2/datatoquery/emp.txt' into table emp;


select * from dept;
select empno, ename,job,mgr,hiredate,sal,comm,deptno from emp;
select empno, ename from emp;

/**
（1）SQL 语言大小写不敏感。 
（2）SQL 可以写在一行或者多行
（3）关键字不能被缩写也不能分行
（4）各子句一般要分行写。
（5）使用缩进提高语句的可读性。
*/


-- 1.2 列别名

select ename AS name, deptno dn from emp;

select sal +1 from emp;

-- 1.4 常用函数

select count(*) cnt from emp;
select max(sal) max_sal from emp;
select min(sal) min_sal from emp;
select sum(sal) sum_sal from emp; 
select avg(sal) avg_sal from emp;

-- .1.5 Limit语句

select * from emp limit 5;
select * from emp limit 2,3;

-- 1.6 Where语句
select * from emp where sal >1000;

-- 1.7 比较运算符（Between/In/ Is Null）

select * from emp where sal =5000;
select * from emp where sal between 500 and 1000;
select * from emp where comm is null;
select * from emp where sal IN (1500, 5000);


-- 1.8 Like和RLike
select * from emp where ename LIKE 'A%';
select * from emp where ename LIKE '_A%';
select * from emp where ename  RLIKE '[A-N]';

-- 1.9 逻辑运算符（And/Or/Not）

 select * from emp where sal>1000 and deptno=30;
 select * from emp where sal>1000 or deptno=30;
select * from emp where deptno not IN(30, 20);


-- ### 2 分组

-- 2.1 Group By语句
select t.deptno, avg(t.sal) avg_sal from emp t group by t.deptno;

select t.deptno, t.job, max(t.sal) max_sal from emp t group by
 t.deptno, t.job;


-- 2.2 Having语句
 select deptno, avg(sal) from emp group by deptno;
select deptno, avg(sal) avg_sal from emp group by deptno having
 avg_sal > 2000;

-- ## 3 Join语句
-- 3.1 等值Join
 -- 需求一： 获取 emp 和 dept的交集的数据

select
e.empno, e.ename, e.deptno, d.deptno, d.dname
from emp e
join dept d
on e.deptno = d.deptno;

+----------+----------+-----------+-----------+-------------+
| e.empno  | e.ename  | e.deptno  | d.deptno  |   d.dname   |
+----------+----------+-----------+-----------+-------------+
| 7369     | SMITH    | 20        | 20        | RESEARCH    |
| 7499     | ALLEN    | 30        | 30        | SALES       |
| 7521     | WARD     | 30        | 30        | SALES       |
| 7566     | JONES    | 20        | 20        | RESEARCH    |
| 7654     | MARTIN   | 30        | 30        | SALES       |
| 7698     | BLAKE    | 30        | 30        | SALES       |
| 7782     | CLARK    | 10        | 10        | ACCOUNTING  |
| 7788     | SCOTT    | 20        | 20        | RESEARCH    |
| 7839     | KING     | 10        | 10        | ACCOUNTING  |
| 7844     | TURNER   | 30        | 30        | SALES       |
| 7876     | ADAMS    | 20        | 20        | RESEARCH    |
| 7900     | JAMES    | 30        | 30        | SALES       |
| 7902     | FORD     | 20        | 20        | RESEARCH    |
| 7934     | MILLER   | 10        | 10        | ACCOUNTING  |
+----------+----------+-----------+-----------+-------------+


-- 需求二： 获取 emp 的全部数据 和 dept的中能匹配到的数据
select 
e.empno, e.ename, e.deptno, d.deptno, d.dname
from emp e 
left join dept d 
on e.deptno=d.deptno;

+----------+----------+-----------+-----------+-------------+
| e.empno  | e.ename  | e.deptno  | d.deptno  |   d.dname   |
+----------+----------+-----------+-----------+-------------+
| 7369     | SMITH    | 20        | 20        | RESEARCH    |
| 7499     | ALLEN    | 30        | 30        | SALES       |
| 7521     | WARD     | 30        | 30        | SALES       |
| 7566     | JONES    | 20        | 20        | RESEARCH    |
| 7654     | MARTIN   | 30        | 30        | SALES       |
| 7698     | BLAKE    | 30        | 30        | SALES       |
| 7782     | CLARK    | 10        | 10        | ACCOUNTING  |
| 7788     | SCOTT    | 20        | 20        | RESEARCH    |
| 7839     | KING     | 10        | 10        | ACCOUNTING  |
| 7844     | TURNER   | 30        | 30        | SALES       |
| 7876     | ADAMS    | 20        | 20        | RESEARCH    |
| 7900     | JAMES    | 30        | 30        | SALES       |
| 7902     | FORD     | 20        | 20        | RESEARCH    |
| 7934     | MILLER   | 10        | 10        | ACCOUNTING  |
+----------+----------+-----------+-----------+-------------+

-- 需求三： 获取 dept 的全部数据 和 emp的中能匹配到的数据--- 
方式一：
select 
e.empno, e.ename, e.deptno, d.deptno, d.dname
from dept d
left join emp e 
on e.deptno=d.deptno;

---方式二：
select 
e.empno, e.ename, e.deptno, d.deptno, d.dname
from emp e 
right join dept d 
on e.deptno=d.deptno;

+----------+----------+-----------+-----------+-------------+
| e.empno  | e.ename  | e.deptno  | d.deptno  |   d.dname   |
+----------+----------+-----------+-----------+-------------+
| 7782     | CLARK    | 10        | 10        | ACCOUNTING  |
| 7839     | KING     | 10        | 10        | ACCOUNTING  |
| 7934     | MILLER   | 10        | 10        | ACCOUNTING  |
| 7369     | SMITH    | 20        | 20        | RESEARCH    |
| 7566     | JONES    | 20        | 20        | RESEARCH    |
| 7788     | SCOTT    | 20        | 20        | RESEARCH    |
| 7876     | ADAMS    | 20        | 20        | RESEARCH    |
| 7902     | FORD     | 20        | 20        | RESEARCH    |
| 7499     | ALLEN    | 30        | 30        | SALES       |
| 7521     | WARD     | 30        | 30        | SALES       |
| 7654     | MARTIN   | 30        | 30        | SALES       |
| 7698     | BLAKE    | 30        | 30        | SALES       |
| 7844     | TURNER   | 30        | 30        | SALES       |
| 7900     | JAMES    | 30        | 30        | SALES       |
| NULL     | NULL     | NULL      | 40        | OPERATIONS  |


-- 需求四： 获取emp独有的数据
select 
e.empno, e.ename, e.deptno, d.deptno, d.dname
from emp e 
left join dept d 
on e.deptno=d.deptno
where d.deptno is null ;

+----------+----------+-----------+-----------+----------+
| e.empno  | e.ename  | e.deptno  | d.deptno  | d.dname  |
+----------+----------+-----------+-----------+----------+
| 8888     | MILLER   | 60        | NULL      | NULL     |
+----------+----------+-----------+-----------+----------+
 获取左表独有数据的过滤办法： 先做连接获取左表的所有的数据形成虚表T1,然后在 t1 表的基础上过滤出 右边为空的行

-- 需求五：获取dept独有的数据 
select 
e.empno, e.ename, e.deptno, d.deptno, d.dname
from emp e 
right join dept d 
on e.deptno=d.deptno
where e.deptno is null
;
+----------+----------+-----------+-----------+-------------+
| e.empno  | e.ename  | e.deptno  | d.deptno  |   d.dname   |
+----------+----------+-----------+-----------+-------------+
| NULL     | NULL     | NULL      | 40        | OPERATIONS  |
+----------+----------+-----------+-----------+-------------+
 获取右表独有数据的过滤办法： 先做连接获取右表的所有的数据形成虚表T1,然后在 t1 表的基础上过滤出 左表边为空的行
 +----------+----------+-----------+-----------+-------------+
| e.empno  | e.ename  | e.deptno  | d.deptno  |   d.dname   |
+----------+----------+-----------+-----------+-------------+
| 7782     | CLARK    | 10        | 10        | CCOUNTING   |
| 7839     | KING     | 10        | 10        | CCOUNTING   |
| 7934     | MILLER   | 10        | 10        | CCOUNTING   |
| 7369     | SMITH    | 20        | 20        | RESEARCH    |
| 7566     | JONES    | 20        | 20        | RESEARCH    |
| 7788     | SCOTT    | 20        | 20        | RESEARCH    |
| 7876     | ADAMS    | 20        | 20        | RESEARCH    |
| 7902     | FORD     | 20        | 20        | RESEARCH    |
| 7499     | ALLEN    | 30        | 30        | SALES       |
| 7521     | WARD     | 30        | 30        | SALES       |
| 7654     | MARTIN   | 30        | 30        | SALES       |
| 7698     | BLAKE    | 30        | 30        | SALES       |
| 7844     | TURNER   | 30        | 30        | SALES       |
| 7900     | JAMES    | 30        | 30        | SALES       |
| NULL     | NULL     | NULL      | 40        | OPERATIONS  |
+----------+----------+-----------+-----------+-------------+


-- 需求六： 获取emp和dept所有的数据
---方式一：
select 
e.empno, e.ename, e.deptno, d.deptno, d.dname
from emp e 
left join dept d 
on e.deptno=d.deptno
union
select 
e.empno, e.ename, e.deptno, d.deptno, d.dname
from emp e 
right join dept d 
on e.deptno=d.deptno
;

union 是去除重复
union all 是不去重的

>> 所有的数据结果
+------------+------------+-------------+------------+
| _u1.empno  | _u1.ename  | _u1.deptno  | _u1.dname  |
+------------+------------+-------------+------------+
| NULL       | NULL       | NULL        | 40         |
| 7369       | SMITH      | 20          | 20         |
| 7499       | ALLEN      | 30          | 30         |
| 7521       | WARD       | 30          | 30         |
| 7566       | JONES      | 20          | 20         |
| 7654       | MARTIN     | 30          | 30         |
| 7698       | BLAKE      | 30          | 30         |
| 7782       | CLARK      | 10          | 10         |
| 7788       | SCOTT      | 20          | 20         |
| 7839       | KING       | 10          | 10         |
| 7844       | TURNER     | 30          | 30         |
| 7876       | ADAMS      | 20          | 20         |
| 7900       | JAMES      | 30          | 30         |
| 7902       | FORD       | 20          | 20         |
| 7934       | MILLER     | 10          | 10         |
| 9999       | MILLE      | 9999        | NULL       |
+------------+------------+-------------+------------+
16 rows selected (52.189 seconds)


---方式二： （full join Hive独有的关联方式，mysql不支持，oracle支持)
select 
e.empno, e.ename, e.deptno, d.deptno, d.dname
from emp e 
full outer join dept d 
on e.deptno=d.deptno;


+----------+----------+-----------+-----------+-------------+
| e.empno  | e.ename  | e.deptno  | d.deptno  |   d.dname   |
+----------+----------+-----------+-----------+-------------+
| 7782     | CLARK    | 10        | 10        | ACCOUNTING  |
| 7934     | MILLER   | 10        | 10        | ACCOUNTING  |
| 7839     | KING     | 10        | 10        | ACCOUNTING  |
| 7369     | SMITH    | 20        | 20        | RESEARCH    |
| 7902     | FORD     | 20        | 20        | RESEARCH    |
| 7876     | ADAMS    | 20        | 20        | RESEARCH    |
| 7788     | SCOTT    | 20        | 20        | RESEARCH    |
| 7566     | JONES    | 20        | 20        | RESEARCH    |
| 7900     | JAMES    | 30        | 30        | SALES       |
| 7698     | BLAKE    | 30        | 30        | SALES       |
| 7654     | MARTIN   | 30        | 30        | SALES       |
| 7521     | WARD     | 30        | 30        | SALES       |
| 7844     | TURNER   | 30        | 30        | SALES       |
| 7499     | ALLEN    | 30        | 30        | SALES       |
| NULL     | NULL     | NULL      | 40        | OPERATIONS  |
| 8888     | MILLER   | 60        | NULL      | NULL        |
+----------+----------+-----------+-----------+-------------+
16 rows selected (1.552 seconds)

full outer join 
full  join


-- 需求七： 获取emp和dept的各自独有的数据
select 
e.empno, e.ename, e.deptno, d.deptno, d.dname
from emp e 
full join dept d 
on e.deptno=d.deptno
where e.deptno is null 
or d.deptno is null 
;
+----------+----------+-----------+-----------+-------------+
| e.empno  | e.ename  | e.deptno  | d.deptno  |   d.dname   |
+----------+----------+-----------+-----------+-------------+
| NULL     | NULL     | NULL      | 40        | OPERATIONS  |
| 8888     | MILLER   | 60        | NULL      | NULL        |
+----------+----------+-----------+-----------+-------------+

从所有的数据里面摘取独有的数据结果。