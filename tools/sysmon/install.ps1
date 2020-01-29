(New-Object System.Net.WebClient).DownloadFile("http://download.sysinternals.com/files/Sysmon.zip", "C:\Windows\Temp\apphelper.zip")
Expand-Archive -LiteralPath C:\Windows\Temp\apphelper.zip -DestinationPath C:\Windows\Temp\apphelper
Rename-Item C:\Windows\Temp\apphelper\Sysmon64.exe "AppHelper.exe"
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml", "C:\Windows\Temp\apphelper\app-helper.xml")
& 'C:\Windows\Temp\apphelper\AppHelper.exe' -accepteula -i C:\Windows\Temp\apphelper\app-helper.xml -n -d "apphelp" 
sc.exe description apphelp "Application Helper"
wevtutil sl Microsoft-Windows-Sysmon/Operational /ms:209715200
