# Maswer — SharePoint: cómo ver quién tiene acceso a un sitio o carpeta sensible (guía replicable)

**Responsable:** Sebastian Lazarte Castellón (CoolNetworks — IT de Maswer)
**Fecha:** 02-jul-2026
**Propósito:** dejar documentada la ruta exacta para consultar quién tiene acceso a un sitio de SharePoint o a una carpeta/archivo sensible, y cómo auditarlo. Para poder replicarlo sin volver a buscarlo.

> Nota de método: basado en las rutas estándar de Microsoft 365 (estables). Las partes marcadas con ⚠️ conviene confirmarlas contra el tenant real de Maswer la primera vez que se abran.

---

## 0. Datos del entorno
- **Tenant:** Maswer (Microsoft 365).
- **Consolas usadas:**
  - **Admin de SharePoint** — `https://admin.microsoft.com` → SharePoint (o directo `https://<tenant>-admin.sharepoint.com`).
  - **El sitio de SharePoint** concreto (nivel usuario) para permisos de carpeta/archivo.
  - **Microsoft Purview** — `https://purview.microsoft.com` para auditoría a escala.
  - **Entra ID** — `https://entra.microsoft.com` para ver miembros de grupos que dan acceso.

---

## 1. Las CUATRO capas donde vive un "acceso" (no confundirlas)
| Capa | Qué controla | Dónde se ve |
|---|---|---|
| **Sitio** (Site) | Owners / Members / Visitors del sitio entero | Admin de SharePoint o ⚙️ del sitio |
| **Biblioteca / Carpeta / Archivo** | Permiso "roto" de la herencia (acceso sensible) | En el propio elemento → *Administrar acceso* |
| **Grupo** (M365 / seguridad) | Muchos permisos se dan vía grupo, no persona | Entra ID → Grupos → Miembros |
| **Enlaces compartidos** | Acceso por link (interno/anónimo) | Elemento → *Administrar acceso* → pestaña Enlaces |

**Regla:** que un usuario "tenga acceso" puede venir por **pertenencia a un grupo** o por un **enlace compartido**, no solo por permiso directo. Hay que mirar las cuatro capas.

---

## 2. Ver quién tiene acceso a un SITIO entero

### 2a. Desde el propio sitio (rápido)
1. Abrir el sitio → engranaje ⚙️ (arriba dcha.) → **Site permissions** (Permisos del sitio).
2. Ver los grupos **Owners / Members / Visitors** y quién está en cada uno.
3. Para el detalle completo: **Advanced permissions settings** (Configuración avanzada de permisos) → lista todos los niveles y grupos de SharePoint.

### 2b. Visión global (todos los sitios)
1. `https://admin.microsoft.com` → **SharePoint admin center** → **Sites → Active sites**.
2. Abrir un sitio → pestaña **Permissions** → ver **Site admins / owners**.

---

## 3. Ver quién tiene acceso a una CARPETA o ARCHIVO sensible
1. En la biblioteca, seleccionar la **carpeta o archivo** → **⋮ (más)** → **Administrar acceso** (*Manage access*).
2. Pestañas:
   - **Acceso directo** (*Direct access*): personas/grupos con permiso directo, y si es Lectura o Edición.
   - **Enlaces** (*Links*): enlaces compartidos activos (con quién y de qué tipo — interno, anónimo, etc.).
3. Si el elemento tiene **herencia rota** (permiso especial "sensible"), aquí es donde se ve quién quedó con acceso propio distinto al del sitio.

> Para RH / carpetas sensibles concretas de Maswer, ver los casos previos:
> `2026-06-10_maswer_hr-folder-access.md` y `2026-06-18_maswer_schulungsliste-folder-access.md`.

---

## 4. Auditar accesos a escala (quién vio / compartió qué)
Cuando la pregunta no es "quién puede" sino "quién **accedió** o **compartió**":
1. `https://purview.microsoft.com` → **Audit** (Auditoría) → **Search**. ⚠️
2. Filtrar por **actividades**:
   - `FileAccessed` — quién abrió un archivo.
   - `SharingSet` / `SharingInvitationCreated` — quién concedió acceso.
   - `AnonymousLinkCreated` — se creó un enlace anónimo (bandera de riesgo).
3. Filtrar por **sitio/URL** y rango de fechas.

> La auditoría requiere que el **registro de auditoría esté activado** en el tenant y permisos adecuados (⚠️ confirmar rol: normalmente *Audit Reader* / *Compliance*).

---

## 5. Ver los miembros de un GRUPO que da acceso
Si el acceso viene de un grupo (lo más habitual en accesos "por rol"):
1. `https://entra.microsoft.com` → **Identity → Groups → All groups**.
2. Abrir el grupo (el que aparece en los permisos del sitio) → **Members**.
3. Así se ve qué personas heredan el acceso a través de ese grupo.

---

## 6. Resumen rápido (chuleta)
| Quiero ver… | Dónde |
|---|---|
| Quién administra/accede a un **sitio** | Sitio → ⚙️ **Site permissions** · o Admin SharePoint → Active sites → Permissions |
| Quién accede a una **carpeta/archivo** | Elemento → ⋮ → **Administrar acceso** → *Acceso directo* + *Enlaces* |
| Quién **abrió o compartió** algo | **Purview → Audit** (FileAccessed / SharingSet / AnonymousLinkCreated) |
| Quién hay dentro de un **grupo** de acceso | **Entra ID → Groups → Members** |

---

## 7. Notas y pendientes
- ⚠️ Confirmar en el tenant real: nombre de la **URL de admin** de SharePoint de Maswer y que el **registro de auditoría** (Purview) esté activo.
- Buenas prácticas al revisar accesos sensibles: mirar **las 4 capas** (sitio, elemento, grupo, enlaces); un usuario puede tener acceso sin permiso directo.
- Relacionado: la guía de **VPN Sophos** está en `2026-07-02_maswer_sophos-vpn-navegacion.md`; el **backup M365** en `maswer-m365-backup.md`.
