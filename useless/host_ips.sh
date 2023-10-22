#!/bin/bash

# Define the input file with IP addresses
input_file="ip_addresses.txt"

# Loop through each line (IP address) in the file
while IFS= read -r ip_address
do
    # Perform a reverse DNS lookup using host
    result=$(host "$ip_address" 2>/dev/null)  # Redirect stderr to /dev/null to suppress error messages

    # Check if the result is not empty, doesn't contain "SERVFAIL," and doesn't contain "connection timed out"
    if [[ -n "$result" && "$result" != *"not found"* && "$result" != *"connection timed out"* ]]; then
        echo "IP: $ip_address"
        echo "$result"
        echo "--------------------------------------------------------"
    fi
done < "$input_file"
