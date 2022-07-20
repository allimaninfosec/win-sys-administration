function CHK {
    Write-Host "Check for Trillian Install"
    $installed = Get-Package -Name Trillian -ErrorAction  Continue
    if ($installed){
        Write-Host "--Trillian is installed--"
        $proc = Get-Process -Name trillian -ErrorAction SilentlyContinue
            if($proc){
                Write-Host "Trillian is running"
                Get-Process -name trillian | Stop-Process -Force
                    Start-Sleep -Seconds 5        
            }
        $proc = Get-Process -Name trillian -ErrorAction SilentlyContinue  
        if ($null -eq $proc){
            Write-Host "Trillian is Shutdown"
            Write-Host "Uninstalling Trillian"
            Uninstall-Package -Name Trillian
        }
    }else{
        Write-Host "--Trillian is NOT INSTRALLED--"
    }
}
CHK