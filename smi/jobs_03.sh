#!/bin/bash

jobid="$1"
if [ "$jobid" == "" ]; then echo "usage: $0 job-id" >&2; exit 1; fi

logroot="/mnt/smi-fs01-nfs/logs/prod"
logdir="${logroot}/CohortPackager"

echo "Looking for errors..."
find $logdir -name \*simple\* -mtime -60 | sort | xargs egrep -h "(All files for job|Reports for) ${jobid}|${jobid} is in state WaitingForStatuses. Expected count is|${jobid} is in state WaitingForCollectionInfo" | uniq -f 2
#echo "Counting Series..."
#numseries=$(find $logdir -name \*simple\* -mtime -60 | sort | xargs egrep -h "ExtractionRequestQueueConsumer.*${jobid}" | wc -l)
#echo "$((numseries * 50)) Series to extract (rounded up to nearest 50)"
