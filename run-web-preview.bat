@echo off
cd /d "%~dp0"
echo Start run-backend.bat first, then open http://127.0.0.1:8080
echo This is the actual Flutter web build. Billing is no-purchase demo mode.
py -3 -m http.server 8080 --bind 127.0.0.1 --directory preview/web
pause
