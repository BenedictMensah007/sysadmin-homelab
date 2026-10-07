\# Recovering a deleted user with the AD Recycle Bin



Enable the Recycle Bin (one time, cannot be undone):



```

Enable-ADOptionalFeature -Identity 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target 'lab.local' -Confirm:$false

```



Delete a test user, then restore them with their group memberships:



```

Remove-ADUser -Identity yboateng -Confirm:$false

Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "Yaw\*"' -IncludeDeletedObjects | Restore-ADObject

```



Result: the user returns to the same OU, with the same group membership.

