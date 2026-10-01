# sysadmin-homelab

\# Sysadmin Homelab



A hands on Windows Server and Linux lab built to practice real systems administration work. Everything runs in Hyper-V on one machine and is managed with PowerShell.



\## Lab setup



\* Windows Server 2025 Datacenter (Server Core) as the domain controller

\* Ubuntu Server joined to the domain

\* Domain: lab.local



\## What I built



\* Active Directory structure: OUs, security groups, users

\* Bulk user creation from a CSV with PowerShell

\* DHCP scope and DNS records, including a reverse lookup zone

\* Group Policy: password policy, login banner, Control Panel restriction

\* Linux authentication through Active Directory



\## Folder guide



\* 01-domain-structure: OUs, groups and bulk users

\* 02-dhcp-dns: DHCP and DNS setup

\* 03-group-policy: Group Policy objects



\## How the scripts are run



Scripts are written on my laptop and sent to the domain controller with PowerShell Direct:



```powershell

Invoke-Command -VMName "DC-2025" -Credential $cred -FilePath .\\01-domain-structure\\create-structure.ps1

```



\## What I learned



\* Reading error messages carefully solves most problems

\* Managing a server remotely without a desktop is faster than I expected

\* Good documentation is part of the job



\## Next



\* File server with permissions

\* Backup and recovery

\* Second domain controller

\* Microsoft Entra hybrid setup



\## Note



All names and users in this repo are made up for the lab. No real passwords are stored here.

