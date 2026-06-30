# Maswer — Recuperación de accesos (post-Oliver)

**Responsable:** Sebastian Lazarte Castellón (CoolNetworks — IT de Maswer)
**Abierto:** 23-jun-2026
**Última actualización:** 30-jun-2026
**Estado:** EN CURSO — diagnóstico cerrado; pendiente enviar solicitud a conet.de
**Contacto conet.de:** Kevin Pütz-Kurth — `KPuetz-Kurth@conet.de`

---

## Problema de raíz

Oliver Orth dejó Maswer con una **transición incompleta**. Cada vez que una tarea necesita privilegios (admin local para elevar, propiedad de carpetas, cuentas de servicio…) reaparece la dependencia de Oliver. No es sostenible y, además, es un **riesgo de seguridad**: un ex-empleado que probablemente aún conoce o retiene credenciales privilegiadas activas (en particular la `localadmin` compartida).

**Objetivo:** dejar de depender de Oliver. Que todo el acceso privilegiado quede bajo control del técnico actual, provisionándolo y/o rotándolo vía **conet.de** (administra la infra de Maswer).

## Dos frentes

1. **Continuidad — recuperar control:** conseguir que el técnico pueda elevar/instalar en cualquier equipo sin bloquearse.
2. **Seguridad — offboarding:** rotar/revocar todo lo que Oliver conocía o poseía (admin de dominio, `localadmin`, cuentas de servicio). Práctica estándar cuando sale un administrador.

---

## Diagnóstico realizado (jun-2026) — qué encontramos

Recorrido con `whoami /groups`, `Get-LocalGroupMember` y `gpresult /r` (elevado) sobre el equipo del técnico (`MESZAZCLI21478`):

**Infraestructura (ver [[maswer-ad-domain-infra]]):**
- Dominio `intern.maswer.com` (NetBIOS `MASWER`), DC `MDERZADC003`. Entorno **híbrido Entra/Office365** (GPO Seamless SSO, grupos Azure/MFA) → **Intune viable** para desplegar software.
- Mapa de unidades por GPO `Laufwerk-*`, **filtradas por grupo de seguridad** (DE recibe P=MaswerAG, O=Intranet, R=SpainSL, M=NEXPRO; denegadas las de otras entidades).

**Hallazgo 1 — Acceso a carpetas/recursos = grupos de AD, NO ACLs** (ver [[maswer-access-via-ad-security-groups]]):
- El token del técnico incluye `MaswDEAG_Schulungsliste_RW`, `MaswDEAG_Profi_Cash_RW`, `NexproES_Accounting_RW`, etc. Para conceder acceso a una carpeta se **añade al usuario al grupo `*_R/_RW`**, no se edita la pestaña Seguridad.
- **Resuelve Schulungsliste y HR sin tocar ACLs.** Schulungsliste **cerrado** (usuarios confirmaron acceso) → [drafts/2026-06-18_maswer_schulungsliste-folder-access.md](drafts/2026-06-18_maswer_schulungsliste-folder-access.md).

**Hallazgo 2 — Admin local en endpoints NO está gestionado por GPO** (el bloqueo real):
- `gpresult /r` (config de EQUIPO) confirma que **NO existe ninguna GPO de Grupos restringidos / Usuarios y grupos locales**. El admin local del técnico se puso **a mano en su propio equipo**.
- Por tanto en las máquinas de **otros usuarios el técnico casi seguro NO es admin** → STAkis y Chrome se bloquean ahí, y **no hay mecanismo que lo arregle solo**.
- `MASWER\localadmin` ni siquiera figura en Administradores local → de ahí el **error 1385** (no es contraseña mala, es la cuenta equivocada).
- El equipo está en `CN=Computers` (contenedor por defecto), **no** en una OU gestionada → una GPO enlazada a OU no lo alcanzaría.

---

## Inventario de accesos (actualizado)

| Área | ¿Lo controla el técnico? | Vía de recuperación | Estado |
|---|---|---|---|
| Acceso a carpetas/recursos (Schulungsliste, HR…) | Sí, vía grupos AD `Masw*_RW` | Añadir usuarios al grupo. *(Falta confirmar si puede `Add-ADGroupMember` o requiere delegación)* | **Schulungsliste cerrado**; modelo resuelto |
| Admin local / UAC en máquinas de OTROS (STAkis, Chrome) | **No** — sin GPO de admin; `localadmin` da error 1385 | conet: GPO de Grupos restringidos que añada `adm1-Administrators` a Administradores local de las workstations | Abierto → conet |
| Equipos en `CN=Computers` (no en OU gestionada) | — | conet: enlazar bien la GPO o mover equipos a OU de Workstations | Abierto → conet |
| Cuenta `localadmin` compartida (la conocía Oliver) | Riesgo | conet: reemplazar por **LAPS** (contraseña única por máquina, rotada) | Abierto → conet |
| Despliegue de software estándar (Chrome) | No estandarizado | Desplegar **Chrome Enterprise MSI** por Intune/GPO, no máquina por máquina | Abierto |
| Offboarding de Oliver (admin dominio, service accounts) | — | conet: rotar/revocar. **Deshabilitar, no borrar** + periodo de gracia | Abierto → conet |

---

## Correo a conet.de (Kevin Pütz-Kurth) — versión humilde y acotada

**Enfoque:** primer contacto. Lidera con el bloqueo real + una **pregunta** ("¿cómo está pensado que IT eleve?"), NO con exigencias técnicas. No prescribe a conet cómo configurar su AD; los temas de seguridad se **plantean para que ellos valoren**, no se ordenan. **En inglés** (el técnico no maneja alemán — [[user-does-not-speak-german-use-english]]).

```
To: Pütz-Kurth, Kevin <KPuetz-Kurth@conet.de>
Cc: Vincenzo Valle <vincenzo.valle@maswer.com>
Subject: Maswer AG — how should IT handle software installs? (quick call?)

Hello Mr. Pütz-Kurth,

I've recently taken over IT support for Maswer AG (CoolNetworks) after Oliver
Orth left, and I'm still filling in some gaps from the handover. I could use
your guidance on one thing that's blocking me.

When I work on a user's machine remotely, I can't elevate to install software —
a STAkis install and a Chrome install are both stuck right now. On my own
machine I'm a local admin and everything works, but on other users' machines
I'm not, and MASWER\localadmin doesn't work either (it returns "logon type not
granted", error 1385).

So my main question is: how is IT meant to do installs / elevate on the
workstations here? Is there an admin account I should be using that I wasn't
handed in the transition, or does my access need to be set up for that?

Two smaller things, only if you think they're worth it — no rush:
- "localadmin" looks like it may be a shared account, and some of the
  credentials Oliver had might still be active. Flagging it in case it's worth
  reviewing on your side.
- A short overview of the privileged accounts and how access is set up would
  help me not to come back with the same question each time.

Could we do a short call (15–20 min) so you can point me in the right
direction? Just let me know a couple of slots that suit you.

Thank you and best regards,
Sebastian Lazarte
CoolNetworks — IT support for Maswer AG
```

---

## Por qué pido cada cosa (guía para mí)

Esto es para que yo entienda el "porqué" de cada punto del correo y pueda defenderlo en la llamada — y para tener claro qué es necesario de verdad y qué no debo exigir.

### 1. Pregunta principal: "¿cómo eleva IT en las máquinas?" — NECESARIO

**Qué pido:** que me digan cómo se supone que hago instalaciones en los equipos de los usuarios (¿una cuenta admin que debo usar? ¿hay que configurarme el acceso?).

**Por qué:** es mi **bloqueo real y diario**. STAkis y Chrome están parados porque no puedo elevar el UAC en máquinas que no son la mía. Lo confirmé técnicamente: en mi token soy admin solo en mi equipo, `gpresult` muestra que **no hay GPO** que reparta admin local a la flota, y `localadmin` falla con error 1385 (ni siquiera es admin ahí). O sea: no es que no sepa hacerlo, es que **no tengo el permiso en esas máquinas**.

**Por qué lo pregunto en vez de exigir una GPO:** porque **quizá ya existe una forma** (p. ej. una cuenta admin de dominio que IT usa para elevar) y simplemente no me la dieron en la transición. Vi `MASWER\admin` como admin en mi equipo — podría ser justo eso. Si exijo "creen una GPO de Grupos restringidos con el grupo X" le estoy diciendo al dueño de la infra cómo configurar su AD, con información que no tengo completa. Describir el problema y dejar que ellos elijan la solución es más correcto y evita meter la pata.

### 2. Observación: `localadmin` compartida + credenciales de Oliver — LO PLANTEO, NO LO ORDENO

**Qué pido:** solo **señalo** que `localadmin` parece compartida y que lo que sabía Oliver puede seguir activo, por si conviene revisarlo.

**Por qué importa:** una cuenta admin local con la **misma contraseña en todas las máquinas** es un riesgo de movimiento lateral (si se filtra, es admin en toda la flota), y un ex-administrador que aún conoce credenciales activas es el agujero clásico de un offboarding incompleto. La buena práctica sería rotarlas y, a futuro, **LAPS** (contraseña única por máquina, rotada automáticamente).

**Por qué NO lo exijo:** rotar admin de dominio o deshabilitar las cuentas de Oliver es una acción gorda que puede **romper cosas** (servicios/tareas que corran bajo esas cuentas) y, sobre todo, **no es mi decisión** — la autorizan Maswer (Vincenzo) y conet. Si lo ordeno y algo se cae, el problema es mío. Por eso lo dejo como preocupación para que **ellos** decidan el cómo y el cuándo (y si se hace: deshabilitar antes que borrar, con periodo de gracia).

### 3. Pedido menor: overview de cuentas privilegiadas — ÚTIL Y DE BAJO RIESGO

**Qué pido:** una lista corta de qué cuentas privilegiadas existen y para qué se usan.

**Por qué:** para **dejar de descubrir la infra ticket a ticket**. Cada caso (HR, Schulungsliste, STAkis) me destapó una pieza nueva. Tener el mapa de una vez me hace autónomo y evito volver a molestar a conet con la misma pregunta. Es solo información, no toca nada, así que es de bajo riesgo pedirlo.

### Lo que NO pido (y por qué lo dejé fuera)

- **No prescribo la GPO de Grupos restringidos ni nombro `adm1-Administrators`:** no sé con certeza qué es ese grupo ni si es el correcto; prescribir a ciegas sobre el AD de otro es arriesgado. (Sí lo tengo anotado como *hipótesis* en el inventario, para la conversación técnica.)
- **No pido LAPS como requisito:** es buena práctica pero no me bloquea hoy; es decisión de infraestructura de conet. Lo dejo implícito en la observación de seguridad.
- **No pido despliegue central de Chrome (Intune):** una vez pueda elevar, instalo Chrome a mano sin problema. Montar despliegue central es un proyecto aparte; lo guardo para más adelante.

---

## Guion para la reunión / call con Kevin

Mismo tono que el correo: **mostrar el problema y preguntar**, no llegar con exigencias. Conet es el dueño de la infra; yo describo el bloqueo y ellos eligen la solución.

1. **Encuadre (30s):** nuevo responsable de IT de Maswer (CoolNetworks), reemplazas a Oliver; Vincenzo Valle (en CC) respalda la autorización.
2. **Muestra la evidencia (no para presumir, para que él diagnostique rápido):** captura del **error 1385** con `localadmin`; soy admin solo en mi equipo; `gpresult` (config de EQUIPO) **sin** GPO de Grupos restringidos; equipo en `CN=Computers`.
3. **Pregunta abierta:** "¿Cómo está pensado que IT eleve/instale en las máquinas? ¿Hay una cuenta que deba usar o hay que configurar mi acceso?" Deja que él proponga el cómo. *(Para mí: si menciona Grupos restringidos / una cuenta admin de dominio, encaja con lo que vi — `adm1-Administrators`, `MASWER\admin` — pero no lo impongo yo.)*
4. **Plantea la seguridad como observación, no como orden:** "`localadmin` parece compartida y lo de Oliver puede seguir activo — ¿conviene revisarlo?" Si ellos deciden rotar/offboarding: sugerir **deshabilitar antes que borrar** y periodo de gracia, pero el cómo/cuándo lo deciden Maswer + conet.
5. **Verificación en vivo:** cuando me den el acceso, conectarme por remoto a la máquina de **otro** usuario y probar elevar el UAC. Si funciona, STAkis/Chrome resueltos.
6. **Cierre útil:** pedir (suave) el overview de cuentas privilegiadas para no volver con la misma pregunta.

---

## Próximos pasos

1. **Enviar el correo de arriba a Kevin Pütz-Kurth** (CC Vincenzo Valle).
2. *(Opcional, confirmación 100%)* conectarse a una máquina de otro usuario y correr `Get-LocalGroupMember -SID S-1-5-32-544` para verificar que el técnico no es admin ahí.
3. Tras la GPO de conet: verificar elevación en remoto y **cerrar STAkis** → [drafts/2026-06-23_stakis-access-install.md](drafts/2026-06-23_stakis-access-install.md). Crear el caso de Chrome si no existe.
4. Confirmar si el técnico puede gestionar los grupos `Masw*_RW` (`Add-ADGroupMember`) o si conet debe delegar ese control.
5. Cerrar cada entrada del inventario cuando el acceso quede bajo control del técnico (y la credencial que conocía Oliver, rotada).

## Casos relacionados

- **Schulungsliste** (acceso por grupo AD) — CERRADO → [drafts/2026-06-18_maswer_schulungsliste-folder-access.md](drafts/2026-06-18_maswer_schulungsliste-folder-access.md)
- **HR folder** (acceso por grupo AD) — cerrado por confirmación → [drafts/2026-06-10_maswer_hr-folder-access.md](drafts/2026-06-10_maswer_hr-folder-access.md)
- **STAkis** (bloqueado por admin local) — ABIERTO → [drafts/2026-06-23_stakis-access-install.md](drafts/2026-06-23_stakis-access-install.md)
