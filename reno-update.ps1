#Requires -Module BurntToast

try {
    $result = winget upgrade --all --include-unknown
    $failed = $result | Select-String -Pattern 'failed' -Quiet
    if ($failed) {
        New-BurntToastNotification -Text 'Reno', 'Some updates failed. Check the winget logs for details.'
    }
    else {
        New-BurntToastNotification -Text 'Reno', 'All updates completed successfully.'
    }
}
catch {
    New-BurntToastNotification -Text 'Reno', "Update failed to run: $_"
}
