# Set Global Variables
$Global:Build = "2004"
$Global:Drive = ""
function Check_DSK {
    #Validating 
    $varSysFree = [Math]::Round((Get-WMIObject -Class Win32_Volume |Where-Object {$_.DriveLetter -eq $env:SystemDrive} | Select -expand FreeSpace) / 1GB)
    if ($varSysFree -lt 20) {
        write-host "  System drive requires at least 20GB: 13 for installation, 7 for the disc image."
        quitOr
    }
}
function quitOr {

        Write-Host "  If you do not believe the error to be valid, you can re-run this Component with the"
        write-host "  `'usrOverrideChecks`' flag enabled, which will ignore blocking errors and proceed."
        write-host "  Support will not be able to assist with issues that arise as a consequence of this action."
        Stop-Process setupHost -ErrorAction SilentlyContinue
        exit 1
}
function download_ISO {
    import-module BitsTransfer -Force
    verify_Network
    $uri = 'https://<storage location>Win10Pro3264-%-US.iso' -replace("%","$Global:Build")
    Start-BitsTransfer -Source $uri -Destination "$env:PUBLIC\win10.iso"
    
}
function verify_Network {
    $results = Invoke-WebRequest http://ip-api.com/json | ConvertFrom-Json 
    $isp = $results.isp
    $notallowed = {"AT&T Mobility LLC", "Cellco Partnership DBA Verizon Wireless", "T-Mobile USA, Inc."}
    if ($isp -notin $notallowed){
        Write-Host "Not On Cellular on $isp"
    }else{
        Write-Host "On $isp Which is Mobile"
        quitOr
    }
}
function Mount_ISO {
    $mount = Mount-DiskImage $env:PUBLIC\win10.iso -PassThru
    $Global:Drive = ($mount | Get-Volume).DriveLetter
}
function upgrade {
    $current_Version = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").releaseid
    if ($current_Version -lt $Global:Build){
        Check_DSK
        download_ISO
        & $Global:Drive":\setup.exe /auto upgrade /quite /no restart"
    }else {
        Write-Host "Running Correct Version"
    }
    
}
upgrade
