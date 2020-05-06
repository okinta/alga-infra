#
# Configures a newly installed Windows Server 2019 instance
#

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
New-Item -ItemType Directory -Force -Path "C:\image"
$Logfile = "C:\image\installation.txt"

function Write-Log
{
   param ([string] $logstring)
   Add-content $Logfile -value $logstring
}

Write-Log "Setting up Windows Server 2019"


function Update-DNS
{
    param(
        [string] $name,
        [string] $value
    )

    $cloudflareApiKey = (Invoke-WebRequest `
        -Uri "http://vault.in.okinta.ge:7020/api/kv/cloudflare_api_key").Content
    $cloudflareEmailAddress = (Invoke-WebRequest `
        -Uri "http://vault.in.okinta.ge:7020/api/kv/cloudflare_email").Content
    $domain = "okinta.ge"
    $name = "$name.$domain"

    Write-Log "Updating DNS, pointing $name to $value"

    Start-Process -Wait -FilePath powershell -ArgumentList `
        "Install-PackageProvider", "-Force", "Nuget"
    Start-Process -Wait -FilePath powershell -ArgumentList `
        "Install-Module" "-Force" "pscloudflare"
    Import-Module pscloudflare
    Write-Log "Installed pscloudflare"

    Connect-CFClientAPI -APIToken $cloudflareApiKey -EmailAddress $cloudflareEmailAddress
    Set-CFCurrentZone -Zone $domain
    $record = Get-CFDNSRecord -Name $name
    Set-CFDNSRecord `
        -ID $record.id `
        -RecordType $record.type `
        -Name $name `
        -Content $value `
        -TTL $record.ttl `
        -Proxied $record.proxied

    Write-Log "DNS updated"
}

# Set up Vultr private networking
$Metadata = (Invoke-WebRequest -Uri "http://169.254.169.254/v1.json").Content | ConvertFrom-Json
$ip = $Metadata.interfaces[1].ipv4.address
$externalIP = $Metadata.interfaces[0].ipv4.address

if ([string]::IsNullOrEmpty($ip)) {
    Write-Log "Cannot find private ip address. Exiting"
    exit
}

Write-Log "Configuring private network for $ip"

# There should be two adapters defined: Ethernet, and Ethernet 2
# We need to figure out which one is public and which is private, because they
# can differ between installations. Find the IP address for each. The private
# adapter should have a bogus IP, whereas the public adapter should be
# configured correctly via DHCP and have an IP equal to $externalIP.
$ethernet1 = (Get-NetAdapter -Name "Ethernet" | Get-NetIPAddress).IPv4Address
$ethernet2 = (Get-NetAdapter -Name "Ethernet 2" | Get-NetIPAddress).IPv4Address

$privateAdapter = ""
if ($ethernet1 -eq $externalIP) {
    $privateAdapter = "Ethernet 2"
} elseif ($ethernet2 -eq $externalIP) {
    $privateAdapter = "Ethernet"
} else {
    Write-Log "Cannot find public adapter. Exiting"
    exit
}

Write-Log "Found private adapter: $privateAdapter"

netsh interface ip set address name=$privateAdapter static $ip 255.255.0.0 0.0.0.0 1
Write-Log "Configured private network"

:DoLoop do {
    Start-Sleep -s 5

    try {
        $apikey = (Invoke-WebRequest -Uri "http://vault.in.okinta.ge:7020/api/kv/vultr_api_key").Content
        $ingestionKey = (Invoke-WebRequest -Uri "http://vault.in.okinta.ge:7020/api/kv/logdna_ingestion_key").Content
    } catch {
        $apikey = ""
        $ingestionKey = ""
    }
}
until (![string]::IsNullOrEmpty($apikey) -and ![string]::IsNullOrEmpty($ingestionKey))

# Set up Vultr-CLI so we can find the tag of this server
[Environment]::SetEnvironmentVariable("VULTR_API_KEY", $apikey, "User")
$env:VULTR_API_KEY = $apikey
Invoke-WebRequest -Uri "https://github.com/vultr/vultr-cli/releases/download/v0.3.0/vultr-cli_0.3.0_windows_64-bit.zip" -OutFile "C:\image\vultr-cli.zip"
Expand-Archive "C:\image\vultr-cli.zip" -DestinationPath "C:\image"
Remove-Item "C:\image\vultr-cli.zip" -Force
Write-Log "Installed vultr-cli"

# Find the tag of this server
$id = $Metadata.instanceid
$tag = C:\image\vultr-cli.exe server info $id | Select-String -Pattern "Tag" -SimpleMatch -CaseSensitive | Select-Object -Last 1
$tag = ($tag.line -split '\s+')[1]
Write-Log "Got tag: $tag"

# Create a new password, store it in the Vault
$newPassword = -join ((33..126) | Get-Random -Count 32 | % {[char]$_})
Invoke-WebRequest -Uri "http://vault.in.okinta.ge:7020/api/kv/windows_password_$externalIP" -Method PUT -Body $newPassword
Get-LocalUser | Set-LocalUser -Password (ConvertTo-SecureString -AsPlainText $newPassword -Force)
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty $RegPath "DefaultPassword" -Value $newPassword -type String

# Configure Remote Desktop
Install-WindowsFeature -Name RDS-RD-Server

# Configure logging
# https://github.com/chocolatey/choco/wiki/Installation#install-with-powershellexe
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = `
    [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
choco install logdna-agent -y
Invoke-WebRequest -Uri `
    "https://s3.okinta.ge/logdna-agent-99badad3ef0aa3565607f86cf216327f4dd52ee6.exe" `
    -OutFile "C:\ProgramData\chocolatey\bin\logdna-agent.exe"
logdna-agent -k $ingestionKey

# Install IQFeed if that's what the server is destined for
if ("iqfeed" -eq $tag) {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/okinta/vultr-scripts/master/iqfeed/setup-windows-iqfeed.ps1" -OutFile "C:\image\setup-windows-iqfeed.ps1"

    Write-Log "Installing IQFeed"
    Start-Process -Wait -FilePath "powershell" `
        -ArgumentList "C:\image\setup-windows-iqfeed.ps1", $ip

    Write-Log "IQFeed installation finished"
    Update-DNS "iqfeed.in" $ip
}

Write-Log "Done"
Restart-Computer -Force
