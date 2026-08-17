@echo off
rem casa.cmd - Cambia las VMs del Lab 01 + Lab 02 a modo NAT (red del hogar)
rem Uso: doble click en casa. La IP se cambia SOLA al arrancar (auto-deteccion de red).
set VBM=C:\Program Files\Oracle\VirtualBox\VBoxManage.exe
for %%V in (slackware-15.0 solaris-11.4 android-x86 windows-server-core windows-server-gui) do (
  "%VBM%" modifyvm "%%V" --nic1 nat >nul 2>&1 && echo [OK] %%V - NAT
)
echo Listo: VMs en modo NAT.
pause
