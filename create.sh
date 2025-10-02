1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:0c:29:ad:aa:80 brd ff:ff:ff:ff:ff:ff
    altname enp3s0
    inet 192.168.50.13/24 brd 192.168.50.255 scope global noprefixroute ens160
       valid_lft forever preferred_lft forever
4: vlan11@ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 00:0c:29:ad:aa:80 brd ff:ff:ff:ff:ff:ff
    inet 192.168.53.191/24 brd 192.168.53.255 scope global noprefixroute vlan11
       valid_lft forever preferred_lft forever
    inet6 fe80::9307:564e:b31e:688/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
