$Global:url = "https://www.ceruleanstudios.com/trillian-v6.3.0.6.msi"
$Global:ver = "6.3.6"

Write-Output "#### CHECKING FOR Trillian Install ####"

$installed = Get-Package -Name Trillian -ErrorAction SilentlyContinue
function Chk_Install {
    if ($installed) {
        Write-Output "INSTALLED"
        upgrade
    }else{
        Write-Output "Not Installed"
        download
        install
    }    
}
function install {

    Write-Host "### Starting Trillian Install"
    Start-Process trillian.msi
    $timeout = New-TimeSpan -Minutes 15
    $install = [diagnostic.stopwatch]::startnew()
    while ($install.elapased -lt $timeout){
        $installd = Get-Package -Name Trillian -ErrorAction SilentlyContinue
        if ($installd){
            Write-Output "#### Trillan Now installed"
            Remove-Item trillian.msi
            Send-MessageBox -title "Upgrade Complete" -message "Trillian Upgrade Complete Please login using your  email address and windows password. If you have any issues please contact us at support@hynesmemorial.org Thank you, Your  IT Department" -duration 60 -style 0x00000000L
        }
        Start-Sleep -Seconds 60 
    }

}
function upgrade {
    $installed = Get-Package -Name Trillian -ErrorAction SilentlyContinue
    if ($installed.Version -ne $Global:ver){
       ask
    }else {
        Write-Host "Latest Trillian Installed"
    }
}
function download {
    Write-Output "#### Downloading Latest Trillian ####"
    Invoke-WebRequest -uri $Global:url -OutFile "trillian.msi"
    if ((Test-Path trillian.msi) -eq "True"){
        Write-Host "-- Trillian Downloaded"
    }else {
        Write-Host "-- Trillian Was not downloaded !!!"
        Exit 1
    }
}
function ask {
    
    #$a = New-Object -ComObject wscript.shell
    #$Answer = $a.popup("IT has identified that your computer is using an out of date Version of Trillian. We would like to take 5-mins to ensure that Your software is updated. Trillian will not function on your computer at this time. Pressing No will delay the update for an hour", 0, " Request", 4)
    $Answer = Send-MessageBox -title "Request" -message "IT has identified that your computer is using an out of date Version of Trillian. We would like to take 5-mins to ensure that Your software is updated. Trillian will not function on your computer at this time. Pressing No will delay the update for an hour" -duration 60 -style 0x00001034L
    Write-Output $Answer
    if ($Answer -eq 6){
        Write-Host "Update Required"
        download
        if (Get-Process -Name Trillian -ErrorAction SilentlyContinue){
            Write-Host "Process Running. Killing process"
            Stop-Process -Name Trillian -Force
            Write-Host "Uninstalling Trillian"
            Uninstall-Package -Name Trillian 
            install
        }
        Write-Host "Uninstalling Trillian"
            Uninstall-Package -Name Trillian 
            install
    }else{
        timer
    }
}
function timer {
    $time = 0
    while ($time -le 60){
        if ($time -eq 60){
            ask
        }
        Start-Sleep 60
        $time ++
    }
}
function Send-MessageBox
{
[CmdletBinding()]
[OutputType([string])]
Param
(        
    [Parameter(Mandatory=$true, Position=0)]
    [string]$title,
    [Parameter(Mandatory=$true, Position=1)]
    [string]$message,
    [Parameter(Mandatory=$true, Position=2)]
    [int]$duration,
    [Parameter(Mandatory=$true, Position=3)]
    [int]$style
)

Begin
{
    $typeDefinition = @"
        using System;
        using System.Runtime.InteropServices;

        public class WTSMessage {
            [DllImport("wtsapi32.dll", SetLastError = true)]
            public static extern bool WTSSendMessage(
                IntPtr hServer,
                [MarshalAs(UnmanagedType.I4)] int SessionId,
                String pTitle,
                [MarshalAs(UnmanagedType.U4)] int TitleLength,
                String pMessage,
                [MarshalAs(UnmanagedType.U4)] int MessageLength,
                [MarshalAs(UnmanagedType.U4)] int Style,
                [MarshalAs(UnmanagedType.U4)] int Timeout,
                [MarshalAs(UnmanagedType.U4)] out int pResponse,
                bool bWait
            );

            static int response = 0;

            public static int SendMessage(int SessionID, String Title, String Message, int Timeout, int MessageBoxType) {
                WTSSendMessage(IntPtr.Zero, SessionID, Title, Title.Length, Message, Message.Length, MessageBoxType, Timeout, out response, true);

                return response;
            }
        }
"@
}

Process
{
    if (-not ([System.Management.Automation.PSTypeName]'WTSMessage').Type)
    {
        Add-Type -TypeDefinition $typeDefinition
    }

    $RawOuput = (quser) -replace '\s{2,}', ',' | ConvertFrom-Csv
    $sessionID = $null

    Foreach ($session in $RawOuput) {  
        if(($session.sessionname -notlike "console") -AND ($session.sessionname -notlike "rdp-tcp*")) {
            if($session.ID -eq "Active"){    
                $sessionID = $session.SESSIONNAME
            }                        
        }else{
            if($session.STATE -eq "Active"){      
                $sessionID = $session.ID
            }        
        }   
    }
    $response = [WTSMessage]::SendMessage($sessionID, $title, $message, $duration, $style )
}
End
{
    Return $response
}
}
Chk_Install
