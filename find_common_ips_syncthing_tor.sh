#!/bin/bash

# verify that tor_exit_list.txt exists and is less than 24 hours old
if [ ! -f tor_exit_list.txt ] || [ $(find tor_exit_list.txt -mtime +1 -print) ]; then
    echo "tor_exit_list.txt does not exist or is more than 24 hours old. Downloading new copy."
    # wget https://check.torproject.org/torbulkexitlist -O tor_exit_list.txt
    ./update_tor_exit_list.sh
fi

# verify that syncthing_relay_list.txt exists and is less than 24 hours old
if [ ! -f syncthing_relay_list.txt ] || [ $(find syncthing_relay_list.txt -mtime +1 -print) ]; then
    echo "syncthing_relay_list.txt does not exist or is more than 24 hours old. Downloading new copy."
    # wget https://relays.syncthing.net/relays.json -O syncthing_relay_list.txt
    ./update_syncthing_relay_list.sh
fi

# create a list of IPs that are in both tor_exit_list.txt and syncthing_relay_list.txt
grep -F -f tor_exit_list.txt syncthing_relay_list.txt > common_ips.txt &&

# use nslookup to get all available information about each IP in common_ips.txt
while read p; do
    nslookup $p > common_ips_nslookup.txt
done < common_ips.txt

