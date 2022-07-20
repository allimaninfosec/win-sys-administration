###Set Variables ###
$installed = Get-Package -Name "Umbrella Roaming Client" -ErrorAction SilentlyContinue
$url = "https://scc-public.s3.amazonaws.com/Downloads/GOLD/XMFSP/9.0.0/ClientInstaller/XM_Fax_9.0.0.599_(Client_Redist)_kJu6F.zip"
$hash = "DC85FBFE67CA12751CFE820B59EE25812D1D7A351C6F4321CB03D24AC04D9C9F"
function install {
     #Check To see if it is installed
    if ($installed){
        Write-Host "Umbrella Roaming Client is installed"
    }else{
        #if not installed down load the file 
        Invoke-WebRequest -Uri $url -OutFile "C:\temp\XM.zip"
        #Calulate the hash of the installer
        Write-Host "Calulating Hash"
        $file = Get-FileHash -Path "C:\temp\XM.zip"
        Write-Host "Checking Hash"
        if ($file.HASH -eq $hash){
            Write-Host "File Downloaded and ready to go"
            Expand-Archive -Path "C:\temp\XM.zip"
            Start-Process "msiexec.exe" -ArgumentList "/i 'C:\temp\XM\XM Fax 9.0.0.599 (Client Redist).msi' /qn ADDLOCAL=printtoweb,printtoweb_all_lang CFG_WEBSERVER_HOST=https://fax.hynesmemorial.org CFG_SENDFAX_LOGIN_TYPE=3 ALLUSERS=1" -Wait
        }
    }
}


install
