#AD Companion script for Hades

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

echo "$line Listing the Hostname and IP Address for machines in the Domain" 

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

echo "$line Listing Group Memberships"

foreach ($group in $(LDAPSearch -LDAPQuery "(objectCategory=group)")) {$group.properties | select {$_.cn}, {$_.member} | Format-List}
