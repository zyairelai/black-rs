#!/bin/bash

# Define an array of numbers
port_numbers=(80 81 443 3000 4200 5000 8000 8006 8080 8443 8444 8888 9443 30821)

if [ "$#" -ne 1 ]; then
  echo "[+] Usage: $0 <ip_list_txt>"
  exit 1
fi

input_file="$1"
output_file="blackrs_output.txt"

# Check if the output file exists and delete it if it does
if [ -e "$output_file" ]; then
  # echo "[+] Deleting existing output file: $output_file"
  rm "$output_file"
fi

if [ -e "rustscan_raw.txt" ]; then
  rm rustscan_raw.txt
fi

if [ -e "rustscan.txt" ]; then
  rm rustscan.txt
fi

# Adding commas to the port numbers for rustscan
comma_separated=""
for number in "${port_numbers[@]}"; do
  if [ -n "$comma_separated" ]; then
    comma_separated+=","
  fi
  comma_separated+="$number"
done

# RustScan 
echo "[+] Rustscan against $1"
echo "[+] Targetted ports: $comma_separated"
rustscan -a "$1" -p "$comma_separated" -g > rustscan_raw.txt
sort -u rustscan_raw.txt -o rustscan.txt

# Function to check for specific error messages
function has_error {
  if [ -z "$1" ]; then
    return 1  # Error found (empty output)
  elif [[ "$1" != *"curl failed"* && \
        "$1" != *"Empty reply from server"* && \
        "$1" != *"no alternative certificate"* && \
  	    "$1" != *"Forbidden"* && \
        "$1" != *"Not Found"* && \
  	    "$1" != *"refused"* && \
        "$1" != *"reset by peer"* && \
        "$1" != *"timed out"* && \
        "$1" != *"400 Bad Request"* && \
        "$1" != *"401 Unauthorized"* && \
        "$1" != *"403 Forbidden"* && \
        "$1" != *"404 Not Found"* && \
        "$1" != *"PROTOCOL_ERROR"* && \
        "$1" != *"SSL_ERROR_SYSCALL"* && \
        "$1" != *"SSL routines"* ]]; then
    return 0  # No error
  else
    return 1  # Error found
  fi
}

echo "[+] Done RustScan!"
echo "[+] Proceeding to curl the Active URLs..."

# Loop through the list of IP addresses in the input file
while IFS= read -r line; do
  # Extract IP and port numbers from the line
  ip=$(echo "$line" | awk -F ' -> ' '{print $1}')
  ports=$(echo "$line" | awk -F ' -> ' '{print $2}' | tr -d '[]' | tr ',' ' ')

  if [ -n "$ip" ]; then
    for port_number in $ports; do
      if [ "$port_number" -eq 8080 ]; then http_url="http://$ip:$port_number"
      elif [ "$port_number" -eq 80 ]; then http_url="http://$ip"
      elif [ "$port_number" -eq 443 ]; then https_url="https://$ip"
      elif [ "$port_number" -eq 8443 ] || [ "$port_number" -eq 9443 ]; then
      	https_url="https://$ip:$port_number"
      else
        http_url="http://$ip:$port_number"
        https_url="https://$ip:$port_number"
      fi
      
      result_http=$(curl -L -s -m 3 -k "$http_url")
      result_https=$(curl -L -s -m 3 -k "$https_url")

      if has_error "$result_http" && [ -n "$result_http" ]; then
        echo "$http_url" >> "$output_file"
      fi

      if has_error "$result_https" && [ -n "$result_https" ]; then
        echo "$https_url" >> "$output_file"
      fi

    done
  fi
done < "rustscan.txt"

# Check if the output file exists empty and then display the final message
if [ -e "$output_file" ]; then
  awk '!seen[$0]++' $output_file > final_ride.txt
  sort -u final_ride.txt -o $output_file
  echo '[+] Active URLs (excluding specific errors) have been saved to' "$output_file"
else
  echo '[+] There are no active URLs'
fi

rm rustscan_raw.txt
rm final_ride.txt
# rm rustscan.txt
