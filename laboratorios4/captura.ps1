<#
  captura.ps1 - Captura SOLO LA VENTANA ACTIVA y la guarda en las evidencias del Lab 04.
  ---------------------------------------------------------------------------------
  Por defecto recorta a la ventana que este en primer plano (no captura todo el
  escritorio). Si no puede, cae a pantalla completa.

  Uso:
      powershell -ExecutionPolicy Bypass -File captura.ps1 -Name "fig-pt-dns"
      powershell -ExecutionPolicy Bypass -File captura.ps1 -Name "fig-pt-dns" -Delay 5
      powershell -ExecutionPolicy Bypass -File captura.ps1 -Name "prueba" -FullScreen

  -Name      : nombre EXACTO del archivo (se guarda <Name>.png).
  -Delay     : segundos antes de capturar (para traer la ventana al frente). Default 3.
  -OutDir    : carpeta destino (default: informe-latex\img\lab04).
  -FullScreen: fuerza capturar toda la pantalla.
#>
param(
    [string]$Name = "captura",
    [int]$Delay = 3,
    [string]$OutDir,
    [switch]$FullScreen
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

if (-not ("NativeWin" -as [type])) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class NativeWin {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
}
"@
}

if (-not $OutDir) {
    # Buscar hacia arriba la carpeta que contiene "informe-latex" (raiz del repo)
    $d = $PSScriptRoot
    while ($d -and -not (Test-Path (Join-Path $d "informe-latex"))) {
        $parent = Split-Path -Parent $d
        if (-not $parent -or $parent -eq $d) { break }
        $d = $parent
    }
    $OutDir = Join-Path $d "informe-latex\img\lab04"
}
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

if ($FullScreen) { Write-Host ("Capturando PANTALLA COMPLETA en {0} s..." -f $Delay) }
else             { Write-Host ("Capturando la VENTANA ACTIVA en {0} s... (trae al frente lo que quieras)" -f $Delay) }
if ($Delay -gt 0) { Start-Sleep -Seconds $Delay }

$x = 0; $y = 0; $w = 0; $h = 0
if (-not $FullScreen) {
    try {
        $hwnd = [NativeWin]::GetForegroundWindow()
        $r = [NativeWin+RECT]::new()
        if ([NativeWin]::GetWindowRect($hwnd, [ref]$r)) {
            $x = $r.Left; $y = $r.Top; $w = $r.Right - $r.Left; $h = $r.Bottom - $r.Top
        }
    } catch { }
}
if ($w -le 0 -or $h -le 0) {
    $b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $x = $b.X; $y = $b.Y; $w = $b.Width; $h = $b.Height
}

$bmp = New-Object System.Drawing.Bitmap($w, $h)
$gfx = [System.Drawing.Graphics]::FromImage($bmp)
$gfx.CopyFromScreen($x, $y, 0, 0, (New-Object System.Drawing.Size($w, $h)))

$file = Join-Path $OutDir ("{0}.png" -f $Name)
$bmp.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)
$gfx.Dispose(); $bmp.Dispose()

Write-Host ("Captura guardada: {0}  ({1}x{2})" -f $file, $w, $h)
