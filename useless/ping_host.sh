#!/bin/bash

# Define the input file with IP addresses
input_file="ip_addresses.txt"

# Loop through each line (IP address) in the file
while IFS= read -r ip_address
do
    # Use the ping command to check if the host is up
    if ping -c 1 "$ip_address" &> /dev/null; then
        echo "$ip_address"
    fi
done < "$input_file"
