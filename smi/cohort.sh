#!/bin/bash
# Usage: ./cohort.sh "e2324-0085_SeriesUID_CT" [Modality]
# to extract from the table rc.$1 (i.e. from the "rc" schema)
# and save in file $1.csv
# Also extract the full Accession,Study,Series into _meta.csv

table="$1"
modality="$2"

if [ "$table" == "" ]; then echo Usage: $0 eNNNN-MMMM_SeriesUID_MM >&2; exit 1; fi

extraction=$(echo "$table" | sed -e 's/rc\.//')

if [ "$modality" == "" ]; then
    modality=$(echo "$table" | grep -o '..$')
fi
if [ "$modality" == "" ]; then echo "Error: cannot determine modality" >&2; exit 1; fi

echo "EXTRACTION $extraction"
echo "MODALITY $modality"

echo RUNNING: 'select "SeriesInstanceUID" from rc."'"$extraction"'"'
sudo psql -U postgres smi -c '\copy (select "SeriesInstanceUID" from rc."'"$extraction"'") to STDOUT with (format CSV,header);' > ${extraction}.csv

if [ "$modality" == "SR" ]; then
    # SR only has ImageTable not Study or Series tables
    echo 'RUNNING: SELECT DISTINCT st."AccessionNumber",st."StudyDate",st."StudyInstanceUID",ex."SeriesInstanceUID" FROM rc."'"$extraction"'" ex INNER JOIN dicom."'"$modality"'_ImageTable" st ON ex."SeriesInstanceUID" = st."SeriesInstanceUID"'
    sudo psql -U postgres smi -c '\copy (SELECT DISTINCT st."AccessionNumber",st."StudyDate",st."StudyInstanceUID",ex."SeriesInstanceUID" FROM rc."'"$extraction"'" ex INNER JOIN dicom."'"$modality"'_ImageTable" st ON ex."SeriesInstanceUID" = st."SeriesInstanceUID") to STDOUT with (format CSV,header);' > ${extraction}_meta.csv
else
    echo 'RUNNING: SELECT st."AccessionNumber",st."StudyDate",se."StudyInstanceUID",ex."SeriesInstanceUID" FROM rc."'"$extraction"'" ex INNER JOIN dicom."'"$modality"'_SeriesTable" se ON ex."SeriesInstanceUID" = se."SeriesInstanceUID" INNER JOIN dicom."'"$modality"'_StudyTable" st ON se."StudyInstanceUID" = st."StudyInstanceUID"'
    sudo psql -U postgres smi -c '\copy (SELECT st."AccessionNumber",DATE(st."StudyDate"),se."StudyInstanceUID",ex."SeriesInstanceUID" FROM rc."'"$extraction"'" ex INNER JOIN dicom."'"$modality"'_SeriesTable" se ON ex."SeriesInstanceUID" = se."SeriesInstanceUID" INNER JOIN dicom."'"$modality"'_StudyTable" st ON se."StudyInstanceUID" = st."StudyInstanceUID") to STDOUT with (format CSV,header);' > ${extraction}_meta.csv
fi
