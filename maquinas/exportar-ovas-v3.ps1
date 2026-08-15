# exportar-ovas-v3.ps1 - REANUDA la exportacion: solo los 11 OVAs faltantes.
# Misma regla v2: nunca exportar la misma VM en paralelo.
$ErrorActionPreference = 'Continue'
$vbm = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'
$out = 'C:\Users\RANGE\Downloads\maquinas\copias'
$logFile = Join-Path $out 'export-v3.log'
$concurrency = 3
New-Item -ItemType Directory -Force -Path $out | Out-Null
function Write-Log([string]$msg) { Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg" -Encoding UTF8 }
Write-Log '=== INICIO reanudacion v3 ==='
$jobs = @(
    @{ VM = 'slackware-15.0';  N = 2 }, @{ VM = 'slackware-15.0';  N = 3 },
    @{ VM = 'android-x86';     N = 2 }, @{ VM = 'android-x86';     N = 3 },
    @{ VM = 'solaris-11.4';    N = 2 }, @{ VM = 'solaris-11.4';    N = 3 },
    @{ VM = 'windows-server-core'; N = 2 }, @{ VM = 'windows-server-core'; N = 3 },
    @{ VM = 'windows-server-gui';  N = 1 }, @{ VM = 'windows-server-gui';  N = 2 }, @{ VM = 'windows-server-gui';  N = 3 }
)
$queue = New-Object System.Collections.Queue
foreach ($j in $jobs) {
    $ova = Join-Path $out ("{0}-copia-{1}.ova" -f $j.VM, $j.N)
    $queue.Enqueue([PSCustomObject]@{ VM = $j.VM; Ova = $ova; Log = "$ova.log"; Err = "$ova.log.err" })
}
$active = @{}
$failures = @()
while ($queue.Count -gt 0 -or $active.Count -gt 0) {
    while ($active.Count -lt $concurrency -and $queue.Count -gt 0) {
        $j = $queue.Dequeue()
        if ($active.Values.VM -contains $j.VM) { $queue.Enqueue($j); break }
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
    foreach ($id in @($active.Keys)) {
        $proc = Get-Process -Id $id -ErrorAction SilentlyContinue
        if (-not $proc) {
            $j = $active[$id]
            $active.Remove($id)
            if ((Test-Path $j.Ova) -and (Get-Item $j.Ova).Length -gt 100MB) {
                $sizeGB = [math]::Round((Get-Item $j.Ova).Length / 1GB, 2)
                Write-Log "DONE  $($j.VM) -> $($j.Ova) ($sizeGB GB)"
            } else {
                Write-Log "FAIL  $($j.VM) -> $($j.Ova)"
                $failures += $j.Ova
            }
        }
    }
}
if ($failures.Count -gt 0) { Write-Log "=== FIN con $($failures.Count) fallos ===" } else { Write-Log '=== FIN: reanudacion completa OK ===' }
