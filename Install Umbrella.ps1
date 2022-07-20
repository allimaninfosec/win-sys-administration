###Set Variables ###
$installed = Get-Package -Name "Umbrella Roaming Client" -ErrorAction SilentlyContinue
$url = "https://<url>/opendns2.2.356.msi"
$hash = "34D66F84858ED107D7F5658AFEA191993E5329B6142A73A16A4F43A5F5C3CABF"
function install {
    if ($installed){
        Write-Host "Umbrella Roaming Client is installed"
    }else{
        Invoke-WebRequest -Uri $url -OutFile "C:\Windows\Temp\opendns.msi"
        $file = Get-FileHash -Path "C:\Windows\Temp\opendns.msi"
        if ($file.HASH -eq $hash){
            Write-Host "File Downloaded and ready to go"
            Start-Process "msiexec.exe" -ArgumentList "/i C:\Windows\Temp\opendns.msi /qn ORG_ID=<org_ID> ORG_FINGERPRINT=<org_FP> USER_ID=<user_ID> HIDE_UI=1" -Wait
        }
    }
}


install
