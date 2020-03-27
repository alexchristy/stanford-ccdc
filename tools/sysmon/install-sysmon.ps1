(New-Object System.Net.WebClient).DownloadFile("http://download.sysinternals.com/files/Sysmon.zip", "C:\Users\$env:USERNAME\Desktop\Sysmon.zip")
(New-Object System.Net.WebClient).DownloadFile("http://stahlworks.com/dev/unzip.exe", "C:\Users\$env:USERNAME\Desktop\unzip.exe")
& "C:\Users\$env:USERNAME\Desktop\unzip.exe" "C:\Users\$env:USERNAME\Desktop\Sysmon.zip" -d "C:\Users\$env:USERNAME\Desktop\Sysmon"
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml", "C:\Users\$env:USERNAME\Desktop\Sysmon\sysmonconfig-export.xml")
& "C:\Users\$env:USERNAME\Desktop\Sysmon\Sysmon64.exe" -accepteula -i "C:\Users\$env:USERNAME\Desktop\Sysmon\sysmonconfig-export.xml" -n 
wevtutil sl Microsoft-Windows-Sysmon/Operational /ms:209715200
# & "C:\Users\$env:USERNAME\Desktop\Sysmon\Sysmon64.exe" -u
