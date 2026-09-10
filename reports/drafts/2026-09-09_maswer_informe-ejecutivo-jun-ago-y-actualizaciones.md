# Informe ejecutivo — Servicio de soporte a Maswer Alemania

## Junio – agosto 2026, con el ciclo de actualizaciones de servidores de septiembre

- **Cliente:** Maswer Alemania
- **Alcance:** operación completa del helpdesk alemán + parcheo de la flota de servidores
- **Fuente:** Freshdesk de CoolNetworks (empresa "Maswer Alemania")
- **Fecha de corte:** 9 de septiembre de 2026
- **Elaborado por:** Sebastian Lazarte Castellon — CoolNetworks

---

## Resumen para dirección

El servicio cerró **28 tickets en el trimestre frente a 26 entradas**: absorbió toda la demanda alemana, liquidó seis casos heredados de meses anteriores y lo hizo con respuesta de mismo día y cero reaperturas. En paralelo se desbloqueó el parcheo de la flota de servidores, que arrastraba dos ciclos fallidos en un servidor de identidad.

**01 — Se cerró más de lo que entró.** Ratio de cierre 1,08×. El inventario no crece: 23 de los 26 tickets del trimestre ya están liquidados, y además se cerraron 6 de periodos anteriores.

**02 — Calidad de servicio sostenida.** Primera respuesta en 2,8 h de mediana, 90 % dentro de SLA y ninguna reapertura en todo el trimestre: lo que se cierra, se cierra bien a la primera.

**03 — La demanda es estandarizable.** La mitad del volumen es gestión de accesos y altas. Industrializar ese flujo es la palanca de capacidad para el próximo trimestre.

**04 — La flota de servidores vuelve a estar al día.** El atraso de julio y agosto en el servidor de sincronización de identidad quedó cerrado, y el resto de la flota entra en la ventana de mantenimiento de fin de mes.

---

## Situación, complicación y resolución

**Situación.** Maswer Alemania opera sobre tres sedes — **Vaihingen, Rüsselsheim y Calden** — con soporte remoto desde España y sin IT local propio.

**Complicación.** El servicio absorbe un **tercio de la carga total** del helpdesk con un equipo compartido, y la mitad de las peticiones son trabajo manual repetitivo. A ello se sumó un bloqueo técnico en el parcheo mensual de servidores que ya acumulaba dos ciclos.

**Resolución.** Estandarizar altas y accesos, reflejar las esperas de terceros en el reloj de SLA, consolidar el modelo de atención por sede y cerrar con el proveedor de plataforma la causa de fondo del bloqueo de parcheo.

---

## Indicadores del trimestre

| Indicador | Valor | Detalle |
|---|---|---|
| Tickets cerrados | 28 | junio 12 · julio 8 · agosto 8 |
| Ratio cierre / entrada | 1,08× | 28 cerrados / 26 entrados |
| Primera respuesta (mediana) | 2,8 h | 90 % dentro de SLA |
| Reaperturas | 0 | sobre 28 cierres |

---

## Volumen mensual

Junio absorbe el pico de demanda y arrastra el mayor esfuerzo de liquidación; agosto cierra el trimestre con el inventario bajo control pese al periodo vacacional.

| Mes | Entrados | Cerrados | Ratio | 1.ª respuesta |
|---|---|---|---|---|
| Junio | 10 | 12 | 1,20× | 2,2 h |
| Julio | 9 | 8 | 0,89× | 20,7 h |
| Agosto | 7 | 8 | 1,14× | 3,0 h |
| **Trimestre** | **26** | **28** | **1,08×** | **2,8 h** |

Mediana de primera respuesta. Julio refleja el efecto de las peticiones agrupadas de altas y buzones, gestionadas en bloque.

---

## Demanda por familia de servicio

Sobre los 26 tickets entrados en el trimestre. No hubo ninguna incidencia crítica de servicio en todo el periodo.

| Familia | Tickets | Peso |
|---|---|---|
| Accesos, permisos y carpetas | 13 | 50 % |
| Red y conectividad | 4 | 15 % |
| Soporte general | 4 | 15 % |
| Puesto de trabajo y equipos | 3 | 12 % |
| Alta de personal | 1 | 4 % |
| Ciberseguridad | 1 | 4 % |

---

## Cobertura por sede, canal e interlocución

Vaihingen concentra la operación y actúa como sede de referencia; Rüsselsheim y Calden se atienden bajo el mismo modelo remoto.

| Sede | Tickets |
|---|---|
| Vaihingen | 9 |
| Rüsselsheim | 1 |
| Calden | 1 |

**Canal de entrada:** portal 22 · teléfono 3 · correo 1.

**Interlocución.** Vincenzo Valle canaliza el 58 % de las peticiones y opera como punto único de contacto de IT en Alemania, lo que reduce ruido y duplicidades. Alketa Vrella (19 %) y Angelika Stangenberg (15 %) completan la interlocución habitual.

---

## Detalle de los tickets cerrados en el trimestre

Tiempos en horas naturales desde la creación, incluidos fines de semana y periodos de espera de terceros.

| # | Fecha alta | Asunto | Familia | Solicitante | Sede | Estado | 1.ª resp. | Cierre |
|---|---|---|---|---|---|---|---|---|
| 636 | 03 jun | Installation of Remote Desktop | Puesto de trabajo | Vincenzo Valle | — | Cerrado | 3,7 h | 147 h |
| 641 | 09 jun | Speicherplatz voll | Ciberseguridad | Alketa Vrella | — | Cerrado | 0,3 h | 43 h |
| 644 | 10 jun | Access permission to the HR folder | Accesos | Vincenzo Valle | — | Cerrado | 22,0 h | 24 h |
| 647 | 10 jun | Revisión periódica de permisos — junio | Accesos | Miguel Rubira | — | Cerrado | — | 305 h |
| 652 | 16 jun | Persistent laptop connectivity issue | Red | Maurizio Carroccia | Vaihingen | Resuelto | 3,5 h | 745 h |
| 653 | 18 jun | Access to the Schulungsliste | Accesos | Vincenzo Valle | — | Resuelto | 0,4 h | 20 h |
| 659 | 24 jun | Steven Conow — Sophos issue | Red | Vincenzo Valle | Vaihingen | Cerrado | — | 1,5 h |
| 662 | 30 jun | Problemas con el portapapeles | Puesto de trabajo | Angelika Stangenberg | Vaihingen | Resuelto | 1,5 h | 5 h |
| 664 | 02 jul | Access to Folders | Accesos | Vincenzo Valle | — | Resuelto | 165 h | 261 h |
| 670 | 13 jul | Recovering Keepass | Accesos | Vincenzo Valle | Vaihingen | Resuelto | 0,6 h | 48 h |
| 671 | 13 jul | New employee in Calden | Alta de personal | Vincenzo Valle | Calden | Cerrado | 20,9 h | 78 h |
| 672 | 13 jul | Request for 6 New Email Addresses | Accesos | Vincenzo Valle | Vaihingen | Cerrado | 20,7 h | 77 h |
| 678 | 21 jul | IT Issues in Calden | Puesto de trabajo | Vincenzo Valle | — | Resuelto | 2,5 h | 818 h |
| 679 | 21 jul | Gestión de permisos y accesos | Accesos | Angelika Stangenberg | Vaihingen | Cerrado | 24,1 h | 833 h |
| 686 | 23 jul | Synchronisierungsprotokoll | Soporte general | Angelika Stangenberg | — | Cerrado | — | 23 h |
| 687 | 24 jul | Problemas de conexión | Red | Alketa Vrella | Vaihingen | Cerrado | 1,2 h | 255 h |
| 688 | 24 jul | Soporte al puesto de trabajo | Soporte general | Alketa Vrella | — | Cerrado | — | 1,2 h |
| 689 | 05 ago | New Email Adress | Accesos | Vincenzo Valle | — | Resuelto | 18,9 h | 122 h |
| 691 | 06 ago | Delete Access and Update IT | Accesos | Vincenzo Valle | — | Resuelto | 1,4 h | 434 h |
| 693 | 17 ago | Incidencia de conectividad | Red | Alketa Vrella | — | Resuelto | 2,8 h | 62 h |
| 694 | 17 ago | Soporte al puesto de trabajo | Soporte general | Alketa Vrella | — | Cerrado | — | 3,2 h |
| 704 | 26 ago | Remote Desktop | Puesto de trabajo | Vincenzo Valle | Rüsselsheim | Cerrado | 3,2 h | 13 h |
| 706 | 31 ago | Email Postfach | Accesos | Vincenzo Valle | Vaihingen | Cerrado | 8,1 h | 24 h |

A estos se suman **6 tickets heredados de meses anteriores** cerrados dentro del trimestre (#605, #607, #610, #618, #619 y #630).

A cierre del periodo quedaban 3 tickets en curso (#657, #658 y #708), en seguimiento activo y sin impacto en la operación del cliente. Los tiempos de cierre superiores a 100 h corresponden a casos con dependencia de terceros o de aprovisionamiento, durante los cuales el reloj del SLA sigue corriendo.

---

## Actualizaciones de servidores y máquinas virtuales

El parcheo mensual de sistema operativo y seguridad de la flota de Maswer es responsabilidad de CoolNetworks desde el ciclo de mayo de 2026. Se ejecuta en una **ventana de mantenimiento a fin de mes**, no de forma continua.

### Alcance del ciclo

| # | Servidor | Ubicación | Sistema | Función | Criticidad | Estado |
|---|---|---|---|---|---|---|
| 1 | MDERZADC003 | Centro de datos Frankfurt | Server 2022 | Controlador de dominio y DNS | Alta | Ventana fin de mes |
| 2 | MDERZADC004 | Centro de datos Frankfurt | Server 2022 | Controlador de dominio y DNS | Alta | Ventana fin de mes |
| 3 | MDERZFIL001 | Centro de datos Frankfurt | Server 2019 | Servidor de archivos | Muy alta | Ventana fin de mes |
| 4 | MEUAZDC011 | Azure Europa | Server 2022 | Controlador de dominio y DNS | Alta | Ventana fin de mes |
| 5 | MEUAZAC011 | Azure Europa | Server 2019 | Sincronización de identidad | Alta | Actualizado |
| 6 | MEUAZPTA011 | Azure Europa | Server 2022 | Autenticación (par redundante) | Alta | Ventana fin de mes |
| 7 | MEUAZPTA012 | Azure Europa | Server 2022 | Autenticación (par redundante) | Alta | Ventana fin de mes |
| 8 | MEUAZEX001 | Azure Europa | Server 2022 | Servicios de correo | Muy alta | Ventana fin de mes |
| 9 | MUSAZDC011 | Azure Estados Unidos | Server 2022 | Controlador de dominio y DNS | Alta | Ventana fin de mes |
| 10 | MEUAZAVD-0 | Azure Europa | Por confirmar | Escritorios virtuales | Por confirmar | Fuera del ciclo |

Los dos cortafuegos de Azure (Europa y Estados Unidos) y los de sede quedan fuera de este ciclo: su firmware lo gestiona el proveedor de plataforma.

### Criterio de ejecución

- Los cuatro controladores de dominio se reinician **escalonados, uno a uno**, para no interrumpir la replicación del directorio.
- El par de servidores de autenticación **nunca se reinicia simultáneamente**: si ambos quedan abajo, nadie puede iniciar sesión en los servicios en la nube.
- Se avisa al proveedor de plataforma antes de la ventana, porque el mantenimiento del servidor de sincronización dispara una alerta de seguridad que reciben ellos.

### El caso MEUAZAC011: dos ciclos bloqueados

El servidor que sincroniza las identidades de Maswer con Microsoft 365 llevaba **dos actualizaciones acumulativas fallidas**, las de julio y agosto, con el mismo código de error tras 6 y 27 intentos respectivamente.

El diagnóstico del 7 de septiembre identificó la causa raíz: el **disco de sistema es de solo 29,4 GB y quedaban 0,5 GB libres**. Las actualizaciones no fallaban al instalarse, sino al descargarse. Cada reintento dejaba una descarga parcial que reducía aún más el espacio disponible, en un bucle que se autoalimentaba. Se descartaron formalmente las otras hipótesis: no había servidor de actualizaciones interno mal configurado, ni proxy, ni bloqueo de red hacia Microsoft.

**Acción y resultado.** Se liberaron unos 5,9 GB vaciando la caché de descarga de Windows Update, deteniendo únicamente los dos servicios implicados y sin tocar el motor de sincronización, de modo que la operación no interrumpió el servicio ni disparó falsas alertas de seguridad. **La actualización acumulativa se instaló correctamente y el atraso de julio y agosto quedó cerrado**, al ser acumulativa cubre también el ciclo de julio que había fallado.

### Resolución con conet: la causa de fondo

La limpieza desbloqueó el ciclo, pero **no elimina el problema**: el disco sigue siendo de 29,4 GB y cada actualización mensual vuelve a llenarlo. Sin una ampliación, la situación se repite en tres o cuatro ciclos.

Aquí opera el reparto de responsabilidad con **conet**, el proveedor que administra la plataforma de servidores de Maswer:

- **Liberar espacio dentro del volumen es de CoolNetworks**, porque el parcheo mensual es nuestro desde mayo de 2026. Eso es lo que se ejecutó.
- **Ampliar el disco es de conet**, porque es dimensionamiento de plataforma.

Se contactó con conet para trasladar la petición: **ampliar el disco de sistema de MEUAZAC011 a 80 GB como mínimo**. La petición aprovecha que en Azure la ampliación exige detener la máquina y la ventana de mantenimiento de fin de mes ya contempla esa parada, de modo que no genera una interrupción adicional para el cliente. En el mismo contacto se les avisó del calendario de mantenimiento, ya que las alertas de seguridad que genera el reinicio del servicio de sincronización llegan a su consola y no a la nuestra.

*(Pendiente de registrar en la próxima revisión: fecha de la respuesta de conet y de la ejecución de la ampliación.)*

---

## Recomendaciones

**Palanca 01 — Industrializar altas y accesos.** Formulario guiado en el portal y plantillas de resolución para altas de usuario y permisos de carpeta, las dos familias que concentran la mitad del volumen. *Alcance potencial: 13 de 26 tickets por trimestre.*

**Palanca 02 — Reflejar las esperas de terceros en el SLA.** Activar el estado «Esperando tercero» en compras y proveedores para que el reloj mida el tiempo de CoolNetworks y no el del proveedor. Los indicadores pasarían a reflejar el desempeño real del equipo. *Afecta a los casos de mayor duración del trimestre.*

**Palanca 03 — Consolidar el modelo por sede.** Extender a Rüsselsheim y Calden el mismo esquema de interlocución que ya funciona en Vaihingen, anticipando el crecimiento de la operación alemana. *Prepara la escala sin aumentar plantilla.*

**Palanca 04 — Cerrar el dimensionamiento de disco con conet.** Un disco de sistema de 29 GB es corto de origen para un servidor con actualización mensual. Elevar la ampliación a compromiso con fecha evita que el parcheo vuelva a bloquearse y que un servidor de identidad quede sin parches de seguridad durante meses. *Elimina la causa raíz de los dos ciclos perdidos.*

---

## Notas metodológicas

- Fuente: Freshdesk de CoolNetworks, empresa «Maswer Alemania». Datos extraídos el 9 de septiembre de 2026.
- Base de cálculo: tickets cerrados o resueltos entre el 01/06/2026 y el 31/08/2026, y tickets creados en ese mismo periodo. Tiempos en horas naturales desde la creación del ticket, sin descontar fines de semana ni esperas de terceros.
- El estado de las actualizaciones de servidores refleja la situación a 9 de septiembre de 2026. La ventana de mantenimiento del ciclo de septiembre es a fin de mes.
