@echo off
rem uni.cmd - Cambia las VMs del Lab 02 + Core a modo BRIDGE (red de la universidad, cable Ethernet Realtek)
rem Uso: doble click. Lo ideal es ejecutarlo con las VMs APAGADAS antes de conectar el cable en la uni.
rem Los watchdogs internos de cada VM (cada 60s) detectan el gateway 10.2.65.1 y aplican
rem las IPs estaticas solos (Slackware .74, Solaris .75, Windows GUI .76, Core .77): esperar hasta 2 min.
rem Lab 01 (android-x86) queda intacto: no se toca.
set VBM=C:\Program Files\Oracle\VirtualBox\VBoxManage.exe
for %%V in (slackware-15.0 solaris-11.4 windows-server-gui windows-server-core) do (
  "%VBM%" modifyvm "%%V" --nic1 bridged --bridgeadapter1 "Realtek PCIe GbE Family Controller" >nul 2>&1 && echo [OK] %%V - bridged Realtek
)
echo.
echo Listo: VMs del Lab 02 + Core en modo BRIDGE (Realtek).
echo Conecta el cable Ethernet en la uni y espera hasta 2 min: los watchdogs aplican las IPs.
echo Acceso SSH en la uni: slackware 10.2.78.74, solaris 10.2.78.75, windows 10.2.78.76, core 10.2.78.77 (puerto 22 directo).
pause