# Tarjetas de red — Lab 02, sección 4

> Grupo de 2: Camilo Aguirre y Juan David Rangel
> Datos recopilados 16-17/08/2026

## 1. Dispositivos físicos

### 1.1 PC principal (Juan David) — LAPTOP-C3Q1U534 (Windows)

**Adaptador Wi-Fi (activo):**
| Campo | Valor |
|---|---|
| Fabricante/Modelo | **Realtek 8852CE WiFi 6E PCI-E NIC** |
| MAC | `08-F9-7E-9E-25-03` |
| IPv4 | `192.168.1.10/24` (DHCP) |
| IPv6 | `fe80::7a67:ecca:4ea2:4cd0%13` (link-local) |
| Gateway | `192.168.1.1` |
| DNS | `192.168.1.1` |
| Velocidad Wi-Fi + SSID | *(pendiente — netsh wlan requiere admin/permiso de ubicación)* |
| Bytes RX | `3.250.114.444` |
| Bytes TX | `3.535.449.942` |

**Adaptador Ethernet (inactivo):**
| Campo | Valor |
|---|---|
| Fabricante/Modelo | **Realtek PCIe GbE Family Controller** |
| MAC | `30-C5-99-8B-F5-8A` |
| Estado | Media disconnected (sin cable) |

**Otros adaptadores virtuales:** Tailscale Tunnel (IPv4 100.123.100.115, IPv6 fd7a:115c:a1e0::5301:64b7), VirtualBox Host-Only (192.168.56.1), 2× Wi-Fi Direct Virtual Adapter (MACs 0A-F9-7E-9E-25-03, 0E-F9-7E-9E-25-03).

### 1.2 Otros dispositivos (3 × integrante)

**[PENDIENTE — Juan David]:** teléfono + otros 2 dispositivos (smartphone/tablet/consola).
**[PENDIENTE — Camilo]:** 3 dispositivos propios.
**[PENDIENTE]:** computadoras de la escuela (cuando vayamos al lab).

## 2. Máquinas virtuales (comparación con el host)

### 2.1 Slackware-15.0 (VM 1)
| Campo | Valor |
|---|---|
| NIC | VirtualBox virtual NIC (e1000) |
| MAC | `08:00:27:0a:46:19` |
| IPv4 | `10.0.2.15/24` (DHCP NAT) |
| IPv6 | *(sin GUA; solo link-local)* |
| RX bytes | `26.101` |
| TX bytes | *(ver /sbin/ip -s link)* |

### 2.2 Solaris-11.4 (VM 2)
| Campo | Valor |
|---|---|
| NIC | **e1000g0** (Intel PRO/1000 emulada por VirtualBox) |
| Media | Ethernet up |
| **Speed** | **1000 Mb/s full-duplex** |
| IPv4 | `10.0.2.15/24` (DHCP NAT) |
| MAC | *(dladm show-phys)* |

## 3. Comparación host vs VMs (para el informe)

- El host usa una NIC **física Realtek** (Wi-Fi 6E + GbE); las VMs usan NICs **virtuales emuladas** (e1000 de VirtualBox).
- La velocidad del enlace Solaris es 1000 Mbps full-duplex (virtual), igual que la GbE física; la Wi-Fi del host depende del AP (Wi-Fi 6E).
- Las MACs de las VMs empiezan con `08:00:27` (OUI de VirtualBox) — las físicas usan OUI de Realtek (`08-F9-7E`) — esto demuestra que son virtuales.
- Las VMs están en NAT (10.0.2.x) — misma subred que el alias NAT, distinta de la LAN real (192.168.1.x).
