#Requires -Module BurntToast

$projectName = 'Reno'
$protocolName = $projectName.ToLower()
$logoPath = Join-Path $PSScriptRoot "$($projectName.ToLower())-logo.png"

try {
    $wingetOutput = winget upgrade --include-unknown
}
catch {
    Write-Error "Failed to run winget: $_"
    exit 1
}

$columnsLine = $wingetOutput | Select-String -Pattern '^Name\s+Id\s+Version'
if (-not $columnsLine) {
    New-BurntToastNotification -Text 'All packages are up to date.' -AppLogo $logoPath
    exit 0
}

$updatesLine = $wingetOutput[($columnsLine.LineNumber + 1)..($wingetOutput.Count - 1)]

$nameColumnStartIndex = 0
$nameColumnEndIndex = $columnsLine.Line.IndexOf('Id')

$updates = foreach ($line in $updatesLine) {
    if ($line -match '^\s*$' -or $line -match '^\d+ upgrade') { break }
    if ($nameColumnEndIndex -gt 0 -and $line.Length -ge $nameColumnEndIndex) {
        $update = $line.Substring($nameColumnStartIndex, $nameColumnEndIndex).Trim()
        if ($update) { $update }
    }
}

if (-not $updates -or $updates.Count -eq 0) {
    New-BurntToastNotification -Text 'All packages are up to date.' -AppLogo $logoPath
    exit 0
}

$notificationTitle = "$($updates.Count) update(s) available."
$notificationText = if ($updates.Count -ge 3) { ($updates[0..2] + "and others") -join "`n" } else { $updates -join "`n" }
$notificationButton = New-BTButton -Content 'Update' -Arguments "${protocolName}://" -ActivationType Protocol

New-BurntToastNotification `
    -Text $notificationTitle, $notificationText `
    -Button $notificationButton `
    -AppLogo $logoPath
