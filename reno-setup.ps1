if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process pwsh -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$projectName = 'Reno'
$protocolName = $projectName.ToLower()
$registryPath = "HKCU:\Software\Classes\$protocolName"
$pwshPath = (Get-Command pwsh -ErrorAction SilentlyContinue)?.Source

$renoPath = Join-Path $PSScriptRoot "$($projectName.ToLower()).ps1"
$renoUpdatePath = Join-Path $PSScriptRoot "$($projectName.ToLower())-update.ps1"

if (-not $pwshPath) {
    Write-Error 'pwsh (PowerShell 7+) was not found on PATH. Please install it from https://aka.ms/powershell'
    exit 1
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error 'winget was not found. Please install App Installer from the Microsoft Store.'
    exit 1
}

if (-not (Test-Path $renoPath)) {
    Write-Error "$($projectName.ToLower()).ps1 not found at '$renoPath'. Make sure all scripts are in the same folder."
    exit 1
}
    
if (-not (Test-Path $renoUpdatePath)) {
    Write-Error "$($projectName.ToLower())-update.ps1 not found at '$renoUpdatePath'. Make sure all scripts are in the same folder."
    exit 1
}

# Registry
$command = "`"$pwshPath`" -WindowStyle Hidden -File `"$renoUpdatePath`""
$commandPath = "$registryPath\shell\open\command" 

$existingCommand = if (Test-Path $commandPath) {
    (Get-ItemProperty -Path $commandPath -Name '(Default)' -ErrorAction SilentlyContinue).'(Default)'
}
else { $null }

if ($existingCommand -ne $command) {
    try {
        New-Item -Path $registryPath -Force | Out-Null
        Set-ItemProperty -Path $registryPath -Name '(Default)'    -Value "URL:$protocolName Protocol"
        Set-ItemProperty -Path $registryPath -Name 'URL Protocol' -Value ""
        New-Item -Path $commandPath -Force | Out-Null
        Set-ItemProperty -Path $commandPath -Name '(Default)' -Value $command
        Write-Host "Protocol handler registered/updated for '${protocolName}://'."
    }
    catch {
        Write-Error "Failed to register protocol handler: $_"
        exit 1
    }
}

# Task Scheduler
$existingTask = Get-ScheduledTask -TaskName $projectName -ErrorAction SilentlyContinue
if ($existingTask) {
    $registered = ($existingTask.Actions[0].Arguments | Select-String -Pattern [regex]::Escape($renoPath) -Quiet)
    if (-not $registered) {
        Write-Warning "A task named '$projectName' already exists but points to a different script. Updating it."
    }
}

$action = New-ScheduledTaskAction -Execute $pwshPath -Argument "-WindowStyle Hidden -File `"$renoPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 5) -StartWhenAvailable

Register-ScheduledTask `
    -TaskName $projectName `
    -Action   $action `
    -Trigger  $trigger `
    -Settings $settings `
    -RunLevel Limited `
    -Force | Out-Null

Write-Host "Task '$projectName' registered. reno.ps1 will run at every login."
