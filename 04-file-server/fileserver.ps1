Install-WindowsFeature FS-FileServer

$nb = (Get-ADDomain).NetBIOSName
$root = "C:\Shares\Departments"
$depts = "IT","HR","Finance"

# Make the main folder and one folder per department
New-Item -Path $root -ItemType Directory -Force | Out-Null
foreach ($d in $depts) {
    New-Item -Path "$root\$d" -ItemType Directory -Force | Out-Null
}

# Main folder: everyone can see inside it, but not open the department folders
icacls $root /inheritance:r /grant "SYSTEM:(OI)(CI)F" "BUILTIN\Administrators:(OI)(CI)F" "$nb\Domain Admins:(OI)(CI)F" "$nb\Domain Users:(RX)"

# Department folders: only that department group, plus admins
foreach ($d in $depts) {
    icacls "$root\$d" /inheritance:r /grant "SYSTEM:(OI)(CI)F" "BUILTIN\Administrators:(OI)(CI)F" "$nb\Domain Admins:(OI)(CI)F" "$nb\GG_${d}:(OI)(CI)M"
}

# Share it, and hide folders people cannot open
New-SmbShare -Name Departments -Path $root -FullAccess "$nb\Domain Admins" -ChangeAccess "$nb\Domain Users"
Set-SmbShare -Name Departments -FolderEnumerationMode AccessBased -Force