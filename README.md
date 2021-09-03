# Build-Script

Windows

Run the following as admin with powershell.
### 1. Install Boxstarter
```
. { Invoke-WebRequest -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Force
```
Download the redwin_deploy.choco script using the boxstarter cmd prompt and run it as admin on the windows system using the prompted for credentials.
### 2. Install Boxstarter Package
```
$Cred = Get-Credential $env:USERNAME
Install-BoxstarterPackage -PackageName https://raw.githubusercontent.com/SamSepiolProxy/Build-Scripts/main/Windows/win_custom.choco -Credential $Cred 
```
