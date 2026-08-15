@echo off
set PATH=C:\Program Files\Oracle\VirtualBox;%PATH%
cd /d C:\Users\RANGE\Downloads\maquinas
echo ========================================
echo  Packer Build - Slackware 15.0 Box (32-bit)
echo ========================================
echo.
packer build -force .\slackware64-15.0\packer.pkr.hcl
echo.
echo ========================================
if %ERRORLEVEL% EQU 0 (
    echo BUILD EXITOSO!
) else (
    echo BUILD FALLIDO - Revisar errores arriba
)
echo ========================================
pause
