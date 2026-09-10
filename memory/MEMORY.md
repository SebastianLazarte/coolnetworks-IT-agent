# Memory Index

**Esta carpeta es la única fuente de verdad de la memoria.** Un hecho por fichero, indexado aquí.
Unificada el 08-sep-2026 fusionando la memoria automática de Claude Code (que vivía fuera del
repo, sin versionar) con la del repositorio. No mantener facts fuera de aquí.

## Quién es el usuario y cómo trabajar con él

- [User identity](user-identity.md) — Sebastian Lazarte Castellon (**sin acentos**), IT de CoolNetworks para Maswer; correo `IT-Support-Germany@maswer.com`
- [User is the whole IT stack](user-is-whole-it-stack.md) — N1+N2+N3 es una sola persona; "escalar a N2" = él sigue con el diagnóstico. El único N2 real es conet.de
- [Sebastian's AD privileges](sebastian-ad-privileges.md) — la cuenta de diario es miembro directo de `BUILTIN\Administrators` del dominio: control total. **Corrige** el falso "read-only" del 14-ago-2026
- [No habla alemán — todo en inglés](user-does-not-speak-german-use-english.md) — correspondencia con conet.de y Maswer en inglés, nunca alemán
- [Terso, sin preámbulo](user-prefers-terse-no-preamble.md) — cuando pide un artefacto, entregar solo el artefacto
- [Editar borradores, no regenerarlos](edit-dont-regenerate-drafts.md) — cambio puntual = tocar solo esa línea; regenerar pierde sus correcciones

## Cómo redactar (respuestas al cliente y a terceros)

- [Tono: directo, no "buena onda"](reply-tone-direct-not-nice.md) — liderar con el "no"; pero directo ≠ seco con quien sufre el problema, ni predicador
- [Sin tecnicismos por defecto](customer-replies-non-technical-by-default.md) — nada de firewall/túnel/IPsec ni "SLA"; impacto de negocio en llano
- [Solo acciones, cero hallazgos](customer-reply-only-actionable-no-findings.md) — nada de "tu cuenta no está bloqueada" ni coletillas de empatía
- [Pedir solo lo operativo](customer-reply-only-ask-operational-info.md) — no preguntar para qué lo quiere; y respetar el alcance que el ticket ya fija
- [No instruir lo que ya hizo](dont-instruct-what-user-already-did.md) — quien se paró y preguntó espera una decisión, no advertencias
- [No decir lo obvio al destinatario](dont-state-the-obvious-to-recipient.md) — no contarle a conet cosas que ya saben de su propia casa
- [Disponibilidad ≠ seguridad](availability-vs-security-language.md) — no usar "harden/mitigar/ataque" para una caída; decir "redundancia/failover"

## Cómo diagnosticar

- [Pasos anclados en la infra documentada](steps-grounded-in-documented-infra.md) — nombrar el servidor/grupo AD real, nunca boilerplate; contrato de salida en `core/rules.md`
- [Separar evidencia de patrón](separate-evidence-from-pattern.md) — decir qué se observó, qué se infirió y qué se recuerda sin verificar; nombrar la alternativa benigna
- [Deferir ante evidencia de consola](defer-to-direct-console-evidence.md) — caso HEF01: refuté por inferencia el diagnóstico de conet y su upgrade de firmware era el arreglo
- [No inventar rutas de portales](dont-invent-portal-navigation.md) — verificar en la doc o pedir captura; un deep link que va a Home = falta de permiso, no URL mala
- [Diagnóstico de endpoint sin Live Response](maswer-diagnostico-endpoint-sin-live-response.md) — mapa de consolas: qué se lee sin tocar el equipo, qué no está licenciado, y la única vía para ejecutar código
- [Nada de sesiones remotas a usuarios finales](no-remote-sessions-endusers.md) — no funcionan por UAC; ir por rutas server-side
- [Preferir el autotest de admin](prefer-admin-self-test.md) — autoconcederse acceso temporal y probarlo él, no encaminar la prueba por el usuario
- [Probar el token sin cerrar sesión](test-token-refresh-without-logoff.md) — `klist purge` + nombre corto del servidor; revocar exige `Close-SmbSession`

## Infraestructura de Maswer

- [Dominio y OUs de AD](maswer-ad-domain-infra.md) — `intern.maswer.com`, DC `MDERZADC003`, Entra híbrido, mapa de unidades de red
- [Inventario de servidores](maswer-servers-inventory.md) — flota on-prem + Azure y la tabla **tarea → servidor**; ⚠️ `MEUAZEX001` NO tiene Exchange pese a la etiqueta
- [Topología de red](maswer-network-topology.md) — WAN completa: hub RZ FFM, sedes DE/ES/MX/US, Azure, convención de nombres de firewall
- [Acceso por grupos de seguridad AD](maswer-access-via-ad-security-groups.md) — carpetas = pertenencia a grupos `Masw*/Nexpro*` `_R/_RW`, no ACLs; el técnico los gestiona él
- [Admin local por tiers adm1/adm2](maswer-local-admin-tiering-adm1-adm2.md) — el admin de flota **ya existe** por GPO; el bloqueo de UAC era el deny de logon de `adm1` en clientes, no falta de permisos
- [Replicación de los DCs de Azure](maswer-replicacion-dcs-azure-altas.md) — replican en cadena; `Sync-ADObject` antes del Delta o el alta no llega a M365
- [Servidor AAD Connect](maswer-aad-connect-server.md) — `MEUAZAC011`; **PTA, no PHS** (las contraseñas nunca sincronizan); error crónico de Export ya identificado
- [Exchange híbrido](maswer-exchange-hybrid.md) — nombre/alias masterizados en el AD on-prem, no editables en M365
- [VPN Sophos](maswer-vpn-sophos.md) — SSL VPN; Central solo lista 3 firewalls: el gateway EU `108.142.212.203` **no está enrolado**
- [Runbook S2S Vaihingen](maswer-vaihingen-s2s-vpn-runbook.md) — caída total de la sede = túnel `S2S_Vaihingen` caído; bounce para recuperar, sin failover
- [Backup de M365](maswer-m365-backup.md) — Hornetsecurity/Altaro 365 Total Backup; activo, pero consola y operador SIN confirmar
- [Licencias Copilot](maswer-m365-copilot-licensing.md) — base **Microsoft 365 Business** (218 puestos) → Copilot Business SÍ aplica; reseller = conet (Patrick Kuhlmann), no ADN
- [Altas: contraseña sin caducidad](maswer-altas-password-no-expira.md) — nunca forzar cambio en el primer login; PTA sin writeback lo bloquea
- [MEUAZAC011 sin disco](meuazac011-disco-c-insuficiente.md) — C: 29,4 GB / 0,5 libres: causa de las LCU que fallaban con `0x80246007`; limpiar lo desbloqueó (sep-2026), ampliar sigue siendo de conet
- [Ventana de mantenimiento a fin de mes](maswer-ventana-mantenimiento-fin-de-mes.md) — el parcheo mensual va en una sola ventana; a mitad de mes un host sin CU está programado, no atrasado
- [Reiniciar ADSync alerta a Defender](adsync-restart-triggers-defender-alert.md) — "Entra Connect Sync tampering" (benigno); avisar antes y notificar a conet
- [Acceso remoto ad-hoc](remote-access-teamviewer-fails-fallback-anydesk.md) — TeamViewer falla → AnyDesk; objetivo: estandarizar una herramienta licenciada

## Proveedores, contactos y casos

- [conet.de administra la infra](conet-de-administers-maswer-infra.md) — empresa externa (NO CoolNetworks); servidores + reseller CSP; **es el "N2 Systems" real**
- [WingWing = desarrollo](wingwing-dev-provider.md) — proveedor de desarrollo de software de Maswer
- [STarkis = STAkis Profi / STAHLGRUBER](starkis-external-vendor-calden.md) — app de tercero en Calden; se abre caso con el fabricante, no escalación interna
- [Contactos de Calden](maswer-calden-contacts.md) — Vincenzo = solicitante; Joachim no técnico, vía Vincenzo; Jan Lukas directo
- [Oliver se fue sin traspaso](oliver-left-maswer-no-handover.md) — no contactarle; el usuario asume su rol; faltan derechos de admin local en la flota
- [Cuentas admin de Oliver aún habilitadas](oliver-orth-admin-accounts-still-enabled.md) — 4 cuentas `*OOrth` activas con Domain Admin efectivo; exposición abierta
- [Bajas: deshabilitar y retener, nunca borrar](leaver-accounts-disable-not-delete.md) — fecha de corte para que el cliente decida; el silencio no es aprobación
- [OORTH = portátil heredado](oorth-portatil-heredado-stefanie-zimmermann.md) — el equipo de Stefanie Zimmermann nunca se reconstruyó ni renombró; sustitución pedida
- [Buzón "Info" bilingüe DE/ES](maswer-info-mailbox-bilingual-de-es.md) — el equipo ES no habla EN/DE; locale se queda en es-ES, el arreglo por usuario es Favoritos
- [Estructura de Freshworks](freshworks-entity-structure.md) — un portal compartido, agrupaciones por empresa, ES primario + EN/DE soportados
- [Informe ejecutivo de Freshdesk = Artifact](informe-ejecutivo-freshdesk-formato-artifact.md) — molde pirámide/MBB publicado en claude.ai, no `.docx`; URL del trimestre jun-ago 2026
