#!/bin/bash

# Download OUI database jika belum ada
OUI_FILE="/tmp/oui.txt"
if [ ! -f "$OUI_FILE" ]; then
    echo "Downloading OUI database..."
    wget -q -O "$OUI_FILE" http://standards-oui.ieee.org/oui/oui.txt
fi

echo "=== MAC ADDRESSES WITH VENDOR LOOKUP ==="

snmpwalk -v2c -c public 192.168.53.10 1.3.6.1.2.1.17.4.3.1.3 | \
awk -v oui_file="$OUI_FILE" '
function get_vendor(mac) {
    # Extract OUI (first 3 bytes)
    split(mac, parts, ":")
    oui = toupper(parts[1] "-" parts[2] "-" parts[3])
    
    # Cari di OUI database
    cmd = "grep -i \"" oui "\" " oui_file " | head -1"
    cmd | getline vendor_line
    close(cmd)
    
    if (vendor_line != "") {
        # Extract company name
        split(vendor_line, line_parts, ")")
        if (length(line_parts) > 1) {
            gsub(/^[ \t]+|[ \t]+$/, "", line_parts[2])
            return line_parts[2]
        }
    }
    return "Unknown"
}
{
    # Extract MAC address
    split($1, parts, ".")
    mac = sprintf("%02x:%02x:%02x:%02x:%02x:%02x", 
                  parts[12], parts[13], parts[14], 
                  parts[15], parts[16], parts[17])
    
    # Extract port number
    port = $NF
    gsub(/[^0-9]/, "", port)
    
    # Get vendor
    vendor = get_vendor(mac)
    
    printf "%s | %s | %s\n", mac, port, vendor
}' | sort -t "|" -k2 -n
