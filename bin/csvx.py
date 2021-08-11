#!/usr/bin/env python3

import csv
import sys

verbose = False
check_column_count = True
check_for_empty_column = False
colname = ''

def determine_csv_delimiter(filename):
  with open(filename, 'r') as fd:
    csvfd = csv.reader(fd, delimiter='|')
    hdr = next(csvfd)
  if len(hdr) > 1:
    return '|'
  with open(filename, 'r') as fd:
    csvfd = csv.reader(fd, delimiter='')
    hdr = next(csvfd)
  if len(hdr) > 1:
    return ''
  with open(filename, 'r') as fd:
    csvfd = csv.reader(fd, delimiter=',')
    hdr = next(csvfd)
  if len(hdr) > 1:
    return ','
  print('ERROR: cannot determine CSV delimiter in %s' % filename)
  return ','
 
  
def extract_csv_column(filename, colname):
  sep = determine_csv_delimiter(filename)
  with open(filename, 'r') as csvfd:
    rownum=0
    for row in csv.DictReader(csvfd):
      print('row %d [%s] = %s' % (rownum,colname,row[colname]))
      rownum = rownum+1

colname = sys.argv[1]
for filename in sys.argv[2:]:
  extract_csv_column(filename, colname)

