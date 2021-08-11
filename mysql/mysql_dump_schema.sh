#!/bin/bash

h="data3"
u="andrewb"
p=""
db="data_load2"
tbl="CT_SeriesTable"

#opts="--xml --no-data --lock-tables=false" # for MyISAM
opts="--xml --no-data --single-transaction=true" # for InnoDB
opts="--no-data --single-transaction=true" # for InnoDB
now=`date +%Y%m%d-%H%M%S`

mysqldump -h $h -u $u --password="$p" $opts $db $tbl > ${db}_${tbl}_${now}.xml
