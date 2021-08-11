#!/bin/bash

cd /tmp

echo "ROLES (cannot login)"
sudo -u postgres psql -c "select rolname,rolcanlogin from pg_roles where rolcanlogin = false;"|grep -v pg_

echo "USERS (roles which can login)"
sudo -u postgres psql -c "select rolname,rolcanlogin from pg_roles where rolcanlogin = true;"|grep -v pg_
