#
# Installs and configures IQFeed client to run and be accessible within the Vultr private network
#

param (
    [Parameter(Mandatory=$true)][string]$apikey,
    [Parameter(Mandatory=$true)][string]$product,
    [Parameter(Mandatory=$true)][string]$version,
    [Parameter(Mandatory=$true)][string]$login,
    [Parameter(Mandatory=$true)][string]$password
)

$ErrorActionPreference = "Stop"

$IQFeedVersion = "6_1_0_20"

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

# Set up Vultr-CLI
[Environment]::SetEnvironmentVariable("VULTR_API_KEY", $apikey, "User")
$env:VULTR_API_KEY = $apikey
Invoke-WebRequest -Uri "https://github.com/vultr/vultr-cli/releases/download/v0.3.0/vultr-cli_0.3.0_windows_64-bit.zip" -OutFile "C:\image\vultr-cli.zip"
Expand-Archive "C:\image\vultr-cli.zip" -DestinationPath "C:\image"
Remove-Item "C:\image\vultr-cli.zip" -Force

# Find out what the private IP is for this machine
$ExternalIP = Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4
$Match = C:\image\vultr-cli.exe server list | Select-String -Pattern $ExternalIP.IPAddress -SimpleMatch | Select-Object -First 1
$PrivateIP = ($Match.line -split '\s+')[0]

# Configure Vultr private networking
netsh interface ip set address name="Ethernet 2" static $PrivateIP 255.255.0.0 0.0.0.0 1

# Install IQFeed
Invoke-WebRequest -Uri "http://www.iqfeed.net/iqfeed_client_$IQFeedVersion.exe" -OutFile "C:\image\iqfeed.exe"
Start-Process -Wait -FilePath "C:\image\iqfeed.exe" -ArgumentList "/S" -PassThru
Remove-Item "C:\image\iqfeed.exe" -Force

# Forward ports so they ca be accessed from the outside
netsh interface portproxy add v4tov4 listenport=5009 listenaddress=$ip connectaddress=127.0.0.1
netsh interface portproxy add v4tov4 listenport=9100 listenaddress=$ip connectaddress=127.0.0.1
netsh interface portproxy add v4tov4 listenport=9200 listenaddress=$ip connectaddress=127.0.0.1
netsh interface portproxy add v4tov4 listenport=9300 listenaddress=$ip connectaddress=127.0.0.1
netsh interface portproxy add v4tov4 listenport=9400 listenaddress=$ip connectaddress=127.0.0.1

# Allow IQFeed client access through firewall
New-NetFirewallRule -Name iqfeed -DisplayName "IQFeed Port Forwarding" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalAddress "$ip" -LocalPort 5009,9100,9200,9300,9400

# Create the IQFeed service so it runs continuously
Invoke-WebRequest -Uri "https://github.com/winsw/winsw/releases/download/v2.7.0/WinSW.NET461.exe" -OutFile "C:\Program Files (x86)\DTN\IQFeed\iqfeed-service.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/okinta/vultr-scripts/master/iqfeed/iqfeed-service.xml" -OutFile "C:\Program Files (x86)\DTN\IQFeed\iqfeed-service.xml"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/okinta/vultr-scripts/master/iqfeed/run-iqfeed.ps1" -OutFile "C:\Program Files (x86)\DTN\IQFeed\run-iqfeed.ps1"

# Inject the IQFeed variables into the config
(Get-Content "C:\Program Files (x86)\DTN\IQFeed\iqfeed-service.xml").replace("%IQFeedProduct%", $product) | Set-Content "C:\Program Files (x86)\DTN\IQFeed\iqfeed-service.xml"
(Get-Content "C:\Program Files (x86)\DTN\IQFeed\iqfeed-service.xml").replace("%IQFeedProductVersion%", $version) | Set-Content "C:\Program Files (x86)\DTN\IQFeed\iqfeed-service.xml"
(Get-Content "C:\Program Files (x86)\DTN\IQFeed\iqfeed-service.xml").replace("%IQFeedLogin%", $login) | Set-Content "C:\Program Files (x86)\DTN\IQFeed\iqfeed-service.xml"
(Get-Content "C:\Program Files (x86)\DTN\IQFeed\iqfeed-service.xml").replace("%IQFeedPassword%", $password) | Set-Content "C:\Program Files (x86)\DTN\IQFeed\iqfeed-service.xml"

# Install the IQFeed service. It should start automatically after reboot
Start-Process -Wait -FilePath "C:\Program Files (x86)\DTN\IQFeed\iqfeed-service.exe" -ArgumentList "install"
