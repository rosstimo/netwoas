#!/bin/bash
# nslookup.sh: Perform nslookup on a list of IP addresses contained in a file passed as an argument
# Usage: ./nslookup.sh <file>

if [ $# -ne 1 ]; then
    echo "Usage: ./nslookup.sh <file>"
    exit 1
fi

if [ ! -f $1 ]; then
    echo "File $1 does not exist"
    exit 1
fi

while read ip; do
    nslookup $ip >> "$1-nslookup.txt"
done < $1
