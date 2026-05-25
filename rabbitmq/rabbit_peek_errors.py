#!/usr/bin/env python3
# Use a rabbitmq consumer to get all the messages in a queue
# but don't ack or nack any of them, just cancel which leaves them in the queue
# (although it may actually requeue them).
# 
# Extract the information of interest such as the executable name,
# and what caused the error.

import argparse
import json
import pika
import sys

# Configuration
queue_name = 'FatalLoggingQueue'
queue_name = 'DLQueue'
user = os.environ.get('RABBITMQ_USER')
password = os.environ.get('RABBITMQ_PASS')
host = 'smi-msgq01'
port = 5672
vhost = 'prod_file_extract'

# Internal config
num_seen = 0
max_messages = 0
sys.stdout.reconfigure(line_buffering=True) # when it hangs waiting for new messages ensure all output has been printed
verbose = False

# Parse arguments
parser = argparse.ArgumentParser(description='My Prog')
parser.add_argument('-v', '--verbose', action="store_true", help='verbose')
parser.add_argument('-q', '--queue', action="store", help='eg. DLQueue or FatalLoggingQueue')
parser.add_argument('-n', '--num-messages', action="store", help='number of messages to read')
args = parser.parse_args()
if args.verbose:
    verbose = True
if args.queue:
    queue_name = args.queue
if args.num_messages:
    max_messages = int(args.num_messages)

# Login to RabbitMQ
credentials = pika.PlainCredentials(user, password)
parameters = pika.ConnectionParameters(host = host, port = port, virtual_host = vhost, credentials = credentials)
connection = pika.BlockingConnection(parameters)
channel = connection.channel()

for method_frame, header_frame, body in channel.consume(queue = queue_name, inactivity_timeout = 5.0):
    if not method_frame:
        break
    if method_frame:
        guid = header_frame.headers['MessageGuid']
        if verbose:
            print('GUID: %s' % guid)
            print('METHOD: %s' % method_frame)
            print('TAG: %s' % method_frame.delivery_tag)
            print('HEADER: %s' % header_frame)
            print('BODY: %s' % body)
        print('FROM: %s' % header_frame.headers['ProducerExecutableName'])
        body = body.decode('utf-8')
        # We don't need to see these parts:
        body = body.replace('IsIdentifiableExtraction=False', '')
        body = body.replace('IsNoFilterExtraction=False', '')
        body = body.replace('KeyTag=SeriesInstanceUID', '')
        body = body.replace('nIdentifiers=50', '')
        # Try and get JSON format
        try:
            body_json = json.loads(body)
            #print('JSON: %s' % json.dumps(body_json, indent=2))
            if 'Exception' in body_json:
                print('EXCEPTION: %s' % body_json['Exception']['Message'])
            elif 'Report' in body_json:
                print('REPORT: %s' % body_json['Report'])
        except:
            print('BODY: %s' % body)
            pass
        num_seen += 1
        if max_messages and (num_seen > max_messages):
            break

# Cancel the consumer and return any pending messages
requeued_messages = channel.cancel()
print('Requeued %i messages' % requeued_messages)

# Close the channel and the connection
channel.close()
connection.close()
