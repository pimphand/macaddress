vlan11@ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 00:0c:29:ad:aa:80 brd ff:ff:ff:ff:ff:ff
    inet 192.168.53.191/24 brd 192.168.53.255 scope global noprefixroute vlan11
       valid_lft forever preferred_lft forever
    inet6 fe80::9307:564e:b31e:688/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever


<?php
$switch_ip = "your_switch_ip";
$community = "your_community";

// Simple direct approach
$ports = snmpwalkoid($switch_ip, $community, ".1.3.6.1.2.1.17.4.3.1.2");
$port_ifindex = snmpwalkoid($switch_ip, $community, ".1.3.6.1.2.1.17.1.4.1.2");
$interfaces = snmpwalkoid($switch_ip, $community, ".1.3.6.1.2.1.2.2.1.2");

// Build interface mapping
$ifindex_map = [];
foreach ($interfaces as $oid => $name) {
    $parts = explode('.', $oid);
    $ifindex = end($parts);
    $ifindex_map[$ifindex] = trim($name, '"');
}

// Build port mapping
$port_map = [];
foreach ($port_ifindex as $oid => $ifindex) {
    $parts = explode('.', $oid);
    $port = end($parts);
    $port_map[$port] = trim($ifindex, '"');
}

// Process MAC addresses
$results = [];
foreach ($ports as $oid => $port) {
    // Extract MAC
    $parts = explode('.', $oid);
    $mac_parts = array_slice($parts, -6);
    $mac = implode(':', array_map(function($p) {
        return str_pad(dechex($p), 2, '0', STR_PAD_LEFT);
    }, $mac_parts));
    
    // Get interface
    $bridge_port = trim($port, '"');
    $ifindex = isset($port_map[$bridge_port]) ? $port_map[$bridge_port] : null;
    $interface = ($ifindex && isset($ifindex_map[$ifindex])) ? $ifindex_map[$ifindex] : "Unknown";
    
    $results[$mac] = [
        'port' => $bridge_port,
        'interface' => $interface
    ];
}

// Sort and display
ksort($results);
echo "MAC Address to Interface Mapping:\n";
echo str_repeat("-", 80) . "\n";
printf("%-20s %-15s %-30s\n", "MAC Address", "Bridge Port", "Interface");
echo str_repeat("-", 80) . "\n";

foreach ($results as $mac => $data) {
    printf("%-20s %-15s %-30s\n", $mac, $data['port'], $data['interface']);
}

// Debug port mappings
echo "\nAvailable Port Mappings:\n";
foreach ($port_map as $port => $ifindex) {
    $interface = isset($ifindex_map[$ifindex]) ? $ifindex_map[$ifindex] : "Unknown";
    echo "Bridge Port $port → ifIndex $ifindex → Interface: $interface\n";
}
?>
