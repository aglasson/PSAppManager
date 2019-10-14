<#
.SYNOPSIS
    TODO:
.DESCRIPTION
    TODO:
.EXAMPLE
    TODO:
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    GitHub Source: https://github.com/aglasson/PSAppManager
    This script uses an Apache License 2.0 permitting commercial use, modification and distribution.
#>

#---- General Functions ----#
function Get-PSAppsEnv {
    [CmdletBinding()]
    param (
        # TODO: Parameter help description
        [Parameter()]
        [string]
        $Path = (Join-Path (Split-path (Get-Module -Name PSAppManager).Path) "LocalSettings.cfg")
    )
    
    try {
        $iniContent = Get-IniContent -FilePath $Path    
    }
    catch {
        Write-Error -Message "No config file at `'$Path`'" -ErrorAction Stop
    }

    if (!($iniContent)) {
        Write-Error -Message "No environment setting found in `'$Path`'"
    }
    else {
        try {
            $iniEnv = $iniContent["_"]["Environment"]
        }
        catch {
            $inicaught = $true
            Write-Error -Message "No environment setting found in `'$Path`'" -ErrorAction Stop
        }

        if (!($inicaught)) {
            Write-Verbose "Environment currently set to: $iniEnv"
            Return $iniEnv
        }
    }
}

function Set-PSAppsEnv {
    [CmdletBinding()]
    param (
        # TODO: Parameter help description
        [Parameter(Mandatory=$True)]
        [string]
        $Environment,
        # TODO: Parameter help description
        [Parameter()]
        [string]
        $Path = (Join-Path (Split-path (Get-Module -Name PSAppManager).Path) "LocalSettings.cfg")
    )
    
    if (!(Test-Path $Path)) {
        Write-Verbose "Cannot find an existing 'LocalSettings.cfg' config file, creating."
        $newFile = $True
        New-Item -Path $Path -ItemType File
    }

    $iniContentNew = @{"Environment"=$Environment}

    if ($newFile){
        Write-Verbose "New file so writing fresh ini content."
        $iniContentNew | Out-IniFile -FilePath $Path -Force
    }
    else {
        try {
            $iniContent = Get-IniContent -FilePath $Path
            $iniContent["_"]["Environment"] = $Environment
            $iniContent | Out-IniFile -FilePath $Path -Force
        }
        catch {
            Write-Warning "Cannot get environment config from exisitng config file. Overwriting existing file required."
            $promptResponse = Read-Host -Prompt "Continue?[y/n]"
            if ( $promptResponse -match "[yY]" ) {
                $iniContentNew | Out-IniFile -FilePath $Path -Force
            }
        }
    }
}

function Get-PSApps {
    [CmdletBinding()]
    param (
        # Path to config file containing relevant app details.
        # [Parameter(AttributeValues)]
        [string]
        $Path = '.\PSAppManager_Settings.csv',
        # Returns full list of apps in CSV including ones not matching device configured environment.
        # [Parameter(AttributeValues)]
        [switch]
        $AllEnvironment
    )

    if ($AllEnvironment) {
        Write-Verbose -Message "'`$AllEnvironment' specified so wildcarding to include returned items not matching device configured environment."
    }
    else {
        $AppEnv = Get-PSAppsEnv
    }

    Write-Verbose -Message "Attempting to get CSV file from 'Get-ConfigCsv' function."
    $appListConfig = Get-ConfigCsv -Path $Path
    Write-Verbose -Message "AppList: $($appListConfig | Out-String)"

    $packageList = @()
    foreach ($item in $appListConfig) {
        try {
            $installedPackage = Get-Package -ProviderName ChocolateyGet -Name $item.Name -ErrorAction Stop
            Write-Verbose -Message "Have installed package: $($item.Name)"

        }
        catch {
            Write-Verbose -Message "Have missing package: $($item.Name)"
    }
    
        try {
            $checkUpdatePackage = Find-Package -ProviderName ChocolateyGet -Name $item.Name -ErrorAction Stop
            if ($installedPackage.Version -lt $checkUpdatePackage.Version) {
                $updatedPackage = $checkUpdatePackage
                Write-Verbose -Message "Found update for package: $($item.Name)"
            }
        }
        catch {
            Write-Verbose -Message "Have package missing from provider: $($item.Name)"
        }
        
        $packageList += [pscustomobject]@{
            name                =   $item.Name
            requiredVersion     =   $item.Version
            installedVersion    =   
        if ($installedPackage) {
                    $installedPackage.Version
    }
    else {
                    "NotInstalled"
        }
            latestVersion       =
                if ($updatedPackage) {
                    $updatedPackage.Version
    }
                else {
                    "UpToDate"
                }
            expectedEnvironment =   $item.environment
            settingsPath        =   $item.SettingsPath
        }

        Clear-Variable -Name updatedPackage,checkUpdatePackage,installedPackage -ErrorAction Ignore
    }

    if ($AllEnvironment) {
        $PackageListFinal = $packageList
    }
    else {
        $PackageListFinal = $packageList | Where-Object {$_.expectedEnvironment -eq $AppEnv -or $_.expectedEnvironment -eq "All"}
    }
    $PackageListFinal
}
        Return $packageList
    }
    else {
        Return $packageList | Where-Object {$_.expectedEnvironment -eq $AppEnv -or $_.expectedEnvironment -eq "All"}
    }
}
    
function Get-ConfigCsv {
    [CmdletBinding()]
    param (
        # Parameter help description
        # [Parameter(AttributeValues)]
        [string]
        $Path = '.\PSAppManager_Settings.csv'
    )

    $AppCSV = Import-Csv -Path $Path

    if ($AppCSV) {
        Write-Log -LogMessage "CSV imported successfully"
    }
    else {
        Write-Log -LogMessage "ERROR: CSV did not seem to import correctly"
    }
    
    Return $AppCSV
}

#---- Deploy Functions ----#


#---- Logging/Output Functions ----#

Function Write-Log {
    Param (
        [Parameter(Mandatory = $True)]
        [string]$LogMessage,
        [switch]$NoVerbose
    )

    # Actual function to write append logfile entries
    # Files will be appended with date stamp - essentially rolling daily
    Function Write-LogEntry {
        Param (
            [string]$LogPath,
            [string]$LogFileBase,
            [string]$LogContent
        )

        # if either LogPath or LogFileBase come in empty determine values from current location and script name.
        if (!$LogPath) {
            # $LogPath = "$(Split-Path $PSCommandPath -Parent)\Logs\"
            $LogPath = "C:\Temp\PSAppManager_Logs\"
        }
        if (!$LogFileBase) {
            $LogFileBase = (Get-ChildItem $PSCommandPath).BaseName
        }

        $LogFilePath = (Join-Path -Path $LogPath -ChildPath ($LogFileBase + "_" + $(Get-Date -Format "yyyy-MM-dd") + ".log"))

        if (!$VerboseOnce) {
            $Global:VerboseOnce = $True
            Write-Verbose "LogPath determined as `'$LogPath`'"
            Write-Verbose "LogFileBase determined as `'$LogFileBase`'"
            Write-Verbose "LogFile determined as `'$LogFilePath`'"
        }

        # If required log path does not exist create it
        if (!(Test-Path $LogPath)) {
            Write-Verbose "Logging directory/s do no exists, creating path: '$LogPath'"
            New-Item $LogPath -ItemType Directory -Force | Out-Null
        }

        # Write line to logfile prepending the line with date and time
        Add-Content -Path $LogFilePath -Value "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.ms"): $LogContent"
    }
    Write-LogEntry -LogPath $logPath -LogFileBase $logFileBase -LogContent $LogMessage
    if (!$NoVerbose) {
        Write-Verbose -Message $LogMessage   
    }
}