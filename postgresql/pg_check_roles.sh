#!/bin/bash
# Display the permissions granted to the given user.
# Usage: [user]  eg. "isaric_user"

user="isaric_user"
if [ "$1" != "" ]; then user="$1"; fi

pg_user="abrooks"
pg_database="isaric"

psql -h localhost -U ${pg_user} -c "select distinct relname from pg_roles cross join pg_class where relnamespace != 11 and relnamespace != 99 and relnamespace != 13887 and pg_has_role('"$user"', rolname, 'member') and has_table_privilege(rolname, pg_class.oid, 'select');" ${pg_database}
