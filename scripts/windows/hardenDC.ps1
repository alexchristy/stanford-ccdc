Import-Module GroupPolicy
param (
	[string]$domain = "http://defaultdomain",
	[string]$ou = "CustomGPOU",
)
New-GPO -Name $gpoName -Comment "Custom GP" -Domain $domain
$ouPath = "OU=" + $ou + ",DC=" + $domain
$gpo = Get-GPO -Name $gpoName
$gpo | Set-GPRegistryValue -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -ValueName "AuditSystemEvents" -Type String -Value "Success, Failure"
$gpo | Set-GPRegistryValue -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -ValueName "AuditLogonEvents" -Type String -Value "Success, Failure"
$gpo | Set-GPRegistryValue -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "LockoutBadCount" -Type DWord -Value 5
$gpo | Set-GPRegistryValue -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "ResetLockoutCount" -Type DWord -Value (New-TimeSpan -Minutes 15)
$gpo | Set-GPRegistryValue -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "LockoutDuration" -Type DWord -Value (New-TimeSpan -Minutes 30)
$gpo | Set-GPRegistryValue -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices" -ValueName "AllRemovableStorageClassesDenyWrite" -Type DWord -Value $true
$gpo | Set-GPRegistryValue -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices" -ValueName "AllRemovableStorageClassesDenyExecute" -Type DWord -Value $true
$gpo | Set-GPRegistryValue -Key "HKCU\Software\Policies\Microsoft\Windows\System" -ValueName "DisableCMD" -Type DWord -Value 2
$gpo | Set-GPRegistryValue -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1
$gpo | Set-GPRegistryValue -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer" -ValueName "DisableMSI" -Type DWord -Value 1
$gpo | Set-GPRegistryValue -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer" -ValueName "AlwaysInstallElevated" -Type DWord -Value 0
$gpo | Set-GPRegistryValue -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "EnableGuestAccount" -Type DWord -Value 0
$gpo | Set-GPRegistryValue -Key "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" -ValueName "NoLMHash" -Type DWord -Value 1
New-GPLink -Name $gpoName -Target $ouPath
gpupdate /force
