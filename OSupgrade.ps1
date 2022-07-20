$URI = "https://<url>/Win10Pro3264-2004-US.iso"

function err_STOP {
    # stop for error message

}
function CHK_OS {
    $os = Get-WmiObject Win32_OperatingSystem
    $IP = Invoke-WebRequest -Uri https://ipapi.co/json/ | ConvertFrom-Json
    if ($os.BuildNumber -lt 19041)
    {
        if ($IP.org -ne "CELLCO")
        {
            Write-Host "Not on cell"
            CHK_Disk
        }else {
            Write-Host "On Cell"
            err_STOP
        }
    }
}
function CHK_Disk {
    $varSysFree = [Math]::Round((Get-WMIObject -Class Win32_Volume |Where-Object {$_.DriveLetter -eq $env:SystemDrive} | Select -expand FreeSpace) / 1GB)
    if ($varSysFree -lt 20){
        Write-Host "System Drive Does not contain enough space $varSysFreee < 20GB"
        err_STOP
    }else{
        Download_ISO
    }
}
function Download_ISO {
    Import-Module BitsTransfer -Force
    Start-BitsTransfer -Source $URI -Destination "$env:PUBLIC\WIN10.iso"
    Write-Host files downloaded
    perform_upgrade
}
function perform_upgrade {
    $mount = Mount-DiskImage -ImagePath "$env:PUBLIC\WIN10.iso"
    $drive = ($mount | Get-Volume).DriveLetter + ":"

    & "$drive\setup.exe" /auto upgrade /quiet /compat IgnoreWarning /showOOBE false

}
Write-Host "Starting"
CHK_OS
