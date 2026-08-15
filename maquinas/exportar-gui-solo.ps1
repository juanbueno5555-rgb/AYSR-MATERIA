$ErrorActionPreference = 'Continue'
$vbm = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'
$out = 'C:\Users\RANGE\Downloads\maquinas\copias'
$ova = Join-Path $out 'windows-server-gui-copia-1.ova'
$log = Join-Path $out 'export-gui.log'
Add-Content -Path $log -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') START windows-server-gui"
$p = Start-Process -FilePath $vbm -ArgumentList @('export','windows-server-gui','-o',$ova,'--ovf20') -RedirectStandardOutput "$ova.log" -RedirectStandardError "$ova.log.err" -PassThru -WindowStyle Hidden
$p.WaitForExit()
if ((Test-Path $ova) -and (Get-Item $ova).Length -gt 100MB) {
    Add-Content -Path $log -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') DONE $([math]::Round((Get-Item $ova).Length/1GB,2)) GB"
} else {
    Add-Content -Path $log -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') FAIL"
}
