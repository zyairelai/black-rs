# BLACK RS
This repository contains the scripts I used for massive IP scans
```
black_rs.sh : Detect all active web URL + ports combinations
knnaabu.sh : Use naabu to detect the top 100 open ports then Nuclei scan
```

![image](https://github.com/zyairelai/black-rs/assets/49854907/b3f690c1-8ded-418a-b29e-115d44dc9fa7)


## Prerequisite
Installing Rust and  Cargo 
```
curl https://sh.rustup.rs -sSf | sh
```
```
source "$HOME/.cargo/env"
```
Installing Rustscan from Cargo and add to `/usr/bin/`
```
cargo install rustscan
```
```
sudo cp ~/.cargo/bin/rustscan /usr/bin/rustscan
```

## INSTALLATION
```
wget https://raw.githubusercontent.com/zyairelai/black-rs/main/black_rs.sh
chmod a+x black_rs.sh
sudo mv black_rs.sh /usr/bin/black_rs
```

## USAGE 
```
$ black_rs
[+] Usage: black_rs <ip_list_txt>
```
This script will eliminate those protocols and port combinations you cannot visit.  
Leaving you clean and clear IP-URL to target!
