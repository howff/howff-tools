#!/bin/bash
source ~abrooks/src/StructuredReports/venv/bin/activate
~/bin/rabbit_send.py "$@".
