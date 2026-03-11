#Requires -Module BurntToast

$projectName = 'Reno'
$logoPath = Join-Path $PSScriptRoot "$($projectName.ToLower())-logo.png"

try {
    $result = winget upgrade --all --include-unknown | Tee-Object -Variable output
    $failed = $result | Select-String -Pattern 'failed' -Quiet
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
