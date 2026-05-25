#!/bin/bash
# Lookup a StudyInstanceUID and return the file path on disk
# which is Year/Month/Day/AccessionNumber
# Usage: Modality StudyUID

#export PGPASSWORD=""
export ID="'1.2.124.113532.10.48.85.25.20150318.133222.35339624'"
export MODALITY="CT"
if [ "$1" != "" ]; then MODALITY="$1"; fi
if [ "$2" != "" ]; then ID="'$2'"; fi
psql -U postgres smi -c 'select "StudyDate","AccessionNumber" from dicom."'${MODALITY}'_StudyTable" where "StudyInstanceUID" = '$ID';'
