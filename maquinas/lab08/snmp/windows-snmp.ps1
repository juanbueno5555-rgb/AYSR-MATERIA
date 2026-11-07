# Agente SNMP en Windows Server (Lab 7, punto 2). Ejecutar como Administrador.
$p = 'HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters'
Install-WindowsFeature SNMP-Service -IncludeManagementTools | Out-Null

# Comunidad de solo lectura (valor 4 = READ ONLY) y quienes pueden preguntar
New-Item -Path "$p\ValidCommunities" -Force | Out-Null
New-ItemProperty -Path "$p\ValidCommunities" -Name 'lab07mon' -Value 4 -PropertyType DWord -Force | Out-Null
New-Item -Path "$p\PermittedManagers" -Force | Out-Null
$i = 1
foreach ($m in '192.168.82.14', '192.168.82.10', '127.0.0.1') {
    New-ItemProperty -Path "$p\PermittedManagers" -Name "$i" -Value $m -PropertyType String -Force | Out-Null
    $i++
}

# Firewall: UDP 161 de entrada, todos los perfiles
Remove-NetFirewallRule -DisplayName 'SNMP UDP 161 Lab7' -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName 'SNMP UDP 161 Lab7' -Direction Inbound -Protocol UDP -LocalPort 161 -Action Allow -Profile Any | Out-Null

Set-Service SNMP -StartupType Automatic
Restart-Service SNMP -Force
Start-Sleep 3
Get-Service SNMP | Select-Object Name, Status
Get-NetUDPEndpoint -LocalPort 161 -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, OwningProcess
Get-NetFirewallRule -DisplayName 'SNMP UDP 161 Lab7' | Select-Object DisplayName, Enabled, Direction, Action
