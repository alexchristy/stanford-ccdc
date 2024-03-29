$scriptFromGithub = "https://raw.githubusercontent.com/DSU-DefSec/ace/master/windows/main.ps1"
$localScriptPath = "C:\downloadedScript.ps1"

# Download the script from GitHub
Invoke-WebRequest -Uri $scriptFromGithub -OutFile $localScriptPath

# Get a list of all domain-joined computers
$computers = Get-ADComputer -Filter *

foreach ($computer in $computers) {
    # Make sure to skip if the computer is the one running the script
    if ($computer.Name -ne $env:COMPUTERNAME) {
        # Remote execution command (example using Invoke-Command for PowerShell)
        Invoke-Command -ComputerName $computer.Name -FilePath $localScriptPath -AsJob
    }
}
