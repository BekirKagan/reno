if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process pwsh -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$projectName = 'Reno'
$protocolName = $projectName.ToLower()
$registryPath = "HKCU:\Software\Classes\$protocolName"

if (Test-Path $registryPath) {
    try {
        Remove-Item -Path $registryPath -Recurse -Force
        Write-Host "Protocol handler '${protocolName}://' has been removed successfully."
    }
    catch {
        Write-Error "Failed to remove protocol handler: $_"
        exit 1
    }
}
else {
    Write-Host "No protocol handler for '${protocolName}://' was found. Nothing to remove."
}

if (Get-ScheduledTask -TaskName $projectName -ErrorAction SilentlyContinue) {
    try {
        Unregister-ScheduledTask -TaskName $projectName -Confirm:$false
        Write-Host "Scheduled task '$projectName' removed."
    }
    catch {
        Write-Error "Failed to remove scheduled task: $_"
        exit 1
    }
}
else {
    Write-Host "No scheduled task named '$projectName' was found. Nothing to remove."
}
