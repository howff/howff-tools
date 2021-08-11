#!/bin/bash

# Create the user account with a random password
# Grant access to a specific role "isaric_user" or "isaric_admin"
# Grant access to a specific database "isaric" via pg_hba.conf
# Reload config

DB="isaric"
PG_DATA_DIR="/data/pgsql/12/data"
PG_BIN_DIR="/usr/pgsql-12/bin"
IP_ADDR="10.22.0.1/32" # ultra as seen from c19-isaric01

new_user="$1"
new_role="$2"
usage="Usage: $0 new_username isaric_user|isaric_admin"

if [ "$new_user" == "" ]; then
  echo "$usage" >&2
  exit 1
fi

if [ "$new_role" == "" ]; then
  echo "$usage" >&2
  exit 1
fi

# Check if user already exists
if psql -c "select rolname,rolcanlogin from pg_roles where rolcanlogin = true;" postgres | grep " $new_user " > /dev/null; then
  echo "ERROR: username $new_user already exists" >&2
  exit 1
fi

# Prevent errors from accessing current directory when sudo
cd /tmp

new_pass=`</dev/urandom tr -dc '12345!@#$%qwertQWERTasdfgASDFGzxcvbZXCVB' | head -c8; echo ""`

echo "Creating ${new_user} with password ${new_pass}"
sudo -u postgres psql -c "CREATE ROLE ${new_user} PASSWORD '${new_pass}' LOGIN;"
sudo -u postgres psql postgres -c "GRANT ${new_role} TO ${new_user};"

echo "Adding permission to access server"
sudo sed -ibck '$a'"host ${DB} ${new_user} ${IP_ADDR} md5" ${PG_DATA_DIR}/pg_hba.conf

echo "Restarting server"
sudo -u postgres ${PG_BIN_DIR}/pg_ctl reload -D ${PG_DATA_DIR}

