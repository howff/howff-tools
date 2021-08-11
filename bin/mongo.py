#!/usr/bin/env python3
# Extract one record from mongo
# Uses bson.json_util.dumps to remove the Mongo nonsense so you can pipe into jq

import os,sys,socket
import bson.json_util
import pymongo

dicomfilepath='2017/01/06/L303633176601/SRe.1.2.840.113619.2.110.301712.170106111625.2.170106113515.8.2'
mongo_host='nsh-smi02'
mongo_user='reader'
mongo_pass=''
mongo_db='dicom'
mongo_collection='image_SR'

if len(sys.argv)>1:
    dicomfilepath = sys.argv[1]

hostname = socket.gethostname().split('.')[0]

# An attempt to get python to set its own path, doesn't work?
#if not 'VIRTUAL_ENV' in os.environ:
#  os.environ['PYTHONPATH']=os.environ['SMI_ROOT'] + '/lib/python3/virtualenvs/semehr/' + hostname + '/lib/python3.6/site-packages'
#  os.environ['PYTHONPATH']=os.environ['SMI_ROOT'] + '/lib/python3/virtualenvs/semehr/' + hostname
#  print(os.environ['PYTHONPATH'])
#import SmiServices

client = pymongo.MongoClient(mongo_host, username=mongo_user, password=mongo_pass, authSource='admin')
db = client[mongo_db]
coll = db[mongo_collection]
rc = coll.find_one( { 'header.DicomFilePath' : dicomfilepath } )
print(bson.json_util.dumps(rc))
