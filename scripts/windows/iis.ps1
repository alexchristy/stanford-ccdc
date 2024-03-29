if ((Get-WindowsFeature Web-Server).InstallState -eq "Installed") {

        Foreach($item in (Get-ChildItem IIS:\AppPools)) { $tempPath="IIS:\AppPools\"; $tempPath+=$item.name; Set-ItemProperty -Path $tempPath -name processModel.identityType -value 4}

        Foreach($item in (Get-ChildItem IIS:\Sites)) { $tempPath="IIS:\Sites\"; $tempPath+=$item.name; Set-WebConfigurationProperty -filter /system.webServer/directoryBrowse -name enabled -PSPath $tempPath -value False}

        Set-WebConfiguration //System.WebServer/Security/Authentication/anonymousAuthentication -metadata overrideMode -value Allow -PSPath IIS:/

        Foreach($item in (Get-ChildItem IIS:\Sites)) { $tempPath="IIS:\Sites\"; $tempPath+=$item.name; Set-WebConfiguration -filter /system.webServer/security/authentication/anonymousAuthentication $tempPath -value 0}

        Set-WebConfiguration //System.WebServer/Security/Authentication/anonymousAuthentication -metadata overrideMode -value Deny-PSPath IIS:/

        $sysDrive=$Env:Path.Substring(0,3); $tempPath=((Get-WebConfiguration "//httperrors/error").prefixLanguageFilePath | Select-Object -First 1) ; $sysDrive+=$tempPath.Substring($tempPath.IndexOf('\')+1); Get-ChildItem -Path $sysDrive -Include *.* -File -Recurse | foreach { $_.Delete()}

    } 