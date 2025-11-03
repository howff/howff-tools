#!/usr/bin/env python3
# Find directories which contain exactly the same set of filenames
# (does not take timestamps into account, does not compare file contents)

import os

dir='c:\\users\\arb\\Downloads\\DVDs'
print('=============================================================')
print('dir %s' % dir)
#print(sorted(os.listdir(dir)))

dir_entries = dict()  # indexed by directoryname, contains the hash of all files
dir_list = dict()     # indexed by directoryname, contains a list of filenames
hash_entries = dict() # indexed by hash, contains a list of directories having that hash

for current_dir, subdirs, files in os.walk(dir):
    if (len(files) == 0):
        continue
    sorted_files = sorted(files)
    hash_of_files = hash(tuple(sorted_files))
    dir_entries[current_dir] = hash_of_files
    dir_list[current_dir] = files
    if hash_entries.get(hash_of_files):
        hash_entries[hash_of_files].append(current_dir)
    else:
        hash_entries[hash_of_files] = [current_dir]

for vv in hash_entries:
    if (len(hash_entries[vv]) > 1):
        print('hash %s = %s' % (vv, hash_entries[vv]))
    if (len(hash_entries[vv]) > 2):
        for xx in dir_entries:
            if dir_entries[xx] == vv:
                print('%s = %s' % (xx, dir_list[xx]))