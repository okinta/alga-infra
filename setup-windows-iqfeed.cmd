:: Runs setup-windows-iqfeed.ps1
powershell.exe Invoke-WebRequest -Uri https://raw.githubusercontent.com/okinta/vultr-scripts/master/setup-windows-iqfeed.ps1 -OutFile C:\image\setup-windows-iqfeed.ps1
powershell.exe -file "C:\image\setup-windows-iqfeed.ps1" "[VULTR_PRIVATE_IP]"
