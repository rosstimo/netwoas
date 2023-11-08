#!/bin/bash

# Define the URL of the SyncThing relay list
SYNCTHING_RELAY_LIST_URL="https://raw.githubusercontent.com/elliotwutingfeng/SyncthingRelayServerIPs/main/ips.txt"
# Define the path for the list to be stored
SYNCTHING_RELAY_LIST_PATH="syncthing_relay_list.txt"

# Fetch the latest SyncThing relay list and save it to the specified path
curl -s $SYNCTHING_RELAY_LIST_URL -o $SYNCTHING_RELAY_LIST_PATH

# Process the list and update firewall rules or logging (this part will depend on your specific setup)

echo "SyncThing relay list updated and processed."
