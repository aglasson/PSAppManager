# PSAppManager 
https://github.com/aglasson/PSAppManager

PowerShell Module to automate personal application and settings synchronisation between Windows devices.  
The intention of this module is to reduce effort involved in configuring, maintaining and migrating applications and application configurations between multiple Windows devices. For example users with complex computing requirements (IT admins, Software developers) that have a work computer, home computer etc. and want to maintain their application versions and configuration across these environments.  
Applications install and version management will take place with a package manager like Chocolatey.  
Application config synchronisation will take place with the likes of GitHub Gist's, Google Drive, OneDrive etc. Ideally detecting the latest configuration file in the default application config directory and copying it to the synchronisation location and vice versa.

## Features
* 

## Installation
#### Manual Import Method
* Copy contents of Master Branch to your PowerShell Module Path directory (suggested: `C:\Program Files\WindowsPowerShell\Modules`)
* Import the module:
  ```powershell
  PS> Import-Module -Name PSAppManager # If in PSModulePath. New Powershell session after copy.
  ```

## Example Usage
TODO: Currently a Placeholder
#### Install expected apps
```powershell
PS> Install-PSApps # This will install stuff
```
#### Running the synchronisation
```
PS> Do-Stuff -Command
```
##### Arguments
`-Arg` This does x

## Logic
TODO: Currently a Placeholder

## Intended Features
#### Major Features
* Refers to a config file that specifies the applications, which system 'environment' they should exist in, their expected versions, config paths for each app.
* Installation of a package manager, installation of desired apps at a desired version.
* Settings synchronisation to and from a location accessible at all intended 'environments'.

#### Minor Features
* 