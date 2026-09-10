---
name: meuazac011-disco-c-insuficiente
description: "MEUAZAC011 tiene un disco de sistema de solo 29,4 GB — causa raíz de las LCU de Server 2019 que fallaban con 0x80246007. Vaciar SoftwareDistribution\\Download lo desbloqueó y la CU se instaló (sep-2026). Limpiar es de CoolNetworks, ampliar es de conet."
metadata:
  type: project
---

**Confirmado 07-sep-2026** en `MEUAZAC011` (Server 2019 Datacenter, build 17763.8755):

- **C: = 29,4 GB totales, 0,5 GB libres (2%)**. D: = 8 GB, 6,9 libres.
- `C:\Windows\SoftwareDistribution\Download` ocupaba **5,86 GB** — el 20% del disco.

Consecuencia: las CU acumulativas fallaban en fase de **descarga**, no de instalación —
2026-07 KB5099538 (`0x80246007`, 6 intentos) y 2026-08 KB5120238 (`0x80246007`, 27 intentos).
Bucle que se autoalimenta: cada reintento deja payload parcial y reduce el espacio para el
siguiente.

**Descartado como causa** (verificado el mismo día): no hay WSUS (la clave de política
`HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate` existe pero sin `WUServer`;
`AU\AUOptions=4`), no hay proxy WinHTTP (`Direct access`), y `windowsupdate.microsoft.com` y
`download.windowsupdate.com` responden en 443. `delivery.mp.microsoft.com` da False, pero es el
endpoint de Delivery Optimization, no el de descarga — irrelevante aquí.

**Reparto de responsabilidad** (útil como precedente frente a
[[conet-de-administers-maswer-infra]]): liberar espacio *dentro* del volumen es de
CoolNetworks, porque el parcheo mensual de SO de los servidores de Maswer es suyo desde el
ciclo de mayo-2026. **Ampliar el disco es de conet** — es plataforma. Un disco de sistema de
29 GB es corto de origen para un Server 2019 con LCU mensual: reaparecerá en 3-4 ciclos.
Petición abierta a conet: ampliar a ≥80 GB, aprovechando que en Azure requiere parar la VM y ya
hace falta ventana para el reinicio.

Vaciar `SoftwareDistribution\Download` (borrar, **no renombrar** — con 0,5 GB libres la copia
`.old` no cabe) recupera ~5,9 GB parando solo `wuauserv` y `bits`, sin tocar ADSync, así que no
dispara la alerta de [[adsync-restart-triggers-defender-alert]]. El reinicio de la instalación
sí.

**Confirmado el 09-sep-2026: funcionó.** Tras la limpieza, la CU acumulativa se instaló
correctamente y el atraso de julio y agosto quedó cerrado (la LCU es acumulativa, así que cubre
el KB5099538 fallido). El diagnóstico de espacio en disco era el correcto — no había que tocar
ni WSUS ni red. **La ampliación del disco sigue pendiente de conet**, así que la cuenta atrás de
3-4 ciclos sigue corriendo desde sep-2026.

Nada que ver con el error crónico de Export de [[maswer-aad-connect-server]], que ya está
identificado como `CN=Oliver Orth` / `msDS-KeyCredentialLink`.
