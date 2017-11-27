#!/bin/bash

if [ $# -eq 2 ]
  then
    find $1 -name *.txt -exec cat {} + > $2
  else
    echo "Usage: ./merge_txlists.sh [TXLISTS_PATH] [OUTPUT_FILE]"
    exit 1
fi


