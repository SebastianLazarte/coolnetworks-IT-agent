---
name: test-token-refresh-without-logoff
description: "Probar un permiso NTFS recién concedido sin cerrar sesión — klist purge + acceso por el nombre corto del servidor; la revocación es asimétrica y necesita Close-SmbSession"
metadata:
  type: feedback
---

Para comprobar si un permiso de carpeta recién aplicado funciona, no hace falta cerrar sesión
de Windows: `klist purge` y luego acceder por el **nombre corto** del servidor
(`\\MDERZFIL001\...` en vez del FQDN `\\MDERZFIL001.intern.maswer.com\...`). SMB abre una
sesión separada por cada nombre de servidor, y el ticket nuevo lleva el PAC con los grupos
actualizados. Confirmado el 27-ago-2026 en el caso Cardozo: misma cuenta, mismo segundo,
`R:` (sesión antigua) denegado y nombre corto accesible con 3889 elementos.

**Why:** un permiso aplicado en AD no llega al puesto hasta que se reconstruye el token. Sin
esta técnica hay que pedir al usuario que cierre sesión, o abrir sesión remota en su equipo —
lo segundo está descartado por [[no-remote-sessions-endusers]].

**How to apply:** es la forma práctica de hacer el autotest que pide
[[prefer-admin-self-test]]: alta temporal de la propia cuenta admin en el grupo,
`Sync-ADObject` a los tres DCs (`MEUAZDC011`, el de Azure, se retrasa y da falsos negativos —
ver [[maswer-replicacion-dcs-azure-altas]]), purga, prueba, y baja con `Remove-ADGroupMember`
+ replicación forzada. **La revocación también es asimétrica:** el acceso sigue vivo hasta
cerrar la sesión SMB — se cierra desde el servidor con `Close-SmbSession`, no desde el cliente.
Relacionado: [[maswer-access-via-ad-security-groups]], [[separate-evidence-from-pattern]].
