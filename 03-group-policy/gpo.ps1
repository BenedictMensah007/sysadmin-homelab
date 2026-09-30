Import-Module GroupPolicy
$base = "DC=lab,DC=local"

# Rule 1: domain password policy
Set-ADDefaultDomainPasswordPolicy -Identity lab.local -MinPasswordLength 10 -ComplexityEnabled $true `
    -LockoutThreshold 5 -LockoutDuration 00:30:00 -LockoutObservationWindow 00:30:00

# Rule 2: login banner for every computer in the domain
New-GPO -Name "Login Banner" | New-GPLink -Target $base
$k = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-GPRegistryValue -Name "Login Banner" -Key $k -ValueName legalnoticecaption -Type String -Value "Notice"
Set-GPRegistryValue -Name "Login Banner" -Key $k -ValueName legalnoticetext -Type String -Value "Authorized use only."

# Rule 3: hide Control Panel for HR users
New-GPO -Name "Block Control Panel" | New-GPLink -Target "OU=HR,OU=Users,OU=Corp,$base"
Set-GPRegistryValue -Name "Block Control Panel" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName NoControlPanel -Type DWord -Value 1