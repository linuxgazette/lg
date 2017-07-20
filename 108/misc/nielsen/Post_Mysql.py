#!/usr/bin/python

""" The purpose of this script is to execute a lot of commands which
will appear in the MySQL Professional Certification exam.
In general, sample commands (which I made up myself) which represent
the various questions from the study guide are here.

Things to do are:
  Master/Slave setup on the same computer.
  Clustering.
  Stored procedures -- MySQL 5.

NOTE: You are encourgaed to execute these commands manually yourself.

"""

import commands,re,string, sys, os

  ## Setup our regular expression objects.
Re_AlphaNumeric = re.compile('[a-zA-Z]')
Re_Pound = re.compile('#')
Re_Prefix=re.compile('__PREFIX__')

  ### Get the prefix or home directory for mysql. 
Prefix="/I/do/not/exist"
#print sys.argv
if len(sys.argv) > 1 and len(sys.argv[1]) > 0:
    Prefix = sys.argv[1]
elif os.environ.has_key('MySQL_Prefix') and len(os.environ['MySQL_Prefix']) >0:
  Prefix = os.environ['MySQL_Prefix']
else:
  print "ERROR: MySQL_Prefix not defined in shell."
  print "Please define in the bash shell with 'export MySQL_Prefix=SOMETHING'."
  print "Or issue this script with a single arguement being the prefix."
  sys.exit()

if not os.path.isdir(Prefix):
  print "MySQL home directory'" + Prefix + "' does not exist."
  print "Please define in the bash shell with 'export MySQL_Prefix=SOMETHING'."
  print "Or issue this script with a single arguement being the prefix."
  sys.exit()

#-------------------------------------------------------------------------
   #Gather the various commands we want to execute
MySQL_Commands = """

create database if not exists testdb;
connect testdb;

  -- create our tables
drop table if exists table1;
create table if not exists table1 (
number1 int4 NOT NULL PRIMARY KEY AUTO_INCREMENT,
text1 text NOT NULL DEFAULT ''
) Type=MyISAM RAID_TYPE=1 RAID_CHUNKS=100 RAID_CHUNKSIZE=2000;
alter table table1 max_rows=1000;
alter table table1 avg_row_length=10;

drop table if exists table2;
create table if not exists table2 (
number2 int4 NOT NULL PRIMARY KEY AUTO_INCREMENT,
number1 int4 NOT NULL, 
text2 text NOT NULL DEFAULT '',
INDEX (number2)
) Type=Innodb;

  -- insert bogus data
  -- delayed until all current reads are finished.
insert delayed into table1 (text1) values ('nothing1');
  -- until there ar no reads left, then it inserts.
insert low_priority into table1 (text1) values ('nothing2');
insert into table1 (text1) values ('nothing3');
insert into table1 (text1) values ('nothing4'),('nothing5'),('nothing6');
insert into table1 (text1) values ('12345678901234567890');

insert into table2 (text2,number1) values ('nothing1',1);
set autocommit=0;
begin; 
insert into table2 (text2,number1) values ('nothing2',2);
begin work; -- alias to begin and ends previous transaction
insert into table2 (text2,number1) values ('nothing3',3);
insert into table2 (text2,number1) values ('nothing4',4);
start transaction; -- alias to begin and ends previous transaction
insert into table2 (text2,number1) values ('nothing5',1);
insert into table2 (text2,number1) values ('nothing6',2);
commit;
insert into table2 (text2,number1) values ('nothing7',3);
set autocommit=1;
insert into table2 (text2,number1) values ('nothing8',4);

 -- we will delete all contents of table2 and reinsert
truncate table2;
insert into table2 (text2,number1) values ('nothing1',1);
 -- allows dirty reads
set session transaction isolation level READ UNCOMMITTED;
insert into table2 (text2,number1) values ('nothing2',2);
 -- allow reads that are commited from other connections. phantoms.
set session transaction isolation level READ COMMITTED;
insert into table2 (text2,number1) values ('nothing3',3);
 -- default plus no mods can happen until this connection is done reading.
set session transaction isolation level SERIALIZABLE;
insert into table2 (text2,number1) values ('nothing4',4);
 -- default, can't modify rows until connection is doen modiyfing
set session transaction isolation level REPEATABLE READ;
insert into table2 (text2,number1) values ('nothing5',1);
insert into table2 (text2,number1) values ('nothing6',2);
insert into table2 (text2,number1) values ('nothing7',3);
insert into table2 (text2,number1) values ('nothing8',4);


  -- some simple commands
show processlist;
describe table1;
show table status;
show table status like 'table1';
show table status like 'table2';


  -- test loading data from mysql
load data local infile 'Output/table1.txt' into table table1;
load data local infile 'Output/table1.txt' replace into table table1;
load data local infile 'Output/table1.txt' ignore into table table1;

  -- test encryption functions we should have. 
insert into table1 (text1) values(encode('test', 'test2'));
insert into table1 (text1) values(des_encrypt('test'));
insert into table1 (text1) values(aes_encrypt('test'));
insert into table1 (text1) values(password('test'));

  -- admin only account for all databases. Can't change data. 
grant create temporary tables, file, grant option, lock tables,
    process, reload, replication client, replication slave, show databases,
    shutdown, super
  on *.*
  to 'admin'@'localhost'
  identified by 'this is a dumb password';

 -- admin just for testdb -- can change data.
grant file, process, show databases
  on *.*
  to 'admin_testdb'@'localhost'
  identified by 'this is a dumb password';

grant create temporary tables, grant option, lock tables
  on testdb.*
  to 'admin_testdb'@'localhost'
  identified by 'this is a dumb password';

grant alter, create, delete, drop, index, insert, select, update
  on testdb.*
  to 'admin_testdb'@'localhost'
  identified by 'this is a dumb password';

 -- an admin just for a table
grant alter, create, delete, drop, index, insert, select,update,grant option 
  on testdb.table1
  to 'admin_table1'@'localhost'
  identified by 'this is a dumb password';

  -- an idiot who always messes up the primary keys on table1
  -- who is assinged just to fix data.  
  -- he cannot modify the primary key.
grant insert, select
  on testdb.table1
  to 'idiot1'@'localhost'
  identified by 'this is a dumb password';
grant update (text1)
  on testdb.table1
  to 'idiot1'@'localhost'
  identified by 'this is a dumb password';

  -- what did we do?      
show grants for root@localhost;
show grants;

  -- test setting password with set password command.
set password for 'idiot1'@'localhost' = password('I am a real moron');

  -- test setting query limitations
grant usage  on testdb.*
  to 'somebody'@'localhost'
  identified by 'Some Random Person'
  with max_connections_per_hour 10
  max_queries_per_hour 10
  max_updates_per_hour 10
  ;

  -- who am i and which permission am I using?
select user(), current_user();

  -- now we create indexes and figure out how they affect the table
  -- given the quereies below. Use explain.
show index from table1 \G

explain select * from table1 where text1 like '%o%'\G
explain select * from table1 where text1 like '%o'\G
explain select * from table1 where text1 like 'o%'\G

alter table table1 add index (text1(10));

explain select * from table1 where text1 like '%o%'\G
explain select * from table1 where text1 like '%o'\G
explain select * from table1 where text1 like 'o%'\G

explain select text1, text2 from table1, table2 where
   text1 = text2\G

drop index text1 on table1;
alter table table1 add index (text1(10));
alter table table1 drop index text1;
alter table table1 add index (text1(10));

drop index text2 on table2;
alter table table2 add index (text2(10));

  -- index not used
explain select text1, text2 from table1, table2 where
   text1 = text2\G

  -- index used
explain select text1, text2 from table1, table2 where
   text1 like 'noth%'
   and text1 = text2\G

alter table table1 drop index all_fields;
alter table table1 add index all_fields (number1, text1(10));

alter table table2 drop index all_fields;
alter table table2 add index all_fields (number2, number1, text2(10));

show table status like 'table1';
show table status like 'table2';
show create table table1;
show create table table2;
show keys from table1;
show keys from table2;

  -- after we have finished up, optimize the table.
analyze table table1;
analyze table table2;
optimize table table1;
optimize table table2;

 -- some misc select statements in regards to locking.
select * from table2 where number1 < 10 LOCK IN SHARE MODE;
update table2 set text2='empty1' where number1 < 10;

select * from table2 where number1 < 3 FOR UPDATE; 
update table2 set text2='empty2' where number1 < 3;
commit;

check table table2;

  -- backup the table1
backup table table1 to '""" + Prefix + """/tmp';

show innodb status\G

  -- this stuff does nothing, since we defined it in my.cnf
set session table-type = MyISAM;  

status;

 -- setup ssl
 -- setup master/slave stuff.

"""

MySQLAdmin_Commands = ['create dummy1','drop dummy1','create dummy1',
'extended-status','flush-hosts','flush-logs','flush-status','flush-tables',
'flush-threads','ping','processlist','refresh','status','variables','version']

   ### Remember to add ssl stuff.
Other_Commands = [
'mysqlcheck --check --analyze --optimize --extended testdb table1',
'mysqlcheck -caoe testdb table1',
'mysqlimport --replace testdb Output/table1.txt',
'mysqlimport --replace testdb Output/table1.txt',
'mysqlimport --delete testdb Output/table1.txt',
'mysqlimport --ignore testdb Output/table1.txt',
'mysqldump --add-drop-table testdb table1  >  Output/testdb_table1.dump1',
'mysqldump --extended-insert testdb table1  >  Output/testdb_table1.dump2',
'mysqldump --complete-insert testdb table1  >  Output/testdb_table1.dump3',
'mysqldump --opt testdb table1  >  Output/testdb_table1.dump4',
'mysqldump --single-transaction testdb table1  >  Output/testdb_table1.dump5',
'mysqldump --xml testdb table1  >  Output/testdb_table1.dump6',
'mysqlshow --version',
'mysqlshow testdb table1',
'mysqlshow --status testdb table1',
'mysqlshow --status --verbose testdb table1',
'mysqlshow --keys testdb table1',
'mysqlbinlog ' + Prefix + '/main_log.000001',
'lock tables table1',
'cd ' + Prefix + '/data/testdb; myisampack -vb *.MYI',
'cd ' + Prefix + '/data/testdb; myisamchk -rq *.MYI',
'cd ' + Prefix + '/data/testdb; myisamchk --unpack *.MYI',
'mysqlcheck --repair testdb table1',
'cd ' + Prefix + '/data/testdb; myisamchk --recover testdb table1',

]

#---------------------------------------------
commands.getstatusoutput('mkdir -p Output')
Write = open('Output/table1.txt', 'w')
Write.write('10      test1\n11      test2\n12      test3\n');
for i in range(0,1000): Write.write(str(i+100)+" test"+str(i+100)+"\n");
Write.close();

Command_Log = open("Output/Command.log", 'w')

print "Executing mysql admin commands."
  ## Executing the commands in the file
Write = open('Output/MySQLAdmin_Commands.log', 'w')
for Command in MySQLAdmin_Commands:
  Command ="mysqladmin -v -f " + Command + " 2>&1"
  Write.write("\nCOMMAND: " + Command + "\n")
  Command_Log.write(Command + "\n")
  Temp = commands.getstatusoutput(Command)
  Write.write(Temp[1])
Write.close()

print  "Executing mysql commands."
Write = open('Output/MySQL_Commands', 'w')
Write.write(MySQL_Commands)
Write.close()
Command = "mysql -v -f mysql < Output/MySQL_Commands > Output/MySQL_Commands.log 2>&1"
commands.getstatusoutput(Command)
Command_Log.write(Command + "\n")
  
print "Executing other commands."
Write = open('Output/Other_Commands.log', 'w')
for Command in Other_Commands:
  Command = Command + " 2>&1"
  Command_Log.write(Command + "\n")
  Write.write("\nCOMMAND: " + Command + "\n")
  Temp = commands.getstatusoutput(Command)
  Write.write(Temp[1])
Write.close()

print "Restarting. You will now need to connect with the new password"
print "for root and other accounts."

  ### We will ignore the next two commands because a restart
  ### flushes the privledges anyways.
  ### Also, once the privs are flushed, the password becomes not null
  ### and we can't connect without a password anymore. 
#mysqladmin flush-privileges
#mysqladmin reload

Command = "mysqladmin shutdown"
print Command
commands.getstatusoutput(Command)
Command_Log.write(Command + "\n")
  
Command = Prefix + "/Start_MySQL"
print Command
commands.getstatusoutput(Command)
Command_Log.write(Command + "\n")
  
Command_Log.close()
  
