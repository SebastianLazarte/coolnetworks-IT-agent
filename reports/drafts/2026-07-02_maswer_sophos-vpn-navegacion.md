# Maswer — Sophos: cómo llegar a los usuarios y conexiones de la VPN (guía replicable)

**Responsable:** Sebastian Lazarte Castellón (CoolNetworks — IT de Maswer)
**Fecha:** 02-jul-2026
**Propósito:** dejar documentada la ruta exacta para consultar los usuarios con acceso VPN, quién está conectado y el histórico, dentro del entorno Sophos de Maswer. Para poder replicarlo sin volver a buscarlo.

---

## 0. Datos del entorno (confirmados 02-jul-2026)
- **Cliente / tenant:** Maswer AG.
- **VPN de acceso remoto:** **Sophos SSL VPN** (cliente **Sophos Connect**, tipo **SSL/TCP**).
- **Gateway al que conecta el cliente:** `108.142.212.203`.
- **Consola cloud:** **Sophos Central** (`https://central.sophos.com`) — gestiona endpoints, servidores y firewalls.
- **Firewalls gestionados en Central:** 4 (todos conectados y administrados).
- **Firewall de la VPN:** **XGSDEFRA01** (par HA `XGSDEFRA01-XGSDEFRA`).
- **Consola local del firewall (alternativa):** `https://<IP-del-firewall>:4444`.

> Credenciales de admin del firewall / Central: gestionadas por quien administra el appliance (posiblemente conet.de). Ver memoria `maswer-vpn-sophos.md`.

---

## 1. Las TRES consolas de Sophos (no confundirlas)
| Consola | Qué es | Para qué sirve aquí |
|---|---|---|
| **Sophos Central** | Portal cloud (Maswer AG) | Punto de entrada; desde aquí se salta al firewall |
| **Firewall Management** (dentro de Central) | Panel que agrupa los 4 firewalls | Elegir el firewall correcto y abrir su consola |
| **Consola SFOS del firewall** (XGSDEFRA01) | La consola del propio appliance | Aquí viven de verdad los usuarios y conexiones VPN |

**Regla:** los datos de VPN (usuarios, Live Users, logs) **NO** están en la "Configuración global" de Central. Están **dentro del firewall**.

---

## 2. Ruta de navegación completa (paso a paso)

1. **Sophos Central** → menú superior **Mis productos** → **Firewall Management**.
2. En **Firewall Management** → menú izquierdo **Firewalls** (o **"Mostrar todos los firewalls"**).
3. En la lista de los 4, seleccionar **XGSDEFRA01** (el de la VPN, gateway `108.142.212.203`).
4. Abrir la consola del dispositivo: botón **Administrar / Ver dispositivo** → se abre la **consola SFOS** por el túnel de Central.
5. Ya dentro del firewall (barra izquierda), según lo que quieras ver → ver §3.

---

## 3. Qué mirar dentro del firewall (SFOS)

### 3a. Quién tiene acceso VPN (permisos)
- **CONFIGURAR → VPN de acceso remoto** → pestaña **VPN SSL** (¡NO la de IPsec — Maswer usa SSL!).
- En cada política de SSL VPN, el campo **"Usuarios y grupos permitidos"** lista quién tiene acceso.
- Complemento: **CONFIGURAR → Autenticación** → **Usuarios / Grupos** para ver el detalle de cada usuario y su grupo.

> ⚠️ Error típico: entrar por la pestaña **IPsec** y verla vacía. La de Maswer es **VPN SSL**.

### 3b. Quién está conectado AHORA (tiempo real)
- **MONITORIZAR Y ANALIZAR → Actividades actuales** → **Usuarios activos / Remote Users (SSL VPN)**.
- Muestra cada usuario conectado con IP asignada, IP de origen y hora de conexión.

### 3c. Histórico (quién se conectó y cuándo)
- **MONITORIZAR Y ANALIZAR → Informes** → sección **VPN**, **o**
- **Visor de registros** (arriba a la derecha) filtrando por módulo **VPN / Autenticación**.

---

## 4. Resumen rápido (chuleta)
| Quiero ver… | Dónde |
|---|---|
| Quién **puede** usar la VPN | Firewall → CONFIGURAR → VPN de acceso remoto → **VPN SSL** → *Usuarios y grupos permitidos* |
| Quién está **conectado ahora** | Firewall → MONITORIZAR Y ANALIZAR → **Actividades actuales** |
| **Histórico** de conexiones | Firewall → **Informes** (VPN) o **Visor de registros** (filtro VPN) |
| Cómo llegar al firewall | Central → Mis productos → Firewall Management → Firewalls → **XGSDEFRA01** → Administrar |

---

## 5. Notas y pendientes
- La VPN **SSL** también se puede reconocer porque el cliente **Sophos Connect** conecta como **SSL/TCP** contra `108.142.212.203`.
- Para el **backup de M365 (Hornetsecurity/Altaro)** la ruta es distinta y está en `maswer-m365-backup.md` (consola de Hornetsecurity, aún por confirmar URL).
- Pendiente: confirmar credenciales de administración del firewall si no se dispone de ellas.
