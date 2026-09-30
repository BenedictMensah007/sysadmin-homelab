param($Users, [securestring]$Password)

$corp = "OU=Corp,DC=lab,DC=local"

foreach ($u in $Users) {
    New-ADUser -Name "$($u.GivenName) $($u.Surname)" `
        -GivenName $u.GivenName -Surname $u.Surname `
        -SamAccountName $u.Username `
        -UserPrincipalName "$($u.Username)@lab.local" `
        -Path "OU=$($u.Department),OU=Users,$corp" `
        -AccountPassword $Password -Enabled $true `
        -ChangePasswordAtLogon $true
    Add-ADGroupMember -Identity "GG_$($u.Department)" -Members $u.Username
}