$ErrorActionPreference = 'Continue'
$outDir = 'C:\Users\RANGE\Downloads\maquinas\isos'
$dest = Join-Path $outDir 'sol-11_4-text-x86.iso'
$log = Join-Path $outDir 'download-status.log'
function Log($msg) {
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg
    Add-Content -Path $log -Value $line
}
Log "INICIO: Oracle Solaris 11.4 Text x86 (archive.org) -> sol-11_4-text-x86.iso"
if (Test-Path $dest) {
    $cur = (Get-Item $dest).Length
    Log "Reanudando sol-11_4-text-x86.iso desde $cur bytes"
}
& curl.exe -sS -L -C - --retry 8 --retry-delay 10 --retry-all-errors --fail -o $dest 'https://archive.org/download/sol-11_4-text-x86/sol-11_4-text-x86.iso'
$code = $LASTEXITCODE
if (Test-Path $dest) {
    $size = (Get-Item $dest).Length
    if ($size -gt 700MB) { Log "OK: sol-11_4-text-x86.iso completo ($size bytes)" }
    else { Log "ERROR: sol-11_4-text-x86.iso incompleto: $size bytes (curl exit $code)" }
} else {
    Log "ERROR: no se creo sol-11_4-text-x86.iso (curl exit $code)"
}
