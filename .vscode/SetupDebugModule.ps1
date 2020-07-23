try {
    Clear-Host
    Import-Module .\PSAppManager\PSAppManager.psd1 -Force -ErrorAction Stop
    Write-Host "PSAppsManager Powershell module re-imported in session for debugging"
}
catch {
    Write-Error "Unable to import module with VSCode launch script"
}