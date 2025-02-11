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

# Related Projects
Check out the rest of the Pentesting Pantheon:

Perform recon to see everything your target is hiding with Argus (https://github.com/Komodo-pty/argus-recon/)

Prepare your next attack with Ares (https://github.com/Komodo-pty/ares-attack)

Hunt for shells with Artemis (https://github.com/Komodo-pty/artemis-hunter)
