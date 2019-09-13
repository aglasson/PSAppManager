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