#!/bin/bash

host="nsh-smi02"
export MONGO_USERNAME="reader"
#export MONGO_PASSWORD=""

mongo --host ${host} -u ${MONGO_USERNAME} -p ${MONGO_PASSWORD} --authenticationDatabase admin "$@"
