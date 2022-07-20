$localhost = 0
$INT = Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces | Get-ChildItem | Select-Object Name
foreach ($reg in $INT){
    $entry =  $reg.Name
    $profile = Get-Item -Path Registry::$entry | Get-ChildItem | Select-Object Name
    #Write-Host $profile
    foreach ($prof in $profile){
        $DNSServer = $prof.Name
        #write-host $DNSServer
        #Set-Location -Path Registry::$DNSServer
        $NS = Get-ItemProperty -Path Registry::$DNSServer -Name NameServer -ErrorAction SilentlyContinue | Select-Object NameServer 
        if ($NS -ne $null -and $NS -ne "") {
            Write-Output "Not Static"
        }else{
            Write-Output "STATIC SET" + $DNSServer
        }
        }
}