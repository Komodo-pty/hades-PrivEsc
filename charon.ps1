#AD Companion script for Hades

param (
    [switch]$h,
    [string[]]$groups,
    [switch]$ag,
    [string[]]$users,
    [switch]$au,
    [switch]$c
)

$help = @'
[Options]
	-h: Show this help menu
        -groups <Group1, Group2, etc>: Specify 1+ group(s) to enumerate children. Look for Nested Groups. For >1 group, use commas between group names
	-ag: Enumerate All Groups
	-users <User, User2, etc>: Specify 1+ user(s) to enumerate account properties
	-au: List All Users
	-c: List the Hostname & IP for each machine in the Domain

[Usage]
	Import-Module C:\path\to\charon.ps1
        powershell -File C:\path\to\charon.ps1 -au -ag -c
	powershell -File C:\path\to\charon.ps1 -groups "HR", "Development Team"
	powershell -File C:\path\to\charon.ps1 -users "bob", "lisa"

'@

if ($h) {
	Write-Host $help
	exit
}

function LDAPSearch {
    param (
        [string]$LDAPQuery
    )

    $PDC = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().PdcRoleOwner.Name
    $DistinguishedName = ([adsi]'').distinguishedName

    $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$PDC/$DistinguishedName")

    $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher($DirectoryEntry, $LDAPQuery)

    return $DirectorySearcher.FindAll()

}

$line = "`n================================================================================`n"

if ($c) {
	
	Write-Host "$line Listing the Hostname and IP Address for machines in the Domain `n"
	Import-Module ActiveDirectory

	$computers = Get-ADComputer -Filter * -Property Name

	# Iterate through each computer and retrieve its hostname and IP address
	
	foreach ($computer in $computers) {
		$hostname = $computer.Name

		try {
			# Resolve the computer's IP address using DNS
			
			$ip = (Resolve-DnsName -Name $hostname -ErrorAction Stop).IPAddress

			# Output the hostname and IP address
			
			[PSCustomObject]@{
				Hostname = $hostname
				IPAddress = $ip
			}
		} catch {
			Write-Warning "Unable to resolve IP for $hostname"
		}
	}
}

if ($ag) {
	Write-Host "$line Listing All Group Memberships `n"
	foreach ($group in $(LDAPSearch -LDAPQuery "(objectCategory=group)")) {$group.properties | select {$_.cn}, {$_.member} | Format-List}
}

if ($groups) {
	foreach ( $value in $groups) {
		Write-Host "$line Members of $value `n"
		$i = LDAPSearch -LDAPQuery "(&(objectCategory=group)(cn=$value))"
		$i.properties.member
	}
}

if ($users) {
        foreach ( $value in $users) {
                Write-Host "$line $value Account Properties`n"
                $i = LDAPSearch -LDAPQuery "(&(objectCategory=user)(cn=$value))"
                $i.properties | Format-List
        }
}

if ($au) {
	Write-Host "$line Listing All Users `n"
	$results = LDAPSearch -LDAPQuery "(samAccountType=805306368)"

	# Iterate over each result (user)
	foreach ($searchResult in $results) {
		Write-Host "$line Properties for user: $($searchResult.Properties['samaccountname'])"

		# Iterate over each property in the result and display it
		foreach ($property in $searchResult.Properties.PropertyNames) {
			$propertyValue = $searchResult.Properties[$property]
			Write-Host "$property : $propertyValue"
		}
	}
}
