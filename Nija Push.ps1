##Push ninja Client
##Set Variables##
Import-Module BitsTransfer -Force
$installed
$url = "https://<url>/internalinfrastructuremainoffice-5.2.1993-windows-installer.msi"
$hash = "E8F638E6BFA61D9218B7EAC07AB3268705521B05E63DCA6083BAC7B05AE2716A"

function Download {
    Write-Host "Downloading the Agent"
    Start-BitsTransfer -Source $url -Destination "C:\Windows\Temp\internalinfrastructuremainoffice-5.2.1993-windows-installer.msi"
    Write-Host "Generating File Hash"
    $file = Get-FileHash -Path "C:\Windows\Temp\internalinfrastructuremainoffice-5.2.1993-windows-installer.msi"
    if ($file.Hash -eq $hash){
        Install
    }else{
        Write-Host "File Hash Mis match"
    }
}
function Install {
    Write-Host "Starting Install process"
    Start-Process "msiexec.exe" -ArgumentList "/i C:\Windows\Temp\internalinfrastructuremainoffice-5.2.1993-windows-installer.msi"
    
}
Download
