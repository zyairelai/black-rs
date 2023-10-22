#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "[+] Usage: $0 <port_number>"
  exit 1
fi

port="$1"

# Check if the input file exists
input_file="rustscan_result.txt"
if [ ! -f "$input_file" ]; then
  echo "Input file not found: $input_file"
  exit 1
fi

# Create a "result" folder if it doesn't exist
output_folder="curl_result"
mkdir -p "$output_folder"

# Output file to save the IP addresses
output_file="$output_folder/curl_$port.txt"

# Loop through the list of IP addresses in the file and run curl for both http and https
while IFS= read -r ip; do
  if [ -n "$ip" ]; then
    result_http=$(curl -k -s "http://$ip:$port")
    result_https=$(curl -k -s "https://$ip:$port")

    if [ -n "$result_http" ] || [ -n "$result_https" ]; then
      echo "$ip" >> "$output_file"
    fi
  fi
done < "$input_file"

echo "IP addresses with non-empty results have been saved to $output_file"
