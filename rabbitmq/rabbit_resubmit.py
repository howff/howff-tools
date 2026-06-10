#!/usr/bin/env python3
# Use a rabbitmq consumer to get all the messages in a queue.
# Filter out the ones which match "System.ApplicationException: Could not run Tesseract"
# and resubmit the DICOM file to CTPAnonymiser so it can be tried again.
# All other messages are not acknowledged (i.e. get left in queue or requeued).
# XXX currently uses a mix of raw pika and SmiServices library.

import argparse
import json
import os
import sys
import yaml
import pika
from SmiServices import Rabbit

# Configuration
queue_name = 'DLQueue'
user = os.environ.get('RABBITMQ_USER')
password = os.environ.get('RABBITMQ_PASS')
host = 'smi-msgq01'
port = 5672
vhost = 'prod_file_extract'
ack_filter = "System.ApplicationException: Could not run Tesseract"
yaml_filename = '/mnt/smi-fs01-nfs/ansible/envs/prod/smi-services-extract-pipeline.yaml'

# Internal config
num_seen = 0
max_messages = 0
sys.stdout.reconfigure(line_buffering=True) # when it hangs waiting for new messages ensure all output has been printed
verbose = False

# Parse arguments
parser = argparse.ArgumentParser(description='My Prog')
parser.add_argument('-v', '--verbose', action="store_true", help='verbose')
parser.add_argument('-n', '--num-messages', action="store", help='number of messages to read')
args = parser.parse_args()
if args.verbose:
    verbose = True
if args.num_messages:
    max_messages = int(args.num_messages)

# Output files
log_verbose = sys.stdout
log_ack  = open(f'{queue_name}_ack.json', 'w')
log_nack = open(f'{queue_name}_nack.json', 'w')

# Read configuration file
with open(yaml_filename) as fd:
    yaml_dict_main = yaml.safe_load(fd)
params = Rabbit._get_pika_connection_parameters(yaml_dict_main)
if verbose: print(params, file=log_verbose)

# Login to RabbitMQ
credentials = pika.PlainCredentials(user, password)
parameters = pika.ConnectionParameters(host = host, port = port, virtual_host = vhost, credentials = credentials)
connection = pika.BlockingConnection(parameters)
channel = connection.channel()

# ---------------------------------------------------------------------
# Convert the rabbit internals into Python dictionaries

def method_frame_to_dict(method_frame):
    """ Convert the Object into a standard dict
    """
    frame = { "exchange": method_frame.exchange, "routing_key": method_frame.routing_key }
    return frame

def header_frame_to_dict(header_frame):
    """ Convert the Object into a standard dict
    """
    frame = header_frame.headers
    del frame['x-death'][0]['time'] # cannot store time in JSON
    return frame

def body_to_dict(body):
    """ Convert the body as a string (not bytes) into a standard dict
    """
    return json.loads(body)

# ---------------------------------------------------------------------
# Filter only matching messages

def filter_match(body_str, filter_str):
    """ Return True if the string filter_str is inside the string body_str.
    Currently simple substring not regex.
    """
    if filter_str in body_str:
        return True
    return False

# ---------------------------------------------------------------------

def resubmit(body_dict):
    # Create a message for CTPAnonymiser
    # but override the fake params it creates with our real values
    msg = Rabbit.CTP_Start_Message(yaml_dict_main,
        dicom_file_path = body_dict['DicomFilePath'],
        extraction_directory = body_dict['ExtractionDirectory'],
        project_number = body_dict['ProjectNumber'],
        job_identifier = body_dict['ExtractionJobIdentifier'],
        output_file_path = body_dict['OutputFilePath'])

    sender = Rabbit.RabbitProducer(yaml_dict_main, "fake_message_to_CTP",
        exchange = 'ExtractFileExchange',
        routingKey = 'anon')
    sender.open()
    sender.sendMessage(msg)
    sender.close()
    if verbose: print("Published %s" % msg.to_json(), file=log_verbose)

# ---------------------------------------------------------------------

print('[', file=log_ack)
print('[', file=log_nack)
num_messages = 0
num_ack = 0

for method_frame, header_frame, body in channel.consume(queue = queue_name, inactivity_timeout = 5.0):
    if not method_frame:
        break
    if method_frame:
        num_messages += 1
        frame_dict = method_frame_to_dict(method_frame)
        header_dict = header_frame_to_dict(header_frame)
        body_dict = body_to_dict(body.decode('utf-8'))
        fd = log_nack
        if ack_filter and filter_match(body_dict.get('Report',''), ack_filter):
            fd = log_ack
            num_ack += 1
            channel.basic_ack(delivery_tag=method_frame.delivery_tag)
            resubmit(body_dict)
        if num_messages > 1:
            print(',', file=fd)
        print(json.dumps( { "frame": frame_dict,
            "header": header_dict,
            "body": body_dict }, indent=2), file=fd)
        if max_messages and (num_messages >= max_messages):
            if verbose: print(f'End after {num_messages} of which {num_ack} were ACK')
            break

print(']', file=log_ack)
print(']', file=log_nack)

# Cancel the consumer and return any pending messages
requeued_messages = channel.cancel()

# Close the channel and the connection
channel.close()
connection.close()

print(f'Total messages: {num_messages} of which {num_ack} were resubmitted.', file=log_verbose)
