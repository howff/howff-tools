#!/usr/bin/env python3

import re
import requests
import sys

repo = sys.argv[1]

if not 'github.com' in repo:
	repo = 'https://github.com/' + repo

repo += '/network/members' # list of forks

resp = requests.get(repo)

# Look for: <a class="" href="/zaitompro/pydal">pydal</a>

for match in re.findall('<a class="" href="([^"]*)">', resp.text):
    print('Found a fork in %s ' % match, end='')
    fork = 'https://github.com' + match
    fork_resp = requests.get(fork)
    fork_match = re.findall('This branch is .*([0-9]+ commits [a-z]*)', fork_resp.text)
    if fork_match:
        print(' %s' % fork_match[0])
    else:
        print('?')
