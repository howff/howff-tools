#!/usr/bin/env python3
# Various checks on a CSV file:
#  * determine the delimiter (comma, tab, pipe)
#  * number of fields in each row must match number of fields in header
#  * column names are not > 63 chars (warn if truncated name is not unique)
#  * column names do not start with a digit (can be quoted in postgresql)
#  * rows without a value in every field (optional)

import csv, sys

verbose = False
check_column_count = True
check_for_empty_column = False

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
 
def check_column_names(hdr):
  for col in hdr:
    if len(col) > 63: print('  WARN: >63 chars in: %s' % col)
    if col[0] in '0123456789': print('  WARN: column name starts with digit: %s' % col)
  shortnames = [s[:63] for s in hdr]
  clashes = set([s for s in shortnames if shortnames.count(s) > 1])
  for clash in clashes: print('  WARN: truncated name is not unique: %s' % clash)

def check_csv_file(filename):
  sep = determine_csv_delimiter(filename)
  with open(filename, 'r') as fd:
    csvfd = csv.reader(fd, delimiter=sep)
    hdr = next(csvfd)
    nfields = len(hdr)
    print('  %d columns' % nfields)
    check_column_names(hdr)
    rownum = 0
    numwarnings = 0
    for row in csvfd:
      rownum = rownum+1
      if verbose: print('\r%d\r' % rownum, end='')
      # Check every row has the same number of fields (find unquoted strings, etc)
      if check_column_count:
        if len(row) != nfields:
          numwarnings = numwarnings+1
          if numwarnings == 10:
            print('  more warnings suppressed')
            #numwarnings=9
          else:
            print('  row %d expected %d cols but got %d' % (rownum, nfields, len(row)))
      # Warn about empty fields?
      if check_for_empty_column:
        for col in row:
          if len(col) ==0:
            print('row %d has an empty column' % n)
    print('  %d rows' % rownum)

for filename in sys.argv[1:]:
  print(f'Checking: {filename}')
  check_csv_file(filename)

