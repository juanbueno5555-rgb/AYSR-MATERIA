# Lab 6, 2.1.c: servidor web de Windows Server (IIS). Ejecutar en PowerShell como Administrador, dentro de la VM Windows.
$ErrorActionPreference = 'Stop'

Install-WindowsFeature -Name Web-Server -IncludeManagementTools        # instala IIS

$html = @'
<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>IIS en Windows Server</title></head>
<body><h1>IIS en Windows Server</h1><p>Laboratorio 6 de AYSR: Camilo Aguirre y Juan David Rangel.</p></body></html>
'@
Set-Content -Path 'C:\inetpub\wwwroot\index.html' -Value $html -Encoding UTF8

# 2.1.e: arranque automatico del servicio web (World Wide Web Publishing Service)
Set-Service -Name W3SVC -StartupType Automatic
Start-Service -Name W3SVC

# Regla de firewall para el puerto 80 (el rol suele crearla; esta orden la deja explicita sin duplicarla)
if (-not (Get-NetFirewallRule -DisplayName 'Lab06 HTTP 80' -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName 'Lab06 HTTP 80' -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow | Out-Null
}

Get-Service W3SVC | Select-Object Name, Status, StartType
(Invoke-WebRequest -Uri 'http://localhost/' -UseBasicParsing).StatusCode    # debe responder 200
