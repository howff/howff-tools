#!/usr/bin/env python3
# Check that the number of consumers running for each queue is as expected
# i.e. that the processes are running to handle messages in the queue.

import os
import requests
from urllib.parse import quote
import sys

RABBITMQ_HOST = "http://smi-msgq01:15672"
USERNAME = os.environ.get('RABBITMQ_USER')
PASSWORD = os.environ.get('RABBITMQ_PASS')

VHOST = "prod_file_extract"
QUEUE_NAME = "ExtractFileAnonQueue"
queues = [
    ("ExtractFileAnonQueue",     40, "CTPAnonymiser"),
    ("ExtractedFileNoVerifyQueue",  1, "CohortPackager"),
    ("ExtractedFileToVerifyQueue", 20, "IsIdentifiable"),
    ("ExtractedFileVerifiedQueue",  1, "CohortPackager"),
    ("RequestQueue",              1, "CohortExtractor"),
    ("RequestInfoQueue",          1, "CohortPackager"),
    ("ExtractFileIdentQueue", 0, "xxx"),
    ("FileCollectionInfoQueue", 1, "xxx"),
]

def rabbit_query(host, username, password, vhost, queue):
    vhost_enc = quote(vhost, safe="")
    queue_enc = quote(queue, safe="")

    url = f"{host}/api/queues/{vhost_enc}/{queue_enc}"

    response = requests.get(
        url,
        auth=(username, password),
        headers={"Accept": "application/json"},
        timeout=10,
    )

    # Exit if 404?
    #response.raise_for_status()

    data = response.json()
    return data
    #num_messages = data.get('messages_ready', 0)
    #if num_messages > 0: print('%s = %d' % (data['name'], num_messages))
    #return data.get("consumers", 0)


if __name__ == "__main__":
    os.environ['http_proxy']=''
    for queue,expected,process in queues:
        data = rabbit_query(RABBITMQ_HOST, USERNAME, PASSWORD, VHOST, queue)
        consumers = data.get('consumers', 0)
        num_messages = data.get('messages_ready', 0)
        #consumers = get_consumer_count(RABBITMQ_HOST, USERNAME, PASSWORD, VHOST, queue)
        print(f"Consumers for queue '{queue}' in vhost '{VHOST}': {consumers}, messages_ready = {num_messages}")
        if consumers != expected: print('Expected %d got %d' % (expected, consumers))
