---
name: maswer-ventana-mantenimiento-fin-de-mes
description: "El parcheo mensual de la flota de servidores de Maswer se ejecuta en una ventana de mantenimiento a fin de mes. Un servidor sin CU a mitad de mes está a la espera de la ventana, no en atraso."
metadata:
  type: project
---

**Confirmado por el usuario el 09-sep-2026.** El parcheo mensual de SO/seguridad de los
servidores de Maswer — responsabilidad de CoolNetworks desde el ciclo de mayo-2026, ver
[[conet-de-administers-maswer-infra]] — se ejecuta en una **ventana de mantenimiento a fin de
mes**, no de forma continua.

**Cómo aplicarlo:** al mirar el estado de parcheo a mitad de mes, un host sin la CU del mes está
*programado*, no *atrasado*. No reportarlo como incidencia ni escalarlo. Solo es atraso cuando
la CU de un mes anterior sigue sin instalarse pasada su ventana — ese fue el caso real de
[[meuazac011-disco-c-insuficiente]], con julio y agosto fallidos.

Consecuencias operativas de tener una única ventana mensual:

- **Los 4 DCs se reinician escalonados, uno a uno** (`MDERZADC003`, `MDERZADC004`, `MEUAZDC011`,
  `MUSAZDC011`) para no romper la replicación de AD — criterio fijado en el ciclo de mayo-2026.
- **El par PTA nunca a la vez** (`MEUAZPTA011` / `MEUAZPTA012`): los dos abajo = autenticación
  pass-through caída y nadie entra en M365. Ver [[maswer-ad-domain-infra]].
- **Avisar a conet antes**: el mantenimiento de `MEUAZAC011` dispara la alerta "Entra Connect
  Sync tampering" en Defender for Cloud, que la reciben ellos →
  [[adsync-restart-triggers-defender-alert]].
- Es la ventana natural para pedir a conet trabajos de plataforma que exigen parar la VM (p. ej.
  la ampliación de disco pendiente de `MEUAZAC011`).

Alcance: los 9 Windows Server del inventario ([[maswer-servers-inventory]]). `MEUAZAVD-0` queda
fuera hasta confirmar OS y uso. Los firewalls Sophos (firmware SFOS) no entran — son de conet.
