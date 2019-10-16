# PSAppManager 
https://github.com/aglasson/PSAppManager

PowerShell Module to automate personal application and settings synchronisation between Windows devices.  
The intention of this module is to reduce effort involved in configuring, maintaining and migrating applications and application configurations between multiple Windows devices. For example users with complex computing requirements (IT admins, Software developers) that have a work computer, home computer etc. and want to maintain their application versions and configuration across these environments.  
Applications install and version management will take place with a package manager like Chocolatey.  
Application config synchronisation will take place with the likes of GitHub Gist's, Google Drive, OneDrive etc. Ideally detecting the latest configuration file in the default application config directory and copying it to the synchronisation location and vice versa.

## Features
* Refers to a CSV for listing expected apps and their versions that can then be installed or updated via Chocolatey 

## Known Issues
* Poor performance of 'Get-PSApps".
* Adhering to 'expectedEnvironment' not implemented properly yet.
* Lack of module, function and parameter PowerShell help inclusion.

## Installation
#### Manual Import Method
* Copy contents of Master Branch to your PowerShell Module Path directory (suggested: `C:\Program Files\WindowsPowerShell\Modules`)
* Import the module:
  ```powershell
  PS> Import-Module -Name PSAppManager # If in PSModulePath. New PowerShell session after copy.
  ```

## Example Usage
#### Install expected apps
```powershell
PS> Get-PSApps # This returns an array of apps from the expected CSV lists versions (installed, latest available), if installed and if update available.
```
#### Install expected apps
```powershell
PS> Install-PSApps [-InstallOnly/UpdateOnly] # This will install and/or update apps listed in CSV. Expects the Get-PSApps object piped into it. 
```
##### Arguments
TODO:  
`-Arg` This does x

## Intended Features
#### Major Features
* Installation/setup and configuration of a package manager (currently just Chocolatey).
* Settings synchronisation to and from a location accessible at all intended 'environments'.

#### Minor Features
* 