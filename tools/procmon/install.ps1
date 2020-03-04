(New-Object System.Net.WebClient).DownloadFile("https://download.sysinternals.com/files/ProcessMonitor.zip", "C:\Users\$env:USERNAME\Desktop\ProcessMonitor.zip")
Expand-Archive -LiteralPath "C:\Users\$env:USERNAME\Desktop\ProcessMonitor.zip" -DestinationPath "C:\Users\$env:USERNAME\Desktop\ProcessMonitor\"
(New-Object System.Net.WebClient).DownloadFile("https://github.com/applied-cyber/ccdc/raw/master/tools/procmon/tcp-udp-all.pmc", "C:\Users\$env:USERNAME\Desktop\ProcessMonitor\tcp-udp-all.pmc"
& "C:\Users\$env:USERNAME\Desktop\ProcessMonitor\Procmon64.exe" /AcceptEula /LoadConfig tcp-udp-all.pmc
