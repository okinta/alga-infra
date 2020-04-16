:: Runs setup-windows-iqfeed.ps1
powershell.exe Invoke-WebRequest -Uri https://raw.githubusercontent.com/okinta/vultr-scripts/master/setup-windows-iqfeed.ps1 -OutFile C:\image\setup-windows-iqfeed.ps1
powershell.exe -file "C:\image\setup-windows-iqfeed.ps1" -ip "[VULTR_PRIVATE_IP]" -product "[IQFEED_PRODUCT]" -version "[IQFEED_PRODUCT_VERSION]" -login "[IQFEED_LOGIN]" -password "IQFEED_PASSWORD"
