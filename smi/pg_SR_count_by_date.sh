#!/bin/bash
#export PGPASSWORD=""

# Count all SRs in 2012 and report by date
read -r -d '' sql <<'_EOF'
SELECT COUNT("StudyDate"),"StudyDate" FROM dicom."SR_ImageTable" WHERE "StudyDate" >= '2012-01-01' AND "StudyDate" < '2012-12-31' group by "StudyDate";
_EOF
sudo psql -U postgres smi -c "$sql"

# Count all SRs in 2012 and report by date
read -r -d '' sql <<'_EOF'
SELECT COUNT("ContentDate"),"ContentDate" FROM dicom."SR_ImageTable" WHERE "ContentDate" >= '2012-01-01' AND "ContentDate" < '2012-12-31' group by "ContentDate";
_EOF
sudo psql -U postgres smi -c "$sql"

# Summary by month in 2012
##select extract(month from "StudyDate") as month,count(*) FROM  dicom."SR_ImageTable" WHERE "StudyDate" >= '2012-01-01' AND "StudyDate" < '2012-12-31' group by  extract
(month from "StudyDate") order by month;
read -r -d '' sql <<'_EOF'
select extract(year from "StudyDate") as year,extract(month from "StudyDate") as month,count(*) FROM  dicom."SR_ImageTable" WHERE "StudyDate" >= '2010-01-01' AND "StudyD
ate" < '2014-12-31' group by  extract(year from "StudyDate"),extract(month from "StudyDate") order by year,month;
_EOF
sudo psql -U postgres smi -c "$sql"
