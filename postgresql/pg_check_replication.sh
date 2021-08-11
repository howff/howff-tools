#!/bin/bash

echo ""

echo "Use on data5:"
echo "\dRp+"
echo "select * from pg_stat_replication;"
echo "select * from pg_replication_slots;"
echo "select * from pg_current_wal_lsn();"
echo "select * from pg_publication;"
echo "select * from pg_publication_rel;"
echo "select * from pg_publication_tables;"
echo "select slot_name,database,active,pg_wal_lsn_diff(pg_current_wal_lsn(),restart_lsn) as retained_bytes from pg_replication_slots;"

echo ""

echo "Use on data4:"
echo "\dRs+"
echo "select * from pg_stat_subscription;"
echo "select * from pg_subscription;"
echo "select * from pg_subscription_rel;"
echo "select pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn(), pg_last_xact_replay_timestamp(), pg_current_wal_lsn(), pg_is_in_recovery();" # NOT pg_is_wal_replay_paused() 

