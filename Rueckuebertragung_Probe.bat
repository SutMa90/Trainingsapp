@echo off
rem WP2.6 Rueckuebertragung Gymi -> Excel, PROBELAUF:
rem schreibt nur in eine Kopie der Excel in Sicherungen\Probe\.
rem Die echte Excel bleibt unveraendert.
chcp 65001 >nul
title Gymi - Rueckuebertragung (Probelauf)
cd /d "%~dp0app"
where dart >nul 2>nul
if errorlevel 1 (
  echo ABBRUCH: Dart/Flutter wurde auf diesem PC nicht gefunden.
  echo Was tun: Flutter muss installiert sein ^(Ordner flutter\bin im Suchpfad^).
  echo.
  pause
  exit /b 1
)
echo Programm wird vorbereitet ^(beim ersten Mal bis ca. 30 Sekunden^) ...
call dart run tool/rueckuebertragung/main.dart --probe
echo.
pause
