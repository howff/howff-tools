#!/bin/sh

set -e

if [ -z "$1" ];then
  echo "Usage: postgres_refresh_remote_view.sh <view> [<schema>]"
  exit 1
fi

echo "$(date) $0 $@"

DB="isaric"
VIEW_NAME="$1"
SCHEMA=${2:-isaric}

# psql complains if it is in a protected directory
cd /tmp

# Must be owner of view, so cannot do this:
#psql -h localhost -U abrooks -c "set role isaric_admin; refresh materialized view isaric.isaric;" isaric

# Do it as postgres:
sudo -u postgres psql ${DB} <<EOF
SET ROLE isaric_admin;

SELECT dblink_connect('conn_db_link', 'covid19_live');

BEGIN;

\timing on

REFRESH MATERIALIZED VIEW ${SCHEMA}.${VIEW_NAME};

COMMIT;

SELECT dblink_disconnect('conn_db_link');
EOF
