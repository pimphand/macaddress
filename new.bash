#!/bin/bash

IP="192.168.53.10"
COMMUNITY="public"
PORT="3"

snmpwalk -v2c -c $COMMUNITY $IP 1.3.6.1.2.1.17.4.3.1.3 | grep " $PORT$" | while read -r line; do
    # Ambil bagian OID (angka-angka belakang sebelum '=')
    OID=$(echo "$line" | awk '{print $1}')
    # Ambil angka heksadesimal setelah OID
    HEX=$(echo "$OID" | awk -F '.' '{for(i=12;i<=NF;i++) printf "%02X:", $i; print ""}')
    # Buang ":" terakhir
    MAC=$(echo "$HEX" | sed 's/:$//')
    
    # Ambil port number
    PNUM=$(echo "$line" | awk '{print $NF}')
    
    echo "MAC Address: $MAC  -->  Port: $PNUM"
done
