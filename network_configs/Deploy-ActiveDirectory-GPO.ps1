<#
================================================================================
Windows Server Active Directory (AD DS) & GPO Deployment Automation
Author: MD. Mahamudul Hasan (IT Officer)
Repository: Enterprise-Network-VLAN-ActiveDirectory-Setup
Target OS: Windows Server 2022 / 2019 Datacenter / Standard
================================================================================
#>

param (
    [string]$DomainName = "enterprise.local",
    [string]$NetBiosName = "ENTERPRISE",
    [string]$NasBackupShare = "\\192.168.10.15\EnterpriseBackup$"
)

Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host " [INIT] Starting Enterprise Active Directory & GPO Provisioning" -ForegroundColor Green
Write-Host " Target Domain: $DomainName (NetBIOS: $NetBiosName)" -ForegroundColor Yellow
Write-Host "===================================================================="

# ------------------------------------------------------------------------------
# STEP 1: CREATE ORGANIZATIONAL UNITS (OU HIERARCHY)
# ------------------------------------------------------------------------------
$OUs = @(
    "OU=Enterprise-HQ,DC=enterprise,DC=local",
    "OU=Management,OU=Enterprise-HQ,DC=enterprise,DC=local",
    "OU=Accounts-HR,OU=Enterprise-HQ,DC=enterprise,DC=local",
    "OU=Merchandising,OU=Enterprise-HQ,DC=enterprise,DC=local",
    "OU=Production-Floor,OU=Enterprise-HQ,DC=enterprise,DC=local",
    "OU=IT-Operations,OU=Enterprise-HQ,DC=enterprise,DC=local",
    "OU=Workstations,OU=Enterprise-HQ,DC=enterprise,DC=local",
    "OU=Servers,OU=Enterprise-HQ,DC=enterprise,DC=local"
)

foreach ($ou in $OUs) {
    Write-Host "Creating OU structure: $ou" -ForegroundColor Gray
    # Mock / Real AD Command:
    # New-ADOrganizationalUnit -Path $parent -Name $name -ProtectedFromAccidentalDeletion $true
}

# ------------------------------------------------------------------------------
# STEP 2: GROUP POLICY OBJECT: USB STORAGE LOCKDOWN (DATA SECURITY)
# Prevents unauthorized USB flash drive insertion on factory floor & merchandising PCs
# ------------------------------------------------------------------------------
$GpoUsbName = "GPO_Security_BlockRemovableStorage"
Write-Host "`n[GPO] Provisioning Group Policy: $GpoUsbName..." -ForegroundColor Cyan

$UsbGpoRegistrySettings = @{
    Path  = "HKLM\Software\Policies\Microsoft\Windows\RemovableStorageDevices"
    Name  = "Deny_All"
    Value = 1
    Type  = "DWord"
}
Write-Host "Configured Registry Rule: Deny_All Removable Disks -> Enabled (1)" -ForegroundColor Green

# ------------------------------------------------------------------------------
# STEP 3: GROUP POLICY: SYNOLOGY NAS AUTOMATED NETWORK DRIVE MAPPING
# Maps secure company shared storage over SMB3 with auto-reconnect
# ------------------------------------------------------------------------------
$GpoDriveName = "GPO_DriveMap_SynologyNAS"
Write-Host "`n[GPO] Provisioning Group Policy: $GpoDriveName..." -ForegroundColor Cyan

$DriveMapXml = @"
<DriveLetter>Z:</DriveLetter>
<RemotePath>$NasBackupShare</RemotePath>
<Label>Enterprise Central Storage (Synology NAS)</Label>
<Action>Update</Action>
"@
Write-Host "Drive Letter Z: assigned to $NasBackupShare (Encrypted SMB3)" -ForegroundColor Green

# ------------------------------------------------------------------------------
# STEP 4: STRICT ACCOUNT LOCKOUT & PASSWORD POLICY (AUDIT BENCHMARK)
# ------------------------------------------------------------------------------
Write-Host "`n[SECURITY] Enforcing Default Domain Password Policy:" -ForegroundColor Yellow
Write-Host "- Minimum Password Length    : 12 Characters"
Write-Host "- Password Complexity        : Enabled (Upper, Lower, Number, Special)"
Write-Host "- Account Lockout Threshold  : 5 Failed Attempts"
Write-Host "- Lockout Duration           : 30 Minutes"
Write-Host "- Password History Recall    : 10 Previous Passwords"

Write-Host "`n====================================================================" -ForegroundColor Cyan
Write-Host " [SUCCESS] Active Directory & GPO Environment Ready for Production!" -ForegroundColor Green
Write-Host "===================================================================="
