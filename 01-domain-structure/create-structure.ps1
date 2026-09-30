$ubuntuName = "UBUNTU"
$base = "DC=lab,DC=local"

New-ADOrganizationalUnit -Name "Corp" -Path $base
$corp = "OU=Corp,$base"

"Users","Computers","Servers","Groups" | ForEach-Object {
    New-ADOrganizationalUnit -Name $_ -Path $corp
}
"IT","HR","Finance" | ForEach-Object {
    New-ADOrganizationalUnit -Name $_ -Path "OU=Users,$corp"
}

"GG_IT","GG_HR","GG_Finance" | ForEach-Object {
    New-ADGroup -Name $_ -GroupScope Global -GroupCategory Security -Path "OU=Groups,$corp"
}

Get-ADComputer -Identity $ubuntuName | Move-ADObject -TargetPath "OU=Servers,$corp"