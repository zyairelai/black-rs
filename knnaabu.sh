#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "[+] Usage: $0 <ip_list.txt>"
  exit 1
fi

# Check if Nuclei installed, if not, HALT
if [ ! -f "/usr/bin/nuclei" ]; then
  echo "[+] Nuclei not found!"
  echo "[+] RTFM and install Nuclei before proceeding!"
  exit 1
fi

# Check if /usr/bin/naabu exists, in not, install it
if [ ! -f "/usr/bin/naabu" ]; then
  echo "[+] /usr/bin/naabu not found!"
  echo "[+] Installing naabu..."
  wget -q https://github.com/projectdiscovery/naabu/releases/download/v2.1.0/naabu_2.1.0_linux_amd64.zip
  unzip -q naabu_2.1.0_linux_amd64.zip
  rm naabu_2.1.0_linux_amd64.zip
  sudo mv naabu /usr/bin/naabu
fi

naabu_output="knn_naabu.txt"
nuclei_output="knn_nuclei.txt"

# Run naabu on silent mode
echo "[+] Following are the Naabu scan output:"
/usr/bin/naabu -silent -l "$1" -o $naabu_output
echo "
[+] Done naabu! The naabu scan output is saved to knn_naabu.txt"

# Sort the IP and Port for OCD purposes
sort -t':' -k1,1 -k2,2n -o $naabu_output $naabu_output

# Run nuclei against the naabu.txt
echo "[+] Proceeding to nuclei scan against knn_naabu.txt"
# /usr/bin/nuclei -l $naabu_output -es info,low -o $nuclei_output
/usr/bin/nuclei -l $naabu_output -o $nuclei_output
echo "
[+] Done! The Nuclei Output is saved to knn_nuclei.txt"
