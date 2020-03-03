(New-Object System.Net.WebClient).DownloadFile("https://www.nirsoft.net/utils/cports-x64.zip", "C:\Users\$env:USERNAME\Desktop\cports-x64.zip")
Expand-Archive -LiteralPath "C:\Users\$env:USERNAME\Desktop\cports-x64.zip" -DestinationPath "C:\Users\$env:USERNAME\Desktop\currports\"
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/applied-cyber/ccdc/master/tools/currports/cports-active.cfg", "C:\Users\$env:USERNAME\Desktop\currports\cports.cfg")
& C:\Users\$env:USERNAME\Desktop\currports\cports.exe
