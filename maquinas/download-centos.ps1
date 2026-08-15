$ErrorActionPreference = 'Continue'
$outDir = 'C:\Users\RANGE\Downloads\maquinas\isos'
$dest = Join-Path $outDir 'CentOS-Stream-10-latest-x86_64-dvd1.iso'
$log = Join-Path $outDir 'download-status.log'
function Log($msg) {
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg
    Add-Content -Path $log -Value $line
}
$expected = 10582097920
Log "INICIO (retry): CentOS Stream 10 DVD -> CentOS-Stream-10-latest-x86_64-dvd1.iso"
if (Test-Path $dest) {
    $cur = (Get-Item $dest).Length
    if ($cur -gt 0) { Log "Reanudando desde $cur bytes" }
}
& curl.exe -sS -L -C - --retry 8 --retry-delay 10 --retry-all-errors --fail -o $dest 'https://mirror.stream.centos.org/10-stream/BaseOS/x86_64/iso/CentOS-Stream-10-latest-x86_64-dvd1.iso'
$code = $LASTEXITCODE
if (Test-Path $dest) {
    $size = (Get-Item $dest).Length
    if ($size -ge $expected) { Log "OK: CentOS completo ($size bytes)" }
    else { Log "ERROR: CentOS incompleto: $size / $expected (curl exit $code)" }
} else {
    Log "ERROR: no se creo CentOS ISO (curl exit $code)"
}
