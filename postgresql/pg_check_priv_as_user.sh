#!/bin/bash
# Show the privileges as a given user
# Usage: username password
# eg. alaw and isaric users

DB="isaric2"
SCH="schema2"

export PGUSER="$1"
export PGPASSWORD="$2"

echo "For ${PGUSER}:"
psql -U ${PGUSER} ${DB} -c "SELECT table_catalog, table_schema, table_name, privilege_type FROM   information_schema.table_privileges;" | egrep -v 'pg_catalog|information_schema'
