#!/bin/bash

table="$1"  # e.g. DX_ImageTable

rdmproot="/mnt/smi-fs01-nfs/ansible/envs/prod/rdmp"

cd $rdmproot

grep -l "${table}$" Catalogue/* | sed -e 's/^[^0-9]*\([0-9][0-9]*\).*/\1/' | while read catalogue; do
  echo Look for Catalogue $catalogue
  catalogueitem=$(grep -l "Catalogue_ID: ${catalogue}$" CatalogueItem/* | head -1)
  columninfo=$(grep ColumnInfo_ID: $catalogueitem | awk '{print$NF}')
  tableinfo=$(grep TableInfo_ID: ColumnInfo/${columninfo}.yaml | awk '{print$NF}')
  tableinfofile=TableInfo/${tableinfo}.yaml
  echo "$(grep Server: $tableinfofile) $(grep Name: $tableinfofile)"
done
