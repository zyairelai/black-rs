#!/bin/bash

# Define the input file with IP addresses
input_file="ip_addresses.txt"

# Loop through each line (IP address) in the file
while IFS= read -r ip_address
do
    # Perform a reverse DNS lookup using nslookup
    result=$(nslookup "$ip_address")

    # Check if the result is not empty, doesn't contain "SERVFAIL," and doesn't contain "connection timed out"
    if [[ -n "$result" && "$result" != *"NXDOMAIN"* && "$result" != *"SERVFAIL"* ]]; then
        echo "IP: $ip_address"
        echo "$result"
        echo "--------------------------------------------------------"
    fi
done < "$input_file"
