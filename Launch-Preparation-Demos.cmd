@echo off
setlocal
set "GODOT=%USERPROFILE%\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe"
if defined GODOT_EXE set "GODOT=%GODOT_EXE%"
if not exist "%GODOT%" (
 echo Godot 4.7.2 introuvable. Definissez GODOT_EXE vers son executable.
 pause
 exit /b 1
)
start "ArchaeologyGame - Preparations" "%GODOT%" --path "%~dp0." res://scenes/experiments/preparation_demos.tscn
endlocal
