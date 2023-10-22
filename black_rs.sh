#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "[+] Usage: $0 <ip_list_txt> <port_number>"\
  exit 1
fi

input_file="$1"
port_number="$2"

echo "[+] Running rustscan against $1 on port $2"

# Rustscan specific port
rustscan -a "$1" -p "$2" -g > fourfourthree.txt

# Use grep and regular expression to extract IP addresses
ip_addresses=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' fourfourthree.txt)

# Use awk to remove duplicates
unique_ip_addresses=$(echo "$ip_addresses" | awk '!seen[$0]++')

# Save the unique IP addresses to a file
echo "$unique_ip_addresses" | sort > "rustscan_result.txt"

# Check if the input file exists
input_file="rustscan_result.txt"
if [ ! -f "$input_file" ]; then
  echo "Input file not found: $input_file"
  exit 1
fi

# Output file to save the active URLs
output_file="rs_$port_number.txt"

# Check if the output file exists and delete it if it does
if [ -e "$output_file" ]; then
  echo "[+] Deleting existing output file: $output_file"
  rm "$output_file"
fi

# Function to check for specific error messages
function has_error {
  if [[ "$1" != *"Connection reset by peer"* && "$1" != *"Empty reply from server"* && "$1" != *"error:1408F10B:SSL routines"* && "$1" != *"SSL_ERROR_SYSCALL"* && "$1" != *"Connection refused"* ]]; then
    return 0  # No error
  else
    return 1  # Error found
  fi
}

# Loop through the list of IP addresses in the file and run curl for both http and https
while IFS= read -r ip; do
  if [ -n "$ip" ]; then
    http_url="http://$ip:$port_number"
    https_url="https://$ip:$port_number"

    # Check if the port_number is 80
    if [ "$port_number" -eq 80 ]; then
      result_http=$(curl -k "$http_url" -o /dev/null 2>&1)
    else
      result_http=$(curl -k "$http_url" -o /dev/null 2>&1)
      result_https=$(curl -k "$https_url" -o /dev/null 2>&1)
    fi

    # Check if the result doesn't contain specific error messages
    if has_error "$result_http"; then
      echo "$http_url" >> "$output_file"
    fi

    if [ "$port_number" -ne 80 ] && has_error "$result_https"; then
      echo "$https_url" >> "$output_file"
    fi
  fi
done < "$input_file"

# Check if the output file exists empty and then display the final message
if [ -e "$output_file" ]; then
  echo "[+] Active URLs (excluding specific errors) have been saved to $output_file"
else
  echo "[+] There are no active URLs on port $port_number"
fi

rm fourfourthree.txt
rm rustscan_result.txt
