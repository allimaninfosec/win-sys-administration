
## Writen By Matt Alliman
# Get BitLocker status 
$enabled = Get-BitLockerVolume  | Where-Object CapacityGB -GT 90 | Where-Object ProtectionStatus -eq "On" | Select-Object MountPoint, ProtectionStatus -ErrorAction SilentlyContinue

if ($enabled){
    #Writes to screen Bitlocker is enabled 
    Write-Host "Bitlocker is enabled"
}else{
    # Writes to host Bitlocker is disabled
    Write-Host "Bitlocker Disabled"
}