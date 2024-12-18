# Ensure the Active Directory module is loaded
Import-Module ActiveDirectory

# Get all domain-joined computers
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
