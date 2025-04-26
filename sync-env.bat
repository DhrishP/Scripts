@echo off
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/DhrishP/Scripts/main/sync-env.ps1' -OutFile 'sync-env.ps1'; .\sync-env.ps1"
pause
