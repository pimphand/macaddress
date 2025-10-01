<?php
$switch_ip = "192.168.53.10";
$community = "public";

// Alternative approach with different OIDs
try {
    // Get MAC address table
    $ports = snmpwalkoid($switch_ip, $community, ".1.3.6.1.2.1.17.4.3.1.2");
    
    // Get port to interface mapping using different OIDs
    $port_ifindex = snmpwalkoid($switch_ip, $community, ".1.3.6.1.2.1.17.1.4.1.2");
    
    // Get interface descriptions
    $interfaces = snmpwalkoid($switch_ip, $community, ".1.3.6.1.2.1.2.2.1.2");
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit;
}

// Parse data
$mac_to_port = [];
$port_to_interface = [];

// Parse MAC addresses
foreach ($ports as $oid => $value) {
    $oid_parts = explode('.', $oid);
    $mac_parts = array_slice($oid_parts, -6);
    
    $mac = implode(':', array_map(function($part) {
        return str_pad(dechex($part), 2, '0', STR_PAD_LEFT);
    }, $mac_parts));
    
    $mac_to_port[$mac] = intval($value);
}

// Parse port to interface mapping
foreach ($port_ifindex as $oid => $value) {
    $oid_parts = explode('.', $oid);
    $bridge_port = end($oid_parts);
    $port_to_interface[$bridge_port] = intval($value);
}

// Parse interface names
$ifindex_to_name = [];
foreach ($interfaces as $oid => $value) {
    $oid_parts = explode('.', $oid);
    $ifindex = end($oid_parts);
    $ifindex_to_name[$ifindex] = trim($value, '"');
}

// Create final mapping
$final_mapping = [];
foreach ($mac_to_port as $mac => $bridge_port) {
    $interface_name = "Unknown";
    
    if (isset($port_to_interface[$bridge_port])) {
        $ifindex = $port_to_interface[$bridge_port];
        if (isset($ifindex_to_name[$ifindex])) {
            $interface_name = $ifindex_to_name[$ifindex];
        }
    }
    
    $final_mapping[$mac] = [
        'bridge_port' => $bridge_port,
        'interface' => $interface_name
    ];
}

// Sort by MAC address
ksort($final_mapping);

// Display results
echo "MAC Address to Interface Mapping:\n";
echo str_repeat("-", 80) . "\n";
printf("%-20s %-15s %-30s\n", "MAC Address", "Bridge Port", "Interface");
echo str_repeat("-", 80) . "\n";

foreach ($final_mapping as $mac => $data) {
    printf("%-20s %-15d %-30s\n", $mac, $data['bridge_port'], $data['interface']);
}
echo str_repeat("-", 80) . "\n";
?>
