#!/usr/bin/env python3
# After you have saved all messages to a JSON file
# you can pipe that file through this program to
# filter out the messages where Tesseract caused IsIdentifiable to crash
# and print a command line to re-run that DICOM file through CTP again.

import json
import os
import sys

dry_run = False

num_messages = 0
num_IsIdentifiable = 0
num_tesseract = 0
errmsg = 'Exception while classifying ExtractedFileStatusMessage:\nSystem.ApplicationException: Could not run Tesseract'

messages = json.load(sys.stdin)
for msg in messages:
    num_messages += 1
    if msg['header']['ProducerExecutableName'] != 'IsIdentifiable':
        continue
    num_IsIdentifiable += 1
    if msg['body']['Report'].find(errmsg) < 0:
        continue
    num_tesseract += 1
    project = msg['body']['ProjectNumber']
    extraction = os.path.basename(msg['body']['ExtractionDirectory'])
    job = msg['body']['ExtractionJobIdentifier']
    input = msg['body']['DicomFilePath']
    output = msg['body']['OutputFilePath']
    dry = '--dry-run' if dry_run else ''
    print(f'rabbit_send.py {dry} -p {project} -e {extraction} -j {job} -i {input} -o {output}')

print('%d messages, %d from IsIdentifiable, %d were Tesseract' %
    (num_messages, num_IsIdentifiable, num_tesseract), file=sys.stderr)
