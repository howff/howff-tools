#!/bin/bash
# Convert from the JSON emitted by Mongo into real JSON, stdin to stdout,
# by removing the ObjectId() and NumberLong() wrappers
# leaving the content inside them.
# eg. ObjectId("123")  becomes  "123"
# Uses an extremely naive method to convert single quotes to double quotes.

sed \
-e 's/ObjectId(\([^)]*\))/\1/' \
-e 's/NumberLong(\([^)]*\))/\1/' | tr "'" '"'
