@echo off
REM
If EXIST c:\windows\ltsvc\ltsvc.exe GOTO EXIT
GOTO INSTALL
:INSTALL
copy \\domain\netlogon\Agent_Install.MSI %windir%\temp
call %windir%\temp\Agent_Install.MSI /q
GOTO EXIT
:EXIT
Exit
