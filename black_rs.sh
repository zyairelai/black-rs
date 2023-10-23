#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "[+] Usage: $0 <ip_list_txt>"
  exit 1
fi

input_file="$1"
output_file="blackrs_output.txt"

# Check if the output file exists and delete it if it does
if [ -e "$output_file" ]; then
  echo "[+] Deleting existing output file: $output_file"
  rm "$output_file"
fi

# Define an array of numbers
port_numbers=(80 81 443 3000 4200 5000 8000 8080 8443 8444 8888 9443 30821)

# Adding commas to the port numbers for rustscan
comma_separated=""
for number in "${port_numbers[@]}"; do
  if [ -n "$comma_separated" ]; then
    comma_separated+=","
  fi
  comma_separated+="$number"
done

# RustScan 
echo "
[+] Rustscan against $1"
echo "[+] Targetted ports: $comma_separated"
echo "[i] You can modify line 18 to specify the port you desire to scan"
rustscan -a "$1" -p "$comma_separated" -g > rustscan_greppable.txt

# Use grep and regular expression to extract IP addresses
ip_addresses=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' rustscan_greppable.txt)

# Use awk to remove duplicates
unique_ip_addresses=$(echo "$ip_addresses" | awk '!seen[$0]++')

# Save the unique IP addresses to a file
echo "$unique_ip_addresses" | sort > "rustscan_result.txt"

# Function to check for specific error messages
function has_error {
  if [[ "$1" != *"Connection refused"* && \
        "$1" != *"Connection reset by peer"* && \
        "$1" != *"Connection timed out"* && \
        "$1" != *"Empty reply from server"* && \
        "$1" != *"SSL_ERROR_SYSCALL"* && \
        "$1" != *"SSL routines"* ]]; then
    return 0  # No error
  else
    return 1  # Error found
  fi
}

# Extract values within square brackets and remove duplicates
active_ports=$(grep -o '\[[0-9]*\]' "rustscan_greppable.txt" | tr -d '[]' | tr ',' '\n' | sort -n | uniq)

# Read the list of active ports from the "rustscan_greppable.txt" file and format it
comma_ports=$(grep -o '\[[0-9]*\]' "rustscan_greppable.txt" | tr -d '[]' | tr ',' '\n' | sort -n | uniq | tr '\n' ',' | sed 's/,$//')

echo "[+] Done RustScan!"
echo "
[+] Proceeding to curl the Active URLs..."
echo "[+] Current Active Ports: $comma_ports"

# Loop through the list of IP addresses in the input file and run curl for active ports
while IFS= read -r ip; do
  if [ -n "$ip" ]; then
    for port_number in $active_ports; do
      http_url="http://$ip:$port_number"
      https_url="https://$ip:$port_number"

      result_http=$(curl -m 3 -k "$http_url" -o /dev/null 2>&1)
      result_https=$(curl -m 3 -k "$https_url" -o /dev/null 2>&1)

      # Check if the result doesn't contain specific error messages and is not empty
      if has_error "$result_http" && [ -n "$result_http" ]; then
        echo "$http_url" >> "$output_file"
      fi

      if [ "$port_number" -ne 80 ] && has_error "$result_https" && [ -n "$result_https" ]; then
        echo "$https_url" >> "$output_file"
      fi
    done
  fi
done < "$input_file"

# Check if the output file exists empty and then display the final message
if [ -e "$output_file" ]; then
  echo '[+] Active URLs (excluding specific errors) have been saved to' "$output_file"
else
  echo '[+] There are no active URLs on the' "$1"
fi

rm rustscan_greppable.txt
rm rustscan_result.txt
