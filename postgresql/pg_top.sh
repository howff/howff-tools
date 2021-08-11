#!/bin/bash

printf "Enter username for the isaric and covid19 databases: "
read user
if [ "$user" == "" ]; then user="abrooks"; fi

printf "Enter password for the isaric database: "
read passi
pg_top -U $user -W -h localhost -p 5432 -d isaric

printf "Enter password for the covid19 database: "
read passc
pg_top -U $user -W -h localhost -p 5433 -d covid19
