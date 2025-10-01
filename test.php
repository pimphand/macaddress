#!/bin/bash

# Configuration
SWITCH_IP="192.168.53.10"
COMMUNITY="public"

# OIDs
OID_PORTS="1.3.6.1.2.1.17.4.3.1.2"        # dot1dTpFdbPort (MAC -> Bridge Port)
OID_PORT_IFINDEX="1.3.6.1.2.1.17.1.4.1.2" # dot1dBasePortIfIndex (Bridge Port -> ifIndex)
OID_INTERFACES="1.3.6.1.2.1.2.2.1.2"      # ifDescr (Interface name)

# Fetch data via SNMP
echo "=== MAC -> Bridge Port ==="
snmpwalk -v2c -c "$COMMUNITY" "$SWITCH_IP" $OID_PORTS

echo ""
echo "=== Bridge Port -> ifIndex ==="
snmpwalk -v2c -c "$COMMUNITY" "$SWITCH_IP" $OID_PORT_IFINDEX

echo ""
echo "=== Interface Descriptions ==="
snmpwalk -v2c -c "$COMMUNITY" "$SWITCH_IP" $OID_INTERFACES
