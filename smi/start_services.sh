#!/bin/bash

set -e

SMI_ENV=prod smi-ctp-anonymiser   --detach --copies 40
SMI_ENV=prod smi-cohort-packager  --detach --copies 1
SMI_ENV=prod smi-is-identifiable  --detach --copies 20
SMI_ENV=prod smi-cohort-extractor --detach --copies 1

echo ""
echo "Check that NERd is running:"
systemctl status smi_nerd
