#!/bin/bash

project="2324-0085"
extraction="e2324-0085_SeriesUID_CT"

if [ "$1" != "" ]; then project="$1"; fi
if [ "$2" != "" ]; then extraction="$2"; fi

# See if this was an SR extraction
if expr match $extraction '.*SR.*' > /dev/null; then isSR=1; else isSR=0; fi

project_dir="/mnt/beegfs/smi/data/studies/prod/${project}"
extraction_dir="${project_dir}/extractions/${extraction}"
reports_dir="${project_dir}/extractions/reports/${extraction}"
counts_dir="${project_dir}/counts"

export SMI_HOME=${SMI_ROOT}/envs/prod

if [ ! -d $extraction_dir ]; then echo ERROR cannot find $extraction_dir >&2; exit 1; fi
if [ ! -d $reports_dir ]; then echo ERROR cannot find $reports_dir >&2; exit 1; fi
if [ ! -f $SMI_HOME/scripts/extraction/createExtractionReportTags.py ]; then echo ERROR cannot find script >&2; exit 1; fi
if [ ! -f $SMI_HOME/scripts/extraction/createExtractionReportPixelData.py ]; then echo ERROR cannot find script >&2; exit 1; fi
if [ ! -f $SMI_HOME/scripts/extraction/createExtractionReportTextValue.py ]; then echo ERROR cannot find script >&2; exit 1; fi

echo "Finalising extraction:"
echo "Files:   $extraction_dir"
echo "Reports: $reports_dir"
echo "Counts:  $counts_dir"
printf "Press Enter to continue: "; read junk

echo "* Deleting DCMtemp-* files..."
find ${extraction_dir}/ -type f -name DCMtemp-\* -delete &

mkdir -p ${counts_dir}
cd ${counts_dir}
echo "* Calculating disk space..."
echo Using: du -sh ../extractions/${extraction} '>' "${extraction}-du.txt"
nohup du -sh ../extractions/${extraction} > "${extraction}-du.txt" 2>&1 &
echo "* Counting files..."
echo Using: find ../extractions/${extraction} -mindepth 2 -type f '|' wc -l '>' "${extraction}-file-count.txt"
nohup find ../extractions/${extraction} -mindepth 2 -type f | wc -l > "${extraction}-file-count.txt" 2>&1 &


cd ${reports_dir}
echo "* Creating extraction report Tags..."
$SMI_HOME/scripts/extraction/createExtractionReportTags.py verification_failures.csv unix


if [ $isSR -eq 1 ]; then
    # For an SR extraction
    echo "* Creating extraction report TextValue..."
    $SMI_HOME/scripts/extraction/createExtractionReportTextValue.py verification_failures.csv unix
else
    # For a non-SR extraction
    echo "* Creating extraction report PixelData..."
    $SMI_HOME/scripts/extraction/createExtractionReportPixelData.py verification_failures.csv unix
fi

errorfile="${reports_dir}/processing_errors.csv"
if [ -f $errorfile ]; then
    errors=$(cat ${errorfile} | wc -l)
    if [ 0$errors -gt 1 ]; then
        echo "ERROR: some errors reported, please read the Troubleshooting guide."
        echo "See: ${errorfile}"
    else
        echo "The processing_errors file is empty and can be deleted:"
        echo "Use: rm ${errorfile}"
    fi
else
    echo "ERROR: The processing_errors file does not exist"
    echo "${errorfile}"
fi

printf "Wait for the count processes above to complete then press Enter: "
read junk

echo "* Making all reports read-only..."
echo "Using: chmod a-w ${reports_dir}/*"
chmod a-w ${reports_dir}/*

echo "Update the GitLab issue and move it to SK::Status::Done"
echo "Notify the Service Manager so that the dataset can be copied to the appropriate location"
echo ""
echo "For S3:"

echo "Login to agans-smi@nsh-fs02"
echo "Populate a bucket directory full of symlinks: smi_bucket_linker.py --project ${project} --extraction ${extraction}"
echo "Create a user (access key) if requested by eDRIS and if not already created: s3createuser.sh -u ${project}"
echo "Create a policy file for the new bucket: s3createbucket.py --bucket ${extraction} which gives eDRIS access (do not use the --user option)"
echo "Check all is ok and provide keys/secrets to eDRIS: s3check.py"
