# hades-PrivEsc
Automated Post Exploitation recon tools for Standalone Windows machines &amp; AD environments.

Hades & Charon are in the early stages of development. I'm still testing & refining these scripts, so expect major updates in the future.

## Table of Contents
- [Setup](#setup)
- [Functionality](#functionality)
- [Hades](#hades)
- [Charon](#charon)
- [Related Projects](#related-projects)

## Setup
Allow PS script execution, import the desired script, &amp; run with `-h` for the Help Menu.

```
Set-ExecutionPolicy -ExecutionPolicy Unrestricted; Get-ExecutionPolicy

Import-Module .\hades.ps1

powershell -File .\hades.ps1 -h
```

## Functionality
Hades: Enumerates the Standalone Windows machine.

Charon: Enumerates the Active Directory Domain

### Hades
```
[Options]
	-h: Show this help menu
	-filePaths <Path1, Path2, etc>: Specify 1+ file path(s) for non-standard directories you want to enumerate
	-a: Aggressive enumeration. Used with -filePaths to check for ALL files in the directory, instead of just checking for interesting types of files

[Usage]
	powershell -File C:\path\to\hades.ps1 -filePaths "C:\path\to\dir1", "C:\path\to\dir2", "C:\path\to\dir3" -a
```

### Charon
```
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
```

## Related Projects
Check out the rest of the Pentesting Pantheon:

Perform recon to see everything your target is hiding with Argus (https://github.com/Komodo-pty/argus-recon/)

Prepare your next attack with Ares (https://github.com/Komodo-pty/ares-attack)

Hunt for shells with Artemis (https://github.com/Komodo-pty/artemis-hunter)
