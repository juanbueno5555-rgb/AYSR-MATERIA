@echo off
rem uni.cmd - Cambia las 5 VMs del Lab 01 a modo BRIDGE (red de la universidad)
rem Uso: doble click en la uni. Dentro de cada VM ejecutar el script "uni" (estatica).
set VBM=C:\Program Files\Oracle\VirtualBox\VBoxManage.exe
for %%V in (slackware-15.0 solaris-11.4-fresh android-x86 windows-server-core windows-server-gui) do (
  "%VBM%" modifyvm "%%V" --nic1 bridged --bridgeadapter1 "Wi-Fi" >nul 2>&1 && echo [OK] %%V - bridge
)
echo Listo: VMs en modo BRIDGE. IPs: Slackware .64, Solaris .65, Core .66, GUI .67, Android DHCP.
pause
