#!/usr/bin/env python3
# Check that the newick-format file can be parsed.
# Handles .xz compressed filenames too.
# Assumes UTF-8 encoding.
# Exit code will be non-zero on error as the newick functions will raise an exception.

import lzma,newick,sys
filename = sys.argv[1]
if '.xz' in filename:
  newick.loads(lzma.open(filename).read().decode('utf8'))
else:
  newick.read(filename)
exit(0)
