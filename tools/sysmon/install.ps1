(New-Object System.Net.WebClient).DownloadFile("http://download.sysinternals.com/files/Sysmon.zip", "C:\Windows\Temp\apphelper.zip")
Expand-Archive -LiteralPath C:\Windows\Temp\apphelper.zip -DestinationPath C:\Windows\Temp\apphelper
Rename-Item C:\Windows\Temp\apphelper\Sysmon64.exe "AppHelper.exe"
& 'C:\Windows\Temp\apphelper\AppHelper.exe' -i -n -d "apphelp"
sc.exe description apphelp "Application Helper"
