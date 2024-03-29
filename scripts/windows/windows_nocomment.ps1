Set-PSReadlineOption -HistorySaveStyle SaveNothing
$PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC4aSa1V6C11ip2W8N4rM+AEAevnlLbpdzkG7O2fw8o3 administrator@ccdc.local"
$NEWDEFAULT="Password_1"
$SSHD_DOWNLOAD="https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.2.2.0p1-Beta/OpenSSH-Win64-v9.2.2.0.msi"

Set-LocalUser -Name $env:USERNAME -Password (ConvertTo-SecureString -String $NEWDEFAULT -AsPlainText -Force)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 0
Set-LocalUser -Name Administrator -Password (ConvertTo-SecureString -String $NEWDEFAULT -AsPlainText -Force)
if (Get-WmiObject -Query "select * from Win32_OperatingSystem where ProductType='2'") {
    exit 0
}
Invoke-WebRequest -Uri $SSHD_DOWNLOAD -OutFile "C:\sshd.msi"
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i C:\sshd.msi /quiet" -PassThru
$process.WaitForExit()
Add-Content -Force -Path $env:ProgramData\ssh\administrators_authorized_keys -Value $PUBKEY
icacls.exe ""$env:ProgramData\ssh\administrators_authorized_keys"" /inheritance:r /grant ""Administrators:F"" /grant ""SYSTEM:F""
New-Item -Force -ItemType Directory -Path $env:USERPROFILE\.ssh
Add-Content -Force -Path $env:USERPROFILE\.ssh\authorized_keys -Value $PUBKEY
Add-Content -Force -Path "$env:ProgramData\ssh\sshd_config" -Value "PasswordAuthentication no"
Restart-Service sshd
Set-NetFirewallProfile -Enabled False -All
netsh advfirewall export "C:\original.wfw"
Get-NetFirewallRule | Set-NetFirewallRule -Enabled False
New-NetFirewallRule -DisplayName "AUTOMATED RULE Big Default Port Allow Rule" -Direction Inbound -Protocol TCP -LocalPort 21,22,25,53,80,110,143,389,443,587,993,995,8080,8443 -Action Allow
$IP = Get-NetAdapter | Sort-Object InterfaceMetric | Select-Object -First 1 | Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.PrefixOrigin -eq "Dhcp" -or $_.PrefixOrigin -eq "Manual"} | Select-Object -ExpandProperty IPAddress
$parts = $IP.Split('.')
$parts[-1] = "0"
$SUBNET = ($parts -join '.') + "/24"
$FirewallRule = @{
    Name = "AUTOMATED RULE Allow outbound to local subnet $SUBNET"
    DisplayName = "AUTOMATED RULE Allow outbound to local subnet $SUBNET"
    Description = "AUTOMATED RULE Allow outbound to local subnet $SUBNET"
    Direction = "Outbound"
    Action = "Allow"
    Protocol = "Any"
    RemoteAddress = "$SUBNET"
}
New-NetFirewallRule @FirewallRule
Set-NetFirewallProfile -Enabled True -DefaultInboundAction Block -DefaultOutboundAction Block
