param (
    [string[]]$filePaths,
    [switch]$h,
    [switch]$a
)

if ($h) {
	Write-Host "`nHades supports the following arguments:`n"
	Write-Host "-h: Help Menu. Displays this message`n"
	Write-Host "-filePaths <Path1, Path2, etc>: Specify 1+ file path(s) for non-standard directories you want to enumerate`n"
	Write-Host "-a: Aggressive enumeration. This is used with -filePaths to check for ALL files in the directory, instead of just checking for interesting types of files`n"
	Write-Host "`n{Example Usage}`n"
	Write-Host 'powershell -File C:\path\to\hades.ps1 -filePaths "C:\path\to\dir1", "C:\path\to\dir2", "C:\path\to\dir3" -a'
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

Write-Host "$line [!] Tip: Only Enumerating Local Machine (users, groups, etc) & not querying Domain information $line"

whoami /all

Write-Host "$line Listing Root Directory"
Get-ChildItem -Path C:\ -Force -EA SilentlyContinue

if ($filePaths) {
	foreach ($filePath in $filePaths) {
		Write-Host "$line Enumerating $filePath"

		if ($a) {
			Write-Host "[+] Aggressively listing all files"
			Get-ChildItem -Path "$filePath" -File -Force -Recurse -ErrorAction SilentlyContinue
		} else {
			Write-Host "[+] Only listing interesting types of files"
			Get-ChildItem -Path "$filePath" -Include *.txt,*.ini,*.pdf,*config*,*htdocs,*htpasswd,*htaccess,*.sql*,*.db,*.php,*.git,*.ps1 -File -Recurse -EA SilentlyContinue
		}

	}
} else {
	Write-Host "No additional directories were specified with -filePaths argument"
}

Write-Host "$line Checking the Recycle Bin for deleted files (without Admin Privs, you can only see the current user's trash by default)"
Get-ChildItem -Path 'C:\$Recycle.Bin' -Force -EA SilentlyContinue -Recurse

Write-Host "$line Current User's PS History"
Get-History

Write-Host "$line Attempting to output every user's PS History"
Get-ChildItem -Path 'C:\Users\*\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\' -Filter 'ConsoleHost_history.txt' -Recurse |
    ForEach-Object {
        Write-Host "`n--- $($_.FullName) ---`n"
        Get-Content $_.FullName
    }

Write-Host "$line Checking for PS Transcription File"
type (Get-PSReadlineOption).HistorySavePath

Write-Host "$line Local Users. Check Account Descriptions"
Get-LocalUser | select *

Write-Host "$line Local Groups. This won't unravel Nested Groups"
Get-LocalGroup

Write-Host "$line Current User's files. Checking 3 subdirectories deep"
Get-ChildItem -Path ~\*,~\*\*,~\*\*\* -Force -File -ErrorAction SilentlyContinue

Write-Host "$line Other Users with Readable files. Checking all User's home directories for common file types"
Get-ChildItem -Path C:\Users\ -Include *.txt,*.pdf,*.xml,*.xls,*.ps1,*.xlsx,*.doc,*.docx,*.ini,*.log,*.zip -File -Force -Recurse -ErrorAction SilentlyContinue

Write-Host "$line Attempting to list Stored Credentials"
cmd /c "cmdkey /list"

Write-Host "$line Checking for Answer Files. These may contain credentials"
Get-ChildItem -Path C:\ -Include unattend.xml,sysprep.xml -File -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "$line Checking for Password Manager Files. Hades currently only supports KeePass"
Get-ChildItem -Path C:\ -Include *.kdbx -File -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "$line Checking for Registry Hives"
Get-ChildItem -Path C:\ -Include SAM,SECURITY,SYSTEM,SAM.OLD,SECURITY.OLD,SYSTEM.OLD,SAM.BAK,SECURITY.BAK,SYSTEM.BAK  -File -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "$line Checking for Backup Files"
Get-ChildItem -Path C:\ -Include *.bak,*.old -File -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "$line Checking for Github Repos. If any are found, manually enumerate commits"
Get-ChildItem -Path C:\ -Include .git -Directory -Force -Recurse -ErrorAction SilentlyContinue

Write-Host "$line Checking for SMB Shares & SMB Connections"
cmd /c "net use"
cmd /c "net share"

Write-Host "$line Checking for Listening Ports"
netstat -ano

Write-Host "$line Fingerprinting Host OS & listing installed Hotfixes"
systeminfo
cmd /c "wmic qfe list"

Write-Host "$line Listing Environment Variables"
Get-ChildItem env:

Write-Host "$line Listing Routing Information"
ipconfig /all
route print

Write-Host "$line Taking Snapshot of Running Processes. Use Powershell-Watch Github Repo for a dynamic list of processes"
Get-Process

Write-Host "$line Listing Scheduled Tasks"
$schtask = schtasks.exe /query /V /FO CSV | ConvertFrom-Csv | Where { $_.TaskName -ne "TaskName" }
$schtask | where {$_."Next Run Time" -notlike "N/A"}

Write-Host "$line Query Registry for installed SW. Manually check each user's Downloads directory, & both Program Files directories in case this misses anything"
Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | select displayname
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | select displayname

Write-Host "$line Enumerate Services. Default Services aren't typically vulnerable, so Hades doesn't check C:\Windows. Manually check it if you're desperate"
Write-Host "[!] Tip: Check for Service Binary Hijacking, Unquoted Service Paths, & Service DLL Hijacking."
cmd /c 'wmic service get name,displayname,pathname,startmode | findstr /v /i "C:\Windows"'

Write-Host "$line Drives used by Host. Manually Enumerate non-standard drives (other than C:)"
wmic logicaldisk get caption


#Nested Groups
#Can add check for text in files (e.g. user, NTLM, password, hash, etc). Case Sensitive? user will match username, right?
