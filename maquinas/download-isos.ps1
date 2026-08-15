$ErrorActionPreference = 'Continue'
$outDir = 'C:\Users\RANGE\Downloads\maquinas\isos'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$log = Join-Path $outDir 'download-status.log'
function Log($msg) {
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg
    Add-Content -Path $log -Value $line
}

$downloads = @(
    @{ Name = 'Windows Server 2025 Eval (en-US)'; Url = 'https://go.microsoft.com/fwlink/?linkid=2293312&clcid=0x409&culture=en-us&country=us'; File = 'windows-server-2025-eval-en-us.iso'; Expected = 6014152704 },
    @{ Name = 'CentOS Stream 10 DVD x86_64'; Url = 'https://mirror.stream.centos.org/10-stream/BaseOS/x86_64/iso/CentOS-Stream-10-latest-x86_64-dvd1.iso'; File = 'CentOS-Stream-10-latest-x86_64-dvd1.iso'; Expected = 10582097920 },
    @{ Name = 'Android-x86 9.0-r2 (k49, VMware)'; Url = 'https://sourceforge.net/projects/android-x86/files/Release%209.0/android-x86_64-9.0-r2-k49.iso/download'; File = 'android-x86_64-9.0-r2-k49.iso'; Expected = 963641344 }
)

foreach ($d in $downloads) {
    $dest = Join-Path $outDir $d.File
    Log "INICIO: $($d.Name) -> $($d.File)"
    if (Test-Path $dest) {
        $cur = (Get-Item $dest).Length
        if ($cur -ge $d.Expected) { Log "YA COMPLETO: $($d.File) ($cur bytes)"; continue }
        Log "Reanudando $($d.File) desde $cur bytes"
    }
    & curl.exe -sS -L -C - --retry 8 --retry-delay 10 --retry-all-errors --fail -o $dest $d.Url
    $code = $LASTEXITCODE
    if (Test-Path $dest) {
        $size = (Get-Item $dest).Length
        if ($size -ge $d.Expected) { Log "OK: $($d.File) completo ($size bytes)" }
        else { Log "ERROR: $($d.File) incompleto: $size / $($d.Expected) (curl exit $code)" }
    } else {
        Log "ERROR: no se creo $($d.File) (curl exit $code)"
    }
}
Log "FIN: todas las descargas finalizadas"
