# Lab 8, parte 2.a: menu de comandos de red para Windows Server (PowerShell).
# Uso: powershell -ExecutionPolicy Bypass -File info_red.ps1

function Pausa { Read-Host "`nPresione Enter para volver al menu" | Out-Null }
function Titulo($t, $d) { Write-Host "`n=== $t ===" -ForegroundColor Cyan; Write-Host "$d`n" }

do {
    Clear-Host
    Write-Host "=========== Informacion de red (Windows) ==========="
    Write-Host " 1) Interfaces e IP              (ipconfig /all)"
    Write-Host " 2) Tabla de rutas               (route print)"
    Write-Host " 3) Puertos en escucha           (netstat -ano)"
    Write-Host " 4) Conexiones activas           (netstat -n)"
    Write-Host " 5) Paquetes por interfaz        (netstat -e)"
    Write-Host " 6) Velocidad y estado del enlace (Get-NetAdapter)"
    Write-Host " 7) Cache ARP                    (arp -a)"
    Write-Host " 0) Salir"
    $op = Read-Host "Opcion"
    switch ($op) {
        '1' { Titulo "Interfaces e IP" "IP, mascara, gateway, DNS y MAC de cada tarjeta."; ipconfig /all }
        '2' { Titulo "Tabla de rutas" "Destinos y por donde salen. 0.0.0.0 es la ruta por defecto (gateway)."; route print }
        '3' { Titulo "Puertos en escucha" "Servicios esperando conexiones, con el PID del proceso."; netstat -ano | Select-String 'LISTENING|Proto' }
        '4' { Titulo "Conexiones activas" "Conexiones TCP establecidas ahora mismo."; netstat -n | Select-String 'ESTABLISHED|Proto' }
        '5' { Titulo "Paquetes por interfaz" "Bytes y paquetes recibidos y enviados, con errores."; netstat -e }
        '6' { Titulo "Velocidad y estado del enlace" "Estado (Up/Down) y velocidad de cada adaptador."; Get-NetAdapter | Format-Table Name, Status, LinkSpeed, MacAddress -AutoSize }
        '7' { Titulo "Cache ARP" "Relacion IP-MAC de los equipos con los que se hablo hace poco."; arp -a }
        '0' { break }
        default { Write-Host "Opcion no valida." }
    }
    if ($op -ne '0') { Pausa }
} while ($op -ne '0')
