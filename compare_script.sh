#!/bin/bash

# Define the path to the files
# LOG_FILE="/var/log/ss_output.log"
# TOR_EXIT_LIST="/path/to/tor_exit_list.txt"
LOG_FILE="ss_output.log"
TOR_EXIT_LIST="tor_exit_list.txt"
HEADER=""
# Read the log file line by line
while IFS= read -r line; do

  #if not blank line get extract time and date
  #echo "$line" if it begins with tcp or udp else skip to next line
  if [[ $line != "" ]] && [[ $line != tcp* ]] && [[ $line != udp* ]]; then
    if [[ $HEADER == "" ]]; then
      # Extract the time and time from the last two columns of $line
      HEADER=$(echo "$line" | awk '{print $5, $6}')
    fi
    echo "HEADER:$HEADER"
  elif [[ $line == tcp* ]] || [[ $line == udp* ]]; then
    echo "Start *************************************************"
    echo "$line"
    LOG_RECORD="$line"

    # Extract the remote IP address and port
    REMOTE_IP_PORT=$(echo "$LOG_RECORD" | awk '{print $6}')
    echo "IP:PORT = $REMOTE_IP_PORT"
    
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

    echo "IP = $REMOTE_IP"
    echo "PORT = $REMOTE_PORT"
    # extract the process name assuming it is in the last column
    PROCESS=$(echo "$LOG_RECORD" | awk '{print $NF}')
    echo "PROCESS = $PROCESS"
    
    # Check if the IP address is in the TOR exit tor_exit_list
    if grep -Fxq "$REMOTE_IP" "$TOR_EXIT_LIST"; then
      echo "#####################################################"
      echo "IP address $REMOTE_IP is in the TOR exit tor_exit_list"
      # Add the IP address to the firewall
      # iptables -A INPUT -s $REMOTE_IP -j DROP

      # append the IP address and process name to a log file with a timestamp formatted as YYYY-MM-DD-HH
      # echo "$HEADER, $REMOTE_IP, $PROCESS" >> /var/log/tor_exit_node_hits.log
      echo "$HEADER, $REMOTE_IP, $PROCESS" >> tor_exit_node_hits-$(date +%Y-%m-%d-%H).log
    else
      echo "IP address $REMOTE_IP is not in the TOR exit tor_exit_list"
    fi
    echo "End *************************************************"
  else
    echo "Not Sure. Line: $line"
    HEADER=""
  fi 
done < "$LOG_FILE"
