# Reporte del caso — Maswer / Alta de Erik Esau Guillermo Valencia

- **Cliente:** Maswer México (site Puebla)
- **Usuario final:** Erik Esau Guillermo Valencia
- **Solicita:** Florencio Olguín (AGU) · CC: Andrea Muñoz (PBC)
- **Técnico:** Sebastian Lazarte Castellón (CoolNetworks)
- **Fecha:** 08-sep-2026
- **Estado:** **EN CURSO** — cuenta AD creada y replicada a los 4 DCs; pendiente sync + licencia

---

## Triaje

| Campo | Valor |
|---|---|
| Categoría | Accounts and Access (alta de usuario) |
| Prioridad | P3 - Media |
| Grupo | N1 |
| Escalado | No |

---

## Acción ejecutada — 08-sep-2026

Mismo procedimiento que el alta de `AQuijano` del mismo día
(ver `2026-09-08_maswer_alta-alex-quijano.md`), en
`OU=PBC,OU=MX,OU=User Accounts,OU=Office365,DC=intern,DC=maswer,DC=com` contra `MDERZADC003`.

| Atributo | Valor |
|---|---|
| `sAMAccountName` / UPN | `EGuillermo` / `EGuillermo@maswer.com` |
| `mail` | `erik.guillermo@maswer.com` |
| `mailNickname` | `EGuillermo` |
| `targetAddress` | `SMTP:EGuillermo@maswerag.onmicrosoft.com` |
| Exchange híbrido | RemoteUserMailbox (los 3 atributos `msExch*`) |
| País | `co=Mexico`, `c=MX`, `countryCode=484` |

- Grupos base del sitio, nada más. Contraseña sin caducidad, sin cambio obligatorio y dictable.
- `Sync-ADObject` a los 3 DCs restantes antes del sync. Replicación OK en los **4 DCs**.

---

## ⚠️ Interpretación del nombre — a confirmar con el cliente

`ERIK ESAU GUILLERMO VALENCIA` se partió como **2 nombres + 2 apellidos**
(*Erik Esau* / *Guillermo Valencia*), que es el patrón de todos los usuarios de PBC
(`Diego Enrique Muñoz Espinoza` → `DMunoz`, `Eduardo Isaac Ramirez Sanchez` → `ERamirez`).
De ahí `EGuillermo` y `erik.guillermo@maswer.com`.

**Si "Guillermo" fuera un tercer nombre** y el único apellido fuera *Valencia*, lo correcto sería
`EValencia` / `erik.valencia@maswer.com`. Cambiarlo **ahora es barato**; una vez asignada la
licencia y aprovisionado el buzón, ya no: el nombre y el alias se gobiernan en el AD on-prem
(ver `memory/maswer-exchange-hybrid.md`) y habría que rehacer direcciones.

**No confundir con `ELuna`** — *Erik Joel De Luna Gómez*, `erik.luna@maswer.com`, ya existente en
el dominio. Persona distinta, sin colisión.

---

## Pendiente

1. **Sync** en `MEUAZAC011`: `Start-ADSyncSyncCycle -PolicyType Delta`.
2. **Licencia** en M365. A día de hoy hay **tres altas seguidas sin licencia confirmada**:
   `LCervantes`, `AQuijano` y `EGuillermo`. Sin licencia no hay buzón, y el usuario lo reporta
   como "no puedo entrar al correo".
3. **Contraseña inicial** en la nota privada del ticket, nunca en el cuerpo del correo.
4. **Accesos del puesto:** solo los 5 grupos base. El ticket no dice qué función tiene ni a qué
   carpetas debe entrar.
