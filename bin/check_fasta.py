#!/usr/bin/env python3
# Check that a fasta file has sets of two lines, patient and sequence

import lzma,sys
filename = sys.argv[1]
if '.xz' in filename:
  fd = lzma.open(filename) as fd:
else:
  fd = open(filename)
for patient in fd:
  if patient[0] != '>':
    print('Unexpected "%s", need > at start' % patient, file=sys.stderr)
    exit(1)
  else:
    pass #print('OK %s' % patient, end='')
  sequence=next(fd)
  if len(sequence) != 29904:
    print('Unexpected line of length %d wanted 29904 for patient %s' % (len(sequence), patient), file=sys.stderr, end='')
    exit(2)
  else:
    pass #print('OK %d' % len(sequence))
exit(0)
