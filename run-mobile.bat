@echo off
cd /d "%~dp0mobile"
if not exist config.json copy config.example.json config.json
call flutter pub get
if errorlevel 1 (
  echo Flutter setup failed. Run flutter doctor and fix the listed issues.
  pause
  exit /b 1
)
call flutter run --dart-define-from-file=config.json
pause
