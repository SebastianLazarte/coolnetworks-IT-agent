# AUDITORÍA DE CUENTAS Y DISPOSITIVOS SIN USO — MASWER

**Cliente:** Maswer (Maswer AG)
**Alcance:** dominio `intern.maswer.com` — todas las cuentas de usuario y todos los objetos de equipo
**Fuente:** lectura LDAP de solo lectura contra los cuatro controladores de dominio
**Fecha de corte:** 9 de septiembre de 2026
**Elaborado por:** Sebastian Lazarte Castellon — CoolNetworks

---

## Resumen

El directorio de Maswer contiene **322 cuentas de usuario** y **513 objetos de equipo**. De las
**241 cuentas habilitadas, 82 no registran ningún acceso desde hace más de un año** o no lo han
registrado nunca. De los 512 objetos de equipo habilitados,
**344 llevan más de un año sin aparecer**, y **282 de ellos más de dos años**.

Ahora bien, la pregunta "cuántas cuentas hay que eliminar" no tiene 82 como respuesta. Al
separar las cuentas por lo que realmente son, **solo 22 corresponden a personas**. El resto son
buzones compartidos, cuentas de departamento o de sede, cuentas de servicio y cuentas
administrativas: **inactivas por diseño, y borrarlas rompería servicios en marcha**. Esa
distinción es el trabajo de este informe, y es la que faltaba en el barrido anterior.

Tres conclusiones para dirección:

**01 — Hay 22 personas con cuenta viva y sin actividad desde hace más de un año.** Veinte de
ellas conservan buzón con licencia y veintidós mantienen acceso a la red por VPN. Ninguna se
puede retirar todavía: el directorio dice cuándo se usó una cuenta por última vez, nunca si
la persona sigue contratada.

**02 — Las credenciales del administrador anterior siguen vivas y en uso.** Tres de las cuentas
de Oliver Orth registran autenticación en los últimos tres días, una de ellas con privilegio de
administrador de dominio. Este es el punto que exige actuación inmediata, y se detalla más abajo.

**03 — Dos tercios del inventario de equipos es chatarra de directorio.** 344 objetos obsoletos,
entre ellos seis servidores ya sustituidos y diez máquinas con sistemas operativos sin soporte.
Limpiarlos no ahorra licencias, pero sí reduce superficie y devuelve un inventario en el que se
puede confiar.

---

## Situación

Esta revisión no nace de un ticket. Nace de dos puntos abiertos que se venían arrastrando:

- El caso de la baja de Jewgenij Schachow (2 de septiembre) destapó el patrón y dejó la
  recomendación escrita sin ejecutar: de 217 cuentas con acceso VPN, 64 estaban habilitadas sin
  ningún acceso en 90 días, y las más antiguas databan de 2020.
- La preparación de la auditoría ISO 27001 y ENS mantiene como acción correctiva pendiente la
  revisión periódica de accesos "hecha y con fecha", y el criterio de que no haya exempleados
  con licencia activa.

Además hay una fecha que condiciona la parte económica:
**las suscripciones Microsoft 365 Business Premium y Basic renuevan el 17 de septiembre de 2026**.
Las reglas de contratación de
Microsoft solo permiten reducir el número de puestos en el momento de la renovación; fuera de
esa ventana, cualquier puesto sobrante queda comprometido otros doce meses.

---

## Datos clave del entorno

| Dato | Valor |
|---|---|
| Dominio | `intern.maswer.com` (NetBIOS `MASWER`), bosque y dominio únicos |
| Controladores de dominio | `MDERZADC003`, `MDERZADC004` (Frankfurt), `MEUAZDC011` (Azure EU), `MUSAZDC011` (Azure US) |
| Identidad híbrida | Sincronización a Microsoft 365 desde `MEUAZAC011`, autenticación pass-through |
| Cuentas de usuario | 322 objetos — 241 habilitadas, 81 deshabilitadas |
| Objetos de equipo | 513 objetos — 512 habilitados, 1 deshabilitado |
| Licenciamiento base | Microsoft 365 Business — 218 puestos comprados, 180 asignados (export de 31-ago-2026) |

---

## Método y base de cálculo

**Qué se ha leído.** Los atributos `lastLogon` y `lastLogonTimestamp` de cada cuenta y de cada
equipo, en los **cuatro** controladores de dominio, quedándose con la fecha más reciente de las
cuatro. Todo son consultas LDAP de solo lectura: no se ha modificado, deshabilitado ni borrado
ningún objeto.

**Por qué contra los cuatro y no contra uno.** `lastLogon` no se replica entre controladores, y
los controladores de Azure replican en cadena, no en malla. Leer uno solo produce falsos
"muertos": ya se documentó una cuenta que en `MDERZADC003` figuraba activa el 27 de agosto y en
`MUSAZDC011` seguía en febrero. El contraste confirma el efecto: la lectura de un solo
controlador daba 83 cuentas y 345 equipos sin uso; la de los cuatro deja 82 y 344.

**Umbrales.** Se reparte la población en tramos de menos de 90 días, 90 a 180 días, 180 días a
un año, uno a dos años, más de dos años, y sin ningún acceso registrado. El corte de **un año**
es el que se usa como cifra principal.

**Qué es dato verificado y qué no.**

- **Verificado:** que la cuenta está habilitada, a qué unidad organizativa pertenece, qué tipo
  de buzón tiene, a qué grupos pertenece y cuándo se autenticó por última vez.
- **No verificado:** que la persona haya dejado la empresa. El directorio no lo sabe. La
  actividad de inicio de sesión por sí sola confunde bajas de maternidad, bajas médicas,
  excedencias y cuentas de uso esporádico con cuentas muertas.
- **Lo que lo resolvería:** el listado de empleados activos de Recursos Humanos. Esa columna
  solo la puede rellenar Maswer.

**Un margen a tener en cuenta.** `lastLogonTimestamp` se replica con hasta 14 días de retraso,
así que las fechas pueden quedarse cortas en ese margen. Es irrelevante para un corte de un
año e importante si alguna vez se baja el umbral a 30 días.

**Cómo se clasifica cada cuenta.** El criterio principal no es el nombre, sino el tipo de buzón
que el directorio le asigna. Un buzón de usuario indica una persona o un puesto con licencia; un
buzón compartido nunca es una persona; la ausencia de buzón indica una cuenta técnica. El nombre
solo se usa para separar personas de cuentas de departamento dentro del primer grupo, con lista
explícita y revisable.

---

## Cuentas de usuario

### Panorama por antigüedad de acceso

De las 241 cuentas habilitadas:

| Antigüedad del último acceso | Cuentas |
|---|---|
| Menos de 90 días | 128 |
| De 90 a 180 días | 16 |
| De 180 días a 1 año | 15 |
| De 1 a 2 años | 22 |
| Más de 2 años | 26 |
| Sin ningún acceso registrado | 34 |
| **Total sin uso desde hace más de un año** | **82** |

### El desglose que cambia la respuesta

Las 82 cuentas sin uso no son 82 bajas. Repartidas por lo que realmente son:

| Naturaleza de la cuenta | Habilitadas | Sin uso > 1 año | Se puede retirar |
|---|---|---|---|
| Persona | 161 | 23 | Sí, previa confirmación de Maswer |
| Departamento, puesto o sede | 20 | 19 | No sin preguntar: son cuentas en uso ocasional |
| Buzón compartido | 16 | 13 | No: son bajas ya procesadas correctamente |
| Servicio y técnicas | 15 | 11 | Solo tras identificar qué las usa |
| Administrativas | 18 | 7 | Sí, y con prioridad — ver apartado propio |
| Sistema y Exchange | 11 | 9 | No: las gestiona el propio producto |
| **Total** | **241** | **82** | |

De las 23 cuentas de persona sin uso, **una es un alta de ayer que todavía no se ha estrenado**
(Erik Esau Guillermo Valencia, creada el 8 de septiembre). No es una baja. Quedan por tanto
**22 candidatas reales**.

Las 13 de la fila "buzón compartido" merecen una nota positiva: son mayoritariamente antiguos
empleados cuyo buzón se convirtió a compartido al marcharse. Es exactamente el tratamiento
correcto, y confirma que el procedimiento de baja funciona cuando se aplica.

### Las 22 personas candidatas

Ninguna de estas cuentas se retira con este informe. La columna de la derecha es la que tiene
que rellenar Maswer.

| Cuenta | Nombre | Último acceso | Días | Sede | Licencia | VPN | ¿Sigue en uso? / confirmado por |
|---|---|---|---|---|---|---|---|
| RGallardo | Rocio del Carmen Gallardo Villanueva | 2024-05-07 | 855 | Puebla | Sí | Sí | |
| CKnoll | Christoph Knoll | 2024-10-11 | 698 | Tuscaloosa | Sí | Sí | |
| VVega | Virginia Vega Nieto | 2024-10-15 | 694 | Zaragoza | Sí | Sí | |
| ERamirez | Eduardo Isaac Ramirez Sanchez | 2025-02-04 | 582 | Puebla | Sí | Sí | |
| KBillingsley | Keambria Billingsley | 2025-03-06 | 552 | Tuscaloosa | Sí | Sí | |
| LMendoza | Luis Alberto Mendoza Jaimes | 2025-04-28 | 499 | Puebla | Sí | Sí | |
| LLopez1 | Leopoldo Lucero Lopez | 2025-05-22 | 475 | Puebla | Sí | Sí | |
| AGarcia | Adriana Garcia Medina | 2025-06-11 | 455 | San Luis Potosí | Sí | Sí | |
| MInal | Mehmet Inal | 2025-06-25 | 441 | Rüsselsheim | Sí | Sí | |
| IJuarez | Isaias Juarez Andrade | 2025-06-26 | 440 | Aguascalientes | Sí | Sí | |
| ELuna | Erik Joel De Luna Gómez | 2025-07-10 | 426 | Aguascalientes | Sí | Sí | |
| GVerdad | Gerardo Verdad | 2025-07-16 | 420 | Puebla | No | Sí | |
| IMartinez | Ilse Martinez | 2025-08-15 | 389 | Aguascalientes | Sí | Sí | |
| HOrtiz | Horacio Ortiz, Jr. | 2023-10-23 | 1.052 | Tuscaloosa | No | Sí | |
| JTeomitzi | Jose Eulalio Teomitzi Carbajal | Nunca | — | Puebla | Sí | Sí | |
| JSoriano | Jessica Soriano Trujillo | Nunca | — | Puebla | Sí | Sí | |
| JRosales | Jose Alfredo Rosales Lozano | Nunca | — | Puebla | Sí | Sí | |
| DEspinosa | Dulce Espinosa | Nunca | — | Puebla | Sí | Sí | |
| IChakrane | Ibtissam Chakrane | Nunca | — | Zaragoza | Sí | Sí | |
| GRosales | Cristian Gabriel Rosales Arellano | Nunca | — | Aguascalientes | Sí | Sí | |
| NDCMarques | Niklas da Costa Marques | Nunca | — | Vaihingen | Sí | Sí | |
| AdVita | Alessio di Vita | Nunca | — | Vaihingen | Sí | Sí | |

Dos patrones que conviene señalar a Maswer:

- **Ocho cuentas nunca se han usado**, y no son recientes: tres se crearon en abril de 2024 y
  dos en diciembre de 2025. Un alta que nunca se estrena suele significar que la persona no
  llegó a incorporarse, o que trabaja sin equipo informático. Si es lo primero, se ha estado
  pagando la licencia desde el alta.
- **La concentración es geográfica.** Catorce de las veintidós están en México y tres en Estados
  Unidos. Solo tres están en Alemania y dos en España. Eso apunta a que el aviso de baja desde
  las sedes americanas no está llegando al servicio de soporte.

### Cuentas que NO deben tratarse como bajas

Diecinueve cuentas de departamento, puesto o sede figuran sin uso desde hace más de un año, y
dieciocho de ellas consumen licencia: `Finanzas MX`, `Compras MX`, `Purchasing USA`,
`Payroll USA`, `Finance USA`, `HR Connect`, `Quejas Sugerencias`, `Team Leader`,
`Team Leader USA`, `Tech Reporting2 MBUSI`, `Transporte Saltillo`, `IT Support AM`,
`Social Networks`, `ADMIN VISADOS`, `CR Zaragoza2`, `Gößnitz`, `Hemau`, `PMX 001` y `replay`.

No son bajas, pero **tampoco son gratis**. Cada una es un puesto pagado que nadie abre. La
pregunta correcta para estas no es "¿quién era?" sino "¿sigue haciendo falta este buzón, y quién
responde de él?".

Once cuentas de servicio llevan más de un año sin autenticarse, cinco de ellas más de cinco años:
`AAD_1f80425d3c6a` (2016), `LDAP_Service2` (2016), `swyx` (2020), `LDAP_Service` (2021) y
`LDAP LDAP` (2023), más `ldap-maswer` y `ldap-service`, que no se han usado nunca. Son restos de
integraciones retiradas. **Antes de tocar ninguna hay que identificar qué proceso la usaba**, no
al revés.

### Cuentas privilegiadas — el hallazgo que exige actuación

El dominio tiene **18 cuentas administrativas habilitadas**. Siete de ellas llevan más de un año
sin usarse:

| Cuenta | Titular | Último acceso | Días sin uso |
|---|---|---|---|
| tplink | Cuenta de dispositivo, miembro directo de Domain Admins | 2017-03-01 | 3.479 |
| admin | Genérica | 2017-03-01 | 3.479 |
| admadfs | Servicio ADFS | 2020-12-08 | 2.100 |
| Admin2_MRGarcia | Miguel Rubira Garcia | 2021-01-07 | 2.071 |
| Administrator1_OOrth | Oliver Orth | 2021-02-10 | 2.037 |
| adm0_conet | Conet Admin | 2025-01-13 | 604 |
| Administrator0_OOrth | Oliver Orth | 2025-05-27 | 470 |

Nueve años de inactividad con privilegio de administrador de dominio, en el caso de `tplink`.

**Lo que cambia el cuadro es lo que sí se usa.** Hasta ahora no se había comprobado si las
cuentas del administrador anterior estaban vivas o solo existían. Ya está comprobado:

| Cuenta de Oliver Orth | Estado | Último acceso | Privilegio |
|---|---|---|---|
| oorth (cuenta normal) | Habilitada | 2026-09-08, en tres controladores | 18 grupos de datos, VPN, Backup Operators |
| Admin2_OOrth | Habilitada | 2026-09-08, en los cuatro controladores | adm2-Administrators |
| Admin1_OOrth | Habilitada | 2026-09-06 | Administrators del dominio, AzureFiles-Administrators |
| Administrator0_OOrth | Habilitada | 2025-05-27 | adm0-Administrators, Domain Admins efectivo |
| Administrator1_OOrth | Habilitada | 2021-02-10 | adm1-Administrators |

**Verificado:** las tres primeras se han autenticado en los últimos tres días, y `Admin1_OOrth`
pertenece al grupo Administrators del dominio.

**Inferido, no confirmado:** que no es una persona quien las usa. `Admin2_OOrth` registra su
acceso **a las 12:10 en punto en los cuatro controladores**, en fechas distintas. Esa regularidad
es la firma de una tarea programada o un servicio, no la de alguien escribiendo una contraseña.

**Lo que no se sabe:** qué proceso es, en qué máquina corre y con qué tipo de inicio de sesión.
Eso solo lo dicen los registros de seguridad de los controladores de dominio (eventos 4624 y
4768), filtrando por esas cuentas y mirando el equipo de origen y el tipo de sesión.

**Por qué importa igual.** Sea una persona o sea un proceso, hay credenciales de un administrador
que ya no está en la empresa en uso activo hoy. Y tiene una consecuencia práctica inmediata:
**deshabilitarlas sin más rompería lo que sea que las está usando.** Por eso el orden correcto
es identificar primero y deshabilitar después, no al revés.

Dato colateral que responde a una pregunta abierta: existe un buzón compartido a nombre de
Oliver Orth creado el **1 de octubre de 2025**. La conversión del buzón a compartido es lo que se
hace cuando alguien se va, así que esa es, con alta probabilidad, la fecha de su salida.

---

## Dispositivos

### Panorama

| Antigüedad desde que se vio por última vez | Equipos |
|---|---|
| Menos de 90 días | 109 |
| De 90 a 180 días | 23 |
| De 180 días a 1 año | 36 |
| De 1 a 2 años | 59 |
| Más de 2 años | 282 |
| Sin ningún registro | 3 |
| **Total sin aparecer desde hace más de un año** | **344** |

Solo **168 equipos de 512 han dado señales de vida en el último año**. El reparto por año del
último contacto muestra que no es un pico reciente sino una acumulación de una década: 6 equipos
se vieron por última vez en 2016, 16 en 2017, 17 en 2018, 29 en 2019, 28 en 2020, 49 en 2021,
49 en 2022, 53 en 2023, 51 en 2024 y 43 en 2025.

### Servidores ya sustituidos que siguen en el directorio

| Servidor | Sistema | Último contacto |
|---|---|---|
| MDERZADC001 | Windows Server 2012 R2 | 2023-11-21 |
| MDERZADC002 | Windows Server 2012 R2 | 2023-11-21 |
| MEUAZDC001 | Windows Server 2012 R2 | 2023-11-13 |
| MEUAZPTA001 | Windows Server 2019 | 2023-05-26 |
| MEUAZPTA002 | Windows Server 2019 | 2023-05-24 |
| MDERZAXX03 | Windows Server 2012 R2 | 2021-08-31 |

Son los predecesores de los controladores y los agentes de autenticación que hoy están en
servicio con numeración 003, 004 y 011. La migración se hizo; la limpieza del directorio, no.

### Sistemas operativos sin soporte

Diez equipos obsoletos corren sistemas que ya no reciben actualizaciones de seguridad: cinco
Windows 8.1 en Barcelona y Zaragoza, cuatro Windows Server 2012 R2 (los de la tabla anterior) y
un Windows 7 (`XEROXFBH`, sin contacto desde enero de 2017). Todos llevan años sin aparecer, así
que lo más probable es que ya no existan físicamente. Confirmarlo cierra un punto de auditoría
sin coste.

### Equipos que no siguen la nomenclatura corporativa

Quince objetos no siguen el patrón de sede y numeración: `MAGDA`, `MASWER-SBUESA`,
`LAPTOP-B33DD389`, `LAPTOP-BISDDK0P`, `XEROXFBH`, `mwsgeu1premium`, `mwsgus2premium`,
`mwsgus3premium` y siete más con prefijos mezclados. Es el mismo patrón que el portátil `OORTH`:
equipos reasignados o dados de alta fuera del procedimiento, que nunca se renombraron. Cada uno
es un equipo cuyo responsable actual no consta en ningún sitio.

### Una advertencia antes de limpiar

El objeto **`AZUREADSSOACC` no tiene ningún inicio de sesión registrado y no se debe tocar.** Es
la cuenta que hace funcionar el inicio de sesión automático contra Microsoft 365 para toda la
plantilla. Por diseño nunca inicia sesión. Borrarla porque "lleva cinco años sin actividad"
dejaría a todos los usuarios sin acceso transparente a Microsoft 365. Es el mejor ejemplo de por
qué la regla "sin actividad, se borra" no se puede aplicar de forma automática.

---

## Impacto en licencias

En el directorio hay **218 buzones de usuario**: 171 en cuentas habilitadas y
**47 en cuentas ya deshabilitadas**. Maswer tiene contratados exactamente
**218 puestos Microsoft 365 Business**, de los cuales 180 figuraban asignados en el último
extracto de facturación disponible, el del 31 de agosto.

La coincidencia entre las dos cifras es llamativa y **no debe darse por buena sin comprobarla**:
que una cuenta deshabilitada conserve su buzón en el directorio no demuestra que siga teniendo
licencia asignada en Microsoft 365. Eso lo resuelve el extracto de facturación del portal, no el
directorio.

Con esa reserva, el margen a revisar antes de la renovación es:

| Concepto | Puestos |
|---|---|
| Diferencia entre puestos comprados y asignados (31-ago) | 38 |
| Cuentas deshabilitadas que conservan buzón de usuario | 47 |
| Cuentas habilitadas con licencia y sin uso desde hace más de un año | 40 |
| — de ellas, personas | 21 |
| — de ellas, cuentas de departamento o sede | 18 |
| — de ellas, técnicas | 1 |

**La ventana se cierra el 17 de septiembre.** No se trata de decidir en ocho días qué se retira:
se trata de decidir en ocho días **cuántos puestos se renuevan**, que es una cifra, no una lista.
Todo lo demás puede seguir su curso después.

Una salvedad que ya costó un caso:
**no se quita la licencia de un buzón que alguien ha heredado.**
Si el buzón de una persona que se fue lo está usando su sustituto, la vía correcta
es convertirlo a buzón compartido, no liberar el puesto.

---

## Lo que este informe no puede responder

La pregunta "qué usuarios ya no trabajan en Maswer desde hace más de un año"
**no se puede contestar desde los sistemas**. Este informe entrega lo más parecido que existe: la lista de
quién no ha usado su cuenta, con nombre, fecha y sede. La confirmación de quién sigue contratado
solo la tiene Maswer.

Tres huecos concretos, y quién los cierra:

- **Listado de empleados activos de Recursos Humanos.** Se pide a través de Vincenzo Valle. Sin
  él no se puede comprometer ninguna fecha de ejecución.
- **Actividad real en Microsoft 365.** Una persona que solo usa el correo desde el móvil o desde
  el navegador puede aparecer inactiva en el directorio y estar trabajando con normalidad. El
  informe de uso del centro de administración lo desmiente en un minuto, y hay que cruzarlo antes
  de enviar ninguna lista con nombres.
- **Quién usa cada equipo.** El directorio dice cuándo se vio una máquina por última vez; nunca
  quién la tiene. Esa columna solo la puede rellenar el cliente.

---

## Plan de retirada

Nada se borra. Las cuentas se deshabilitan y se retienen, y no se ejecuta ningún cambio sin
autorización escrita de dirección adjunta al ticket, con fecha y remitente. Borrar una cuenta
elimina también su buzón y sus ficheros, y no tiene vuelta atrás.

### 1. Cerrar la exposición de las cuentas privilegiadas

Identificar en los registros de seguridad de los controladores qué está usando las cuentas de
Oliver Orth, deshabilitar las cinco una vez identificado el proceso y sustituido, y rotar las
contraseñas de las cuentas compartidas y de servicio que él conocía. Deshabilitar `tplink` y
`admin`, sin uso desde 2017.

- **Qué aporta:** cierra el acceso con privilegio de administrador de un empleado que ya no está.
- **Alcance:** cinco cuentas `*OOrth`, más `tplink`, `admin`, `admadfs` y `Admin2_MRGarcia`.
- **Impacto en servicio:** ninguno si se identifica antes el proceso; corte de ese proceso si se
  hace al revés. Por eso el orden no es negociable.
- **Coordinación:** las cuentas compartidas y de servicio las conoce también conet.de; la
  rotación se acuerda con ellos.

### 2. Pedir el listado de empleados activos

Solicitar a Maswer, a través de Vincenzo Valle, la relación de personal en alta, y cruzarla con
las 22 candidatas de este informe.

- **Qué aporta:** convierte una lista de cuentas inactivas en una lista de bajas reales.
- **Impacto en servicio:** ninguno.

### 3. Una sola ronda de confirmación, con una única fecha límite

Enviar las tablas de este informe como hoja de confirmación, con la columna "¿sigue en uso? /
confirmado por" vacía, y **una sola fecha límite compartida** para todas las rondas: personas,
cuentas de departamento, cuentas de servicio y equipos. El silencio en la fecha límite no es
aprobación: las cuentas siguen deshabilitadas y el asunto abierto hasta que llegue la
confirmación por escrito.

- **Qué aporta:** una sola interlocución en lugar de perseguir respuestas por separado.
- **Impacto en servicio:** ninguno.

### 4. Decidir el número de puestos antes del 17 de septiembre

Contrastar el extracto de facturación actualizado con las 47 cuentas deshabilitadas que
conservan buzón, y fijar con conet.de (Patrick Kuhlmann) cuántos puestos se renuevan. Antes de
liberar ninguno, verificar qué retiene realmente la copia de seguridad de Microsoft 365.

- **Qué aporta:** evita comprometer doce meses más de puestos que nadie usa.
- **Impacto en servicio:** ninguno, siempre que no se toque ningún buzón heredado.

### 5. Limpiar el inventario de equipos

Retirar en primer lugar los seis servidores ya sustituidos y los diez equipos con sistema sin
soporte, previa confirmación de que no existen físicamente. Después, los 282 objetos sin contacto
desde hace más de dos años. Excluir `AZUREADSSOACC`.

- **Qué aporta:** un inventario en el que se puede confiar, y menos superficie expuesta.
- **Impacto en servicio:** ninguno para los equipos que ya no existen.

### 6. Cerrar el hueco que causó la acumulación

La concentración de cuentas inactivas en México y Estados Unidos indica que las bajas de esas
sedes no llegan a soporte. Acordar con Maswer un aviso de baja por sede evita repetir esta
auditoría dentro de un año.

- **Qué aporta:** que el problema no vuelva.
- **Impacto en servicio:** ninguno.

---

## Resumen de acciones

| # | Acción | Beneficio | Impacto en servicio |
|---|---|---|---|
| 1 | Identificar y cerrar las cuentas del administrador anterior | Cierra un acceso privilegiado vivo | Ninguno si se identifica primero |
| 2 | Pedir el listado de empleados activos vía Vincenzo Valle | Permite decidir las bajas reales | Ninguno |
| 3 | Hoja de confirmación con fecha límite única | Una sola ronda en lugar de varias | Ninguno |
| 4 | Fijar puestos a renovar antes del 17-sep | Evita 12 meses de puestos sin uso | Ninguno |
| 5 | Retirar servidores sustituidos y equipos sin soporte | Inventario fiable, menos superficie | Ninguno |
| 6 | Aviso de baja desde las sedes americanas | Impide que se repita | Ninguno |

---

## Valoración

| Elemento | Estado |
|---|---|
| Pérdida de datos | Ninguna |
| Cambios ejecutados sobre el directorio | Ninguno — auditoría de solo lectura |
| Cuentas deshabilitadas o borradas en esta revisión | Ninguna |
| Incidente de seguridad confirmado | No |
| Exposición de seguridad abierta | Sí — credenciales del administrador anterior en uso |
| Interrupción del servicio | Ninguna |

El estado del directorio es el de una empresa que ha crecido y cambiado de administrador sin que
la retirada de accesos siguiera el mismo ritmo que las altas. No hay indicios de uso indebido, y
nada de lo encontrado apunta a un ataque. Lo que hay es una acumulación de diez años que reduce
la fiabilidad del inventario y mantiene abiertas más puertas de las necesarias.

El punto que no admite espera es el de las cuentas del administrador anterior. El resto es
higiene ordenada, y se resuelve con una ronda de confirmación bien planteada y una fecha.

---

## Anexo — alcance de los datos

La relación completa, cuenta por cuenta y equipo por equipo, con último acceso, unidad
organizativa, tipo de buzón, grupos y pertenencia a VPN, está disponible como fichero de datos
para adjuntar a la hoja de confirmación. En este documento se recogen las 22 cuentas de persona
candidatas y los subconjuntos prioritarios de equipos; la lista íntegra de los 344 objetos de
equipo no se reproduce aquí por extensión.

---

*Documento preparado por CoolNetworks · 9 de septiembre de 2026.*
