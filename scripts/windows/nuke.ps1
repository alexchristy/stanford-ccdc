If (Test-Path "C:\Windows\SysWOW64\certutil.exe") {
    Remove-Item -Path "C:\Windows\SysWOW64\certutil.exe" -Force
}
If (Test-Path "C:\Windows\System32\certutil.exe") {
    Remove-Item -Path "C:\Windows\System32\certutil.exe" -Force
}

Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system -Name LocalAccountTokenFilterPolicy -Value 0
#Remove all startup or shutdown scripts
remove-item -Force 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\*'
remove-item -Force 'C:\autoexec.bat'
remove-item -Force "C:\Users\*\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\*"
remove-item -Force "C:\Windows\System32\GroupPolicy\Machine\Scripts\Startup"
remove-item -Force "C:\Windows\System32\GroupPolicy\Machine\Scripts\Shutdown"
remove-item -Force "C:\Windows\System32\GroupPolicy\User\Scripts\Logon"
remove-item -Force "C:\Windows\System32\GroupPolicy\User\Scripts\Logoff"
reg delete HKLM\Software\Microsoft\Windows\CurrentVersion\Run /VA /F
reg delete HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce /VA /F 
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /VA /F
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce /VA /F
