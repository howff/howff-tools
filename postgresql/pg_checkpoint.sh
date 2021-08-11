#!/bin/bash
DB="isaric"
psql --quiet -U postgres -d ${DB} -c 'CHECKPOINT;'
