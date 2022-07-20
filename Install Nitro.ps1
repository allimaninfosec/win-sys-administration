# Build functions

function Nitro_Installed {
    $Global:installed = (gp HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -contains 'Nitro Pro'  
}

# Nitro Pro Install

Write-Host "Starting Nitro Pro Install"
Write-Host ""
Write-Host "Checking for Nitro Install"

Nitro_Installed
if ($Global:installed -eq "True"){
    Write-Host "Nitro Installed Already"
}
# Force Powershell to use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host ""
Write-Host "Downloading Nitro Pro"

Invoke-WebRequest -Uri "http://install.nitropdf.com/professional_13162300/en/enterprise/nitro_pro13_x64.msi" -OutFile "nitropro.msi"

if ((Test-Path nitropro.msi) -eq "True"){
    Write-Host "Nitro Pro Downloaded"
}else {
    Write-Host "Nitro Pro Was not downloaded !!!"
    Exit 1
}
Write-Host ""
Write-Host "Installing Nitro Pro"

Start-Process nitropro.msi "/qn <key>"
$timeout = New-TimeSpan -Minutes 15
$install = [diagnostic.stopwatch]::startnew()
while ($install.elapsed -lt $timeout) {
    Nitro_Installed
    if ($Global:installed -eq "True"){
        Write-Host "Nitro Pro Installed"
        Write-Host "Now Removing Installer"
        Remove-Item nitropro.msi
    }
    Start-Sleep -Seconds 60 
}
