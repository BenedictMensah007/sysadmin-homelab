$disk = Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Select-Object -First 1
if ($disk.IsOffline) { Set-Disk -Number $disk.Number -IsOffline $false }
if ($disk.IsReadOnly) { Set-Disk -Number $disk.Number -IsReadOnly $false }
Initialize-Disk -Number $disk.Number -PartitionStyle GPT
New-Partition -DiskNumber $disk.Number -DriveLetter X -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Backup" -Confirm:$false | Out-Null