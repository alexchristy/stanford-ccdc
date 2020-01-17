Get-WinEvent -FilterHashtable @{logname="Microsoft-Windows-Sysmon/Operational";id=3} -MaxEvents 100 | Format-List
