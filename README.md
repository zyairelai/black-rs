# BLACK RS
This repository contains the scripts I used for massive IP scans

![image](https://github.com/zyairelai/black-rs/assets/49854907/b3f690c1-8ded-418a-b29e-115d44dc9fa7)


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

## INSTALLATION
```
wget https://raw.githubusercontent.com/zyairelai/host-ip-recon/main/black_rs.sh
chmod a+x black_rs.sh
sudo mv black_rs.sh /usr/bin/black_rs
```

## USAGE 
Use `rs_port.sh` to scan the port you want to target
```
$ black_rs
[+] Usage: black_rs <ip_list_txt> <port_number>
[+] Do note that this script can only take port number one at a time
```
Example
```
black_rs target_ips.txt 8443
```
This script will eliminate those protocols and port combinations you cannot visit.  
Leaving you clean and clear IP-URL to target!
