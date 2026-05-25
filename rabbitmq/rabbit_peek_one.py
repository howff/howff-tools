#!/usr/bin/env python3
# This is only good for getting one single message.
# If you try to get more than one you just get the same message again and again.

import json
import pika
import sys

user = os.environ.get('RABBITMQ_USER')
password = os.environ.get('RABBITMQ_PASS')
host = 'smi-msgq01'
port = 5672
vhost = 'prod_file_extract'


credentials = pika.PlainCredentials(user, password)
parameters = pika.ConnectionParameters(host = host, port = port, virtual_host = vhost, credentials = credentials)
connection = pika.BlockingConnection(parameters)
channel = connection.channel()

seen={}
def get_one_message(queue_name : str):
    global seen
    method_frame, header_frame, body = channel.basic_get(queue = queue_name)
    if method_frame:
        guid = header_frame.headers['MessageGuid']
        print('GUID: %s' % guid)
        if seen.get(guid, 0) == 1:
            print('ALREADY_SEEN %s' % guid)
            return False
        seen[guid]=1
        print('METHOD: %s' % method_frame)
        #print('TAG: %s' % method_frame.delivery_tag)
        print('HEADER: %s' % header_frame)
        print('FROM: %s' % header_frame.headers['ProducerExecutableName'])
        #print('BODY: %s' % body)
        try:
            body_json = json.loads(body.decode('utf-8'))
            #print('JSON: %s' % json.dumps(body_json, indent=2))
            if 'Exception' in body_json:
                print('EXCEPTION: %s' % body_json['Exception']['Message'])
            elif 'Report' in body_json:
                print('REPORT: %s' % body_json['Report'])
        except:
            print('BODY: %s' % body)
            pass
        channel.basic_nack(method_frame.delivery_tag, requeue = True)
    else:
        print('No message returned')
        return False
    return True

nn=0
while True:
    #queue = 'DLQueue'
    queue = 'FatalLoggingQueue'
    if not get_one_message(queue):
        break
    nn+=1
    if nn>=30:
        break
