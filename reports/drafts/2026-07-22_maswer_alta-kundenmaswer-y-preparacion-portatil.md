# Caso — Alta de `kundenmaswer@maswer.com` y preparación del portátil de Oscar

- **Fecha:** 2026-07-22
- **Cliente / contacto:** Maswer — Miriam Juan (portal Freshworks, 22-jul-2026 10:52)
- **Ticket:** "Petición urgente: crear cuenta de correo kundenmaswer@maswer.com + preparar el portátil de Oscar"
- **Técnico:** Sebastian (IT-Support-Germany)
- **Categoría / Prioridad:** Accounts and Access + Request (equipo/software) · **P2** (fecha límite de negocio, un puesto sin operar)
- **SLA:** primera respuesta 1 h · resolución objetivo 8 h laborables
- **Grupo:** N1 (ejecución en infra Maswer) — con dos dependencias externas (ver Escalado)
- **Fecha comprometida por el cliente:** **viernes 24-jul-2026**, Miguel Champer se lleva el portátil

## Petición tal y como llega

1. Crear una cuenta de correo `kundenmaswer@maswer.com`.
2. Preparar el portátil que tenía Oscar con ese correo y dejarlo operativo **para otra persona**.
3. Con "todos los programas": WhatsApp, correo, Adobe, Excel, Word, "las apps de Maswer".
4. Importancia alta: entrega el viernes.

## Lectura del caso

Son **dos trabajos distintos** metidos en un ticket: un alta de identidad (rápida, remota,
controlada) y una **reasignación de equipo** (física, con dependencias que no controlamos).
El primero se puede cerrar hoy. El segundo es el que marca si llegamos al viernes.

Tres decisiones de fondo:

**1. `kundenmaswer` es una dirección funcional, no una persona.** "Kunden" = clientes.
Reproducir el patrón del caso MGeisz (una persona trabajando con la identidad de otra) es
exactamente lo que hay que evitar. El diseño correcto es: **cuenta de usuario nominal** para
la persona que recibe el portátil + **buzón compartido** `kundenmaswer@maswer.com` con acceso
Full Access / Send As. El buzón compartido **no consume licencia**; una cuenta de usuario sí.

**2. El portátil de Oscar no se "pasa", se reinstala.** Entregar el equipo con el perfil, la
sesión de correo y los datos de Oscar dentro es un problema de protección de datos, no un
atajo. El equipo se restablece y se entrega limpio, unido al dominio, con la cuenta nueva.

**3. "Todos los programas" no es un alcance.** Excel/Word salen de la licencia M365. Adobe y
"las apps de Maswer" son listas abiertas con coste y licencias detrás. Hay que cerrarlas hoy
o no se instalan a tiempo.

## Huecos que bloquean la ejecución (regla: no inventar información)

| # | Hueco | Por qué bloquea |
|---|---|---|
| 1 | **Nombre y apellidos de la persona** que recibe el portátil | Sin nombre no hay cuenta nominal ni UPN. ¿Es Miguel Champer el usuario final o solo quien lo recoge? |
| 2 | **Sede / entidad** (Maswer DE, Maswer ES, Nexpro) | Determina la OU en `intern.maswer.com` y qué grupos `Masw*`/`Nexpro*` aplican |
| 3 | **Licencia M365** para la cuenta nueva | Coste → aprobación del cliente. Sin licencia no hay buzón ni Office |
| 4 | **A qué carpetas/apps debe acceder** — nombre de un compañero equivalente | El acceso va por grupo de seguridad; se replica el perfil de alguien del mismo puesto |
| 5 | **Qué es "Adobe"** | Reader (gratis) vs Acrobat Pro / Creative Cloud (licencia de pago → Ventas) |
| 6 | **Qué son "las apps de Maswer"** | Lista abierta. Si incluye STAkis o ProfiCash, arrastran licencia de proveedor y bloqueo de admin local |
| 7 | **WhatsApp: ¿con qué número?** | WhatsApp Desktop se vincula a un teléfono. Si no hay número de empresa asignado, la app no se puede dejar operativa |
| 8 | **Dónde está físicamente el portátil** y quién lo tiene | El técnico trabaja en remoto; la reinstalación requiere el equipo en manos de IT |
| 9 | **Estado de la cuenta de Oscar** | Precedente MGeisz: cuentas de bajas que siguen habilitadas. Hay que comprobarlo y cerrarlo |

## Plan de ejecución

### Fase A — Identidad (remota, se puede cerrar hoy)

1. **Comprobar la cuenta de Oscar** en `MDERZADC003` (PowerShell AD elevada): estado, último
   inicio de sesión, grupos y buzón. Si es una baja, deshabilitar y documentar — no reutilizar
   el objeto para la persona nueva.

   ```powershell
   Get-ADUser -Filter "GivenName -like 'Oscar*' -or Name -like '*Oscar*'" `
     -Properties Enabled,LastLogonDate,memberOf,mail,DistinguishedName |
     Format-List Name,SamAccountName,Enabled,LastLogonDate,mail,DistinguishedName
   ```

2. **Verificar que `kundenmaswer@maswer.com` está libre** antes de tocar nada, en la Exchange
   Management Shell de `MEUAZEX001`:

   ```powershell
   Get-Recipient -ResultSize Unlimited -Filter "EmailAddresses -eq 'smtp:kundenmaswer@maswer.com'" |
     Format-List Name,PrimarySmtpAddress,RecipientTypeDetails
   ```

3. **Crear la cuenta nominal** de la persona en la OU de su sede en `intern.maswer.com`
   (`New-ADUser`, UPN `@maswer.com`, cambio de contraseña obligatorio en el primer inicio) y
   **replicar los grupos** del compañero de referencia — pertenencia a grupos `Masw*_R`/`_RW`,
   nunca ACL directa sobre la carpeta.

4. **Crear `kundenmaswer` como buzón compartido** en `MEUAZEX001` (Exchange híbrido: el buzón
   se gobierna desde on-prem, no desde M365), y conceder acceso a la persona nueva:

   ```powershell
   # Exchange Management Shell en MEUAZEX001
   New-RemoteMailbox -Shared -Name 'Kunden Maswer' -Alias 'kundenmaswer' `
     -UserPrincipalName 'kundenmaswer@maswer.com' -OnPremisesOrganizationalUnit '<OU de recursos>'
   ```

   > **A confirmar:** la OU destino de cuentas de recurso y si los permisos Full Access /
   > Send As se aplican desde Exchange Online una vez sincronizado el objeto. Comprobarlo antes
   > de la ventana, no durante.

5. **Forzar sincronización** en `MEUAZAC011`: `Start-ADSyncSyncCycle -PolicyType Delta`.
   Esperar al *Export* hacia `maswerag.onmicrosoft.com` — `Result: Success` solo indica que el
   ciclo arrancó. ⚠️ Si hubiera que reiniciar el servicio ADSync, dispara la alerta de Defender
   "Entra Connect Sync tampering" (benigna): avisar a conet.de antes.
6. **Asignar la licencia M365** a la cuenta nominal (el buzón compartido no lleva licencia) y
   verificar el buzón en el Exchange admin center tras el Export.
7. **Contraseña temporal por teléfono**, nunca por ticket ni por correo.

### Fase B — Portátil (presencial, es la ruta crítica)

1. **Recuperar el equipo** y comprobar antes de borrar nada: clave de recuperación BitLocker,
   registro del dispositivo en Entra/Defender, y si queda algo de Oscar que Maswer necesite
   conservar (el negocio decide qué se guarda; IT no decide eso solo).
2. **Restablecer Windows** y volver a unir al dominio. Entrega limpia, sin el perfil de Oscar.
3. **Instalar la base:** Office (Word/Excel con la licencia M365), Outlook configurado con la
   cuenta nominal + el buzón compartido `kundenmaswer@maswer.com`, navegador, antivirus/EDR.
4. **Instalar el resto según la lista cerrada** del punto 5-6 de huecos. Las instalaciones se
   hacen mientras el equipo está en manos de IT: en máquinas de otros usuarios el técnico
   **no** es admin local (bloqueo conocido desde la salida de Oliver; GPO pendiente con
   conet.de), y ahí una instalación como STAkis se queda parada en el UAC.
5. **Prueba de aceptación antes de entregar:** inicio de sesión con la cuenta nueva, envío y
   recepción desde la dirección `kundenmaswer@maswer.com`, acceso a las carpetas de red y
   apertura de cada aplicación de la lista.

## Riesgo sobre la fecha del viernes

| Trabajo | ¿Llega al viernes? |
|---|---|
| Cuenta nominal + buzón compartido + correo operativo | **Sí**, si hoy llegan nombre, sede y aprobación de licencia |
| Windows reinstalado + Office + correo + carpetas | **Sí**, si el portátil está en manos de IT como muy tarde el jueves |
| Adobe de pago / apps de proveedor (tipo STAkis) | **No garantizado** — dependen de licencia y de proveedor externo |
| WhatsApp | **Depende** de que exista un número de teléfono asignado a esa persona |

Lo honesto es comprometer el portátil operativo con correo, Office y carpetas para el viernes,
y tratar las aplicaciones de terceros como un segundo paso, sin bloquear la entrega.

## Escalado

**N1 con dos dependencias externas**, no escalado por complejidad técnica:

- **Cliente / Ventas:** aprobación de la licencia M365 y de cualquier Adobe de pago. Es una
  decisión de coste, no técnica.
- **conet.de (Kevin Pütz-Kurth):** solo si alguna instalación tiene que hacerse sobre un equipo
  donde el técnico no es admin local. Con el portátil recién reinstalado en manos de IT, no
  debería hacer falta.

**Hallazgo de higiene a registrar:** revisar el estado de la cuenta de Oscar y, de paso, del
resto de bajas. Es el segundo caso en un mes (MGeisz, 31-may) en que un equipo o una cuenta de
alguien que ya no está sigue en circulación.

## Respuesta preparada para Miriam (español)

```text
Hola Miriam,

Recibido. Lo tengo dividido en dos partes: la cuenta de correo, que puedo dejar lista
hoy mismo, y el portátil, que hay que reinstalar antes de entregarlo.

Te explico lo del portátil: el equipo de Oscar no se puede entregar tal cual, porque
lleva dentro su sesión y sus datos. Lo dejo como nuevo y lo entrego limpio, con el
correo y los programas ya puestos.

Para poder empezar necesito esto:

1. Nombre y apellidos de la persona que va a usar el portátil, y en qué sede trabaja.
   ¿Es Miguel Champer quien lo va a usar, o solo quien lo recoge?
2. El nombre de un compañero que tenga el mismo puesto, para darle los mismos accesos.
3. Qué Adobe necesita: solo abrir PDF, o la versión de pago para editarlos.
4. Qué programas de Maswer en concreto tiene que llevar.
5. ¿Tiene teléfono de empresa? WhatsApp necesita un número para funcionar.
6. ¿Dónde está ahora el portátil y quién me lo puede hacer llegar?

Para el viernes te garantizo el portátil funcionando con el correo nuevo, Word, Excel
y las carpetas de red. Los programas con licencia de terceros dependen del proveedor
y no te puedo prometer que estén ese mismo día; irían justo después.

La licencia de correo tiene coste, así que necesito tu visto bueno para pedirla.

Si me pasas los seis puntos hoy, el portátil puede estar en manos de Miguel el viernes.

Un saludo,
Soporte CoolNetworks
```

## Estado actual

**No se ha ejecutado ningún cambio en producción.** El caso queda a la espera de la
información de Miriam (puntos 1 a 6) y de la aprobación de licencia. En cuanto lleguen, la
Fase A se ejecuta el mismo día y la Fase B en cuanto el equipo esté disponible.
