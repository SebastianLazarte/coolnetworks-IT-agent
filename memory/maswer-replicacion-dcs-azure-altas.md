---
name: maswer-replicacion-dcs-azure-altas
description: "Los DCs de Azure replican en cadena y van rezagados — tras crear/modificar una cuenta hay que hacer Sync-ADObject hacia MEUAZDC011 y MUSAZDC011 antes del ciclo de sync, o el alta no llega a M365"
metadata:
  type: project
---

Maswer tiene 4 DCs en 3 sitios: `MDERZADC003` + `MDERZADC004` (Default-First-Site-Name,
192.168.0.x), `MUSAZDC011` (Azure-Site-US) y `MEUAZDC011` (Azure-Site, EU).

**`MEUAZDC011` tiene un único partner de replicación entrante en la partición de dominio:
`MUSAZDC011`.** La cadena real es `MDERZADC003` → `MUSAZDC011` → `MEUAZDC011`: dos saltos
intersitio. Verificado 07-sep-2026 con `Get-ADReplicationPartnerMetadata`.

**Consecuencia:** una cuenta creada contra `MDERZADC003` tarda en llegar a `MEUAZDC011`, que es
(inferencia razonable, **no verificada en consola**) el DC del que lee
[[maswer-aad-connect-server]] y al que preguntan los agentes de PTA. Síntomas vistos:
`Start-ADSyncSyncCycle -PolicyType Delta` no exporta nada y el usuario no aparece en M365; y un
cambio de marcas de contraseña que "no hace efecto" en el inicio de sesión.

**How to apply:** tras cualquier alta o cambio de atributos de cuenta, empujar el objeto antes
de lanzar el ciclo de sync:

```powershell
Sync-ADObject -Object "<DN>" -Source MDERZADC003.intern.maswer.com -Destination MEUAZDC011.intern.maswer.com
Sync-ADObject -Object "<DN>" -Source MDERZADC003.intern.maswer.com -Destination MUSAZDC011.intern.maswer.com
```

Es replicación de objeto único: no toca topología y no hace falta `repadmin /syncall`. Después,
`Start-ADSyncSyncCycle -PolicyType Delta` en `MEUAZAC011` y el usuario aparece en el primer
ciclo. Para confirmar de qué DC lee AAD Connect: *Synchronization Service Manager* → Connectors
→ conector de AD → Properties.

También explica los falsos negativos al probar permisos recién concedidos —
[[test-token-refresh-without-logoff]]. Procedimiento de alta completo en
`reference/runbook-altas-usuarios-y-permisos.md` y [[maswer-altas-password-no-expira]].
