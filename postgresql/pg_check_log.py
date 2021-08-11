#!/usr/bin/env python3
# Outputs all lines from postgres log files EXCEPT for the grafana queries.
# Must be run using sudo to get permission to read log file directory.

import glob
import re
import sys

log_pattern = '/db/c19-proj/pg_log/postgresql*.log'
log_pattern = '/db/isaric-nsh/pg_log/postgresql*.log'
log_pattern = '/db/prod-db01-pg12/pg_log/postgresql*.log'

if len(sys.argv) > 1:
  log_pattern = sys.argv[1]

# Want to ignore patterns like these:
# 2021-02-26 08:00:08.321 UTC [postgres_exporter_isaric postgres 19991] LOG:  statement: SELECT 'lib/pq ping test';
# 2020-05-28 09:14:40.639 UTC [postgres pgbench 29771] LOG:  statement: SELECT abalance FROM pgbench_accounts WHERE aid = 56

grafana_pattern = '.*postgres_exporter_isaric .*LOG:  statement:.*' # grafana by itself
pgbench_pattern = '.*postgres pgbench.*LOG:  statement:.*'          # pgbench by itself
ignore_pattern  = '('+grafana_pattern+')|('+pgbench_pattern+')'     # put them together in brackets separated by pipe
ignore_pattern  = '.*LOG:  statement:.*'                            # ANY sql statement
ignore_re = re.compile(ignore_pattern)

for file in sorted(glob.glob(log_pattern)):
  print(file)
  with open(file, 'r') as fd:
    for line in fd:
      line = line.rstrip()
      if len(line) < 2:
        continue
      if line[0] == '\t' and was_grafana:
        continue
      was_grafana = not (ignore_re.match(line) is None)
      if not was_grafana:
        print(line)
