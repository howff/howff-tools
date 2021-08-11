#!/bin/bash

DB="covid19"
#export PGPASSWORD=""

psql -U postgres ${DB} -c '\z *.*'|egrep -v 'pg_catalog|information_schema|^   '
