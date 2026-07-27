# Reporte del caso — Maswer / Acceso VPN desde Kosovo (Alketa Vrella)

- **Cliente:** Maswer (Maswer AG)
- **Solicitante / usuaria final:** Alketa Vrella (`alketa.vrella@maswer.com`) — en copia: Elfriede Pietz (`elfriede.pietz@maswer.com`)
- **Canal:** Freshworks (portal) — **2 tickets abiertos con el mismo contenido**, viernes 24-jul-2026 16:08
- **Técnico:** Sebastian Lazarte (CoolNetworks — IT de Maswer)
- **Fecha:** 24-jul-2026
- **Estado actual:** EN CURSO — **bloqueado por falta de acceso administrativo al firewall**. Solicitud enviada a conet.de. **Sin incidente de seguridad y sin pérdida de datos.**

---

## Triage del ticket

| Campo | Valor |
|---|---|
| Categoría | Red e Infraestructura — VPN de acceso remoto, excepción geográfica |
| Prioridad | P3 - Media (una usuaria, petición planificada, aún no bloqueada) |
| Grupo | N2 Sistemas (cambio en firewall perimetral) |
| SLA inicial | Respuesta en 4 h |
| Fecha límite real | **lunes 27-jul-2026 por la mañana** — la usuaria viaja ese día |
| Escalado | Sí, a **conet.de** (no a N2 interno): el firewall implicado no está bajo administración de CoolNetworks |

---

## Solicitud recibida

Ticket original en alemán:

> "Hallo zusammen, könnt ihr bitte die Verbindung für die Kosovo-Region vom 27.07.2026 bis zum 17.08.2026 freischalten? Ich werde mich in diesem Zeitraum im Kosovo aufhalten und muss von dort aus arbeiten. Daher benötige ich den entsprechenden Zugriff. Bitte schaltet die Verbindung möglichst zeitnah frei und gebt mir kurz Bescheid, sobald die Freischaltung erfolgt ist. Vielen Dank für eure Unterstützung."

Traducción: pide **habilitar la conexión VPN para Kosovo del 27.07.2026 al 17.08.2026**, porque estará trabajando desde allí durante ese periodo. Pide que se haga cuanto antes y que se le avise al terminar.

Adjunta captura del cliente **Sophos Connect** fallando contra el gateway `108.142.212.203`.

---

## Cronología

| Hora | Evento |
|---|---|
| 24-jul 16:08 | Alketa abre el ticket (portal), con captura del fallo de Sophos Connect. |
| 24-jul | Abre un **segundo ticket** con el mismo texto → duplicado, a fusionar contra el primero. |
| 24-jul | Triage. Hipótesis principal: bloqueo por país de origen en el gateway VPN de la región EU. |
| 24-jul | Verificación en Sophos Central (tenant "Maswer AG"): **el firewall de la VPN EU no está enrolado**. |
| 24-jul | Confirmada la consola del firewall accesible en `172.30.1.12:4444` desde la subred Azure DE, pero **sin cuenta admin**. |
| 24-jul | Enviada solicitud a conet.de (Kevin Pütz-Kurth). |
| 26-jul 6:51 | Alketa (nota pública): su VPN **funciona desde Alemania** (captura adjunta) y confirma que trabajará con su **portátil de empresa `MDEVAI004`**, no el privado. → confirma que el fallo, si lo hay desde Kosovo, es **geográfico**, no un fallo general de su VPN. |
| 27-jul 8:10 | Miguel Á. Rubira (CEO CoolNetworks) responde en el ticket pidiéndole que confirme **acceso a SharePoint** (diagnóstico del posible bloqueo por Acceso Condicional en M365, independiente del firewall). |
| 27-jul 8:10 | Autorespuesta de Alketa: **ausente / no localizable, sin reenvío de correo**. Contactos urgentes: Werner Thuleweit (jefe de proyecto) y Elfriede Pietz (asistencia). → el canal con la usuaria queda cortado; contacto operativo pasa a Elfriede Pietz. |

---

## Trabajo realizado (resumen técnico)

1. **Identificación del punto de bloqueo.** El cliente de la usuaria apunta a `108.142.212.203` = firewall Sophos de **Azure West Europe** (`MEUAZFW001`), el que termina el acceso remoto de los usuarios europeos. La hipótesis principal es un bloqueo por país de origen; secundaria (no descartada), una directiva de Acceso Condicional en Entra ID por ubicación con nombre, que bloquearía M365 aunque la VPN sí levante.

2. **Sophos Central — tenant "Maswer AG".** Firewall Management → Firewalls lista **únicamente 3** dispositivos, todos SFOS 21.5.0 GA-Build171 y sin agrupar:

   | Nombre en Central | IP pública | Modelo | Qué es |
   |---|---|---|---|
   | XGSDEFRA (par HA) | 195.20.133.175 | XGS128 | Hub RZ Frankfurt (on-prem) |
   | XGSDEVAI01 | 87.234.245.186 | XGS128 | Vaihingen an der Enz |
   | XGSUSAZ01 | 104.210.193.97 | SFV2C4 (virtual) | Azure **US** (= `MUSAZFW001`) |

   El selector de entidad no despliega otros tenants: **no hay un segundo Central donde pueda estar**.

3. **Hallazgo principal: el firewall EU está fuera de gestión.** `108.142.212.203` **no aparece en Central**, pese a que su gemelo estadounidense (XGSUSAZ01, misma arquitectura virtual en Azure y mismo build) sí está enrolado. La asimetría no es un descuido de búsqueda.

4. **Sí es alcanzable desde dentro.** Su interfaz interna responde en `https://172.30.1.12:4444` desde la subred Azure DE (verificado desde `MEUAZAC011`). Presenta certificado autofirmado — comportamiento normal de appliance. **No se dispone de cuenta administrativa sobre él.**

5. **Escalado a conet.de.** Solicitud enviada a Kevin Pütz-Kurth con dos peticiones: (a) la habilitación temporal para Kosovo del 27.07 al 17.08, y (b) o bien enrolar ese firewall en el tenant de Central, o bien emitir una cuenta admin sobre `172.30.1.12`.

---

## Causa raíz y bloqueo

La petición en sí es una operación rutinaria de firewall (excepción temporal de país sobre la política de SSL VPN). **No se ha podido ejecutar por falta de acceso administrativo**, no por complejidad técnica.

El bloqueo real es de gobierno del entorno: el dispositivo que da acceso remoto a todos los usuarios europeos de Maswer está fuera del alcance de gestión y de monitorización de CoolNetworks. Cualquier petición sobre él —y cualquier caída— depende íntegramente del tiempo de respuesta de un tercero.

---

## Estado final

**EN CURSO, a la espera de conet.de.** **Sin incidente de seguridad, sin pérdida de datos, sin cambios en producción.** No se ha tocado ninguna configuración.

### Acciones pendientes

| Acción | Cuándo |
|---|---|
| Fusionar el ticket duplicado contra el primero (conservando a Elfriede Pietz en copia) | inmediato |
| **Coordinar con Miguel Á. Rubira (CEO)** — ya está en el ticket; evitar trabajo duplicado sobre conet/Maswer | inmediato |
| **Habilitar Kosovo (país entero) vía conet** sin esperar a la IP — la ventana ya corre desde hoy y la usuaria no está localizable | inmediato |
| Respuesta de conet.de sobre la habilitación | 27-jul (ventana ya activa) |
| Confirmar vía **Elfriede Pietz** (no Alketa, ausente) si accede a SharePoint desde Kosovo → descarta/confirma bloqueo por Acceso Condicional en M365 | 27-jul |
| Recabar la **IP pública real** de la usuaria (vía Elfriede Pietz) y acotar la regla a esa IP | cuando sea posible |
| **Cerrar la excepción** | **18-ago-2026** |

---

## Respuesta a la clienta (alemán — excepción acordada con el técnico)

> Hallo Alketa,
>
> wir haben deine Anfrage erhalten und arbeiten heute daran.
>
> Damit du planen kannst: wir können nicht zusagen, dass der Zugang am Montagmorgen bereit ist. Das hängt von einer Berechtigung ab, die wir intern noch klären. Wir melden uns heute auf jeden Fall bei dir.
>
> Zwei Dinge brauchen wir in der Zwischenzeit von dir:
>
> 1. Bitte versuche heute oder am Wochenende, dich von Deutschland aus zu verbinden. Auf deinem Screenshot schlägt die Verbindung bereits jetzt fehl – das kann ein ganz anderes Problem sein und nichts mit dem Kosovo zu tun haben. Wenn es auch in Deutschland nicht funktioniert, hilft dir die Freischaltung nicht weiter, und wir müssen das jetzt wissen und nicht erst am Montag.
> 2. Bitte bestätige, dass du mit deinem Firmenlaptop arbeitest und nicht mit einem privaten Rechner. Für ein privates Gerät können wir den Zugang nicht freischalten.
>
> Viele Grüße
> CoolNetworks Support

**Por qué está redactada así:** no promete el lunes (no se puede garantizar mientras dependa de un tercero) y pide a la usuaria que **pruebe la conexión desde Alemania antes de viajar**. Su captura muestra un fallo *ya*, tres días antes del viaje: si el problema no es geográfico, desbloquear Kosovo no le resuelve nada y hay que saberlo antes del lunes.

---

## Notas para casos similares

- **Kosovo (XK) es un caso especial en geolocalización.** No es un código ISO plenamente oficial y muchas bases de GeoIP clasifican los rangos kosovares como **Serbia (RS)** o **Albania (AL)**. Abrir solo XK puede dejar a la usuaria igualmente bloqueada. Por eso el plan correcto es acotar por **IP pública real** una vez en destino, que además es más seguro que abrir un país entero.
- **En Azure, la `.1` de la subred NO es tu firewall.** Es la puerta de enlace de la plataforma. Las VMs apuntan siempre ahí y el desvío al firewall se hace por tablas de rutas (UDR). Buscar la interfaz interna del firewall por el *default gateway* de un servidor es un método que no funciona en Azure — aquí la IP correcta (`172.30.1.12`) salió del diagrama de red Visio.
- **Aviso de certificado ≠ fallo.** `ERR_CERT_AUTHORITY_INVALID` en `:4444` significa que el appliance **está ahí y respondiendo**. Si no hubiera nada, sería un timeout.
- **Corrección al reporte del 02-jul-2026** (`2026-07-02_maswer_sophos-vpn-navegacion.md`): aquel documento daba por hecho que el firewall de la VPN era **XGSDEFRA01** y contaba **4 firewalls** en Central. Ninguna de las dos cosas se sostiene hoy: Central lista **3**, XGSDEFRA está en `195.20.133.175`, y el gateway al que conectan los clientes (`108.142.212.203`) **no está gestionado en Central**. Aquella guía sigue siendo válida para *navegar* SFOS, pero no para identificar el firewall correcto.
- **El acceso admin y la petición puntual van en el mismo correo a conet.** Separados, el segundo punto no se contesta nunca.

---

## Riesgo a señalar a dirección

Independientemente de cómo se resuelva esta petición, queda documentado que **el firewall que termina la VPN de acceso remoto de toda la región europea no está bajo gestión ni monitorización de CoolNetworks**. Hoy el coste es un ticket que espera; el día que ese equipo falle, no hay visibilidad ni capacidad de actuación propia. Se recomienda cerrar este punto con conet.de con independencia del caso de Kosovo.

---

**Referencias internas:** [[maswer-vpn-sophos]] · [[maswer-network-topology]] · [[maswer-servers-inventory]] · [[conet-de-administers-maswer-infra]] · [[maswer-vaihingen-s2s-vpn-runbook]] · [[user-does-not-speak-german-use-english]]
