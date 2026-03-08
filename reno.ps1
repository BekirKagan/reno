#Requires -Module BurntToast

$protocolName = 'reno'
$regBase = "HKCU:\Software\Classes\$protocolName"

$renoPath = Join-Path $PSScriptRoot 'reno-update.ps1'
if (-not (Test-Path $renoPath)) {
    Write-Error "reno-update.ps1 not found at '$renoUpdatePath'. Make sure all scripts are in the same folder."
    exit 1
}

$pwshPath = (Get-Command pwsh -ErrorAction SilentlyContinue)?.Source
if (-not $pwshPath) {
    Write-Error 'pwsh (PowerShell 7+) was not found on PATH. Please install it from https://aka.ms/powershell'
    exit 1
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error 'winget was not found. Please install App Installer from the Microsoft Store.'
    exit 1
}

$command = "`"$pwshPath`" -WindowStyle Hidden -File `"$renoPath`""
$commandPath = "$regBase\shell\open\command" 

$currentCommand = if (Test-Path $commandPath) {
    (Get-ItemProperty -Path $commandPath -Name '(Default)' -ErrorAction SilentlyContinue).'(Default)'
}
else { $null }

if ($currentCommand -ne $command) {
    try {
        New-Item -Path $regBase -Force | Out-Null
        Set-ItemProperty -Path $regBase -Name '(Default)'    -Value "URL:$protocolName Protocol"
        Set-ItemProperty -Path $regBase -Name 'URL Protocol' -Value ""
        New-Item -Path $commandPath -Force | Out-Null
        Set-ItemProperty -Path $commandPath -Name '(Default)' -Value $command
        Write-Host "Protocol handler registered/updated for '${protocolName}://'."
    }
    catch {
        Write-Error "Failed to register protocol handler: $_"
        exit 1
    }
}

try {
    $wingetOutput = winget upgrade --include-unknown
}
catch {
    Write-Error "Failed to run winget: $_"
    exit 1
}

$columnsLine = $wingetOutput | Select-String -Pattern '^Name\s+Id\s+Version'
if (-not $columnsLine) {
    Write-Host 'All packages are up to date.'
    exit 0
}

$updatesLine = $wingetOutput[$columnsLine.LineNumber + 1]

$nameColumnStartIndex = 0
$nameColumnEndIndex = $columnsLine.ToString().IndexOf('Id')

$updates = foreach ($line in $updatesLine) {
    if ($line -match '^\s*$' -or $line -match '^\d+ upgrade') { break }
    $update = $line.Substring($nameColumnStartIndex, $nameColumnEndIndex).Trim()
    if ($update) { $update }
}

if (-not $updates -or $updates.Count -eq 0) {
    Write-Host 'All packages are up to date.'
    exit 0
}

$notificationTitle = "$($updates.Count) update(s) available."
$notificationText = if ($updates.Count -ge 3) { ($updates[0..2] + "and others") -join "`n" } else { $updates -join "`n" }
$notificationButton = New-BTButton -Content 'Update' -Arguments "${protocolName}://" -ActivationType Protocol

New-BurntToastNotification `
    -Text $notificationTitle, $notificationText `
    -Button $notificationButton
