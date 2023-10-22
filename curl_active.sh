#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "[+] Usage: $0 <port_number>"
  echo "[+] Do note that this script can only take port number one at a time"
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

# Output file to save the active URLs
output_file="$output_folder/$port.txt"

# Check if the output file exists and delete it if it does
if [ -e "$output_file" ]; then
  echo "Deleting existing output file: $output_file"
  rm "$output_file"
fi

# Initialize a counter for the active URLs
url_counter=1

# Function to check for specific error messages
function has_error {
  if [[ "$1" != *"Connection reset by peer"* && "$1" != *"Empty reply from server"* && "$1" != *"error:1408F10B:SSL routines"* && "$1" != *"SSL_ERROR_SYSCALL"*  ]]; then
    return 0  # No error
  else
    return 1  # Error found
  fi
}

# Loop through the list of IP addresses in the file and run curl for both http and https
while IFS= read -r ip; do
  if [ -n "$ip" ]; then
    http_url="http://$ip:$port"
    https_url="https://$ip:$port"

    # Check if the port is 80
    if [ "$port" -eq 80 ]; then
      result_http=$(curl -k "$http_url" -o /dev/null 2>&1)
    else
      result_http=$(curl -k "$http_url" -o /dev/null 2>&1)
      result_https=$(curl -k "$https_url" -o /dev/null 2>&1)
    fi

    # Check if the result doesn't contain specific error messages
    if has_error "$result_http"; then
      echo "$http_url" >> "$output_file"
    fi

    if [ "$port" -ne 80 ] && has_error "$result_https"; then
      echo "$https_url" >> "$output_file"
    fi
  fi
done < "$input_file"

echo "Active URLs (excluding specific errors) have been saved to $output_file"
