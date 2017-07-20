#! /bin/bash

source ./environment.sh

${PSQL} ${PGOPTS} -U ${PGADMIN} <<EOSQL
DROP DATABASE ${DBNAME};
DROP ROLE ${DBOWNER};
DROP ROLE ${PUBUSER};
EOSQL
