	$ports = snmpwalk($switch_ip, $community, "1.3.6.1.2.1.17.4.3.1.2"); // Port Numbers
	$port_ifindex = snmpwalk($switch_ip, $community, "1.3.6.1.2.1.17.1.4.1.2"); // Port ifIndex
	$interfaces = snmpwalk($switch_ip, $community, "1.3.6.1.2.1.2.2.1.2"); // Port Interface Descriptions
