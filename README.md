# Sysadmin Homelab

A hands on Windows Server and Linux lab built to practice real systems administration work. Everything runs in Hyper-V on one machine and is managed with PowerShell. Each folder documents one part of the build, and the newest one is a write-up of a real failure and how I recovered from it.

## Lab setup

| Machine | Role | Address |
|---|---|---|
| DC-2025 (DC01) | Windows Server 2025 Datacenter (Server Core): Active Directory, DNS, DHCP and the file server | 192.168.100.10 |
| Ubuntu-Server | Ubuntu Server 26.04 LTS joined to the domain, mounts the Departments share | 192.168.100.20 |

* Domain: lab.local
* Network: one internal Hyper-V switch for the lab, plus a second adapter on the Ubuntu server for updates
* Everything is managed from my laptop over PowerShell Direct and SSH

## What I built

* Active Directory structure: OUs, security groups, users
* Bulk user creation from a CSV with PowerShell
* DHCP scope and DNS records, including a reverse lookup zone
* Group Policy: password policy, login banner, Control Panel restriction
* File server with department shares and permissions
* Linux authentication through Active Directory, with login and sudo limited to one AD group
* Backup and recovery: backup scripts and the AD Recycle Bin for restoring deleted objects
* Incident write-up: the Ubuntu server stopped booting, and I rebuilt it

## Folder guide

* [01-domain-structure](01-domain-structure): OUs, groups and bulk users
* [02-dhcp-dns](02-dhcp-dns): DHCP and DNS setup
* [03-group-policy](03-group-policy): Group Policy objects
* [04-file-server](04-file-server): PowerShell script that builds the department shares and permissions
* [05-linux-access](05-linux-access): notes on joining Ubuntu to the domain and logging in with AD accounts
* [06-backup-dr](06-backup-dr): backup scripts, backup disk preparation and the AD Recycle Bin, with notes
* [07-incident-ubuntu-rebuild](07-incident-ubuntu-rebuild): what broke, what I checked, and how I rebuilt the Ubuntu server
* [screenshots](screenshots): proof of the results

## How the scripts are run

Scripts are written on my laptop and sent to the domain controller with PowerShell Direct:

```powershell
Invoke-Command -VMName "DC-2025" -Credential $cred -FilePath .\01-domain-structure\create-structure.ps1
```

## What I learned

* Reading error messages carefully solves most problems
* Managing a server remotely without a desktop is faster than I expected
* Good documentation is part of the job
* A checkpoint is not a backup, so I export the VM as well
* Take a checkpoint after every working stage, not after something breaks
* When a console freezes, work over SSH instead

## Next

* Second domain controller
* Microsoft Entra hybrid setup

## Note

All names and users in this repo are made up for the lab. No real passwords are stored here.
