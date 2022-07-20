$computers = Get-ADComputer -Properties NAME -Filter {name -like "*<server>*"} | select NAME

foreach( $computer in $computers){
    $ping = Test-Connection -ComputerName $computer.NAME -count 1 -Quiet
    if($ping -eq "true")
    {
        Get-CimInstance Win32_OperatingSystem -ComputerName $computer.NAME -ErrorAction SilentlyContinue | select csname, lastBootuptime | Export-Csv -Path uptime.csv -Append
        Get-HotFix -ComputerName $computer.NAME | Sort-Object -Descending -Property InstalledOn -ErrorAction SilentlyContinue | Select-Object -First 1 | Export-Csv -Path updates.csv -Append
        #$OS = Get-WmiObject win_operatingsystem -ComputerName $computer.NAME
        #$Uptime = $OS.ConvertToDateTime($OS.LastBootUpTime)
        #$computer
        #$Uptime

    }
    else
    {
        #Write-Host "$computer is not reachable" -ForegroundColor Red
    }
}
