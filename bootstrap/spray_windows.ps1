# don't save history
Set-PSReadlineOption -HistorySaveStyle SaveNothing

# HARDCODE THIS PUBKEY BEFORE DEPLOYMENT
$PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII60R2wnE2PGLBDUXhhqLoylh3qjAJrVyYItQT8N0Ty+ root@salt"
# CHANGE THIS IN COMPETITION
$NEWDEFAULT="Password_1"
# TODO, FIND NON HTTP LINK TO THIS MSI
$SSHD_DOWNLOAD="https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.2.2.0p1-Beta/OpenSSH-Win64-v9.2.2.0.msi"

# STEP -1: Roll our own password
Set-LocalUser -Name $env:USERNAME -Password (ConvertTo-SecureString -String $NEWDEFAULT -AsPlainText -Force)
# TODO, USE CMD COMMAND VERSION
# THIS FAILED TESTING

# STEP ZERO: make sure we're an administrative user
# MAKE SURE IT WORKS IF ADMINISTRATOR IS A DOMAIN USER
# Maybe we should roll passwords first
if (-not [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    exit 0
}

# Patch EternalBlue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 0

# STEP ONE: Change Administrator password
# TODO CHECK TO MAKE SURE THIS ALSO ACTIVATES THE ADMINISTRATOR
Set-LocalUser -Name Administrator -Password (ConvertTo-SecureString -String $NEWDEFAULT -AsPlainText -Force)

# Hardening is only done on the DC because the rest of the boxes are taken care of later
# stop here if we're a DC
# TODO, TEST THIS, IT'S FROM CPP
if (Get-WmiObject -Query "select * from Win32_OperatingSystem where ProductType='2'") {

#if ((Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty DomainRole) -eq 4) {
# TODO, TEST THIS ON A DC
# TODO, URGENT, THIS FAILED TESTING
    Write-Output "DOMAIN CONTROLLER HERE IMPORTANT IMPORTANT IMPORTANT IMPORTANT"

    # Zerologon patch (IS THIS TESTED IN THE DOC?)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" -Name "FullSecureChannelProtection" -Value 1 -Type DWORD -Force

    # SIGRed patch (IS THIS TESTED?)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\DNS\Parameters" -Name "TcpReceivePacketSize" -Value 0xFF00 -Type DWORD -Force
    Restart-Service DNS

    # SMBGhost
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" DisableCompression -Type DWORD -Value 1 -Force

    # Print Nightmare
    Stop-Service -Name "Spooler"
    Set-Service -Name "Spooler" -StartupType Disabled

    # Certifried
    if (Get-Service -Name "CertSvc" -ErrorAction SilentlyContinue) {
        Stop-Service -Name "CertSvc"
        Set-Service -Name "CertSvc" -StartupType Disabled
    }


    # Bluekeep
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1 -Type DWORD -Force

    exit 0
}


# STEP TWO: Install and configure sshd

# Retrieve sshd installer
Invoke-WebRequest -Uri $SSHD_DOWNLOAD -OutFile "C:\sshd.msi"
# TODO REPLACE WITH $env:TEMP

# Start the installation process
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i C:\sshd.msi /quiet" -PassThru

# Wait for the installation to complete
$process.WaitForExit()

# add pubkey to authorized_keys
Add-Content -Force -Path $env:ProgramData\ssh\administrators_authorized_keys -Value $PUBKEY
icacls.exe ""$env:ProgramData\ssh\administrators_authorized_keys"" /inheritance:r /grant ""Administrators:F"" /grant ""SYSTEM:F""

# this technically does nothing since administrators_authorized_keys is used
# but better safe than sorry
New-Item -Force -ItemType Directory -Path $env:USERPROFILE\.ssh
Add-Content -Force -Path $env:USERPROFILE\.ssh\authorized_keys -Value $PUBKEY

# Disable password authentication for sshd
Add-Content -Force -Path "$env:ProgramData\ssh\sshd_config" -Value "PasswordAuthentication no"
Restart-Service sshd

Write-Output "sshd successfully configured"

# STEP THREE: firewall configuration

# Turn off the firewall so we never get locked out
Set-NetFirewallProfile -Enabled False -All

# backup all original rules in case something explodes
netsh advfirewall export "C:\original.wfw"

# toss all existing firewall rules
Get-NetFirewallRule | Set-NetFirewallRule -Enabled False

# allow inbound from all service ports
New-NetFirewallRule -DisplayName "AUTOMATED RULE Big Default Port Allow Rule" -Direction Inbound -Protocol TCP -LocalPort 21,22,25,53,80,110,143,389,443,993,995,8080,8443 -Action Allow

# allow outbound to local subnet

# Get the ip of the primary network interface
$IP = Get-NetAdapter | Sort-Object InterfaceMetric | Select-Object -First 1 | Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.PrefixOrigin -eq "Dhcp" -or $_.PrefixOrigin -eq "Manual"} | Select-Object -ExpandProperty IPAddress

# Convert the IP address to a subnet
# TODO IS ALL THIS STRING HANDLING REQUIRED OR CAN YOU GIVE IT A RAW IP
$parts = $IP.Split('.')
$parts[-1] = "0"
$SUBNET = ($parts -join '.') + "/24"

# Define the outbound firewall rule
$FirewallRule = @{
    Name = "AUTOMATED RULE Allow outbound to local subnet $SUBNET"
    DisplayName = "AUTOMATED RULE Allow outbound to local subnet $SUBNET"
    Description = "AUTOMATED RULE Allow outbound to local subnet $SUBNET"
    Direction = "Outbound"
    Action = "Allow"
    Protocol = "Any"
    RemoteAddress = "$SUBNET"
}

# Create the allow outbound rule
New-NetFirewallRule @FirewallRule

# default deny everything and enable firewall
Set-NetFirewallProfile -Enabled True -DefaultInboundAction Block -DefaultOutboundAction Block
