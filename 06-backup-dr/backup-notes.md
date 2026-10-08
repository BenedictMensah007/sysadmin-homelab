\# Backing up the domain controller



A second virtual disk (X:) was added to the DC and a system state backup was taken with Windows Server Backup.



```

Install-WindowsFeature Windows-Server-Backup

wbadmin start systemstatebackup -backupTarget:X: -quiet

wbadmin get versions

```



Note: this is a lab setup. In a real environment the backup goes to a separate device or offsite storage, never the same machine.

