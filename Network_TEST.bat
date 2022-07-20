@echo off 
echo Locating Default Gateways
ipconfig | findstr Default >> results.txt
echo Locating DNS
ipconfig /all | findstr Servers >> results.txt
echo Testing Paths
tracert -4 -h 4 8.8.8.8 >> results.txt