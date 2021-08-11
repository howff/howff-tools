#!/bin/bash

user="andrewb"
db="data_load2"

csv="/beegfs-hdruk/extract/v12/PACS/projects/1516-IMG3/image-requests/SeriesInstanceUID_for_SR.csv"

tr -d '\015' < "${csv}" | tail -n +2 | \
  while read series; do
    cmd="SELECT SeriesInstanceUID,RelativeFileArchiveURI FROM SR_ImageTable WHERE SeriesInstanceUID = '${series}';"
    mysql -Ns -h localhost -u "${user}" -e "$cmd" "${db}"
  done
