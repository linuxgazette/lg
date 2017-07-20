/* Creates the tables: */
create table cpu (
cpu_id serial primary key, 
cpu_type text );
	
create table video (
video_id serial primary key, 
video_type text );
	
create table computer (
computer_id serial primary key,
computer_ram integer,
cpu_id integer references cpu(cpu_id),
video_id integer references video(video_id)
);

/* Creates the stored procedures to populate the database */
create or replace function test_data_video()
RETURNS integer AS $$
DECLARE
  count integer;
  sql text;
begin
  count = 1;
  LOOP
    sql = 'insert into video(video_id, video_type) values ('|| count ||', ''video ' || count || ''')';
    EXECUTE sql;
    count = count + 1;
    EXIT WHEN count > 50000;
  END LOOP;
  return count;	
END;
$$ LANGUAGE plpgsql;	


create or replace function test_data_cpu()
RETURNS integer AS $$
DECLARE
  count integer;
  sql text;
begin
  count = 1;
  LOOP
    sql = 'insert into cpu(cpu_id, cpu_type) values ('|| count ||', ''cpu ' || count || ''')';
    EXECUTE sql;
    count = count + 1;
    EXIT WHEN count > 50000;
  END LOOP;
  return count;	
END;
$$ LANGUAGE plpgsql;	

create or replace function test_data_computer()
RETURNS integer AS $$
DECLARE
  count integer;
  sql text;
begin
  count = 1;
  LOOP 
    sql = 'insert into computer(computer_id, computer_ram, cpu_id, video_id) values';
    sql = sql || '('|| count ||', ' || random()*1024 || ', ' || (random()*49999)+1 || ', ' || (random()*49999)+1 || ')';
    EXECUTE sql;
    count = count + 1;
    EXIT WHEN count > 500000;
  END LOOP;  
  return count;	
END;
$$ LANGUAGE plpgsql;	

/* Clean up the tables */
delete from computer where 1=1;
delete from video where 1=1;
delete from cpu where 1=1;

/* Populate the Tables */
select * from test_data_video();
select * from test_data_cpu();
select * from test_data_computer();

/* To check the values */
select * from video;
select * from cpu;
select * from computer;

/* Creates the views */
create or replace view computer_full_label(computer_id, computer_ram, cpu_type, video_type) as (
select a.computer_id, a.computer_ram, b.cpu_type, c.video_type 
from computer a, cpu b, video c 
where (a.cpu_id=b.cpu_id) AND (a.video_id=c.video_id)
);

create or replace view computer_full_right as (
select computer_id, computer_ram, cpu_type, video_type from computer a
right join cpu b on (a.cpu_id=b.cpu_id)
right join video c on (a.video_id=c.video_id)
);

create or replace view computer_full_natural as (
select computer_id, computer_ram, cpu_type, video_type from computer
natural right join cpu
natural right join video
);

/* The tests: */

/* No views */
select a.computer_id, a.computer_ram, b.cpu_type, c.video_type from computer a, cpu b, video c where (a.cpu_id=b.cpu_id) AND (a.video_id=c.video_id);
select computer_id, computer_ram, cpu_type, video_type from computer a right join cpu b on (a.cpu_id=b.cpu_id) right join video c on (a.video_id=c.video_id);
select computer_id, computer_ram, cpu_type, video_type from computer natural right join cpu natural right join video;

/* With Views */
select * from computer_full_label;
select * from computer_full_right;
select * from computer_full_natural;



