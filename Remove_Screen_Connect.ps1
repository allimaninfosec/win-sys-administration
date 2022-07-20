$Global:max = 45
$Global:count = 0
$Global:Status = 1

function Kill_IT{
if ((Get-Service | Where-Object Name -like ScreenConnect*).Status -eq "Running"){
    $Global:Status = 1
    Write-Host "Running"
    Get-Service | Where-Object Name -like ScreenConnect* | Stop-Service -Force
}else {
    Write-Host "Not Running"
    $Global:Status = 0    
}
}
function Remove {
    Get-Package | Where-Object Name -like ScreenConnect* | Uninstall-Package
}
function chk {
    while ($Global:Status -eq "1" -And $Global:count -ne $Global:max){
        Kill_IT
        start-sleep -Seconds 1
        write-host "Going $count"
        $count += 1
    }
    Remove 
}
if (Get-Package | Where-Object Name -like ScreenConnect*){
  chk  
}else{
    write-host "Not Installed"
}
