$config = "https://<url>/vpn.xml"
$progurl = "https://<url>/anyconnect-win-4.9.04043-core-vpn-predeploy-k9.msi"

Invoke-WebRequest -Uri $progurl -OutFile "$env:PUBLIC\anyconnect.msi"


Start-Process $env:PUBLIC\anyconnect.msi "/qn"

#Remove-Item -Path $env:PUBLIC\anyconnect.msi
if (Test-Path -Path "C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile"){
    Write-Host "path is here "
}else {
    Write-Host "Path being created"
}
Invoke-WebRequest -uri $config -OutFile "C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile\vpn.xml"
