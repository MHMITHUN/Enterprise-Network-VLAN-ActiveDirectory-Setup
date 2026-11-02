# ==============================================================================
# MikroTik RouterOS v7.x Multi-VLAN Segmentation & Firewall Topology
# Author: MD. Mahamudul Hasan
# Repository: Enterprise-Network-VLAN-ActiveDirectory-Setup
# Target Hardware: MikroTik CCR1009 / RB4011 / RB3011 / hEX S
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. CREATE MAIN BRIDGE WITH 802.1Q VLAN FILTERING
# ------------------------------------------------------------------------------
/interface bridge
add name=bridge-vlan-trunk vlan-filtering=no comment="Core Trunk Bridge"

# ------------------------------------------------------------------------------
# 2. DEFINE ENTERPRISE VLAN INTERFACES
# ------------------------------------------------------------------------------
/interface vlan
add name=vlan10-mgmt vlan-id=10 interface=bridge-vlan-trunk comment="VLAN 10: Management & Core Servers"
add name=vlan20-cctv vlan-id=20 interface=bridge-vlan-trunk comment="VLAN 20: IP CCTV Cameras & NVR Storage"
add name=vlan30-biometrics vlan-id=30 interface=bridge-vlan-trunk comment="VLAN 30: ZKTeco Biometrics & Zebra Printers"
add name=vlan40-admin vlan-id=40 interface=bridge-vlan-trunk comment="VLAN 40: Corporate Admin & ERP Workstations"

# ------------------------------------------------------------------------------
# 3. IP ADDRESS POOLS & GATEWAY ASSIGNMENTS
# ------------------------------------------------------------------------------
/ip address
add address=192.168.10.1/24 interface=vlan10-mgmt comment="VLAN 10 Gateway (Servers/NAS)"
add address=192.168.20.1/24 interface=vlan20-cctv comment="VLAN 20 Gateway (CCTV)"
add address=192.168.30.1/24 interface=vlan30-biometrics comment="VLAN 30 Gateway (Biometrics/Zebra)"
add address=192.168.40.1/24 interface=vlan40-admin comment="VLAN 40 Gateway (Admin/ERP)"

/ip pool
add name=pool-vlan20 ranges=192.168.20.100-192.168.20.250
add name=pool-vlan30 ranges=192.168.30.50-192.168.30.200
add name=pool-vlan40 ranges=192.168.40.50-192.168.40.250

# ------------------------------------------------------------------------------
# 4. DHCP SERVERS & DNS CONFIGURATION
# ------------------------------------------------------------------------------
/ip dhcp-server
add name=dhcp-vlan20 interface=vlan20-cctv address-pool=pool-vlan20 disabled=no
add name=dhcp-vlan30 interface=vlan30-biometrics address-pool=pool-vlan30 disabled=no
add name=dhcp-vlan40 interface=vlan40-admin address-pool=pool-vlan40 disabled=no

/ip dhcp-server network
add address=192.168.20.0/24 gateway=192.168.20.1 dns-server=192.168.10.2,8.8.8.8
add address=192.168.30.0/24 gateway=192.168.30.1 dns-server=192.168.10.2,8.8.8.8
add address=192.168.40.0/24 gateway=192.168.40.1 dns-server=192.168.10.2,8.8.8.8

# ------------------------------------------------------------------------------
# 5. BRIDGE PORT TAGGING & TRUNK CONFIGURATION
# ether1: Uplink to Cisco/TP-Link Managed Switch (Trunk with VLANs 10,20,30,40)
# ether2: Dedicated NVR Server Access Port (VLAN 20 PVID)
# ------------------------------------------------------------------------------
/interface bridge port
add bridge=bridge-vlan-trunk interface=ether1 comment="802.1Q Core Trunk to Layer 2 Switch"
add bridge=bridge-vlan-trunk interface=ether2 pvid=20 comment="Direct Access Port for NVR Server"
add bridge=bridge-vlan-trunk interface=ether3 pvid=10 comment="Direct Access Port for Active Directory DC"

/interface bridge vlan
add bridge=bridge-vlan-trunk vlan-ids=10 tagged=bridge-vlan-trunk,ether1 untagged=ether3
add bridge=bridge-vlan-trunk vlan-ids=20 tagged=bridge-vlan-trunk,ether1 untagged=ether2
add bridge=bridge-vlan-trunk vlan-ids=30 tagged=bridge-vlan-trunk,ether1
add bridge=bridge-vlan-trunk vlan-ids=40 tagged=bridge-vlan-trunk,ether1

# ------------------------------------------------------------------------------
# 6. ENTERPRISE FIREWALL ISOLATION RULES
# Critical Security Requirement:
# - Drop all external WAN internet access for IP CCTV cameras (prevents botnet hijacking)
# - Isolate Biometric VLAN, allowing ONLY ADMS push port 4370 to database server (192.168.10.5)
# ------------------------------------------------------------------------------
/ip firewall filter
add chain=forward action=accept connection-state=established,related comment="Accept established connections"

# CCTV Isolation: Block camera VLAN from accessing WAN internet
add chain=forward action=drop in-interface=vlan20-cctv out-interface-list=WAN comment="SECURITY: Drop WAN access for CCTV cameras (Prevent Mirai/IoT botnets)"

# Biometrics Rule: Allow ADMS port 4370 to central HRMS database only
add chain=forward action=accept in-interface=vlan30-biometrics dst-address=192.168.10.5 dst-port=4370,3306 protocol=tcp comment="Allow ZKTeco ADMS & MySQL push to DB server"
add chain=forward action=drop in-interface=vlan30-biometrics out-interface=vlan10-mgmt comment="Drop all other unauthorized traffic from Biometrics to Mgmt"

# Admin to Management Jump Host Access Only
add chain=forward action=accept in-interface=vlan40-admin dst-address=192.168.10.2 dst-port=389,636,88,53,445 protocol=tcp comment="Allow Active Directory Auth from Admin to DC"
add chain=forward action=drop in-interface=vlan40-admin out-interface=vlan20-cctv comment="Isolate Admin PCs from direct raw CCTV access (Must use NVR portal)"

# ------------------------------------------------------------------------------
# 7. BANDWIDTH QUEUE PRIORITIZATION (QoS)
# Prioritize Biometric Time-Attendance & ERP traffic over generic user downloads
# ------------------------------------------------------------------------------
/queue simple
add name="01-Biometrics-Priority" target=192.168.30.0/24 max-limit=20M/20M priority=2/2 comment="High Priority for ZKTeco Shift Punches"
add name="02-ERP-Admin-Priority" target=192.168.40.0/24 max-limit=50M/50M priority=4/4 comment="Standard Workstation Bandwidth"

# ------------------------------------------------------------------------------
# 8. ENABLE VLAN FILTERING
# ------------------------------------------------------------------------------
/interface bridge set bridge-vlan-trunk vlan-filtering=yes
