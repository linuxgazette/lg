---              Generic Functions for Perl/Postgresql version 0.1

---                       Copyright 2001, Mark Nielsen
---                            All rights reserved.
---    This Copyright notice was copied and modified from the Perl 
---    Copyright notice. 
---    This program is free software; you can redistribute it and/or modify
---    it under the terms of either:

---        a) the GNU General Public License as published by the Free
---        Software Foundation; either version 1, or (at your option) any
---        later version, or

---        b) the "Artistic License" which comes with this Kit.

---    This program is distributed in the hope that it will be useful,
---    but WITHOUT ANY WARRANTY; without even the implied warranty of
---    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either
---    the GNU General Public License or the Artistic License for more details.

---    You should have received a copy of the Artistic License with this
---    Kit, in the file named "Artistic".  If not, I'll be glad to provide one.

---    You should also have received a copy of the GNU General Public License
---   along with this program in the file named "Copying". If not, write to the 
---   Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 
---    02111-1307, USA or visit their web page on the internet at
---    http://www.gnu.org/copyleft/gpl.html.

-- create a method to unpurge just one item.  
-- create a method to purge one item. 
--  \i HOME/TABLENAME.table
---------------------------------------------------------------------

drop function sql_TABLENAME_insert ();
CREATE FUNCTION sql_TABLENAME_insert () RETURNS int4 AS '
DECLARE
    record1 record;  oid1 int4; id int4 :=0; record_backup RECORD;
BEGIN
   insert into TABLENAME (date_updated, date_created, active)
        values (CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, 1);
     -- Get the unique oid of the row just inserted. 
   GET DIAGNOSTICS oid1 = RESULT_OID;
     -- Get the TABLENAME id. 
   FOR record1 IN SELECT TABLENAME_id FROM TABLENAME where oid = oid1
      LOOP
      id := record1.TABLENAME_id;
   END LOOP;
   
     -- If id is NULL, insert failed or something is wrong.
   IF id is NULL THEN return (-1); END IF;
     -- It should also be greater than 0, otherwise something is wrong.
   IF id < 1 THEN return (-2); END IF;

      -- Now backup the data. 
    FOR record_backup IN SELECT * FROM TABLENAME where TABLENAME_id = id
       LOOP
       insert into TABLENAME_backup (TABLENAME_id, date_updated, date_created, 
           active, error_code) 
         values (id, record_backup.date_updated, record_backup.date_created,
            record_backup.active, ''insert'');
    END LOOP;

     -- Everything has passed, return id as TABLENAME_id.
   return (id);
END;
' LANGUAGE 'plpgsql';
---------------------------------------------------------------------

drop function sql_TABLENAME_delete (int4);
CREATE FUNCTION sql_TABLENAME_delete (int4) RETURNS int2 AS '
DECLARE
    id int4 := 0;
    id_exists int4 := 0;
    record1 RECORD; 
    record_backup RECORD;
    return_int4 int4 :=0;

BEGIN
     -- If the id is not greater than 0, return error.
   id := clean_numeric($1);
   IF id < 1 THEN return -1; END IF;

     -- If we find the id, set active = 0. 
   FOR record1 IN SELECT TABLENAME_id FROM TABLENAME 
          where TABLENAME_id = id
      LOOP
      update TABLENAME set active=0, date_updated = CURRENT_TIMESTAMP
           where TABLENAME_id = id;  
      GET DIAGNOSTICS return_int4 = ROW_COUNT;       
      id_exists := 1;
   END LOOP;
      
     -- If we did not find the id, abort and return -2.  
   IF id_exists = 0 THEN return (-2); END IF;

   FOR record_backup IN SELECT * FROM TABLENAME where TABLENAME_id = id
      LOOP
      insert into TABLENAME_backup (TABLENAME_id, date_updated, date_created,
          active BACKUPCOLUMNS ,error_code)
           values (record_backup.TABLENAME_id, record_backup.date_updated, 
             record_backup.date_updated, record_backup.active
             BACKUPVALUES , ''delete''
      );
   END LOOP;

     -- If id_exists == 0, Return error.
     -- It means it never existed. 
   IF id_exists = 0 THEN return (-1); END IF;

     -- We got this far, it must be true, return ROW_COUNT.   
   return (return_int4);
END;
' LANGUAGE 'plpgsql';

---------------------------------------------------------------------
drop function sql_TABLENAME_update (int4 FIELDS);
CREATE FUNCTION sql_TABLENAME_update  (int4 FIELDS) 
  RETURNS int2 AS '
DECLARE
    id int4 := 0;
    id_exists int4 := 0;
    record_update RECORD; record_backup RECORD;
    return_int4 int4 :=0;
    CLEANVARIABLES
BEGIN
    REMAKEVARIABLES
     -- If the id is not greater than 0, return error.
   id := clean_numeric($1);
   IF id < 1 THEN return -1; END IF;

   FOR record_update IN SELECT TABLENAME_id FROM TABLENAME
         where TABLENAME_id = id
      LOOP
      id_exists := 1;
   END LOOP;

   IF id_exists = 0 THEN return (-2); END IF;

   update TABLENAME set date_updated = CURRENT_TIMESTAMP
      UPDATEFIELDS 
        where TABLENAME_id = id;
   GET DIAGNOSTICS return_int4 = ROW_COUNT;

   FOR record_backup IN SELECT * FROM TABLENAME where TABLENAME_id = id
      LOOP
     insert into TABLENAME_backup (TABLENAME_id,
         date_updated, date_created, active
         BACKUPCOLUMNS, error_code)
       values (record_update.TABLENAME_id, record_backup.date_updated,
         record_backup.date_updated, record_backup.active
         BACKUPVALUES, ''update''
      );
   END LOOP;

     -- We got this far, it must be true, return ROW_COUNT.   
   return (return_int4);
END;
' LANGUAGE 'plpgsql';
---------------------------------------------------------------------

drop function sql_TABLENAME_copy (int4);
CREATE FUNCTION sql_TABLENAME_copy (int4) 
  RETURNS int2 AS '
DECLARE
    id int4 := 0;
    id_exists int4 := 0;
    record1 RECORD; record2 RECORD; record3 RECORD;    
    return_int4 int4 := 0;
    id_new int4 := 0;
    TABLENAME_new int4 :=0;
BEGIN
     -- If the id is not greater than 0, return error.
   id := clean_numeric($1);
   IF id < 1 THEN return -1; END IF;

   FOR record1 IN SELECT TABLENAME_id FROM TABLENAME where TABLENAME_id = id
      LOOP
      id_exists := 1;
   END LOOP;
   IF id_exists = 0 THEN return (-2); END IF;

     --- Get the new id
   FOR record1 IN SELECT sql_TABLENAME_insert() as TABLENAME_insert
      LOOP
      TABLENAME_new := record1.TABLENAME_insert;
   END LOOP;
     -- If the TABLENAME_new is not greater than 0, return error.
   IF TABLENAME_new < 1 THEN return -3; END IF;

   FOR record2 IN SELECT * FROM TABLENAME where TABLENAME_id = id
      LOOP

     FOR record1 IN SELECT sql_TABLENAME_update(TABLENAME_new COPYFIELDS)
        as TABLENAME_insert
      LOOP
        -- execute some arbitrary command just to get it to pass. 
      id_exists := 1;
     END LOOP;
   END LOOP;

     -- We got this far, it must be true, return new id.   
   return (TABLENAME_new);
END;
' LANGUAGE 'plpgsql';

------------------------------------------------------------------
drop function sql_TABLENAME_purge ();
CREATE FUNCTION sql_TABLENAME_purge () RETURNS int4 AS '
DECLARE
    record_backup RECORD; oid1 int4 := 0;
    return_int4 int4 :=0;
    deleted int4 := 0;
    delete_count int4 :=0;
    delete_id int4;

BEGIN 

     -- Now delete one by one. 
   FOR record_backup IN SELECT * FROM TABLENAME where active = 0
      LOOP
         -- Record the id we want to delete. 
      delete_id = record_backup.TABLENAME_id;

      insert into TABLENAME_backup (TABLENAME_id, date_updated, date_created,
          active BACKUPCOLUMNS ,error_code)
           values (record_backup.TABLENAME_id, record_backup.date_updated, 
             record_backup.date_updated, record_backup.active
             BACKUPVALUES , ''purge''
          );

        -- Get the unique oid of the row just inserted. 
      GET DIAGNOSTICS oid1 = RESULT_OID;

        -- If oid1 less than 1, return -1
      IF oid1 < 1 THEN return (-2); END IF;
        -- Now delete this from the main table.   
      delete from TABLENAME where TABLENAME_id = delete_id;

        -- Get row count of row just deleted, should be 1. 
      GET DIAGNOSTICS deleted = ROW_COUNT;
        -- If deleted less than 1, return -3
      IF deleted < 1 THEN return (-3); END IF;
      delete_count := delete_count + 1;

    END LOOP;

     -- We got this far, it must be true, return the number of ones we had.  
   return (delete_count);
END;
' LANGUAGE 'plpgsql';

------------------------------------------------------------------
drop function sql_TABLENAME_purgeone (int4);
CREATE FUNCTION sql_TABLENAME_purgeone (int4) RETURNS int4 AS '
DECLARE
    record_backup RECORD; oid1 int4 := 0;
    record1 RECORD;
    return_int4 int4 :=0;
    deleted int4 := 0;
    delete_count int4 :=0;
    delete_id int4;
    purged_no int4 := 0;

BEGIN

    delete_id := $1;
        -- If purged_id less than 1, return -4
    IF delete_id < 1 THEN return (-4); END IF;

   FOR record1 IN SELECT * FROM TABLENAME 
      where active = 0 and TABLENAME_id = delete_id 
      LOOP
      purged_no := purged_no + 1;
   END LOOP;

        -- If purged_no less than 1, return -1
   IF purged_no < 1 THEN return (-1); END IF;

     -- Now delete one by one.
   FOR record_backup IN SELECT * FROM TABLENAME where TABLENAME_id = delete_id
      LOOP

      insert into TABLENAME_backup (TABLENAME_id, date_updated, date_created,
          active BACKUPCOLUMNS ,error_code)
           values (record_backup.TABLENAME_id, record_backup.date_updated,
             record_backup.date_updated, record_backup.active
             BACKUPVALUES , ''purgeone''
          );

        -- Get the unique oid of the row just inserted.
      GET DIAGNOSTICS oid1 = RESULT_OID;

        -- If oid1 less than 1, return -2
      IF oid1 < 1 THEN return (-2); END IF;
        -- Now delete this from the main table.
      delete from TABLENAME where TABLENAME_id = delete_id;

        -- Get row count of row just deleted, should be 1.
      GET DIAGNOSTICS deleted = ROW_COUNT;
        -- If deleted less than 1, return -3
      IF deleted < 1 THEN return (-3); END IF;
      delete_count := delete_count + 1;

    END LOOP;

     -- We got this far, it must be true, return the number of ones we had.
   return (delete_count);
END;
' LANGUAGE 'plpgsql';

------------------------------------------------------------------------
drop function sql_TABLENAME_unpurge ();
CREATE FUNCTION sql_TABLENAME_unpurge () RETURNS int2 AS '
DECLARE
    record1 RECORD;
    record2 RECORD; 
    record_backup RECORD;
    purged_id int4 := 0;
    purge_count int4 :=0;
    timestamp1 timestamp;
    purged_no int4 := 0;
    oid1 int4 := 0;
    oid_found int4 := 0;
    highest_oid int4 := 0;

BEGIN

     -- Now get the unique ids that were purged. 
   FOR record1 IN select distinct TABLENAME_id from TABLENAME_backup 
       where TABLENAME_backup.error_code = ''purge''
          and NOT TABLENAME_id = ANY (select TABLENAME_id from TABLENAME)
      LOOP

      purged_id := record1.TABLENAME_id;
      timestamp1 := CURRENT_TIMESTAMP;
      purged_no := purged_no + 1;
      oid_found := 0;
      highest_oid := 0;

        -- Now we have the unique id, find its latest date. 

      FOR record2 IN select max(oid) from TABLENAME_backup 
          where TABLENAME_id = purged_id and error_code = ''purge''
        LOOP 
          -- record we got the date and also record the highest date.
        oid_found := 1; 
        highest_oid := record2.max;
      END LOOP;
 
         -- If the oid_found is 0, return error. 
      IF oid_found = 0 THEN return (-3); END IF;

        -- Now we have the latest date, get the values and insert them. 
      FOR record_backup IN select * from TABLENAME_backup 
          where oid = highest_oid
        LOOP 

      insert into TABLENAME_backup (TABLENAME_id, date_updated, date_created,
          active BACKUPCOLUMNS ,error_code)
           values (purged_id, record_backup.date_updated, 
             timestamp1, record_backup.active
             BACKUPVALUES , ''unpurge''
          );

        -- Get the unique oid of the row just inserted. 
      GET DIAGNOSTICS oid1 = RESULT_OID;
        -- If oid1 less than 1, return -1
      IF oid1 < 1 THEN return (-1); END IF;

      insert into TABLENAME (TABLENAME_id, date_updated, date_created,
          active BACKUPCOLUMNS)
           values (purged_id, timestamp1,
             timestamp1, record_backup.active
             BACKUPVALUES );
        -- Get the unique oid of the row just inserted.
      GET DIAGNOSTICS oid1 = RESULT_OID;
        -- If oid1 less than 1, return -2
      IF oid1 < 1 THEN return (-2); END IF;

      END LOOP;

   END LOOP;

     -- We got this far, it must be true, return how many were affected.  
   return (purged_no);
END;
' LANGUAGE 'plpgsql';

---------------------------------------------------------------------
drop function sql_TABLENAME_unpurgeone (int4);
CREATE FUNCTION sql_TABLENAME_unpurgeone (int4) RETURNS int2 AS '
DECLARE
    record_id int4;
    record1 RECORD;
    record2 RECORD;
    record_backup RECORD;
    return_int4 int4 :=0;
    purged_id int4 := 0;
    purge_count int4 :=0;
    timestamp1 timestamp;
    purged_no int4 := 0;
    oid1 int4 := 0;
    oid_found int4 := 0;
    highest_oid int4 := 0;

BEGIN

      purged_id := $1;
        -- If purged_id less than 1, return -1
      IF purged_id < 1 THEN return (-1); END IF;
        --- Get the current timestamp.
      timestamp1 := CURRENT_TIMESTAMP;

   FOR record1 IN select distinct TABLENAME_id from TABLENAME_backup
       where TABLENAME_backup.error_code = ''purge''
          and NOT TABLENAME_id = ANY (select TABLENAME_id from TABLENAME)
          and TABLENAME_id = purged_id
      LOOP
      purged_no := purged_no + 1;

   END LOOP;

        -- If purged_no less than 1, return -1
   IF purged_no < 1 THEN return (-3); END IF;

        -- Now find the highest oid.  
   FOR record2 IN select max(oid) from TABLENAME_backup
          where TABLENAME_id = purged_id and error_code = ''purge''
        LOOP
          -- record we got the date and also record the highest date.
        oid_found := 1;
        highest_oid := record2.max;
    END LOOP;

         -- If the oid_found is 0, return error.
    IF oid_found = 0 THEN return (-4); END IF;

        -- Now get the data and restore it. 
    FOR record_backup IN select * from TABLENAME_backup 
          where oid  = highest_oid
        LOOP 
        -- Insert into backup that it was unpurged. 
      insert into TABLENAME_backup (TABLENAME_id, date_updated, date_created,
          active BACKUPCOLUMNS ,error_code)
           values (purged_id, timestamp1, 
             record_backup.date_created, record_backup.active
             BACKUPVALUES , ''unpurgeone''
          );

        -- Get the unique oid of the row just inserted. 
      GET DIAGNOSTICS oid1 = RESULT_OID;
        -- If oid1 less than 1, return -1
      IF oid1 < 1 THEN return (-1); END IF;
        -- Insert into live table. 
      insert into TABLENAME (TABLENAME_id, date_updated, date_created,
          active BACKUPCOLUMNS)
           values (record_backup.TABLENAME_id, timestamp1,
             record_backup.date_updated, record_backup.active
             BACKUPVALUES );
        -- Get the unique oid of the row just inserted.
      GET DIAGNOSTICS oid1 = RESULT_OID;
        -- If oid1 less than 1, return -2
      IF oid1 < 1 THEN return (-2); END IF;

      END LOOP;

     -- We got this far, it must be true, return how many were affected (1).  
   return (purged_no);
END;
' LANGUAGE 'plpgsql';




