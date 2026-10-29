@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tools\san_francisco\start-local.ps1"
pause
