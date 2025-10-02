 ip route
default via 192.168.50.1 dev ens160 proto static metric 100 
192.168.50.0/24 dev ens160 proto kernel scope link src 192.168.50.13 metric 100 
192.168.53.0/24 dev vlan11 proto kernel scope link src 192.168.53.191 metric 400 
