#
# Configures a newly installed Windows Server 2019 instance
#

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
New-Item -ItemType Directory -Force -Path "C:\image"
$Logfile = "C:\image\installation.txt"

Function Write-Log
{
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring
}

Write-Log "Setting up Windows Server 2019"

# Set up Vultr private networking
$Metadata = (Invoke-WebRequest -Uri "http://169.254.169.254/v1.json").Content | ConvertFrom-Json
$ip = $Metadata.interfaces[1].ipv4.address
$externalIP = $Metadata.interfaces[0].ipv4.address

if ([string]::IsNullOrEmpty($ip)) {
    Write-Log "Cannot find private ip address. Exiting"
    exit
}

Write-Log "Configuring private network for $ip"
netsh interface ip set address name="Ethernet 2" static $ip 255.255.0.0 0.0.0.0 1
Write-Log "Configured private network"

:DoLoop do {
    Start-Sleep -s 5

    try {
        $apikey = (Invoke-WebRequest -Uri "http://vault.in.okinta.ge:7020/api/kv/vultr_api_key").Content
    } catch {
        $apikey = ""
    }
}
until (![string]::IsNullOrEmpty($apikey))

# Set up Vultr-CLI so we can find the tag of this server
[Environment]::SetEnvironmentVariable("VULTR_API_KEY", $apikey, "User")
$env:VULTR_API_KEY = $apikey
Invoke-WebRequest -Uri "https://github.com/vultr/vultr-cli/releases/download/v0.3.0/vultr-cli_0.3.0_windows_64-bit.zip" -OutFile "C:\image\vultr-cli.zip"
Expand-Archive "C:\image\vultr-cli.zip" -DestinationPath "C:\image"
Remove-Item "C:\image\vultr-cli.zip" -Force
Write-Log "Installed vultr-cli"

# Find the tag of this server
$id = $Metadata.instanceid
$tag = C:\image\vultr-cli.exe server info $id | Select-String -Pattern "Tag" -SimpleMatch | Select-Object -First 1
$tag = ($tag.line -split '\s+')[1]
Write-Log "Got tag: $tag"

# Create a new password, store it in the Vault
$newPassword = -join ((33..126) | Get-Random -Count 32 | % {[char]$_})
Invoke-WebRequest -Uri "http://vault.in.okinta.ge:7020/api/kv/windows_password_$externalIP" -Method PUT -Body $newPassword
Get-LocalUser | Set-LocalUser -Password (ConvertTo-SecureString -AsPlainText $newPassword -Force)
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty $RegPath "DefaultPassword" -Value $newPassword -type String

# Install IQFeed if that's what the server is destined for
if ("iqfeed" -eq $tag) {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/okinta/vultr-scripts/master/iqfeed/setup-windows-iqfeed.ps1" -OutFile "C:\image\setup-windows-iqfeed.ps1"

    Write-Log "Installing IQFeed"
    Start-Process -Wait -FilePath "powershell" -ArgumentList "C:\image\setup-windows-iqfeed.ps1", $ip
}

Write-Log "Done"
