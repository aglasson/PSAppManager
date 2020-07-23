try {
    Clear-Host
    Import-Module .\PSAppManager\PSAppManager.psd1 -Force -ErrorAction Stop
    Write-Host "PSAppsManager Powershell module re-imported in session for debugging - Available Commands: $((Get-Module PSAppManager).ExportedCommands.Keys)"
}
catch {
    Write-Error -Message "Unable to import module with VSCode launch script: $($_.Exception)"
}