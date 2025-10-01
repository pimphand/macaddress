<?php
$switch_ip = "your_switch_ip";
$community = "your_community";

// Get bridge port numbers for MAC addresses (dot1dTpFdbPort)
$ports = snmpwalk($switch_ip, $community, ".1.3.6.1.2.1.17.4.3.1.2");

// Get bridge port to ifIndex mapping (dot1dBasePortIfIndex)
$port_ifindex = snmpwalk($switch_ip, $community, ".1.3.6.1.2.1.17.1.4.1.2");

// Get interface names (ifDescr)
$interfaces = snmpwalk($switch_ip, $community, ".1.3.6.1.2.1.2.2.1.2");

// Parse MAC addresses and port numbers
$mac_to_port = [];
foreach ($ports as $oid => $value) {
    // Extract MAC address from OID (last 6 parts)
    $oid_parts = explode('.', $oid);
    $mac_parts = array_slice($oid_parts, -6);
    
    $mac = implode(':', array_map(function($part) {
        return str_pad(dechex($part), 2, '0', STR_PAD_LEFT);
    }, $mac_parts));
    
    // Extract port number from value (remove "INTEGER: ")
    $port_number = intval(str_replace('INTEGER: ', '', $value));
    $mac_to_port[$mac] = $port_number;
}

// Map bridge ports to interface names
$port_to_interface = [];
foreach ($port_ifindex as $oid => $value) {
    // Extract bridge port from OID (last part)
    $oid_parts = explode('.', $oid);
    $bridge_port = end($oid_parts);
    
    // Extract ifIndex from value
    $ifindex = intval(str_replace('INTEGER: ', '', $value));
    
    // Find interface name
    foreach ($interfaces as $if_oid => $if_name) {
        $if_oid_parts = explode('.', $if_oid);
        $current_ifindex = end($if_oid_parts);
        
        if ($current_ifindex == $ifindex) {
            $port_to_interface[$bridge_port] = str_replace('STRING: ', '', $if_name);
            break;
        }
    }
}

// Sort by MAC address
ksort($mac_to_port);

// Display results
echo "MAC Address to Interface Mapping:\n";
echo str_repeat("-", 80) . "\n";
printf("%-20s %-15s %-30s\n", "MAC Address", "Bridge Port", "Interface");
echo str_repeat("-", 80) . "\n";

foreach ($mac_to_port as $mac => $bridge_port) {
    $interface = isset($port_to_interface[$bridge_port]) ? $port_to_interface[$bridge_port] : "Unknown";
    printf("%-20s %-15d %-30s\n", $mac, $bridge_port, $interface);
}
echo str_repeat("-", 80) . "\n";
echo "Total MAC addresses: " . count($mac_to_port) . "\n";

// Debug information
echo "\nDebug Information:\n";
echo "Port ifIndex entries: " . count($port_ifindex) . "\n";
echo "Interface entries: " . count($interfaces) . "\n";
echo "Port to Interface mappings: " . count($port_to_interface) . "\n";

// Show available interfaces
echo "\nAvailable Interfaces:\n";
foreach ($interfaces as $oid => $if_name) {
    $if_oid_parts = explode('.', $oid);
    $ifindex = end($if_oid_parts);
    echo "ifIndex $ifindex: " . str_replace('STRING: ', '', $if_name) . "\n";
}
?>
