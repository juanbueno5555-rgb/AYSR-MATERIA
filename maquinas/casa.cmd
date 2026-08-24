@echo off
rem casa.cmd - Cambia las VMs del Lab 02 + Core a modo NAT (red del hogar, DHCP)
rem Uso: doble click. Los watchdogs internos restauran DHCP solos.
rem Vuelve a crear los forwards SSH por si se perdieran al cambiar el tipo de NIC.
rem Los forwards ya existentes dan error silencioso (nul): son equivalentes al deseado.
set VBM=C:\Program Files\Oracle\VirtualBox\VBoxManage.exe
for %%V in (slackware-15.0 solaris-11.4 windows-server-gui windows-server-core) do (
  "%VBM%" modifyvm "%%V" --nic1 nat >nul 2>&1 && echo [OK] %%V - NAT
)
rem --- forwards SSH: slackware 2222, solaris 2223, windows 2225, core 2224 ---
"%VBM%" modifyvm "slackware-15.0" --natpf1 "ssh2222,tcp,,2222,,22" >nul 2>&1
"%VBM%" modifyvm "solaris-11.4" --natpf1 "ssh2223,tcp,,2223,,22" >nul 2>&1
"%VBM%" modifyvm "windows-server-gui" --natpf1 "ssh,tcp,,2225,,22" >nul 2>&1
"%VBM%" modifyvm "windows-server-core" --natpf1 "ssh2224,tcp,,2224,,22" >nul 2>&1
"%VBM%" modifyvm "windows-server-core" --natpf1 "winrm5985,tcp,,5985,,5985" >nul 2>&1
echo Listo: VMs del Lab 02 + Core en modo NAT + forwards SSH/WinRM garantizados.
pause