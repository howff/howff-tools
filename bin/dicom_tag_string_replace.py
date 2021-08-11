#!/usr/bin/env python3
# A text filter which replaces DICOM tags by their textual label.
# eg. to find the SeriesInstanceUID from a DICOM file:
# dcm2json file.dcm | dicom_tag_lookup.py | jq '..|.SeriesInstanceUID|.Value'

import re
import sys
try:
  from pydicom.datadict import keyword_for_tag
except:
  print('You need to install the pydicom library:')
  print('  python3 -m pip install --user /home/import/python_pip/pydicom-1.4.0-py2.py3-none-any.whl')
  exit(1)

# ---------------------------------------------------------------------
def dicom_tag_subst(fd_in, fd_out):
    for line in fd_in:
        for match in re.findall('[0-9A-Fa-f]{4},{0,1}[0-9A-Fa-f]{4}', line):
           label = keyword_for_tag(int(match.replace(',', ''), 16))
           if label != '':
               line = re.sub(match, label, line)
        print(line, end='')

# ---------------------------------------------------------------------

if __name__ == "__main__":
    dicom_tag_subst(sys.stdin, sys.stdout)
