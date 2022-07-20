$groups = Get-ADGroup -Filter * -Properties * | Where-Object mail -NE $null

foreach ($group in $group){
    Write-Host $group
    
}