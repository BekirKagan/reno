#Requires -Module BurntToast

$projectName = 'Reno'

try {
    $result = winget upgrade --all --include-unknown
    $failed = $result | Select-String -Pattern 'failed' -Quiet
    if ($failed) {
        New-BurntToastNotification -Text $projectName, 'Some updates failed. Check the winget logs for details.'
    }
    else {
        New-BurntToastNotification -Text $projectName, 'All updates completed successfully.'
    }
}
catch {
    New-BurntToastNotification -Text $projectName, "Update failed to run: $_"
}
