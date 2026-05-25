#!/bin/bash
# Start the extraction by running "smi-extract-images" with the correct params
# for the given project.
# Usage: XX eNNNN-MMMM_XX.csv
# where XX is the modality needed.

modality="$1"
csv="$2"

if ! expr match "$csv" "^e[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9].*_[A-Z][A-Z].csv$" >/dev/null; then
        echo "Usage: $0 MODALITY eNNNN-MMMMblah_MM.csv" >&2
        exit 1
fi
project=$(echo "$csv" | cut -c2-10)
echo Project = $project
echo Modality = $modality

reqdir="/mnt/beegfs/smi/data/studies/prod/${project}/image-requests"

echo ""
echo Running SMI_ENV=prod smi-extract-images -p "${project}" -m "${modality}" -c "${reqdir}/${csv}"
echo ""
SMI_ENV=prod smi-extract-images -p "${project}" -m "${modality}" -c "${reqdir}/${csv}"
