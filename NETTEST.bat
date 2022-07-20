@echo off 
echo --PINGING--
ping 8.8.8.8 >> test.txt
echo --TESTING PATH --
tracert -4 -h 4 8.8.8.8 >> test.txt
echo --CHECKING WIRELESS--
NetSh WLAN Show All >> test.txt
pause