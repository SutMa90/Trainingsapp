@echo off
rem WP2.7 Rueckuebertragung Gymi -> Excel (echte Excel im Projektordner).
rem Vor dem Schreiben: Vorschau, Rueckfrage J/N und Sicherung in Sicherungen\.
chcp 65001 >nul
title Gymi - Rueckuebertragung
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
call dart run tool/rueckuebertragung/main.dart
echo.
pause
