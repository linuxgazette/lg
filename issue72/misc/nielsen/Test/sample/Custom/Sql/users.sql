select sql_users_insert();
select sql_users_update(1,'Username1','Password1',1);
select sql_users_insert();
select sql_users_update(2,'Username2','Password2',1);

drop function sql_users_verify(text,text);
CREATE FUNCTION sql_users_verify (text,text) RETURNS int4 AS '
DECLARE
    record1 record;  id int4 :=0;
    username text; password text;
    active int4 := 0;
BEGIN
   username := clean_text($1);
   password := clean_text($2);

   FOR record1 IN SELECT users_id FROM users
        where users.username = username
          and users.password = password
          and users.active = 1
      LOOP
      id := record1.users_id;
   END LOOP;

     -- If id < 1 check if username exists .
   IF id is NULL THEN  
     FOR record1 IN SELECT users_id,active FROM users
        where users.username = username
       LOOP
       id := record1.users_id;
--       active := record1.active;
         -- If active is < 1, isn not active.
--       IF active < 1 THEN return (-3); END IF;
         -- If id is > 0, password is incorrect.
       IF id  > 0 THEN return (-2); END IF;
       END LOOP;
   END IF;

        -- If id is < 1, username does not exist. 
   IF id  < 1 THEN return (-1); END IF;

     -- Everything has passed, return id as users_id.
   return (id);
END;
' LANGUAGE 'plpgsql';
select sql_users_verify('Username1','Password1');

drop function sql_users_exists(text);
CREATE FUNCTION sql_users_exists (text) RETURNS int4 AS '
DECLARE
    record1 record;  id int4 :=0;
    username text; password text;
BEGIN
   username := clean_text($1);

   FOR record1 IN SELECT users_id FROM users
        where users.username = username
      LOOP
      id := record1.users_id;
   END LOOP;

     -- Everything has passed, return id as users_id.
   return (id);
END;
' LANGUAGE 'plpgsql';
select sql_users_exists('Username1');

drop function sql_users_active(text);
CREATE FUNCTION sql_users_active (text) RETURNS int4 AS '
DECLARE
    record1 record;  id int4 :=0;
    username text; password text;
BEGIN
   username := clean_text($1);

   FOR record1 IN SELECT users_id FROM users where users.username = username
      LOOP
      id := record1.users_id;
   END LOOP;

     -- Everything has passed, return id as users_id.
   return (id);
END;
' LANGUAGE 'plpgsql';
select sql_users_active('Username1');


