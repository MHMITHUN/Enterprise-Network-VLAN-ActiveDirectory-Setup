# Enterprise Multi-VLAN Network Segmentation & Active Directory DC Setup

[![Live Demo](https://img.shields.io/badge/Demo-Live%20Network%20NOC%20Console-06b6d4)](https://mhmithun.github.io/Enterprise-Network-VLAN-ActiveDirectory-Setup/)
[![License: MIT](https://img.shields.io/badge/License-MIT-emerald.svg)](LICENSE)
[![Platform: MikroTik RouterOS](https://img.shields.io/badge/Router-MikroTik%20RouterOS%20v7-blue.svg)](network_configs/mikrotik_vlan_setup.rsc)
[![Windows Server](https://img.shields.io/badge/Windows%20Server-2022%20AD%20DS-0284c7.svg)](network_configs/Deploy-ActiveDirectory-GPO.ps1)

Production-grade enterprise network topology design and centralized directory services infrastructure featuring MikroTik 802.1Q VLAN trunking, hardware bridge filtering, firewall segmentation, QoS prioritization, and Windows Server 2022 Active Directory Domain Controller (AD DS) automated Group Policy Object (GPO) security lockdown.

---

## 🌐 Architecture & Live Web Dashboard

The project includes an **interactive Network NOC & Active Directory Dashboard** (`index.html`):
- **4-VLAN Segmentation Topology**: Interactive architecture map separating Management (VLAN 10), IP CCTV (VLAN 20), Factory Biometrics/Zebra Printers (VLAN 30), and Corporate Admin/ERP (VLAN 40).
- **Interactive MikroTik ICMP Ping Terminal**: Live Layer 3 ping diagnostic tool testing latency and firewall rule enforcement across subnets.
- **Windows Server Active Directory GPO Inspector**: Live policy validator for removable media lockdown, Synology NAS drive mapping, and password complexity.

---

## 🛠️ Key Technical Implementations

1. **MikroTik RouterOS 802.1Q VLAN Script (`network_configs/mikrotik_vlan_setup.rsc`)**:
   - Hardware bridge VLAN filtering (`vlan-filtering=yes`).
   - Automated IP pools and DHCP servers with DHCP snooping to prevent rogue DHCP attacks.
   - **Critical Firewall Isolation**:
     - Complete WAN internet block on CCTV VLAN 20 (prevents IoT botnet exploits like Mirai).
     - Biometrics VLAN 30 isolated, permitting only ADMS push port 4370 and MySQL port 3306.
   - QoS Bandwidth Queuing prioritizing biometric turnstile punches over general browsing.

2. **Windows Server Active Directory & GPOs (`network_configs/Deploy-ActiveDirectory-GPO.ps1`)**:
   - Automated Organizational Unit (OU) hierarchy creation: `Enterprise-HQ`, `Production-Floor`, `Merchandising`, `Accounts-HR`, `Workstations`.
   - **GPO 01 (Removable Storage Lockdown)**: Disables USB flash drives across factory floor and merchandising PCs.
   - **GPO 02 (Automated NAS Backup Drive)**: Maps encrypted SMB3 share `Z:` pointing to Synology NAS (`\\192.168.10.15\Backup$`).
   - **GPO 03 (Password & Account Lockout)**: Enforces 12-character complex passwords and 5-attempt lockout conforming to ISO 27001 standards.

---

## 🚀 Quick Start

### 1. Run the Interactive Web Console
```bash
# Open index.html in any modern web browser or run:
python -m http.server 8082
# Navigate to http://localhost:8082
```

### 2. Deploy MikroTik Script
Import `mikrotik_vlan_setup.rsc` directly via WinBox or MikroTik SSH:
```bash
/import file-name=mikrotik_vlan_setup.rsc
```

### 3. Deploy Active Directory Script
Execute `Deploy-ActiveDirectory-GPO.ps1` in an elevated PowerShell session on Windows Server 2022:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process
.\network_configs\Deploy-ActiveDirectory-GPO.ps1 -DomainName "enterprise.local"
```

---

## 📄 License & Maintainer

Maintained by **[MD. Mahamudul Hasan](https://github.com/MHMITHUN)**  
- GitHub: [@MHMITHUN](https://github.com/MHMITHUN)  
- LinkedIn: [linkedin.com/in/mahamudul0](https://linkedin.com/in/mahamudul0)  
- Email: mhmmithun1@gmail.com  

Released under the [MIT License](LICENSE).
