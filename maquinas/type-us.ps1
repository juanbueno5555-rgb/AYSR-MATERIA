# type-us.ps1 - Envia texto a una VM de VirtualBox usando scancodes crudos US (layout-independent).
# El guest tiene layout US; keyboardputstring distorsiona caracteres (leccion memoria #33).
# Uso: powershell -NoProfile -File type-us.ps1 -Vm <vm> -Text "<texto>"
# Enter/Tab/Backspace se envian aparte con keyboardputscancode (1c 9c / 0f 8f / 0e 8e).
param(
  [Parameter(Mandatory=$true)][string]$Vm,
  [Parameter(Mandatory=$true)][string]$Text
)
$vbm = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'

$base = @{
  'a'=0x1e;'b'=0x30;'c'=0x2e;'d'=0x20;'e'=0x12;'f'=0x21;'g'=0x22;'h'=0x23;'i'=0x17;'j'=0x24;'k'=0x25;'l'=0x26;'m'=0x32
  'n'=0x31;'o'=0x18;'p'=0x19;'q'=0x10;'r'=0x13;'s'=0x1f;'t'=0x14;'u'=0x16;'v'=0x2f;'w'=0x11;'x'=0x2d;'y'=0x15;'z'=0x2c
  '1'=0x02;'2'=0x03;'3'=0x04;'4'=0x05;'5'=0x06;'6'=0x07;'7'=0x08;'8'=0x09;'9'=0x0a;'0'=0x0b
  '-'=0x0c;'='=0x0d;'['=0x1a;']'=0x1b;';'=0x27;','=0x33;'.'=0x34;'/'=0x35;' '=0x39
}
$shiftMap = @{
  '!'=0x02;'@'=0x03;'#'=0x04;'$'=0x05;'%'=0x06;'^'=0x07;'&'=0x08;'*'=0x09;'('=0x0a;')'=0x0b
  '_'=0x0c;'+'=0x0d;'{'=0x1a;'}'=0x1b;':'=0x27;'"'=0x28;'~'=0x29;'|'=0x2b;'<'=0x33;'>'=0x34;'?'=0x35
}

$codes = New-Object System.Collections.Generic.List[string]
foreach ($ch in $Text.ToCharArray()) {
  $c = [string]$ch
  $sc = $null
  if ($shiftMap.ContainsKey($c)) {
    $sc = $shiftMap[$c]
    $codes.Add('2a'); $codes.Add(('{0:x2}' -f $sc)); $codes.Add(('{0:x2}' -f ($sc + 0x80))); $codes.Add('aa')
  }
  elseif ($c -cmatch '^[A-Z]$') {
    $sc = $base[$c.ToLower()]
    $codes.Add('2a'); $codes.Add(('{0:x2}' -f $sc)); $codes.Add(('{0:x2}' -f ($sc + 0x80))); $codes.Add('aa')
  }
  else {
    $sc = $base[$c]
    $codes.Add(('{0:x2}' -f $sc)); $codes.Add(('{0:x2}' -f ($sc + 0x80)))
  }
}
if ($codes.Count -gt 0) {
  # Pacing: enviar en rafagas cortas con pausa (el guest puede dropear teclas con rafagas largas)
  $chunkSize = 24
  for ($i = 0; $i -lt $codes.Count; $i += $chunkSize) {
    $end = [Math]::Min($i + $chunkSize, $codes.Count)
    $chunk = $codes.ToArray()[$i..($end - 1)]
    & $vbm controlvm $Vm keyboardputscancode $chunk 2>&1 | Out-Null
    Start-Sleep -Milliseconds 180
  }
}
Write-Output "Enviados $($codes.Count) scancodes a $Vm (paced)"
