if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process pwsh -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$protocolName = 'reno'
$regBase = "HKCU:\Software\Classes\$protocolName"
$taskName = "Reno"

if (Test-Path $regBase) {
    try {
        Remove-Item -Path $regBase -Recurse -Force
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

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    try {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Scheduled task '$taskName' removed."
    }
    catch {
        Write-Error "Failed to remove scheduled task: $_"
        exit 1
    }
}
else {
    Write-Host "No scheduled task named '$taskName' was found. Nothing to remove."
}
