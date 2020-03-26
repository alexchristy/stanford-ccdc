(New-Object System.Net.WebClient).DownloadFile("https://www.nirsoft.net/utils/cports-x64.zip", "C:\Users\$env:USERNAME\Desktop\cports-x64.zip")
(New-Object System.Net.WebClient).DownloadFile("http://stahlworks.com/dev/unzip.exe", "C:\Users\$env:USERNAME\Desktop\unzip.exe")
& "C:\Users\$env:USERNAME\Desktop\unzip.exe" "C:\Users\$env:USERNAME\Desktop\cports-x64.zip" -d "C:\Users\$env:USERNAME\Desktop\currports"
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/applied-cyber/ccdc/master/tools/currports/cports.cfg", "C:\Users\$env:USERNAME\Desktop\currports\cports.cfg")
& C:\Users\$env:USERNAME\Desktop\currports\cports.exe
