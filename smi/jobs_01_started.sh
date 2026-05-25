#!/bin/bash

logroot="/mnt/smi-fs01-nfs/logs/prod"
logdir="${logroot}/ExtractImages"

find $logdir -name \*simple\* -mtime -60 | sort | xargs egrep -h 'FATAL|^ExtractionJobIdentifier:|^Submitted:|^ExtractionDirectory:'
