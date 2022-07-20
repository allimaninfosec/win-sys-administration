## Writen By Matt Alliman
#Get Nethealth Mobile install Status
$status = Get-AppxPackage -Name NetHealth.NetHealthHospice -ErrorAction SilentlyContinue

if ($status){
    Write-Host "Optima Installed"
}else{
    Write-Host "Optima Not Installed"
}