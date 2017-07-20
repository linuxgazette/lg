# Edit to suit your local environment.
PSQL='/usr/local/bin/psql'

PGOPTS='-X -q'
# PGOPTS='-X -a'
CONTRIB=`pg_config --sharedir`/contrib
PGADMIN=postgres
DBPROTO=template1
DBENCODE='UNICODE'
DBNAME=accounts

# PostgreSQL roles
#
# DBOWNER owns the database (and all objects in it)
DBOWNER=accadmin
#
# PUBUSER is the account we use to access the public interface
PUBUSER=jq_public

# Application administrative account
#
# The ADMIN account can create, modify, and delete other accounts.
ADMIN=admin
