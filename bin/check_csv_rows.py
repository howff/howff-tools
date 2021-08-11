#!/usr/bin/env python3
# Checks that all rows have the same number of fields as the header row.
# Handles .xz compressed files too.

import csv,lzma,sys
filename = sys.argv[1]
if '.xz' in filename:
  fd = lzma.open(filename)
  data = fd.read().decode('utf8')
else:
  fd = open(filename)
  data = fd.read()
reader = csv.DictReader(data.splitlines())
hdr = next(reader)
num_fields = len(hdr)
for row in reader:
  if len(row) != num_fields:
    print('ERROR: expected %d fields got %d in "%s"' % (num_fields, len(row), filename))
    print(row)
    exit(1)
exit(0)
