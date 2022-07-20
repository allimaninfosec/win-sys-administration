Function ConvertTo-Hex {
    Param([int]$Number)
    '0x{0:x}' -f $Number
    }
$Active_AV = New-Object System.Collections.ArrayList
$AV = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct
Write-Host "Checking for AVS in reg"
foreach ($item in $AV){
    $hx = ConvertTo-Hex $item.productState
    $mid = $hx.substring(3,2)
    if ($mid -match "00|01"){
        $ENABLED = $false
    }else{
        $ENABLED = $true
        $Active_AV.add($item.displayName)
    }

}
$ENABLED = $false
Write-Host "Checking if AV is installed"
foreach ($item in $Active_AV){
    $APP = $item.Split(" ")[0]
    $installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -like $APP + "*"
    if ($installed -ge 1 ){
        $ENABLED = $true
    }
}
$wfbssAgentExists = Get-ItemProperty -Path 'HKLM:HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\TrendMicro\PC-cillinNTCorp\CurrentVersion\HostedAgent' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'AgentGuid' -ErrorAction SilentlyContinue
if ($wfbssAgentExists){
    $ENABLED = $true
}
Write-Host "Checking to see if SophosSetup.exe is already running"
if ((get-process "sophossetup" -ea SilentlyContinue) -eq $Null){
        Write-Host "--SophosSetup Not Running" 
}
else {
    Write-Host "<-Start Result->"
    Write-Host "CSMon_Result= AV Installing"
    Write-Host "<-End Result->"
    exit 0
 }
if ($ENABLED -eq $true){
    Write-Host "<-Start Result->"
    Write-Host "CSMon_Result= AV Installed"
    Write-Host "<-End Result->"
    exit 0
}else{
    Write-Host "<-Start Result->"
    Write-Host "CSMon_Result= AV Not installed"
    Write-Host "<-End Result->"
    exit 1
}