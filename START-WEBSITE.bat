@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -Command "& ([scriptblock]::Create([System.IO.File]::ReadAllText('Scan-Music.ps1')))"
if errorlevel 1 (
  echo Could not scan the music folder. Keep all extracted files together.
  pause
  exit /b 1
)
start "" "%~dp0index.html"
endlocal
