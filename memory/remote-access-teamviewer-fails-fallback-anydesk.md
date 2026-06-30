---
name: remote-access-teamviewer-fails-fallback-anydesk
description: Remote support tooling on Maswer is ad-hoc — TeamViewer sometimes fails so the user falls back to telling users to install AnyDesk. Goal is to standardize on one licensed tool.
metadata:
  type: project
---

Para dar soporte remoto a los equipos de Maswer (instalar STAkis, elevar UAC en máquinas de otros, etc.) el usuario usa **TeamViewer**, pero **a veces no funciona** y termina pidiéndole al usuario que instale **AnyDesk** como alternativa. Es un flujo improvisado, ticket a ticket, no estandarizado.

**Why:** El usuario lo reportó directo. Importa porque sin acceso remoto fiable no puede ejecutar las instalaciones/elevaciones en las máquinas de otros usuarios — es la otra mitad del problema de acceso junto con los derechos de admin ([[oliver-left-maswer-no-handover]]).

**Causa típica probable (a confirmar):** TeamViewer gratuito detecta "uso comercial" y limita/corta sesiones; también versiones distintas o bloqueo de firewall. La rotación TeamViewer→AnyDesk evita el síntoma pero no la raíz.

**How to apply:**
- Objetivo: **estandarizar en UNA herramienta licenciada** con acceso desatendido (unattended) desplegada igual en todos los endpoints, en vez de improvisar.
- El despliegue masivo (GPO/script) en Maswer pasa por **conet.de** ([[conet-de-administers-maswer-infra]]) — encadenarlo con la petición de admin a Kevin Pütz-Kurth.
- Comunicación con el usuario final sobre instalar AnyDesk → en inglés ([[user-does-not-speak-german-use-english]]).
