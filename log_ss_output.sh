#!/bin/bash

# Define the path for the log file
# LOG_FILE="/var/log/ss_output.log"
LOG_FILE="ss_output.log"

# Get the current date and time
NOW=$(date +"%Y-%m-%d %H:%M:%S")

# Write the current date and time to the log file
echo "Logging ss output at $NOW" >> $LOG_FILE

# Run ss and append the output to the log file
ss -tupn >> $LOG_FILE

# Add an empty line for readability in the log file
echo "" >> $LOG_FILE
