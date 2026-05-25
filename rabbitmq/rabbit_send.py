#!/usr/bin/env python
# See /home/abrooks/src/StructuredReports/src/library/SmiServices/Rabbit.py

import argparse
import pika
import sys
import yaml
from SmiServices import Rabbit

# Options
project = '2324-0085'
extraction  = 'e2324-0085_SeriesUID_DX'
extractionJobId  = '5b87d484-28c4-40fc-a385-8c37e11e1bc9' # get this from ~/jobs_01.sh
input_filepath = '2017/08/28/S110007031198/DX.1.3.46.670589.30.36.0.1.72567767433727.1503936595156.2'
output_filepath = '1.2.840.113564.9.1.5117.2017082803570014/1.3.46.670589.30.36.0.1.72567767433727.1503936595211.1/1.3.46.670589.30.36.0.1.72567767433727.1503936595156.2-an.dcm'
verbose = False
debug = False
dry_run = False

# Parse arguments
parser = argparse.ArgumentParser(description='My Prog')
parser.add_argument('--dry-run', action="store_true", help='do not send message')
parser.add_argument('-d', '--debug', action="store_true", help='debug')
parser.add_argument('-v', '--verbose', action="store_true", help='verbose')
parser.add_argument('-p', '--project', action="store", help='project, e.g. 2324-0085')
parser.add_argument('-e', '--extraction', action="store", help='extraction, e.g. e2324-0085_SeriesUID_DX')
parser.add_argument('-j', '--job', action="store", help='job identifier, e.g. 5b87d484-28c4-40fc-a385-8c37e11e1bc9')
parser.add_argument('-i', '--input', action="store", help='input path, e.g. YYYY/MM/DD/Accession/MM.1.2.3')
parser.add_argument('-o', '--output', action="store", help='output path, e.g. Study/Series/1.2.3-an.dcm')
args = parser.parse_args()
if args.dry_run:
    dry_run = True
if args.verbose:
    verbose = True
if args.debug:
    debug = True
if args.project:
    project = args.project
if args.extraction:
    extraction = args.extraction
if args.job:
    extractionJobId = args.job
if args.input:
    input_filepath = args.input
if args.output:
    output_filepath = args.output

# Configuration
yaml_filename = '/mnt/smi-fs01-nfs/ansible/envs/prod/smi-services-extract-pipeline.yaml'

# Read configuration file
with open(yaml_filename) as fd:
    yaml_dict_main = yaml.safe_load(fd)
params = Rabbit._get_pika_connection_parameters(yaml_dict_main)
if debug: print(params)

# Create a message for CTPAnonymiser
# but override the fake params it creates with our real values
msg = Rabbit.CTP_Start_Message(yaml_dict_main,
    dicom_file_path = input_filepath,
    extraction_directory = f"{project}/extractions/{extraction}",
    project_number = f"{project}",
    job_identifier = extractionJobId,
    output_file_path = output_filepath)
msg.msg_dict['OutputPath'] = output_filepath
if debug: print("CTP input file will be %s/%s" % (yaml_dict_main['FileSystemOptions']['FileSystemRoot'], input_filepath))
if debug: print("CTP output file will be %s/%s/%s" % (yaml_dict_main['FileSystemOptions']['ExtractRoot'], msg.msg_dict['ExtractionDirectory'], msg.msg_dict['OutputPath']))

if dry_run:
    sys.exit(0)

sender = Rabbit.RabbitProducer(yaml_dict_main, "fake_message_to_CTP",
    exchange = 'ExtractFileExchange',
    routingKey = 'anon')
sender.open()
sender.sendMessage(msg)
sender.close()
print("Published %s" % msg.to_json())

#pika_connection = pika.BlockingConnection(params)
#pika_model = pika_connection.channel()
#pika_model.basic_publish(
#    exchange = "ExtractFileExchange",
#    routing_key = 'anon',
#    body = msg.to_json(),
#    properties = Rabbit._get_pika_message_properties("fake_message_to_CTP", 1234),
#    mandatory = True,
#)
# Close the channel and the connection
#pika_model.close()
#pika_connection.close()
