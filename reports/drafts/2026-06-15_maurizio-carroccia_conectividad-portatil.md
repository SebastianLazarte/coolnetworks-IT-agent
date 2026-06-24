# Reporte de caso — Maurizio Carroccia / Problema de conectividad en portátil

- **Cliente:** Maswer GmbH
- **Usuario final:** Maurizio Carroccia
- **Técnico asignado:** Sebastian Lazarte (CoolNetworks)
- **Fecha de apertura:** 15-jun-2026
- **Origen:** Escalado por dirección (correo de Carlos, CEO, revisión del primer mes de servicio)
- **Estado actual:** Abierto · pendiente de diagnóstico

---

## Triage del ticket

| Campo | Valor |
|---|---|
| Categoría | Red / Conectividad |
| Prioridad | P2 — Alta (usuario con problema activo sin resolver) |
| Grupo | N1 diagnóstico inicial → N2 Sistemas si aplica |
| SLA respuesta | 30 min desde apertura |

---

## Contexto

El CEO de Maswer, Carlos, indicó en la reunión de revisión del primer mes de servicio (15-jun-2026) que Maurizio Carroccia **continúa teniendo un problema de conectividad en su portátil pendiente de resolver**.

No se ha podido determinar aún si es la misma incidencia anterior o una nueva. El problema no estaba registrado como ticket activo en la plataforma.

---

## Síntomas conocidos

- Conectividad intermitente o degradada en el portátil de Maurizio.
- Duración: al menos varias semanas (activo desde antes de la revisión del primer mes).
- Impacto operativo en el usuario: pendiente de cuantificar.

> **Pendiente:** contactar a Maurizio para recopilar síntomas concretos (cuándo ocurre, si afecta a Wi-Fi / LAN / VPN, comportamiento exacto).

---

## Diagnóstico inicial — preguntas abiertas

1. ¿El problema es de Wi-Fi, LAN por cable, VPN o los tres a la vez?
2. ¿Es intermitente (se cae y se recupera) o permanente?
3. ¿Ocurre en una ubicación concreta o en cualquier red?
4. ¿Otros equipos en la misma red funcionan correctamente?
5. ¿Se reinició el portátil recientemente? ¿Hay actualizaciones pendientes de Windows / drivers de red?
6. ¿El problema apareció tras algún cambio reciente (actualización, configuración, traslado del equipo)?

---

## Próximos pasos

- [ ] Contactar a Maurizio para recopilar síntomas y reproducir el problema.
- [ ] Verificar drivers de red (Wi-Fi / Ethernet) en el equipo.
- [ ] Revisar el adaptador de red en Device Manager (errores, advertencias).
- [ ] Comprobar configuración de red (IP, DNS, gateway) y compararla con otro equipo funcional.
- [ ] Si aplica: revisar logs de eventos de Windows relacionados con la red.
- [ ] Si el problema persiste: valorar reinstalación de drivers o revisión de hardware de red.

---

## Comunicaciones

- [ ] Informar a Maurizio de la apertura del ticket y solicitar ventana de diagnóstico.
- [ ] Actualizar a dirección (Oliver / Carlos) con el estado una vez completado el diagnóstico inicial.

---

## Notas

- Este ticket se abre a partir de un escalado de dirección, no de una solicitud directa del usuario. Es importante contactar cuanto antes para demostrar seguimiento proactivo.
- La falta de registro previo como ticket activo es en sí un punto de mejora en el proceso de seguimiento de incidencias abiertas.
