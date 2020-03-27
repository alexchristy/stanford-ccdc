(New-Object System.Net.WebClient).DownloadFile("https://download.sysinternals.com/files/ProcessMonitor.zip", "C:\Users\$env:USERNAME\Desktop\ProcessMonitor.zip")
(New-Object System.Net.WebClient).DownloadFile("http://stahlworks.com/dev/unzip.exe", "C:\Users\$env:USERNAME\Desktop\unzip.exe")
& "C:\Users\$env:USERNAME\Desktop\unzip.exe" "C:\Users\$env:USERNAME\Desktop\ProcessMonitor.zip" -d "C:\Users\$env:USERNAME\Desktop\ProcessMonitor"
(New-Object System.Net.WebClient).DownloadFile("https://github.com/applied-cyber/ccdc/raw/master/tools/procmon/proc-tcp.pmc", "C:\Users\$env:USERNAME\Desktop\ProcessMonitor\proc-tcp.pmc")
& "C:\Users\$env:USERNAME\Desktop\ProcessMonitor\Procmon64.exe" /AcceptEula /LoadConfig "C:\Users\$env:USERNAME\Desktop\ProcessMonitor\proc-tcp.pmc"
