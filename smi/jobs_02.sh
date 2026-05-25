#!/bin/bash

jobid="$1"
if [ "$jobid" == "" ]; then echo "usage: $0 job-id" >&2; exit 1; fi

logroot="/mnt/smi-fs01-nfs/logs/prod"
logdir="${logroot}/CohortExtractor"

echo "Looking for errors..."
find $logdir -name \*simple\* -mtime -60 | sort | xargs egrep -h "(ERROR|FATAL).*${jobid}" | sed -e 's/ExtractionIdentifiers":\[[^]]*//'
echo "Counting Series..."
numseries=$(find $logdir -name \*simple\* -mtime -60 | sort | xargs egrep -h "ExtractionRequestQueueConsumer.*${jobid}" | wc -l)
echo "$((numseries * 50)) Series to extract (rounded up to nearest 50)"
