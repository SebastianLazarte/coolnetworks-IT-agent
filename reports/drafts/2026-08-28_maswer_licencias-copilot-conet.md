# Copilot para Maswer — Copilot Business vía conet

**Fecha:** 2026-08-31 (rev. 6 — replanteado sobre datos reales de licenciamiento)
**Cliente:** Maswer AG · **Reseller:** CONET Services GmbH · Patrick Kuhlmann, `PKuhlmann@conet.de`
**SKU:** **Microsoft Copilot Business** — 218,40 €/licencia/año
**Estado:** pendiente de que Maswer decida cuántas licencias
**Fecha límite:** la promoción del catálogo acaba el **30-sep-2026**

---

## 1. Situación (verificada, export CSV de *Facturación → Sus productos*, 31-ago-2026)

| Producto | Asignadas | Compradas | Renueva |
|---|---|---|---|
| Microsoft 365 Business Premium | 156 | 189 | 17-sep-2026 |
| Microsoft 365 Business Basic | 23 | 27 | 17-sep-2026 |
| Microsoft 365 Business Standard | 1 | 2 | 24-may-2027 |
| Microsoft 365 Copilot | 1 | 1 | **2-jun-2027** |

**218 puestos Business en total. Ni una licencia E3/E5.**

## 2. Qué SKU corresponde

**Microsoft Copilot Business.** Requiere base Microsoft 365 Business (✔ las tres) y tope de
300 puestos (✔ 218).

> *"The Copilot Business add-on delivers the same capabilities as the Microsoft Copilot
> offering."* — Microsoft Copilot Business FAQ

Mismos modelos, mismas apps, mismos agentes Researcher/Analyst, mismo grounding en Microsoft
Graph. La única diferencia con el SKU de 312 € es el precio, la base exigida y el tope de 300.

| | 5 licencias | 6 licencias |
|---|---|---|
| Copilot Business a tarifa (218,40 €) | 1.092,00 € | 1.310,40 € |

> ⚠️ **No se sabe si hay descuento sobre este SKU.** El catálogo del tenant muestra la línea
> *"Up to 15% off Limited Time Offer – Microsoft 365 Copilot Business"* **al mismo precio**
> que la estándar (218,40 €), igual que pasaba con la enterprise. **218,40 € es el único
> número sólido**; cualquier cifra con 15% aplicado es especulación hasta que Patrick lo
> confirme.

**Condiciones:** compromiso anual (no hay mes a mes), facturación anual adelantada o mensual
con +5% de recargo. Cancelación solo en las primeras **168 h**; después, las licencias no se
reducen hasta la renovación.

**Dos ataduras a tener presentes:**
- La licencia enterprise actual **no se convierte**: cumple su compromiso hasta el
  **2-jun-2027**. Las nuevas sí pueden ser Business desde ya; convivirían ~9 meses.
- Con Copilot Business **no se puede pasar a un plan Enterprise** hasta que acabe el
  compromiso.

## 3. El trial — y su riesgo

Existe un SKU de prueba de **25 puestos, 30 días**, sin datos de pago. La prueba
self-service viene **activada por defecto**: cualquier usuario elegible puede lanzarla desde
Copilot Chat (se desactiva desde el admin center).

> ⚠️ **No activarlo sin preguntar antes.** Doc de NCE: *"Trial subscriptions count against the
> First Purchase constraint. Promotional pricing isn't applied when autorenewing from a trial
> to paid subscription."* → la prueba **puede quemar el descuento de primera compra**. Con 5
> licencias eso son ~164 €/año. Es la pregunta 1 del correo a Patrick.

**Comprobación técnica antes de desplegar:** Copilot no aparece en Office si los equipos
están en canal **Semi-Annual Enterprise**. Tiene que ser Current o Monthly Enterprise. Tras
asignar licencia puede tardar hasta 24 h y requerir reiniciar las aplicaciones.

---

## 4. Correo a Carlos

**To:** `[Carlos]` · **Cc:** `[Miguel]`, `[Rubira]`
**Subject:** Licencias Copilot

---

> **Nota aparte, no copia en el hilo de conet.** Ese hilo lleva ahora un *"disregard my
> previous message"* y el presupuesto del SKU equivocado: Carlos vería el vaivén, no el
> avance.

Hola Carlos,

Te pongo al día: estamos gestionando con el proveedor las licencias de Copilot.

Serán **6**: las 5 que indicaste, más una para mí, para gestionar las incidencias y hacer el
seguimiento de uso.

Estoy cerrando con ellos qué modalidad nos corresponde y a qué precio. En cuanto tenga la
oferta te la paso.

Un saludo,
Sebastian

---

## 5. Correo a Patrick — puede salir ya

> Pregunta la elegibilidad en vez de afirmarla, y pide precio por licencia en vez de un
> número cerrado. Así no depende de que Maswer haya decidido la cantidad.
>
> **No incluir:** el desglose de licencias de Maswer (lo ve en su Partner Center), la fecha
> de 2-jun-2027 (nos la dio él), ni el trial.

**To:** PKuhlmann@conet.de · **Cc:** swilhelm@conet.de
**Subject:** RE: Maswer – Copilot licence options and quote (tenant maswer.com)

> **Sin Carlos en copia** — a él va la nota de la sección 4, aparte y en español.
> Empieza anulando el correo enviado esta mañana, que preguntaba por el SKU equivocado.

---

Hi Patrick,

Please disregard my previous message — I have since checked our licensing base and the
question has changed.

Which Copilot licence types can we actually buy on our current licensing base? In particular,
**does Microsoft Copilot Business apply to us?**

If it does, please quote **6 licences**, annual commitment, billed annually upfront:

1. **Price per licence per year**, and the total.
2. Our catalogue shows both *"Microsoft 365 Copilot Business"* and *"Up to 15% off Limited
   Time Offer – Microsoft 365 Copilot Business"* at **the same price, 218,40 € per
   licence/year**. **Is a discount actually available on this SKU**, and if so what is the
   net price?
3. **What we would pay at renewal**, once any discount no longer applies.

Best regards,

Sebastian Lazarte Castellon
IT Support — Maswer
IT-Support-Germany@maswer.com

---

## 6. Orden

Los dos correos pueden salir **a la vez**: el de Patrick ya no depende de la cantidad.

1. **Patrick** → confirmar tipo de licencia + precio por licencia.
2. **Carlos** → cuántas licencias y para quién.
3. Con precio y aprobación → confirmar por escrito a Patrick. **Anotar fecha y hora**: las
   168 h de cancelación corren desde ahí.
4. Asignar en *Facturación → Licencias*. Comprobar canal de Office antes.

## 7. Fuentes

- Export CSV *Facturación → Sus productos* del tenant, 31-ago-2026 — **evidencia directa**.
- [Microsoft Copilot Business FAQ](https://learn.microsoft.com/en-us/microsoft-365/copilot/copilot-business-faq) — misma capacidad, base exigida, tope 300, no conversión.
- [New commerce promotions](https://learn.microsoft.com/en-us/partner-center/pricing/new-commerce-promotions) — FirstPurchase, trials, renovaciones.
- [Set up Microsoft Copilot and assign licenses](https://learn.microsoft.com/en-us/microsoft-365/copilot/microsoft-365-copilot-setup) — asignación, canales de Office.
- Correo de Patrick Kuhlmann (conet), 28-ago-2026 — términos NCE, 168 h, 2-jun-2027.
