---
name: oliver-left-maswer-no-handover
description: Oliver Orth left Maswer with an incomplete access handover. Do NOT contact him. The user now owns Maswer IT; recover admin access via the user's own creds or conet.de.
metadata:
  type: project
---

Oliver Orth **ya no trabaja en Maswer**. La transición no fue buena: no transfirió todos los accesos, en particular las cuentas con permiso de administrador que se usaban para elevar instalaciones / cambios de sistema en los equipos Maswer (UAC). Ese rol **es ahora trabajo del usuario**.

**Why:** El usuario lo dijo directamente: "es mi trabajo ahora, él debería haberme dado todos los accesos porque ya no trabaja en Maswer... la idea es ya no molestar a Oliver." Esto **anula** la suposición anterior (memoria previa `oliver-owns-admin-install-accounts`) de que Oliver era el gatekeeper al que se le pedían credenciales/procedimientos.

**Alcance real del hueco (importante):** en **su propia máquina el usuario SÍ puede instalar todo** (es admin local ahí). El bloqueo aparece solo cuando trabaja sobre **las máquinas de OTROS usuarios de Maswer** (p. ej. el portátil del solicitante de STAkis), donde su cuenta no está en el grupo Administradores local y el UAC lo frena. Por tanto lo que falta no es "una cuenta admin" genérica, sino **derechos de admin local que apliquen a todos los endpoints del dominio MASWER** (cuenta de dominio en el grupo Administradores local de los equipos, vía GPO/Restricted Groups, o Domain Admin).

**Confirmado por `gpresult /r` (jun-2026):** en la config de EQUIPO **NO existe ninguna GPO de Grupos restringidos / Usuarios y grupos locales**. Es decir, el admin local del técnico se puso **a mano en su propio equipo**, no hay nada que lo empuje a la flota → en las máquinas de OTROS usuarios casi seguro **no es admin**, y por eso STAkis/Chrome se bloquean ahí. La cuenta `MASWER\localadmin` ni siquiera aparece en Administradores local (de ahí el error 1385). Ver [[maswer-ad-domain-infra]].

**How to apply:**
- **No escalar a Oliver ni redactar correos pidiéndole credenciales o procedimientos.** Está fuera de Maswer.
- Cuando una tarea requiera elevar (UAC, instalaciones, cambios de sistema) en el equipo de **otro** usuario de Maswer, el camino es provisionar vía **conet.de** una cuenta de dominio con admin local en los endpoints — ver [[conet-de-administers-maswer-infra]]. (Si fuera en la propia máquina del usuario, no hay bloqueo.)
- **Pedido concreto a conet (con evidencia):** (1) crear GPO de Grupos restringidos / GPP que añada el grupo de admin (`adm1-Administrators`) a Administradores local de todas las workstations; (2) ojo: los equipos están en `CN=Computers` (contenedor por defecto), una GPO enlazada a OU no los alcanza → enlazar bien o mover a una OU gestionada; (3) **LAPS** para reemplazar la `localadmin` compartida que conocía Oliver.
- Relacionado con [[user-is-whole-it-stack]]: el usuario ahora también cubre lo que hacía Oliver en Maswer.
- Caso que destapó esto: instalación de STAkis (`KWB_STAKIS_NET_CLIENT.EXE`) bloqueada en el UAC; `MASWER\localadmin` falla con error 1385 (logon type no concedido).
