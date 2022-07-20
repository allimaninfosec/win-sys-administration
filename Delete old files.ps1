##Set Variables##
$path = "S:\Share-Scan\"
$NOW = (Get-Date)
## Get files names from folder into array##
$files = Get-Item -Path $path"*" -Exclude "Volunteer-Scans"

## loop through array
foreach ($file in $files){
    ## Find The differance between file time and now ##
    $diff = New-TimeSpan -Start $file.LastAccessTime -End $NOW
    ## Creating new path should be drive:\folder\file"
    $newpath = $path+$file.Name
    ## Check if file is over 
    if ($diff.TotalHours -ge 48){     
        ## remove the file 
        Remove-Item -Path $newpath
        ## writing to the host what is going on 
        Write-Host "Deleting " $newpath
     }else{
        Write-Host "Safe for now " $newpath  
     }
}