# host-ip-recon
This repository contains the scripts I used for massive IP scans

## Prerequisite
Installing Rust and  Cargo
```
curl https://sh.rustup.rs -sSf | sh
```
```
source "$HOME/.cargo/env"
```
Installing Rustscan from Cargo
```
cargo install rustscan
```
Adding rustscan to `/usr/bin/`
```
sudo cp ~/.cargo/bin/rustscan /usr/bin/rustscan
```

## GET MY SCRIPT
```
wget https://raw.githubusercontent.com/zyairelai/host-ip-recon/main/curl_active.sh
wget https://raw.githubusercontent.com/zyairelai/host-ip-recon/main/rs_port.sh
chmod a+x curl_active.sh rs_port.sh
```

## USAGE on `rs_port.sh`
Use `rs_port.sh` to scan the port you want to target
```
$ ./rs_port.sh
[+] Usage: ./rs_port.sh <ip_list_txt> <port_number>
[+] Recommended to check 80,443,8000,8080,8443
```
Example
```
./rs_port.sh target_ips.txt 80,443,8000,8080,8443
```
You shall see `rustscan_result.txt` in the same directory
```
cat rustscan_result.txt
```
## USAGE on `curl_active.sh`
This will be more specific on the IP address protocol  
```
$ ./curl_active.sh
[+] Usage: ./curl_active.sh <port_number>
[+] Do note that this script can only take port number one at a time
```
Before running this `curl_active.sh`, it takes the previous `rustscan_result.txt` as input  
This will eliminate those protocols and port combinations you cannot visit.  
Leaving you clean and clear IP-URL to target!
