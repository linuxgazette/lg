#! /bin/bash

source ./environment.sh

echo "Setup PostgreSQL roles"
read -s -e -p "Enter password for database owner '${DBOWNER}': " DBPASS
echo
read -s -e -p "Enter password for user '${PUBUSER}': " JQPASS
echo
echo "Setup application administrative account"
read -s -e -p "Enter password for initial admin account '${ADMIN}': " ADMINPASS
echo
echo


########################################################################
# Create required roles and then create the database.
${PSQL} -U ${PGADMIN} ${PGOPTS} <<EOSQL
CREATE ROLE ${DBOWNER} LOGIN PASSWORD '${DBPASS}';
CREATE ROLE ${PUBUSER} LOGIN PASSWORD '${JQPASS}';
CREATE DATABASE ${DBNAME} OWNER ${DBOWNER} TEMPLATE ${DBPROTO} ENCODING '${DBENCODE}';
EOSQL
########################################################################



########################################################################
# Create private schema. Every database object we create, except for
# our interface functions, will go into this restricted schema.
#
# Public schema will contain interface functions available to our John
# Q Public user.
#
# export PGPASSWORD=${DBPASS}
${PSQL} -U ${PGADMIN} -d ${DBNAME} ${PGOPTS} <<EOSQL
CREATE SCHEMA private AUTHORIZATION ${DBOWNER};
CREATE SCHEMA interface AUTHORIZATION ${DBOWNER};
-- 
GRANT USAGE ON SCHEMA interface TO ${PUBUSER};
EOSQL
########################################################################



########################################################################
# Load extra functions we need
#
# The search path for pgcrypto is set at the beginning of the pgcrypto.sql file.
# We strip that out so we can set the search path we want.
#
TMP=./pgcrypt.tmp.sql
grep -A 1000 search_path ${CONTRIB}/pgcrypto.sql | tail -n +2 > ${TMP}
if [ -s ${TMP} ]; then
    echo "SET search_path TO private;" | \
        cat - ${TMP} | \
        psql -U ${PGADMIN} -d ${DBNAME}
    rm -f ${TMP}
else
    echo "Error: ${TMP} file doesn't exist or is empty."
    echo "Did you build pgcrypto contrib module?"
    echo
    exit
fi
########################################################################



########################################################################
# Create private tables, functions, and so forth
#
export PGPASSWORD=${DBPASS}
${PSQL} -U ${DBOWNER} -d ${DBNAME} -h localhost ${PGOPTS} <ddl.sql

${PSQL} -U ${DBOWNER} -d ${DBNAME} -h localhost ${PGOPTS} <<EOSQL
------------------------------------------------------------------------
SET search_path TO interface;

SELECT register( '${ADMIN}', '${ADMINPASS}' );

SET search_path TO private;

INSERT INTO administrators ( account )
  SELECT account_id
  FROM accounts
  WHERE username = '${ADMIN}';
------------------------------------------------------------------------
EOSQL
