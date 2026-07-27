# INFORME EJECUTIVO

**Análisis de las incidencias IT en Maswer Alemania**

**Periodo analizado:** Mayo – Junio 2026

---

## Resumen ejecutivo

Tras analizar la documentación disponible, los tickets registrados y las actuaciones realizadas por CoolNetworks en Alemania durante los meses de mayo y junio de 2026, **no se observa una situación de mal funcionamiento generalizado del servicio IT**.

La mayoría de las incidencias registradas corresponden a actividades habituales de soporte técnico: administración de usuarios, gestión de permisos, configuración de equipos y asistencia funcional a usuarios.

Únicamente se identifica una incidencia crítica de infraestructura que provocó una pérdida temporal de conectividad y acceso a recursos corporativos. Dicha incidencia fue causada por un equipo ubicado en un centro de datos externo y fue restablecida el mismo día tras la intervención del proveedor responsable.

No se ha encontrado evidencia de pérdida de datos, brechas de seguridad, incumplimientos reiterados de SLA ni degradación estructural de los servicios IT en Alemania.

---

## Principales incidencias detectadas

### 1. Problema con Microsoft Visio

**Usuario afectado:** Maurizio Carroccia

Inicialmente se reportó una incidencia relacionada con la aplicación Visio. Tras el análisis se comprobó que el equipo del usuario tenía Office instalado pero **no la aplicación Microsoft Visio**, que era lo que faltaba. Se verificó la licencia asignada y se completó la instalación, dejándola funcional para el usuario.

**Conclusión:** no se trataba de una caída del servicio ni de un fallo de infraestructura, sino de una necesidad de instalación de software en el equipo.

### 2. Incidencia de conectividad WiFi

Durante el periodo se registró una incidencia de conectividad. La actuación de CoolNetworks fue inmediata y la propia usuaria confirmó la recuperación del servicio **en menos de una hora** desde la apertura del ticket.

**Conclusión:** incidencia puntual resuelta satisfactoriamente, sin impacto prolongado.

### 3. Caída general de conectividad

Esta ha sido la incidencia más relevante registrada durante el periodo.

**Servicios afectados:**
- Internet
- VPN corporativa
- Carpetas compartidas
- Recursos corporativos centralizados

**Causa identificada:** el equipo que conectaba la oficina con la infraestructura corporativa, ubicado en un centro de datos externo, dejó de responder. El proveedor responsable restauró dicho equipo y, posteriormente, CoolNetworks verificó el correcto funcionamiento de todos los servicios.

**Impacto:** paralización temporal de determinadas tareas operativas durante varias horas.

**Resultado:**
- Recuperación del servicio el mismo día.
- Sin pérdida de información.
- Sin incidentes de ciberseguridad.
- Comunicación continua con los usuarios afectados.

### 4. Lentitud en las actualizaciones (Vaihingen)

Se reportaron problemas de rendimiento durante procesos de actualización. Las investigaciones apuntaron a la necesidad de revisar:
- Operador de comunicaciones.
- Ancho de banda disponible.
- Equipamiento local.
- Infraestructura WAN.

No existe evidencia técnica que permita atribuir esta situación a una actuación incorrecta de CoolNetworks.

**Conclusión:** incidencia de rendimiento en fase de diagnóstico, con múltiples factores externos involucrados.

### 5. Intento de phishing (ticket 641)

Se recibió un correo que indicaba falsamente que el almacenamiento del buzón estaba lleno y que en 22 días se dejaría de recibir correo. El mensaje llegó a una cuenta que en la práctica no se utiliza, lo que descartaba un aviso legítimo de cuota. El caso se gestionó a través del área de Ciberseguridad. Tras la revisión:
- Se identificó el mensaje como **phishing** (intento de generar urgencia para robar credenciales).
- El usuario no introdujo credenciales.
- No se produjo acceso no autorizado.

**Conclusión:** incidente de seguridad detectado y contenido correctamente, sin consecuencias para la organización.

---

## Gestión de permisos y accesos corporativos

Uno de los aspectos más relevantes detectados es que **una parte importante de los tickets no corresponden a averías o fallos de servicio, sino a solicitudes de acceso a recursos corporativos**.

### Carpeta HR

Se solicitaron accesos a la carpeta de RR.HH. para dos usuarios. El proceso seguido fue:
1. Solicitud formal.
2. Validación de autorizaciones (la carpeta HR contiene datos sensibles).
3. Asignación de permisos.
4. Confirmación por parte de los usuarios.

La gestión se cerró con la **confirmación de acceso por parte de los propios usuarios**.

**Punto importante:** la carpeta HR está especialmente protegida y su control final lo tiene el proveedor externo **conet.de**. Por eso no pudimos verificar los permisos directamente desde el servidor: nuestra cuenta no tiene el acceso necesario, y es conet.de quien debe concederlo. El acceso quedó confirmado por los propios usuarios, pero **conviene revisar todos los accesos a estas carpetas** para asegurar que cada usuario tiene el permiso que le corresponde.

### Acceso a aplicación financiera (Profi Cash)

Solicitud de acceso a la herramienta Profi Cash para un usuario. Se identificó el entorno de acceso, se configuró del lado del cliente y se remitió el acceso al usuario para su uso. No requirió instalación de software adicional en el equipo.

### Alta de nuevo usuario

Solicitud de creación de una cuenta nueva con los mismos accesos que una empleada existente. Se creó la cuenta, se replicaron los permisos y se asignó la licencia y el buzón correspondientes. Actuación dentro de la administración normal de usuarios y sistemas corporativos.

---

## Tiempos de respuesta observados

Los tiempos de respuesta obtenidos a partir de los tickets revisados muestran una actuación rápida y alineada con las buenas prácticas de soporte IT.

| Incidencia | Tiempo de respuesta |
|---|---|
| Problema Visio | 11 minutos |
| Incidencia WiFi | Atención inmediata |
| Caída general de conectividad | 37 minutos |
| Solicitud acceso HR | 42 minutos |
| Incidente de phishing | Mismo día |

Las incidencias críticas fueron atendidas en **menos de una hora** y las solicitudes administrativas se gestionaron en plazos razonables.

---

## Distribución real de las actuaciones

El análisis de los tickets permite estimar la siguiente distribución del trabajo:

| Tipo de actuación | Peso aproximado |
|---|---|
| Gestión de permisos y accesos | 35 % |
| Soporte a usuarios y software | 25 % |
| Configuración de equipos | 15 % |
| Incidencias de conectividad | 15 % |
| Seguridad y consultas | 10 % |

Esta distribución demuestra que **gran parte de la actividad corresponde a soporte operativo normal y no a incidencias derivadas de fallos de infraestructura**.

---

## Valoración del servicio

La documentación revisada acredita que:

✓ Los tickets fueron atendidos.
✓ Se mantuvo comunicación constante con los usuarios.
✓ Las incidencias críticas fueron escaladas adecuadamente.
✓ Se realizaron actuaciones remotas de soporte.
✓ Se gestionaron correctamente los accesos y permisos solicitados.
✓ Los problemas reportados fueron resueltos o correctamente diagnosticados.

No se observa evidencia de incumplimientos reiterados ni de degradación estructural del servicio IT en Alemania.

---

## Recomendaciones de mejora

Con independencia de que el servicio se haya prestado correctamente, se recomienda:

**1. Mejora de la documentación técnica.** Mantener evidencias periódicas de firewalls, VPN, conectividad WAN y rendimiento de enlaces.

**2. Informes mensuales de servicio.** Presentar un informe mensual que incluya: tickets abiertos, tickets cerrados, tiempo medio de respuesta, incidencias críticas y acciones preventivas.

**3. Redundancia de comunicaciones.** Evaluar soluciones de respaldo para minimizar el impacto de incidencias en proveedores externos o centros de datos.

**4. Revisión de accesos a carpetas.** Comprobar todos los accesos a las carpetas corporativas para confirmar que cada usuario tiene exactamente el permiso que le corresponde. Para poder hacerlo, **conet.de debe conceder a la cuenta de CoolNetworks el acceso necesario** para revisar y verificar los permisos a nivel de servidor; sin ese acceso, quedan puntos ciegos fuera de nuestro alcance.

---

*Documento preparado por CoolNetworks · 11 de junio de 2026.*
