#
# Installs and configures IQFeed client to run and be accessible within the
# Vultr private network
#

param (
    [Parameter(Mandatory=$true)][string]$ip
)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

$product = (Invoke-WebRequest -Uri "http://10.2.96.3:7020/api/kv/iqfeed_product").Content
$version = (Invoke-WebRequest -Uri "http://10.2.96.3:7020/api/kv/iqfeed_product_version").Content
$login = (Invoke-WebRequest -Uri "http://10.2.96.3:7020/api/kv/iqfeed_login").Content
$password = (Invoke-WebRequest -Uri "http://10.2.96.3:7020/api/kv/iqfeed_password").Content

# Install IQFeed
$IQFeedVersion = "6_1_0_20"
Invoke-WebRequest -Uri "http://www.iqfeed.net/iqfeed_client_$IQFeedVersion.exe" -OutFile "C:\image\iqfeed.exe"
Start-Process -Wait -FilePath "C:\image\iqfeed.exe" -ArgumentList "/S" -PassThru
Remove-Item "C:\image\iqfeed.exe" -Force

# Forward ports so they can be accessed from the outside
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

# Forward IQFeed logs to LogDNA
New-Item -ItemType Directory -Path "C:\DTN"
New-Item -ItemType File -Path "C:\DTN" -Name IQConnectLog.txt
logdna-agent -t iqfeed
logdna-agent -d "C:\DTN"
logdna-agent -f "C:\DTN\IQConnectLog.txt"
