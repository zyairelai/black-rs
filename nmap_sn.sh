# Nmap -sn scan to ping live target
echo "
[+] Pinging live host using nmap"
nmap -sn -iL ip_addresses.txt > nmap_raw.txt

# Use grep and regular expression to extract IP addresses
ip_addresses=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' nmap_raw.txt)

# Use awk to remove duplicates
unique_ip_addresses=$(echo "$ip_addresses" | awk '!seen[$0]++')

# Save the unique IP addresses to a file
echo "$unique_ip_addresses" > "nmap.txt"

# Loop through the unique IP addresses (optional)
for ip in $unique_ip_addresses; do
  echo "$ip"
done
