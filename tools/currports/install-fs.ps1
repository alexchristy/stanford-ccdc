# Invokes Powershell install from URL - not safe, but fast.
$DownloadUrl = Invoke-WebRequest https://raw.githubusercontent.com/applied-cyber/ccdc/master/tools/currports/install.ps1; Invoke-Expression $($DownloadUrl.Content)
