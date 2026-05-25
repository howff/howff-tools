#!/bin/bash
# Copy the CSV file from smi-edris-db01 which contains the list of Series UIDs
# that we want to extract.
# Copies it to "/mnt/beegfs/smi/data/studies/prod/${project}/image-requests"
# Usage: eNNNN-MMMM_XX.csv

csv="$1"

if ! expr match "$csv" "^e[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]" >/dev/null; then
        echo "Usage: $0 eNNNN-MMMMblah.csv" >&2
        exit 1
fi
project=$(echo "$csv" | cut -c2-10)
echo Project = $project

reqdir="/mnt/beegfs/smi/data/studies/prod/${project}/image-requests"
mkdir -p "${reqdir}"

# If it already exists then it will need to be writeable
if [ -f "${reqdir}/${csv}" ]; then chmod +w "${reqdir}/${csv}"; fi

# Copy CSV
echo "Copying $csv from smi-edris-db01 to $reqdir"
scp smi-edris-db01:"$csv" "${reqdir}"
chmod a-w "${reqdir}/${csv}"

# Also copy the metadata filet (for personal interest, not used by SMI software)
echo "Copying meta.csv from smi-edris-db01 also"
scp smi-edris-db01:$(basename "$csv" .csv)_meta.csv "${reqdir}"
