@echo off
title Build 3D Print Cost v1.0
cd /d "%~dp0"

echo ============================================
echo       3D PRINT COST v1.0 - BUILD EXE
echo ============================================
echo.

py -m pip install --upgrade pyinstaller openpyxl
if errorlevel 1 goto error

py -m PyInstaller --noconfirm --clean --onefile --windowed ^
  --name "3D_Print_Cost" ^
  --icon "3D_Print_Cost.ico" ^
  --add-data "3D_Print_Cost.ico;." ^
  --collect-all openpyxl ^
  "3D_Print_Cost.py"

if errorlevel 1 goto error

echo.
echo ============================================
echo BUILD COMPLETATA
echo EXE: dist\3D_Print_Cost.exe
echo ============================================
pause
exit /b 0

:error
echo.
echo ERRORE DURANTE LA BUILD.
echo Controlla che Python e pip siano installati.
pause
exit /b 1
