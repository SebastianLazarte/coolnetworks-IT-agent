# Reporte del caso — Joaquín / Reinstalación de STAkis Profi

- **Cliente:** [a confirmar — cliente de STAHLGRUBER]
- **Usuario final:** Joaquín [apellido a confirmar]
- **Otros implicados:** Oliver Orth (técnico con experiencia previa instalando STAkis)
- **Técnico asignado:** Sebastian Lazarte (CoolNetworks)
- **Fecha de apertura:** 05-jun-2026
- **Estado actual:** en investigación · pendiente respuesta de Oliver

---

## Contexto

Se solicita instalar **STAkis Profi** (software de gestión de talleres y comercio de repuestos de STAHLGRUBER) en el equipo nuevo de Joaquín. El usuario ya lo tenía instalado en su máquina anterior, por lo que se trata de una **reinstalación tras cambio de equipo**, no de un alta nueva.

STAkis Profi no es software de descarga pública: se distribuye únicamente a través del portal de clientes de STAHLGRUBER (`kunden.stahlgruber.de`) o por contacto directo con `stakis.support@stahlgruber.de`. Requiere licencia/credenciales del cliente.

---

## Cronología

| Fecha | Evento |
|---|---|
| 05-jun | Solicitud inicial del usuario: "quiero instalar starkis". Aclaración con captura del producto → confirmado **STAkis Profi** (STAHLGRUBER). |
| 05-jun | Investigación de la vía oficial de instalación: portal de clientes STAHLGRUBER, hotline `0800 5782-547`, mail `stakis.support@stahlgruber.de`. Descartado uso de copias no oficiales (mhhauto, obd2diagnoseshop, etc.) por riesgo de malware y problemas de licencia. |
| 05-jun | Confirmado que el cliente ya es cliente de STAHLGRUBER → vía oficial viable. |
| 05-jun | Redactado correo en alemán dirigido al soporte de STAkis (`stakis.support@stahlgruber.de`) para solicitar instalador, licencia y requisitos de sistema. **No enviado todavía** — pendiente decisión interna. |
| 05-jun | Cambio de enfoque: se prioriza consultar primero a **Oliver Orth**, que ya tiene experiencia instalando STAkis, antes de escalar al soporte del proveedor. |
| 05-jun | Redactado correo en inglés a Oliver pidiéndole su procedimiento habitual de instalación (origen del instalador, licencia/activación, problemas comunes). Pendiente envío y respuesta. |

---

## Trabajo realizado

### Investigación
- Identificación del software a partir de la captura del usuario (no era "Starlink" ni "Starship" — era **STAkis Profi** de STAHLGRUBER).
- Localización de los canales oficiales de distribución y soporte:
  - Portal: [kunden.stahlgruber.de](https://kunden.stahlgruber.de/)
  - Hotline: `0800 5782-547`
  - Mail: `stakis.support@stahlgruber.de`
  - PDF de producto: `kunden.stahlgruber.de/downloads/STAkis_Profi_web.pdf`
- Revisión de [stahlgruber.de/en/services/digital-customer-systems](https://www.stahlgruber.de/en/services/digital-customer-systems) para confirmar canales de soporte.
- Descartadas fuentes no oficiales por riesgo de seguridad y legal.

### Comunicación (redactada, pendiente de envío)
- **Correo a soporte STAkis** (alemán): solicita instalador, licencia y requisitos para el equipo destino. Incluye plantilla con campos a completar (nº cliente, SO, single/multi-puesto, instalación previa).
- **Correo a Oliver Orth** (inglés): consulta su procedimiento habitual — origen del instalador, licenciamiento, errores típicos. Tono cordial, ofrece llamada si es más práctico.

### Decisiones de triage
- Categoría: Software (3rd-party / STAHLGRUBER).
- Prioridad: P3 (solicitud estándar, sin impacto operativo inmediato — Joaquín puede seguir trabajando en otras tareas).
- Vía elegida: consultar primero al técnico interno con experiencia (Oliver) antes de abrir caso con el proveedor.

---

## Estado actual y pendientes

**Estado:** en investigación · pendiente respuesta de Oliver

**Próximos pasos:**
1. Enviar el correo a Oliver con la consulta del procedimiento.
2. Según la respuesta de Oliver:
   - Si tiene instalador + licencia documentados internamente → proceder con la instalación remota.
   - Si no → enviar el correo en alemán al soporte de STAkis pidiendo instalador y credenciales del cliente.
3. Confirmar con Joaquín / cliente:
   - Número de cliente STAHLGRUBER.
   - Si la instalación previa era single-puesto o multi-puesto.
   - Si se usaba en conjunto con STAkis-S u otros módulos.
4. Coordinar ventana de instalación remota con Joaquín (AnyDesk / Quick Assist / herramienta interna definida).

**Notas:**
- Sin actividad sobre la máquina de Joaquín todavía — toda la sesión fue investigación y preparación de comunicaciones.
- No se ha gastado tiempo del usuario final más allá de la captura inicial del producto.
