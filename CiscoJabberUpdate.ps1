$URI = "webserver/CiscoJabberSetup.msi"
$hub = "https://www.poly.com/content/dam/www/software/PlantronicsHubInstaller.exe"

function Download {
    Import-Module BitsTransfer -Force
    Start-BitsTransfer -Source $URI -Destination "$env:PUBLIC\Jabber.msi"
    Start-BitsTransfer -Source $hub -Destination "$env:PUBLIC\Hub.exe" 0
    
    
}
function Install {
    Start-Process "$env:PUBLIC\Jabber.msi /quite"

}
function Check_Version {
    $version = (Get-Package -Name "Cisco Jabber" | Select-Object Name, Version).Version 
    if ($version -eq "14.0.0.55563"){
        Write-Host "Version is up to date"
    }
}
