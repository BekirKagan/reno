#Requires -Module BurntToast

$projectName = 'Reno'
$logoPath = Join-Path $PSScriptRoot "$($projectName.ToLower())-logo.png"

try {
    winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements --authentication-mode silent
    $failed = $LASTEXITCODE -ne 0
    if ($failed) {
        New-BurntToastNotification `
            -Text $projectName, 'Some updates failed. Check the winget logs for details.' `
            -AppLogo $logoPath
    }
    else {
        New-BurntToastNotification `
            -Text $projectName, 'All updates completed successfully.' `
            -AppLogo $logoPath
    }
}
catch {
    New-BurntToastNotification `
        -Text $projectName, "Update failed to run: $_" `
        -AppLogo $logoPath
}
