---
name: oliver-left-maswer-no-handover
description: Oliver Orth left Maswer with an incomplete access handover. Do NOT contact him. The user now owns Maswer IT; recover admin access via the user's own creds or conet.de.
metadata:
  type: project
---

Oliver Orth **ya no trabaja en Maswer**. La transición no fue buena: no transfirió todos los accesos, en particular las cuentas con permiso de administrador que se usaban para elevar instalaciones / cambios de sistema en los equipos Maswer (UAC). Ese rol **es ahora trabajo del usuario**.

**Why:** El usuario lo dijo directamente: "es mi trabajo ahora, él debería haberme dado todos los accesos porque ya no trabaja en Maswer... la idea es ya no molestar a Oliver." Esto **anula** la suposición anterior (memoria previa `oliver-owns-admin-install-accounts`) de que Oliver era el gatekeeper al que se le pedían credenciales/procedimientos.

**How to apply:**
- **No escalar a Oliver ni redactar correos pidiéndole credenciales o procedimientos.** Está fuera de Maswer.
- Cuando una tarea requiera admin local/dominio para elevar (UAC, instalaciones, cambios de sistema) en equipos Maswer, el camino es: (1) una cuenta admin que el **propio usuario** ya controle; (2) si no la tiene por la transición incompleta, recuperarla/provisionarla vía **conet.de**, que administra la infra de Maswer — ver [[conet-de-administers-maswer-infra]].
- Relacionado con [[user-is-whole-it-stack]]: el usuario ahora también cubre lo que hacía Oliver en Maswer.
- Caso que destapó esto: instalación de STAkis (`KWB_STAKIS_NET_CLIENT.EXE`) bloqueada en el UAC; `MASWER\localadmin` falla con error 1385 (logon type no concedido).
