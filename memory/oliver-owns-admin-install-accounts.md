---
name: oliver-owns-admin-install-accounts
description: Oliver is the person who manages the special accounts with admin rights used to install software on machines
metadata:
  type: project
---

Oliver maneja las cuentas especiales con permiso de administrador que se usan para instalar software en las máquinas (ej: instalar Visio cuando el usuario no es admin local y el UAC pide credenciales de admin).

**Why:** El usuario (técnico) no tiene/no conoce las credenciales admin propias para elevar instalaciones; Oliver es el dueño/gatekeeper de esas cuentas.

**How to apply:** Cuando una tarea requiera credenciales de admin local/dominio para elevar (UAC, instalaciones, cambios de sistema), el camino es pedírselas a Oliver. Relacionado con [[user-is-whole-it-stack]] — para temas que requieren privilegios que el usuario no posee, Oliver es la dependencia.
