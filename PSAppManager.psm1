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
function Get-PSApps {
    [CmdletBinding()]
    param (
        # Parameter help description
        # [Parameter(AttributeValues)]
        [switch]
        $Update,
        # Path to config file containing relevant app details.
        # [Parameter(AttributeValues)]
        [string]
        $Path = '.\PSAppManager_Settings.csv',
        # Path to config file containing relevant app details.
        # [Parameter(AttributeValues)]
        [switch]
        $Missing
    )

    Write-Verbose -Message "Attempting to get CSV file from 'Get-ConfigCsv' function."
    $appListConfig = Get-ConfigCsv -Path $Path
    Write-Verbose -Message "AppList: $($appListConfig | Out-String)"

    $missingPackage = @()
    $installedPackage = @()
    foreach ($item in $appListConfig) {
        try {
            $installedPackage += Get-Package -ProviderName ChocolateyGet -Name $item.Application -ErrorAction Stop
        }
        catch {
            $missingPackage += $item
        }
    }
    
    Write-Verbose "The packages listed but not identified with 'Get-Package': $($missingPackage | Out-String)"

    if ($Missing) {
        Write-Verbose "'Get-PSApps' switch '-Missing' used so returning only missing packages."
        Return $missingPackage
    }
    else {
        Write-Verbose "'Get-PSApps' not using '-Missing' switch so returning only installed packages."
        Return $installedPackage
    }
    
    Write-Verbose "The packages listed but not identified with 'Get-Package': $($missingPackage | Out-String)"
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