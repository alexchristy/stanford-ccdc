$DownloadUrl = Invoke-WebRequest https://raw.githubusercontent.com/applied-cyber/ccdc/master/tools/sysmon/install.ps1; Invoke-Expression $($DownloadUrl.Content)
