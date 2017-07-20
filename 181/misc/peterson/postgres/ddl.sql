------------------------------------------------------------------------
SET search_path TO private;
------------------------------------------------------------------------


------------------------------------------------------------------------
CREATE TABLE accounts (
  account_id
    UUID
    NOT NULL
    DEFAULT encode( gen_random_bytes( 16 ), 'hex' )::uuid
    PRIMARY KEY,
  username
    VARCHAR(8)
    NOT NULL
    CHECK( username ~ '^[_a-z]{1}[-_a-z0-9]{0,7}$' ),
  salt
    CHAR(24)
    NOT NULL
    DEFAULT ENCODE( gen_random_bytes( 12 ), 'hex' ),
  -- sha256 hash of salt+password
  passhash
    BYTEA
    NOT NULL
    DEFAULT gen_random_bytes( 32 )
);
CREATE UNIQUE INDEX account_idx ON accounts( username );

CREATE RULE administrator_account_protect__rule AS
ON DELETE TO accounts
WHERE username = '${ADMIN}'
DO INSTEAD NOTHING;
------------------------------------------------------------------------


------------------------------------------------------------------------
-- Can have multiple simultaneous sessions from same account, e.g.
-- logged in from different computers.  However, we compare 'started'
-- with 'last_touch' time, and if they are close, we return the existing
-- session id, rather than creating a new one.
--
CREATE TABLE sessions (
  account
    UUID
    NOT NULL
    REFERENCES accounts( account_id ),
  started
    TIMESTAMP WITH TIME ZONE
    NOT NULL
    DEFAULT CURRENT_TIMESTAMP,
  last_touch
    TIMESTAMP WITH TIME ZONE
    NOT NULL
    DEFAULT CURRENT_TIMESTAMP,
  session_id
    UUID
    NOT NULL
    DEFAULT ENCODE( gen_random_bytes( 16 ), 'hex' )::UUID
    PRIMARY KEY
);
------------------------------------------------------------------------


------------------------------------------------------------------------
CREATE TABLE administrators (
  account
    UUID
    REFERENCES accounts( account_id )
    PRIMARY KEY
);

-- Don't allow primary administrative account to be deleted.
CREATE RULE administrators__preserve_primary_admin
AS ON DELETE TO administrators
WHERE
  account IN
  (SELECT account_id FROM accounts WHERE username = '${ADMIN}')
DO INSTEAD nothing;
------------------------------------------------------------------------



------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
-- INTERNAL FUNCTIONS
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------



------------------------------------------------------------------------
-- Verify whether password is valid for given username
CREATE OR REPLACE FUNCTION
i_verify_password( IN un TEXT,
                   IN password TEXT,
                   OUT ok BOOL )
AS $$
SELECT
  passhash = digest( (salt || $2)::BYTEA, 'SHA256' )
FROM
  accounts
WHERE
  username = $1;
$$ LANGUAGE SQL;
------------------------------------------------------------------------


------------------------------------------------------------------------
-- Given a session id, return user's account_id if session exists,
-- and update last_touch field.
CREATE OR REPLACE FUNCTION
i_get_session_account_id ( sessionId UUID )
RETURNS UUID AS
$$
DECLARE
  accountId UUID;
BEGIN
  SELECT account
  INTO accountId
  FROM sessions
  WHERE session_id = sessionId;
  --
  IF FOUND THEN
    UPDATE sessions
    SET last_touch = now();
  ELSE
    RAISE EXCEPTION 'session_check: session % was not found', sessionId;
  END IF;
  --
  RETURN accountId;
END;
$$
LANGUAGE plpgsql;
------------------------------------------------------------------------


------------------------------------------------------------------------
-- Does username correspond to session id?
CREATE OR REPLACE FUNCTION
i_is_self( IN un TEXT,
           IN sessionId UUID )
RETURNS BOOL AS
$$
DECLARE
  authorized BOOL;
BEGIN
  authorized = false;
  SELECT account_id IS NOT NULL
  FROM sessions, accounts
  WHERE sessions.session_id = sessionId AND
        sessions.account = accounts.account_id AND
        accounts.username = un
  INTO STRICT authorized;
  RETURN authorized;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
      RETURN false;
END;
$$ LANGUAGE plpgsql;
------------------------------------------------------------------------


------------------------------------------------------------------------
-- Does session id belong to an administrator?
CREATE OR REPLACE FUNCTION
i_is_admin( IN sessionId UUID )
RETURNS BOOL AS
$$
DECLARE
  authorized BOOL;
BEGIN
  authorized = false;
  SELECT administrators.account IS NOT NULL
  FROM sessions, administrators
  WHERE sessions.session_id = sessionId AND
        sessions.account = administrators.account
  INTO STRICT authorized;
  RETURN authorized;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
      RETURN false;
END;
$$ LANGUAGE plpgsql;

CREATE TYPE login_info AS ( session_id UUID, is_admin BOOLEAN );
------------------------------------------------------------------------


------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
-- EXTERNAL INTERFACE FUNCTIONS
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------


------------------------------------------------------------------------
SET search_path TO interface, private;
------------------------------------------------------------------------

-- GENERAL NOTE
-- Input parameter types must match types available to wso2's data
-- services server, namely:
-- STRING
-- INTEGER
-- REAL
-- DOUBLE
-- NUMERIC
-- TINYINT
-- SMALLINT
-- BIGINT
-- DATE[yyyy-mm-dd]
-- TIME[hh:mm:ss]
-- TIMESTAMP
-- BIT
-- ORACLE REF CURSOR
--
-- That means that we often have to accept a string value, and then cast
-- to the type we want inside our function (e.g. pass UUID as TEXT).

-- Create a new user account with password.
CREATE OR REPLACE FUNCTION
register( IN un TEXT,
            IN password TEXT )
RETURNS BOOL AS
$$
DECLARE
  old_path TEXT;
  salt CHAR(24);
BEGIN
  old_path := pg_catalog.current_setting('search_path');
  PERFORM pg_catalog.set_config('search_path', 'private', true);

  salt := ENCODE( gen_random_bytes( 12 ), 'hex' );

  INSERT INTO accounts ( username, salt, passhash )
  VALUES ( $1,
           salt,
           digest( (salt || password)::BYTEA, 'SHA256' )
         );

  PERFORM pg_catalog.set_config('search_path', old_path, true);

  RETURN true;

  EXCEPTION
    WHEN unique_violation THEN
      RAISE NOTICE 'register: %', SQLERRM;
      RETURN false;
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER
VOLATILE;

-- Insert a username into the session table if it doesn't already
-- exist.  Return the associated session_id for the username.
CREATE OR REPLACE FUNCTION
login ( un TEXT,
        pw TEXT )
RETURNS private.login_info AS
$$
DECLARE
  old_path TEXT;
  sessionId UUID;
  accountId UUID;
  authOK BOOLEAN;
  isAdmin BOOLEAN;
  ret private.login_info;
BEGIN
  authOK := false;

  old_path := pg_catalog.current_setting('search_path');
  PERFORM pg_catalog.set_config('search_path', 'private', true);

  SELECT account_id, account IS NOT NULL
  INTO accountId, isAdmin
  FROM accounts
  LEFT OUTER JOIN administrators
  ON ( accounts.account_id = administrators.account )
  WHERE username = un;

  IF NOT FOUND THEN
    RAISE WARNING 'login: username % not found', un;
    PERFORM pg_catalog.set_config('search_path', old_path, true);
    RETURN NULL;
  END IF;
  SELECT i_verify_password( un, pw ) INTO STRICT authOK;

  IF authOK THEN
    SELECT session_id
    INTO sessionId
    FROM sessions, accounts
    WHERE accounts.username = un AND
          accounts.account_id = sessions.account;
  ELSE
    RAISE WARNING 'login: bad password for %', un;
    PERFORM pg_catalog.set_config('search_path', old_path, true);
    RETURN NULL;
  END IF;

  IF NOT FOUND THEN
    RAISE INFO 'login: creating new session for username %', un;
    sessionId = ENCODE( gen_random_bytes( 16 ), 'hex' )::UUID;
    INSERT INTO sessions ( session_id, account ) VALUES ( sessionId, accountId );
  ELSE
    UPDATE sessions SET last_touch = CURRENT_TIMESTAMP
    WHERE session_id = sessionId;
  END IF;

  PERFORM pg_catalog.set_config('search_path', old_path, true);

--  SELECT ROW( sessionId::UUID, isAdmin ) INTO ret;
  SELECT sessionId::UUID, isAdmin INTO ret;
  RETURN ret;
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER
VOLATILE;


-- Terminate session
CREATE OR REPLACE FUNCTION
logout ( sessionId VARCHAR(36) )
RETURNS BOOL AS
$$
DECLARE
  old_path TEXT;
BEGIN
  old_path := pg_catalog.current_setting('search_path');
  PERFORM pg_catalog.set_config('search_path', 'private', true);

  DELETE FROM sessions
  WHERE session_id = sessionId::UUID;
  --
  IF FOUND THEN
    RAISE INFO 'logout: session % terminated', sessionId;
    PERFORM pg_catalog.set_config('search_path', old_path, true);
    RETURN true;
  ELSE
    RAISE INFO 'logout: session % was not found', sessionId;
    PERFORM pg_catalog.set_config('search_path', old_path, true);
    RETURN false;
  END IF;
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER
VOLATILE;


-- Reset password, if session user is authorized.
CREATE OR REPLACE FUNCTION
set_password( IN un TEXT,
              IN password TEXT,
              IN sessionId TEXT )
RETURNS BOOL AS
$$
DECLARE
  old_path TEXT;
BEGIN
  old_path := pg_catalog.current_setting('search_path');
  PERFORM pg_catalog.set_config('search_path', 'private', true);

  IF i_is_self( un, sessionId::UUID ) OR i_is_admin( sessionId::UUID ) THEN
    UPDATE accounts
    SET passhash = digest( (salt || $2)::BYTEA, 'SHA256' )
    WHERE username = $1;
    PERFORM pg_catalog.set_config('search_path', old_path, true);
    RETURN true;
  ELSE
    RAISE WARNING 'set_password: password change attempted for % by unauthorized user', un;
    PERFORM pg_catalog.set_config('search_path', old_path, true);
    RETURN false;
  END IF;

  PERFORM pg_catalog.set_config('search_path', old_path, true);

  RETURN false;
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER
VOLATILE;


CREATE OR REPLACE FUNCTION
get_usernames( IN sessionId TEXT )
RETURNS SETOF VARCHAR(8) AS
$$
DECLARE
  old_path TEXT;
BEGIN
  old_path := pg_catalog.current_setting('search_path');
  PERFORM pg_catalog.set_config('search_path', 'private', true);

  IF sessionId IS NULL THEN
    RETURN;
  END IF;

  IF i_is_admin( sessionId::UUID ) THEN
    RETURN QUERY
      SELECT username
      FROM accounts
      ORDER BY username;
    RETURN;
  ELSE
    RETURN QUERY
      SELECT username
      FROM accounts, sessions
      WHERE sessions.account = accounts.account_id AND
            sessions.session_id = sessionId::UUID;
    RETURN;
  END IF;

  IF NOT FOUND THEN
    RAISE INFO 'get_usernames: username not found';
  END IF;

  PERFORM pg_catalog.set_config('search_path', old_path, true);

  RETURN;
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER
VOLATILE;
------------------------------------------------------------------------
