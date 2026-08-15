$job = Get-Job -Name "packer-build" -ErrorAction SilentlyContinue
if (-not $job) {
    Write-Host "No hay job de build corriendo." -ForegroundColor Yellow
    exit
}

Write-Host "Estado: $($job.State)" -ForegroundColor Cyan
Write-Host ""

$output = Receive-Job -Job $job -Keep
if ($output) {
    # Mostrar las últimas líneas
    $lines = $output -split "`r`n"
    $tail = $lines[-20..-1] -join "`r`n"
    Write-Host $tail -ForegroundColor White
}

if ($job.State -eq "Completed") {
    Write-Host ""
    Write-Host "=== BUILD COMPLETADO ===" -ForegroundColor Green
    $fullOutput = $output -join "`r`n"
    if ($fullOutput -match "Build finished successfully|The build and validation succeeded") {
        Write-Host "EXITO!" -ForegroundColor Green
    } else {
        Write-Host "REVISAR - puede haber errores" -ForegroundColor Red
    }
} elseif ($job.State -eq "Failed") {
    Write-Host ""
    Write-Host "=== BUILD FALLÓ ===" -ForegroundColor Red
}
