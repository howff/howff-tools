#!/bin/bash
# Show activity in postgresql server

cd /tmp

sudo -u postgres psql -c "SELECT 
    pid
    ,datname
    ,usename
    ,application_name
    ,client_hostname
    ,query_start
    ,query
    ,state
FROM pg_stat_activity
WHERE state = 'active';"

sudo -u postgres psql -c "select datname,usesysid,usename,client_hostname,state,query from pg_stat_activity  where pid <> pg_backend_pid()"
