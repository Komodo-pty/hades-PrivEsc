# hades-PrivEsc
Automated Post Exploitation recon tools for Local Windows machines &amp; AD environments.

Hades: Enumerates the Local Windows machine.

Charon: Enumerates the Active Directory Domain

# Usage
Allow PS script execution before using either script, import the desired script, & run with -h for the Help Menu.

Set-ExecutionPolicy -ExecutionPolicy Unrestricted; Get-ExecutionPolicy

Import-Module .\hades.ps1

powershell -File .\hades.ps1 -h

# Work in progress
Hades & Charon are in the early stages of development. I'm still testing & refining these scripts, so expect major updates in the future.
