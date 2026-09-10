---
name: defer-to-direct-console-evidence
description: "No refutar el diagnóstico de un ingeniero del proveedor con inferencia sacada de su informe escrito — caso HEF01: su diagnóstico de firmware era correcto y el mío no"
metadata:
  type: feedback
---

El 2026-08-17 Maik Kantz (conet.de) diagnosticó una caída de WiFi en toda la sede HEF01 como un
fallo de detección de RED en SFOS 21.5.0 GA-Build171, y recomendó actualizar a 21.5 MR2.
Argumenté largo y tendido que estaba equivocado — que la teoría del firmware explicaba solo el
artefacto de visualización "n/a" y no la caída que sufrían los usuarios, y que las renovaciones
DHCP cada 2 minutos más el LED rojo apuntaban a un RED ciclando sobre hardware defectuoso.
**La actualización lo arregló. No se tocó ningún hardware.**

**Why:** Maik tenía los logs de DHCP, la vista de REDs en el XGS, la comparación entre
dispositivos del mismo appliance y el conocimiento del problema documentado en ese build. Yo
tenía una captura de pantalla de ese correo. Monté una historia rival a base de inferencia y la
entregué en un registro que la evidencia no sostenía — y el punto que empujé con más fuerza
("ha diagnosticado el artefacto de monitorización, no la caída") era el más equivocado, porque
la asociación fallida del RED **era** la caída. El tono seguro amplificó el error en vez de
señalarlo. También leí su razonamiento sin caridad: el "dado que varios otros REDs funcionan
bien… por tanto actualizar" no estaba del revés, argumentaba que el XGS está sano en general y
que un arreglo de software es el siguiente paso proporcionado antes que mandar hardware.

**How to apply:** cuando un ingeniero con acceso directo a consola da un diagnóstico, tratar mi
inferencia rival como **hipótesis a contrastar, no como refutación** — y nombrar explícitamente
qué evidencia tiene cada parte antes de tomar partido. Reservar el registro seguro para lo que
he verificado yo mismo. Donde su razonamiento parezca flojo, buscar primero la lectura caritativa
que lo hace correcto. Relacionado: [[separate-evidence-from-pattern]],
[[conet-de-administers-maswer-infra]], [[maswer-vpn-sophos]].
