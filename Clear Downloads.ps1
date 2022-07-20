$count = 0
function FindFolders {
    $Userfolders = (Get-ChildItem -Path $env:SystemDrive\Users).Name
    Write-Host $Userfolders
    foreach ($user in $Userfolders){
        Get_docs($user)
    }
}

function Get_docs($user) {
    if (Test-Path -Path "$env:SystemDrive\Users\$user\Downloads" -ErrorAction SilentlyContinue){
        $files = Get-ChildItem -Path "$env:SystemDrive\Users\$user\Downloads"
        $currentDate = Get-Date
        $DateToDelete = $currentDate.AddDays(-30)
        Write-Host "$user Checking files"
        Get-ChildItem -Path "$env:SystemDrive\Users\$user\Downloads\*" -Recurse | Where-Object {$_.LastWriteTime -lt $DateToDelete} | Remove-Item -Force -Recurse
        foreach ($file in $files){
            $last = New-TimeSpan -End $CurrentDate -Start $file.LastWriteTime
            $Fname = $file.Name
            if ($file.LastWriteTime -lt $currentDate.AddDays(-30)){
                Write-Host "$user Removing $fname was $last old"
                $global:count ++
            }else{
                
                Write-Host "$user File $fname is $last old"
            }
        }
}
}
FindFolders
Write-Host "Removed $count files"