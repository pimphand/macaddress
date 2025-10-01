<?php
$switch_ip = "192.168.53.10";
$community = "public";

// Get bridge port numbers for MAC addresses
$ports = snmpwalk($switch_ip, $community, "1.3.6.1.2.1.17.4.3.1.2");

// Get bridge port to ifIndex mapping
$port_ifindex = snmpwalk($switch_ip, $community, "1.3.6.1.2.1.17.1.4.1.2");

// Get interface names
$interfaces = snmpwalk($switch_ip, $community, "1.3.6.1.2.1.2.2.1.2");

// Parse the results
$mac_to_port = [];
foreach ($ports as $oid => $port_number) {
    // Extract MAC address from OID
    $mac_parts = explode('.', $oid);
    $mac_parts = array_slice($mac_parts, -6); // Last 6 parts are MAC address
    $mac = implode(':', array_map(function($part) {
        return str_pad(dechex($part), 2, '0', STR_PAD_LEFT);
    }, $mac_parts));
    
    $mac_to_port[$mac] = $port_number;
}

// Map bridge ports to interface names
$port_to_interface = [];
foreach ($port_ifindex as $bridge_port => $ifindex) {
    if (isset($interfaces[$ifindex])) {
        $port_to_interface[$bridge_port] = $interfaces[$ifindex];
    }
}

// Display results
echo "MAC Address to Interface Mapping:\n";
foreach ($mac_to_port as $mac => $bridge_port) {
    $interface = isset($port_to_interface[$bridge_port]) ? $port_to_interface[$bridge_port] : "Unknown";
    echo "MAC: $mac → Bridge Port: $bridge_port → Interface: $interface\n";
}
?>
MAC: 00 → Bridge Port: INTEGER: 104 → Interface: Unknown
MAC: 01 → Bridge Port: INTEGER: 111 → Interface: Unknown
MAC: 02 → Bridge Port: INTEGER: 111 → Interface: Unknown
MAC: 03 → Bridge Port: INTEGER: 97 → Interface: Unknown
MAC: 04 → Bridge Port: INTEGER: 108 → Interface: Unknown
MAC: 05 → Bridge Port: INTEGER: 98 → Interface: Unknown
MAC: 06 → Bridge Port: INTEGER: 112 → Interface: Unknown
MAC: 07 → Bridge Port: INTEGER: 107 → Interface: Unknown
MAC: 08 → Bridge Port: INTEGER: 112 → Interface: Unknown
MAC: 09 → Bridge Port: INTEGER: 112 → Interface: Unknown
MAC: 0a → Bridge Port: INTEGER: 115 → Interface: Unknown
MAC: 0b → Bridge Port: INTEGER: 113 → Interface: Unknown
MAC: 0c → Bridge Port: INTEGER: 0 → Interface: Unknown
MAC: 0d → Bridge Port: INTEGER: 116 → Interface: Unknown
MAC: 0e → Bridge Port: INTEGER: 115 → Interface: Unknown
MAC: 0f → Bridge Port: INTEGER: 116 → Interface: Unknown
MAC: 10 → Bridge Port: INTEGER: 115 → Interface: Unknown
MAC: 11 → Bridge Port: INTEGER: 106 → Interface: Unknown
MAC: 12 → Bridge Port: INTEGER: 105 → Interface: Unknown
MAC: 13 → Bridge Port: INTEGER: 106 → Interface: Unknown
MAC: 14 → Bridge Port: INTEGER: 102 → Interface: Unknown

