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

echo "$line [!] Tip: Only Enumerating Local Machine (users, groups, etc) & not querying Domain information $line"

whoami /all

echo "$line Listing Root Directory"
Get-ChildItem -Path C:\ -Force -EA SilentlyContinue

echo "$line [!] Tip: If the script is not run interactively (e.g. via WinRM), Hades won't be able to prompt you for directories to search & you'll need to manually Enumerate them" 

$userInput = Read-Host -Prompt "Enter non-standard directories seperated by a comma (e.g. inetpub,xampp)"
$userInput = $userInput.split(",");
foreach ($i in $userInput) { echo "$line Listing Contents of $i";  Get-ChildItem -Path C:\"$i" -File -Recurse -ErrorAction SilentlyContinue; }

echo "$line Checking the Recycle Bin for deleted files (without Admin Privs, you can only see the current user's trash by default)"
Get-ChildItem -Path 'C:\$Recycle.Bin' -Force -EA SilentlyContinue -Recurse

echo "$line Current User's PS History"
Get-History

echo "$line Checking for PS Transcription File"
type (Get-PSReadlineOption).HistorySavePath

echo "$line Local Users. Check Account Descriptions"
Get-LocalUser | select *

echo "$line Local Groups. This won't unravel Nested Groups"
Get-LocalGroup

echo "$line Current User's files. Checking 3 subdirectories deep"
Get-ChildItem -Path ~\*,~\*\*,~\*\*\* -Force -File -ErrorAction SilentlyContinue

echo "$line Other Users with Readable files. Checking all User's home directories for common file types"
Get-ChildItem -Path C:\Users\ -Include *.txt,*.pdf,*.xml,*.xls,*.ps1,*.xlsx,*.doc,*.docx,*.ini,*.log,*.zip -File -Force -Recurse -ErrorAction SilentlyContinue

echo "$line Checking for Answer Files. These may contain credentials"
Get-ChildItem -Path C:\ -Include unattend.xml,sysprep.xml -File -Recurse -Force -ErrorAction SilentlyContinue

echo "$line Attempting to list Stored Credentials"
cmd /c "cmdkey /list"

echo "$line Checking for Password Manager Files. Hades currently only supports KeePass"
Get-ChildItem -Path C:\ -Include *.kdbx -File -Recurse -Force -ErrorAction SilentlyContinue

echo "$line Checking for Registry Hives"
Get-ChildItem -Path C:\ -Include SAM,SECURITY,SYSTEM,SAM.OLD,SECURITY.OLD,SYSTEM.OLD,SAM.BAK,SECURITY.BAK,SYSTEM.BAK  -File -Recurse -Force -ErrorAction SilentlyContinue

echo "$line Checking for Backup Files"
Get-ChildItem -Path C:\ -Include *.bak,*.old -File -Recurse -Force -ErrorAction SilentlyContinue

echo "$line Checking for Github Repos. If any are found, manually enumerate commits"
Get-ChildItem -Path C:\ -Include .git -Directory -Force -Recurse -ErrorAction SilentlyContinue

echo "$line Checking for SMB Shares & SMB Connections"
cmd /c "net use"
cmd /c "net share"

echo "$line Checking for Listening Ports"
netstat -ano

echo "$line Fingerprinting Host OS & listing installed Hotfixes"
systeminfo
cmd /c "wmic qfe list"

echo "$line Listing Environment Variables"
Get-ChildItem env:

echo "$line Listing Routing Information"
ipconfig /all
route print

echo "$line Taking Snapshot of Running Processes. Use Powershell-Watch Github Repo for a dynamic list of processes"
Get-Process

echo "$line Listing Scheduled Tasks"
$schtask = schtasks.exe /query /V /FO CSV | ConvertFrom-Csv | Where { $_.TaskName -ne "TaskName" }
$schtask | where {$_."Next Run Time" -notlike "N/A"}

echo "$line Query Registry for installed SW. Manually check each user's Downloads directory, & both Program Files directories in case this misses anything"
Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | select displayname
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | select displayname

echo "$line Enumerate Services. Default Services aren't typically vulnerable, so Hades doesn't check C:\Windows. Manually check it if you're desperate"
echo "[!] Tip: Check for Service Binary Hijacking, Unquoted Service Paths, & Service DLL Hijacking."
cmd /c 'wmic service get name,displayname,pathname,startmode | findstr /v /i "C:\Windows"'

echo "$line Drives used by Host. Manually Enumerate non-standard drives (other than C:)"
wmic logicaldisk get caption

#Nested Groups
#Can add check for text in files (e.g. user, NTLM, password, hash, etc). Case Sensitive? user will match username, right?
