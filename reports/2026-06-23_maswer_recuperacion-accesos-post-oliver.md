# Maswer — Recuperación de accesos (post-Oliver)

**Responsable:** Sebastian Lazarte Castellón (CoolNetworks — IT de Maswer)
**Abierto:** 23-jun-2026
**Estado:** EN CURSO — inventario vivo

---

## Problema de raíz

Oliver Orth dejó Maswer con una **transición incompleta**. Cada vez que una tarea necesita privilegios (admin local/dominio, dueño de carpetas, cuentas de servicio…) reaparece la dependencia de Oliver. No es sostenible y, además, es un **riesgo de seguridad**: un ex-empleado que probablemente aún conoce o retiene credenciales privilegiadas activas.

**Objetivo:** dejar de depender de Oliver. Que todo el acceso privilegiado quede bajo control del técnico actual, recuperándolo y/o rotándolo vía **conet.de** (administra la infra de Maswer).

## Dos frentes

1. **Continuidad — recuperar control:** conseguir las cuentas/permisos que el técnico no tiene hoy (para no bloquearse en cada install/permiso).
2. **Seguridad — offboarding:** rotar/revocar todo lo que Oliver conocía o poseía (contraseñas de admin de dominio, cuentas admin locales como `localadmin`, cuentas de servicio, propiedad de carpetas). Práctica estándar cuando sale un administrador.

---

## Inventario de accesos (vivo — se va llenando sobre la marcha)

| Área | Qué requiere privilegio | ¿Lo controla el técnico? | Vía de recuperación | Estado |
|---|---|---|---|---|
| Admin local / UAC en endpoints | Instalar software (STAkis, Visio…) | **No** — `MASWER\localadmin` da error 1385 | conet.de: cuenta admin de dominio operativa **o** añadir la cuenta del técnico al grupo Administradores local (GPO) | Abierto |
| Propiedad de carpetas (Besitzer) en servidor | ACLs de carpetas (HR, Schulungsliste) | Parcial — Oliver figuraba como owner | conet.de: reasignar owner / dar acceso a la pestaña Seguridad | Abierto |
| Cuenta `localadmin` (MASWER) | — | Desconocido | Rotar contraseña (la conocía Oliver) | Abierto |
| _(añadir según aparezcan)_ | | | | |

---

## Acción de raíz: solicitud a conet.de

Resuelve STAkis y todos los casos futuros de un golpe, en vez de ir tarea por tarea.

```
To: [conet.de contact]
Cc: Vincenzo Valle <vincenzo.valle@maswer.com>
Subject: Maswer — privileged access handover after Oliver Orth's departure (provisioning + rotation)

Hi [Name],

I've taken over IT for Maswer after Oliver Orth left, and the handover left
gaps on the privileged-access side. Right now every task that needs elevation
ends up blocked on access Oliver used to hold — for example installing software
(STAkis won't elevate: MASWER\localadmin returns "logon type not granted",
error 1385) and changing folder permissions (HR / Schulungsliste, where Oliver
was listed as owner). I'd like to fix this at the root so it stops recurring.

Could you help with the following?

1. Provisioning — set me up with a domain admin account of my own (or add my
   account to the admin groups needed) so I can handle installs and system
   changes on Maswer devices and servers myself, without depending on anyone.
2. Security / offboarding — rotate and revoke the privileged credentials Oliver
   held or knew: domain admin accounts, the local admin accounts on the
   workstations (e.g. localadmin), and any service accounts. Standard practice
   when an admin leaves.
3. Folder ownership — reassign ownership (Besitzer) of the shares that were
   under Oliver's account so I can manage the Security tab / ACLs (HR,
   Schulungsliste, and others as they come up).
4. Handover record — a short list of the privileged accounts and where they're
   used, so I'm not rediscovering this one ticket at a time.

This is currently blocking at least one user request (a STAkis install). Happy
to jump on a call to set it up quickly.

Thanks,
Sebastian Lazarte
CoolNetworks — IT for Maswer
```

---

## Próximos pasos

1. Identificar el contacto de **conet.de** y enviar la solicitud de arriba.
2. Ir registrando en la tabla **cada hueco que aparezca** ("esto requería Oliver").
3. Cerrar cada entrada cuando el acceso quede bajo control del técnico (y la credencial que conocía Oliver, rotada).
4. Caso inmediato bloqueado por esto: **STAkis** → ver [drafts/2026-06-23_stakis-access-install.md](drafts/2026-06-23_stakis-access-install.md).
