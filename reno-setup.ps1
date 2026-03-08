
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process pwsh -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$taskName = "Reno"
$renoPath = Join-Path $PSScriptRoot "reno.ps1"
$pwshPath = (Get-Command pwsh -ErrorAction SilentlyContinue)?.Source

if (-not $pwshPath) {
    Write-Error "pwsh not found on PATH. Please install it from https://aka.ms/powershell"
    exit 1
}

if (-not (Test-Path $renoPath)) {
    Write-Error "reno.ps1 not found at '$renoPath'. Make sure all scripts are in the same folder."
    exit 1
}

$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existingTask) {
    $registered = ($existingTask.Actions[0].Arguments | Select-String -Pattern [regex]::Escape($renoPath) -Quiet)
    if (-not $registered) {
        Write-Warning "A task named '$taskName' already exists but points to a different script. Updating it."
    }
}

$action = New-ScheduledTaskAction -Execute $pwshPath -Argument "-WindowStyle Hidden -File `"$renoPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 5) -StartWhenAvailable

Register-ScheduledTask `
    -TaskName $taskName `
    -Action   $action `
    -Trigger  $trigger `
    -Settings $settings `
    -RunLevel Limited `
    -Force | Out-Null

Write-Host "Task '$taskName' registered. reno.ps1 will run at every login."
