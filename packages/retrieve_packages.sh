#!/usr/bin/sh
mkdir windows

# .NET 4.5.2
wget -cO - https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe > windows/NET-4.5.2.exe

# windows 7 and server 2008 64 bit
wget -cO - http://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win7AndW2K8R2-KB3191566-x64.zip > powershell_5_6.1_x64.zip
unzip -o powershell_5_6.1_x64.zip
mv Win7AndW2K8R2-KB3191566-x64.msu windows/powershell_5_6.1_x64.msu

# windows 7 and server 2008 32 bit
wget -cO - http://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win7-KB3191566-x86.zip > powershell_5_6.1_x32.zip
unzip -o powershell_5_6.1_x32.zip
mv Win7-KB3191566-x86.msu windows/powershell_5_6.1_x86.msu

# windows server 2012 6.2 64 bit only
wget -cO - http://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/W2K12-KB3191565-x64.msu > windows/powershell_5_6.2_x64.msu

# windows server 2012 r2 and 8.1 64 bit
wget -cO - http://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu > windows/powershell_5_6.3_x64.msu

# windows 8.1 32 bit
wget -cO - http://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1-KB3191564-x86.msu > windows/powershell_5_6.3_x86.msu
