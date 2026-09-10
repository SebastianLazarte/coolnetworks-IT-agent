---
name: maswer-m365-copilot-licensing
description: "Licenciamiento Copilot en Maswer. La base es Microsoft 365 Business (218 puestos), NO E3/E5 → Copilot Business SÍ es elegible (218,40 €/año). Compra vía conet (Patrick Kuhlmann), no ADN."
metadata:
  type: reference
---

> **Este fichero corrige una conclusión anterior errónea.** Hasta el 31-ago-2026 se dio por
> hecho que la base de Maswer era **enterprise (E3/E5)** — inferido de indicios de producto
> (Defender P2, Purview, AVD, 14 sedes) — y de ahí que Copilot Business y su trial gratuito
> **no** aplicaban. **Era falso.** El export CSV real de *Facturación → Sus productos* lo
> desmintió. **Lección: no inferir el plan base desde indicios de producto** — el CSV lo
> resuelve en 30 s. Ver [[separate-evidence-from-pattern]].

## Base real de licenciamiento (export CSV, 31-ago-2026)

Maswer está **íntegramente en planes Microsoft 365 Business**:

| Producto | Asignadas | Compradas | Renueva |
|---|---|---|---|
| Microsoft 365 Business Premium | 156 | 189 | 17-sep-2026 |
| Microsoft 365 Business Basic | 23 | 27 | 17-sep-2026 |
| Microsoft 365 Business Standard | 1 | 2 | 24-may-2027 |
| Microsoft 365 Copilot (SKU enterprise) | 1 | 1 | **2-jun-2027** |

Otros: Defender for Office 365 P1 (9), Power BI Pro (5), Visio Plan 2 (4), Planner/Project
Plan 3 (1). Perfil de facturación: **ADN**, canal "Comercial directo", casi todo con
**facturación mensual** (= +5%). **Total puestos Business comprados: 218.**

## Consecuencia

- **Microsoft 365 Copilot Business SÍ es elegible** (base Business + 218 puestos < 300) y **el
  trial gratuito de 1 mes también**. Mismo motor, mismos agentes Researcher/Analyst, mismo
  grounding en Graph; la diferencia con el SKU enterprise es gobernanza/cumplimiento y el tope
  de 300 puestos.
- Maswer **ya tiene contratada 1 licencia del SKU enterprise** *Microsoft 365 Copilot*. Añadir
  usuarios a esa suscripción = añadir puestos, no contratar producto nuevo.
- **"Copilot Pro" no existe como opción**: es producto de consumo ligado a cuentas Microsoft
  personales, no se vende por CSP ni se asigna en el tenant.

## Precios del catálogo (EUR, ago-2026), verificados aritméticamente

| SKU | Mensual | Anual adelantado |
|---|---|---|
| Microsoft 365 Copilot (enterprise) | 27,30 € | **312,00 €** (3 años: 936,00 €) |
| Microsoft 365 Copilot **Business** | 19,11 € | **218,40 €** (término 1 mes: 21,84 €) |

- **Facturar mensualmente cuesta exactamente +5%** en ambos SKU (27,30×12 = 327,60 vs 312,00;
  19,11×12 = 229,32 vs 218,40). No compra flexibilidad: el término anual sigue atado.
- **El término de 3 años no tiene descuento:** 936 ÷ 3 = 312 €, idéntico al anual. Solo blinda
  el precio. **P3Y descartado para Maswer**: exige ~100 licencias mínimo por producto, y el 15%
  a 3 años pide 300+. Con 10 puestos no aplica — el término anual no es preferencia, es la
  única opción.
- Existe oferta **"–15% hasta 10 puestos"** que **muestra el mismo precio** que el SKU estándar
  → hay que **llegar al checkout** para ver si se aplica.

## Canal de compra (confirmado 28-ago-2026, ADN ticket #269249)

`Microsoft → ADN Distribution (distribuidor) → CONET Services GmbH (reseller) → Maswer`.

**ADN no atiende a cliente final y rebota** — figura en el tenant solo como *support contact*,
etiqueta de trazabilidad de Microsoft. **Todas las licencias se piden a conet.de**, el mismo
proveedor que lleva la infraestructura → [[conet-de-administers-maswer-infra]].

**Contacto comercial: Patrick Kuhlmann**, Junior Account Manager, Sales — `PKuhlmann@conet.de`.
Responde con especialista de licencias Microsoft detrás. Es el interlocutor para licencias, **no
Stefan ni Kevin** (técnicos).

## Oferta cerrada 28-ago-2026 — y por qué revisarla

conet iguala el 15% por su canal CSP → **265,20 €/lic/año · 2.652 €/año por 10 puestos** (12
meses, pago anual adelantado), sobre el **SKU enterprise**. La promo del Admin Center es
independiente del canal CSP y conet no puede validarla.

⚠️ **Abierto:** esa oferta se negoció bajo la premisa falsa de base E3/E5. Con la base real
Business, **Copilot Business a 218,40 € es más barato que los 265,20 € pactados** y es elegible.
Antes de cursar o renovar, contrastar los dos SKU con Patrick Kuhlmann.

**Reglas NCE de promociones** (Microsoft Learn, `partner-center/pricing/new-commerce-promotions`,
act. 20-ago-2026 — verificadas 31-ago-2026):
- La promo se mantiene en la renovación **solo si la fecha de renovación cae dentro del periodo
  de vigencia** de la promoción; fuera de él, renueva a tarifa de lista.
- ⚠️ **Restricción `FirstPurchase` / new-to-offer:** si el SKU **ya está aprovisionado en el
  tenant** (o lo estuvo en el último año), la promo **no aplica**. **Maswer ya tiene 1 licencia
  de Copilot** → riesgo real de no ser elegible al 15%. Lo verifica el partner con
  `VerifyPromotionEligibilities`, no el cliente.
- Si el término de la compra no coincide con el de la promo → **precio sin promoción**.
- Promos solapadas sobre el mismo SKU → se aplica automáticamente **la más profunda**. La doc
  cita para Copilot una *"Limited Time Offer: M365 Copilot for All – 30% off"* junto a la del
  15% → siempre preguntar si hay una mejor.
- Licencias añadidas a una suscripción con promo entran **al precio de promo** mientras la
  ventana siga abierta.
- **NCE: cancelación dentro de 168 h** tras cursar el pedido; después, comprometido 12 meses y
  reducción de puestos solo en renovación. **No hay co-terminación**: la suscripción Copilot
  existente renueva el 2-jun-2027.

**How to apply:** ante cualquier petición de Copilot en Maswer, primero abrir *Administrar* en
la suscripción existente y mirar puestos contratados vs. asignados — puede que no haya que
comprar nada. El criterio de licencia también decide qué opciones aparecen en los portales
([[dont-invent-portal-navigation]]). Ver [[defer-to-direct-console-evidence]].
