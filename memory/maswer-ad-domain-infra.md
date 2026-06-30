---
name: maswer-ad-domain-infra
description: Maswer AD domain reference — domain intern.maswer.com (NetBIOS MASWER), DC MDERZADC003, hybrid Entra/Office365, OU + network-drive map. Use for any Maswer endpoint/AD task.
metadata:
  type: reference
---

Datos de infraestructura de Active Directory de Maswer (de `gpresult /r` en el equipo del técnico, jun-2026):

- **Dominio:** `intern.maswer.com` — NetBIOS `MASWER`. Nivel: Windows 2008 o posterior.
- **Controlador de dominio:** `MDERZADC003.intern.maswer.com`.
- **Entorno híbrido:** OU raíz `Office365`, GPO `Seamless Single Sign On`, grupos `MFA-MASWER` / `AzureFiles-Administrators` → Entra/Azure AD híbrido. Sugiere que **Intune** es viable para desplegar software (p. ej. Chrome Enterprise MSI).
- **Estructura de OUs de usuarios:** `OU=<sitio>,OU=<país>,OU=User Accounts,OU=Office365` (ej. la cuenta del técnico: `OU=HEF,OU=DE,...`).
- **Equipos:** al menos el equipo del técnico está en el contenedor por defecto `CN=Computers` (NO en una OU gestionada de Workstations). Importante: las GPO enlazadas a OUs **no** llegan a `CN=Computers`, solo las de nivel dominio.

**Mapa de unidades de red (por GPO `Laufwerk-*`, filtradas por grupo de seguridad / entidad):**
- Recibidas por el técnico (DE): **P**=MaswerAG · **O**=Intranet · **R**=SpainSL · **M**=NEXPRO
- Denegadas por seguridad (otras entidades): W=Zaragoza · V=Taller · T=Mexico · Q=MaswerGmbH · S=MontajesSL · Z=MaswerTestDrive · U=USA

Las unidades se mapean por **User Configuration** (según OU/grupo del usuario), por eso aplican aunque el equipo esté en `CN=Computers`. Refuerza el modelo de acceso por grupo — ver [[maswer-access-via-ad-security-groups]] y [[freshworks-entity-structure]].
