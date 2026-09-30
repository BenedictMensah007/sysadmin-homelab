Install-WindowsFeature DHCP -IncludeManagementTools

$dc = (Get-ADDomainController).HostName
Add-DhcpServerInDC -DnsName $dc -IPAddress 192.168.100.10
Add-DhcpServerSecurityGroup
Restart-Service dhcpserver

Add-DhcpServerv4Scope -Name "LabScope" -StartRange 192.168.100.100 -EndRange 192.168.100.200 -SubnetMask 255.255.255.0
Set-DhcpServerv4OptionValue -ScopeId 192.168.100.0 -DnsServer 192.168.100.10 -DnsDomain lab.local

Add-DnsServerPrimaryZone -NetworkId "192.168.100.0/24" -ReplicationScope Domain
Add-DnsServerResourceRecordA -Name "web01" -ZoneName lab.local -IPv4Address 192.168.100.50 -CreatePtr