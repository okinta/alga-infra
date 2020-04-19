#
# Configures a newly installed Windows Server 2019 instance
#

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

# Set up Vultr private networking
$Metadata = Invoke-WebRequest -Uri "http://169.254.169.254/v1.json" | ConvertTo-Json
$ip = $Metadata.interfaces[1].ipv4.address
if ([string]::IsNullOrEmpty($ip)) {
    netsh interface ip set address name="Ethernet 2" static $ip 255.255.0.0 0.0.0.0 1
}
