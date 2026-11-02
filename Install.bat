@echo off
rem Double-click to install Sort My Footage.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
echo.
pause
