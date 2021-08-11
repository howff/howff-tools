#!/bin/bash

pg_user="abrooks"
if [ "$1" != "" ]; then pg_user="$1"; fi
pg_db="covid19" # covid19 on data5, isaric on data4

#export PGPASSWORD=""

echo "===================================================================================="
echo "Table: isaric_data"
psql -h localhost -U abrooks -c "select min(epcc_date_received),max(epcc_date_received),min(epcc_date_inserted),max(epcc_date_inserted) from isaric.isaric_data" $pg_db

echo "===================================================================================="
echo "View: isaric"
psql -h localhost -U abrooks -c "select min(epcc_date_received),max(epcc_date_received),min(epcc_date_inserted),max(epcc_date_inserted) from isaric.isaric" $pg_db

# XXX why are these missing?
# isaric_definite_no_subjid isaric_keep_14 isaric_keep_14_28
for table in isaric_clean isaric_oneline isaric_outcome isaric_surv isaric_topline isaric_treatment; do
    echo "===================================================================================="
    echo "Table: ${table}_data"
    psql -h localhost -U abrooks -c "select min(epcc_date_received) as min_date_rx,max(epcc_date_received) as max_date_rx,min(epcc_date_inserted) as min_date_inserted,max(epcc_date_inser
ted) as max_date_inserted from isaric.${table}_data" $pg_db
    psql -h localhost -U abrooks -c "select min(raw_epcc_date_received) as min_raw_date_rx, max(raw_epcc_date_received) as max_raw_date_rx, min(epcc_date_received) as min_date_rx, max(ep
cc_date_received) as max_date_rx, min(epcc_date_inserted) as min_date_inserted, max(epcc_date_inserted) as max_date_inserted from isaric.${table}_data" $pg_db
    echo "View: ${table}"
    psql -h localhost -U abrooks -c "select min(epcc_date_received) as min_date_rx, max(epcc_date_received) as max_date_rx, min(epcc_date_inserted) as min_date_inserted ,max(epcc_date_in
serted) as max_date_inserted from isaric.${table}" $pg_db
    psql -h localhost -U abrooks -c "select min(raw_epcc_date_received) as min_raw_date_rx,max(raw_epcc_date_received) as max_raw_date_rx,min(epcc_date_received) as min_date_rx,max(epcc_
date_received) as max_date_rx,min(epcc_date_inserted) as min_date_inserted,max(epcc_date_inserted) as max_date_inserted from isaric.${table}" $pg_db
done

