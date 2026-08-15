@echo off
rem casa.cmd - Cambia las 5 VMs del Lab 01 a modo NAT (red del hogar)
rem Uso: doble click en casa. Dentro de cada VM ejecutar el script "casa" (DHCP).
set VBM=C:\Program Files\Oracle\VirtualBox\VBoxManage.exe
for %%V in (slackware-15.0 solaris-11.4-fresh android-x86 windows-server-core windows-server-gui) do (
  "%VBM%" modifyvm "%%V" --nic1 nat >nul 2>&1 && echo [OK] %%V - NAT
)
echo Listo: VMs en modo NAT.
pause
