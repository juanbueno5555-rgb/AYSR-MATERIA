@echo off
rem uni.cmd - Cambia las VMs del Lab 01 + Lab 02 a modo BRIDGE (red de la universidad)
rem Uso: doble click en la uni. La IP se cambia SOLA al arrancar (auto-deteccion de red).
rem IPs uni: Slackware .64->.74, Solaris .65->.75, Core .66, GUI .67->.76, Android DHCP.
set VBM=C:\Program Files\Oracle\VirtualBox\VBoxManage.exe
for %%V in (slackware-15.0 solaris-11.4 android-x86 windows-server-core windows-server-gui) do (
  "%VBM%" modifyvm "%%V" --nic1 bridged --bridgeadapter1 "Wi-Fi" >nul 2>&1 && echo [OK] %%V - bridge
)
echo Listo: VMs en modo BRIDGE. Los clones originales fueron reemplazados por los nuevos (auto-red).
pause
