# This script enables all auditing on a Windows system

# Enable auditing of successful and failed logon events
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Lsa' -Name "AuditLogonEvents" -Value 3

# Enable auditing of account management events
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Lsa' -Name "AuditAccountManage" -Value 3

# Enable auditing of directory service access events
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\NTDS\Diagnostics' -Name "16 Directory Service Access" -Value 2

# Enable auditing of object access events
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\eventlog\Security' -Name "Object Access" -Value 3

# Enable auditing of policy change events
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Lsa' -Name "AuditPolicyChange" -Value 3

# Enable auditing of privilege use events
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Lsa' -Name "AuditPrivilegeUse" -Value 3

# Enable auditing of system events
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\eventlog\System' -Name "Audit System Events" -Value 7
