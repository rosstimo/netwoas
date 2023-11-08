#!/bin/bash

# run ss -tupn and store the output in a variable. if ss is not installed otherwise exit
ss_output=$(ss -tupn) || { echo >&2 "ss not installed.  Aborting."; exit 1; }

TOR_EXIT_LIST="tor_exit_list.txt"
# check if tor_exit_list.txt exists. If not run script update_tor_exit_list.sh and abort if error
if [ ! -f tor_exit_list.txt ]; then
  echo "tor_exit_list.txt not found. Running update_tor_exit_list.sh"
  ./update_tor_exit_list.sh || { echo >&2 "Error running update_tor_exit_list.sh. Aborting."; exit 1; }
fi

# check if tor_exit_list.txt is older than 1 day. If yes run script update_tor_exit_list.sh
if test `find "tor_exit_list.txt" -mtime +1`; then
  echo "tor_exit_list.txt is older than 1 day. Running update_tor_exit_list.sh"
  ./update_tor_exit_list.sh || { echo >&2 "Error running update_tor_exit_list.sh. Aborting."; exit 1; }
fi

# extract the ip address and process name from each line of $ss_output and stor them in variables
while read -r line; do
  # if not blank line and line begins with tcp or udp else skip to next line
  # if [[ $line != "" ]] && [[ $line != tcp* ]] && [[ $line != udp* ]]; then
  if [[ $line == tcp* ]] || [[ $line == udp* ]]; then

    LOG_RECORD="$line"
    # Extract the remote IP address and port
    REMOTE_IP_PORT=$(echo "$LOG_RECORD" | awk '{print $6}')
    REMOTE_IP=""
    REMOTE_PORT=""

    # if REMOTE_IP_PORT contains "[", then it is an IPv6 address]"
    # extract the IP and PORT accordingly
    if [[ $REMOTE_IP_PORT == *[* ]]; then
      REMOTE_IP=$(echo "$REMOTE_IP_PORT" | awk -F'[][]' '{print $2}')
      REMOTE_PORT=$(echo "$REMOTE_IP_PORT" | awk -F'[][]' '{print $3}' | awk -F':' '{print $2}')
    else
      REMOTE_IP=$(echo "$REMOTE_IP_PORT" | awk -F':' '{print $1}')
      REMOTE_PORT=$(echo "$REMOTE_IP_PORT" | awk -F':' '{print $2}')
    fi

    # extract the process name assuming it is in the last column
    PROCESS=$(echo "$LOG_RECORD" | awk '{print $NF}')

    # set HEADER to current date and time
    HEADER=$(date +%Y-%m-%d_%H:%M:%S)
    echo "$HEADER, $REMOTE_IP, $PROCESS" 

    # Check if the IP address is in the TOR exit tor_exit_list
    if grep -Fxq "$REMOTE_IP" "$TOR_EXIT_LIST"; then
      #echo "IP address $REMOTE_IP is in the TOR exit tor_exit_list"

     # Add the IP address to the firewall
     # iptables -A INPUT -s $REMOTE_IP -j DROP

     # append the IP address and process name to a log file with a timestamp formatted as YYYY-MM-DD-HH
     # echo "$HEADER, $REMOTE_IP, $PROCESS" >> /var/log/tor_exit_node_hits.log
     echo "$HEADER, $REMOTE_IP, $PROCESS" >> tor_exit_node_hits-$(date +%Y-%m-%d-%H).log
   else
     #echo "IP address $REMOTE_IP is not in the TOR exit tor_exit_list"
     continue
    fi
  fi 

done <<< "$ss_output"
