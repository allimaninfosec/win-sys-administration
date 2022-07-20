## Scripted by Matt Alliman
#Install NetHealth Mobile Store App because optima sucks 
Import-Module BitsTransfer
function CHK {
    $installed = Get-AppxPackage -Name NetHealth.NetHealthHospice
    if ($installed){
        write-host("installed")
    }else{
        Download_ME
        write-host("Installing")
        add-ProvisionedAppxPackage -PackagePath $env:TEMP\optima.appxbundle -online -SkipLicense
        
    }
    
}
function Download_ME {
    Write-Host "Setting Up download location"
    $product_url = "https://www.microsoft.com/store/productId/9NDXQ1H36PMV"
    $api_url = "https://store.rg-adguard.net/api/GetFiles"
    $body = @{
        type = 'url'
        url =  $product_url
        ring = 'RP'
        lang = 'en-US'
    }
    write-host "Fetching Download URL"
    $raw = Invoke-RestMethod -method Post -uri $api_url -ContentType 'application/x-www-form-urlencoded' -body $body
    $raw | Select-String '<tr style.*<a href=\"(?<url>.*)"\s.*>(?<text>.*)<\/a>' -AllMatches | % { $_.Matches } | % { 
    $url = $_.Groups[1].Value
    $text = $_.Groups[2].Value
    if($text -match "_(x64|neutral).*[^e]appxbundle$") {
        Write-Host $text $url
        write-host "Oh Baby We are downloading Optima"
        Start-BitsTransfer -Source $url -Destination $env:TEMP\optima.appxbundle
    }
}
}
CHK
write-host "We own you Optima ;D"