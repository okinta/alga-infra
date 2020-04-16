#
# Installs and configures IQFeed client to run and be accessible within the Vultr private network
#

param (
    [Parameter(Mandatory=$true)][string]$ip,
    [Parameter(Mandatory=$true)][string]$product,
    [Parameter(Mandatory=$true)][string]$version,
    [Parameter(Mandatory=$true)][string]$login,
    [Parameter(Mandatory=$true)][string]$password
)

$ErrorActionPreference = "Stop"

$IQFeedVersion = "6_1_0_20"

# Configure Vultr private networking
netsh interface ip set address name="Ethernet 2" static $ip 255.255.0.0 0.0.0.0 1

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
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/okinta/vultr-scripts/master/run-iqfeed.ps1" -OutFile "C:\Program Files (x86)\DTN\IQFeed\run-iqfeed.ps1"
$params = @{
  Name = "IQFeed"
  BinaryPathName = "powershell C:\Program Files (x86)\DTN\IQFeed\run-iqfeed.ps1 --product $product --version $version --login $login --password $password"
  DependsOn = "NetLogon"
  DisplayName = "IQFeed"
  StartupType = "Automatic"
  Description = "Runs IQFeed client continuously."
}
New-Service @params
