#!/bin/bash

DB="covid19"

echo "All permissions in schema covid19.*:"
psql -U postgres ${DB} -c '\z covid19.*'
echo "All permissions in schema isaric.*:"
psql -U postgres ${DB} -c '\z isaric.*'

sch="covid19"
view="ecoss"

echo "Permissions on ${sch}.${view}:"
psql -U postgres ${DB} -c "select coalesce(nullif(s[1], ''), 'public') as grantee,
  s[2] as privileges
from
  pg_class c
  join pg_namespace n on n.oid = relnamespace
  join pg_roles r on r.oid = relowner,
  unnest(coalesce(relacl::text[], format('{%s=arwdDxt/%s}', rolname, rolname)::text[])) acl,
  regexp_split_to_array(acl, '=|/') s
where nspname = '${sch}' and relname = '${view}';"
