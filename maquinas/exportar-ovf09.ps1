$vbm = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'
$out = 'C:\Users\RANGE\Downloads\maquinas\copias\vmware'
$log = Join-Path $out 'export-ovf09.log'
$vm = $args[0]
$ova = Join-Path $out "$vm.ovf"
Add-Content -Path $log -Value "$(Get-Date -Format 'HH:mm:ss') START $vm ovf09"
& $vbm export $vm -o $ova --ovf09 2>&1 | Out-File -Append "$out\$vm.err"
if ((Test-Path $ova)) { Add-Content -Path $log -Value "$(Get-Date -Format 'HH:mm:ss') DONE $vm" } else { Add-Content -Path $log -Value "$(Get-Date -Format 'HH:mm:ss') FAIL $vm" }
