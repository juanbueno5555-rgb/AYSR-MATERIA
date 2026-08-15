# Exporta 3 copias OVA de cada VM del Lab 01 (15 OVAs) con pool de 3 procesos en paralelo.
# Uso: powershell -NoProfile -ExecutionPolicy Bypass -File exportar-ovas.ps1

$ErrorActionPreference = 'Continue'
$vbm = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'
$out = 'C:\Users\RANGE\Downloads\maquinas\copias'
$logFile = Join-Path $out 'export.log'
$vms = @('slackware-15.0', 'android-x86', 'solaris-11.4', 'windows-server-core', 'windows-server-gui')
$concurrency = 3

New-Item -ItemType Directory -Force -Path $out | Out-Null

function Write-Log([string]$msg) {
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg"
    Add-Content -Path $logFile -Value $line -Encoding UTF8
}

Write-Log '=== INICIO exportacion OVAs ==='

$queue = New-Object System.Collections.Queue
foreach ($vm in $vms) {
    foreach ($n in 1..3) {
        $ova = Join-Path $out ("{0}-copia-{1}.ova" -f $vm, $n)
        $queue.Enqueue([PSCustomObject]@{ VM = $vm; Ova = $ova; Log = "$ova.log"; Err = "$ova.log.err" })
    }
}

$active = @{}
$failures = @()

while ($queue.Count -gt 0 -or $active.Count -gt 0) {
    # llenar el pool
    while ($active.Count -lt $concurrency -and $queue.Count -gt 0) {
        $j = $queue.Dequeue()
        Write-Log "START $($j.VM) -> $($j.Ova)"
        $args = @('export', $j.VM, '-o', $j.Ova, '--ovf20')
        try {
            $p = Start-Process -FilePath $vbm -ArgumentList $args -RedirectStandardOutput $j.Log -RedirectStandardError $j.Err -PassThru -WindowStyle Hidden
            $active[$p.Id] = $j
        } catch {
            Write-Log "LAUNCH-FAIL $($j.VM): $($_.Exception.Message)"
            $failures += $j.Ova
        }
    }
    Start-Sleep -Seconds 15
    # limpiar procesos terminados
    foreach ($id in @($active.Keys)) {
        $proc = Get-Process -Id $id -ErrorAction SilentlyContinue
        if (-not $proc) {
            $j = $active[$id]
            $active.Remove($id)
            if (Test-Path $j.Ova) {
                $sizeGB = [math]::Round((Get-Item $j.Ova).Length / 1GB, 2)
                Write-Log "DONE  $($j.VM) -> $($j.Ova) ($sizeGB GB)"
            } else {
                Write-Log "FAIL  $($j.VM) -> $($j.Ova) (sin archivo; ver $($j.Err))"
                $failures += $j.Ova
            }
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Log "=== FIN con $($failures.Count) fallos: $($failures -join ', ') ==="
} else {
    Write-Log '=== FIN: 15 OVAs exportados OK ==='
}
