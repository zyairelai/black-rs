#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "[+] Usage: $0 <ip_list_txt> <port_number>"
  echo "[+] Recommended to check 80,443,8000,8080,8443"
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

rm fourfourthree.txt

echo "[+] Done scanning! Output is saved to rustscan_result.txt"
