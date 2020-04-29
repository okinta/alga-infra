#
# Runs IQFeed client continuously
#

param (
    [Parameter(Mandatory=$true)][string]$product,
    [Parameter(Mandatory=$true)][string]$version,
    [Parameter(Mandatory=$true)][string]$login,
    [Parameter(Mandatory=$true)][string]$password
)

While ($true) {
    Start-Process -Wait -FilePath 'C:\Program Files (x86)\DTN\IQFeed\iqconnect.exe' -ArgumentList "-product $product -version $version -login $login -password $password -autoconnect -savelogininfo"

    # Archive the old log
    $log = "C:\DTN\IQConnectLog.txt"
    if (Test-Path $log -PathType leaf) {
        $time = "{0:MMddyyyy-HHmmss}" -f (Get-Date)
        $rename = "C:\DTN\IQConnectLog.$time.log"
        Move-Item -Path $log -Destination $rename
    }

    Start-Sleep -Seconds 1
}
