@echo off
rem uni-win-b.cmd - Aplica IP estatica de la universidad al clon windows-server-gui-b
rem Ejecutar como Administrador DENTRO de windows-server-gui-b cuando esten en la uni (bridge)
netsh interface ipv4 set address name="Ethernet" static 10.2.78.76 255.255.0.0 10.2.65.1
netsh interface ipv4 set dns name="Ethernet" static 10.2.65.1
echo IP estatica 10.2.78.76 aplicada. Verificar con ipconfig.
pause
