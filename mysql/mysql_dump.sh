#!/bin/bash

h="data3"
u="andrewb"
p=""

h="localhost"
u="root"
p=""

db="launchpad"

opts="--skip-opt --skip-extended-insert --skip-lock-tables --column-statistics=0"
opts="--skip-opt --skip-extended-insert --skip-lock-tables"
now=`date +%Y%m%d-%H%M%S`

tbl="CT_SeriesTable"
mysqldump -h $h -u $u --password="$p" $opts $db $tbl | bzip2 -c > ${db}_${tbl}_${now}.sql.bz2

tbl="CT_StudyTable"
mysqldump -h $h -u $u --password="$p" $opts $db $tbl | bzip2 -c > ${db}_${tbl}_${now}.sql.bz2
