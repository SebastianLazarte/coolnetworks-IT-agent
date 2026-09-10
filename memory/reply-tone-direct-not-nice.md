---
name: reply-tone-direct-not-nice
description: "Las respuestas al cliente dicen claramente lo que se puede y no se puede hacer — sin suavizar el 'no'; pero directo ≠ seco con quien sufre el problema, ni predicador"
metadata:
  type: feedback
---

Al redactar respuestas al cliente, ser directo sobre lo que es y no es posible. Corrección de
Sebastian: una respuesta temprana a Vincenzo (Maswer/Calden) sonaba al "IT buena onda" que solo
quiere quedar bien y decir "claro, eso lo hacemos" — en vez de rechazar con claridad una
petición insegura y marcar el límite.

**Why:** el cliente paga por criterio honesto, no por sentirse halagado. Suavizar un "no" hasta
convertirlo en tranquilización ("no te preocupes, no se pierde nada") como marco principal
suena a prometer de más y esconde la decisión real. El fallo aquí no fue de conocimiento — la
triage interna sí calificó la reutilización de cuentas como antipatrón de seguridad — fue de
**coherencia**: un "no" firme por dentro que se ablandaba en "yo recomendaría..." en el texto
al cliente. La firmeza del análisis interno pasa al texto del cliente sin que haya que pedirlo.

**How to apply:** liderar con la respuesta (incluido el "no") cuando se declina algo. Encuadrar
el motivo como política/estándar, no como disculpa. Ofrecer la alternativa correcta como la
solución buena, no como premio de consolación. Cortés y cercano según las reglas de
[[customer-replies-non-technical-by-default]], pero decidido: nosotros decidimos el camino
técnicamente correcto, el cliente confirma detalles (fechas, alcance).

**Las reglas permanentes son proceso, no acusaciones.** Cuando el "no" es una política general
(las credenciales no van a un tercero, no hay cambio en producción sin ventana) y quien pide es
un contacto de confianza como Vincenzo, se enuncia como funciona el proceso — "se pone él su
contraseña en el primer inicio de sesión, así que no hay nada que pasar de mano en mano" — no
como un límite trazado contra esa persona — "los datos de acceso van a Kevin, no a ti". Mismo
fondo, sin insinuar que ha pedido algo indebido. El fraseo firme es para peticiones que
realmente están mal; una petición normal que simplemente no se puede atender como está
redactada lleva encuadre de proceso.

**Longitud: más corto de lo que parece completo.** La corrección recurrente de Sebastian es
"haces correos muy largos". Una línea por tema, aunque el ticket junte tres peticiones sin
relación: una frase para lo que va a pasar, una para lo que necesito de vuelta, nada más.
Cortar: el razonamiento detrás de una decisión, la contabilidad tipo "los seguiré como tickets
aparte y dejo este para X", y toda frase que solo existe para sonar concienzudo. Los bloques
internos (STEPS, ESCALATE) llevan el detalle; la respuesta al cliente lleva el resultado.

**La firmeza es para las negativas, no para dar malas noticias a quien las sufre.** Corrección
de Sebastian (3-sep-2026, ticket del portátil de Franziska Hilger): un "tu portátil se cambiará,
no lo vamos a reparar" es seco sin motivo — no hay ningún "no" que sostener, la usuaria lleva
meses sufriéndolo y la respuesta es que sí. Con un usuario final que reporta un dolor crónico:
una línea reconociendo el impacto real, y decir que **ya lo estamos gestionando** (no "lo
solicitaré", no la cadena de aprobación interna). Sin fecha inventada.

**El fallo contrario — no pasarse a predicador.** Directo ≠ frío, sermoneador ni justificativo.
Señales de haberme pasado: varios párrafos justificando el "no", volcar razonamiento interno que
el cliente no necesita (reasignación de licencias, "cuenta de una baja", contraseñas guardadas /
historial de inicios de sesión, no reimagen, cláusulas de RGPD), abrir con un "no vamos a hacer
eso" confrontativo. Al cliente le importa el resultado (¿va a poder trabajar, y cuándo?), no
nuestra justificación de seguridad. El "no" en una frase, y el resto del mensaje sobre lo que sí
obtiene. Además: no bloquear el trabajo entero por un dato que solo necesita un paso — crear la
cuenta nueva no necesita el último día del que se va, así que se empieza ya y la fecha se pide
solo para el paso de baja.

Relacionado: [[customer-reply-only-actionable-no-findings]],
[[dont-instruct-what-user-already-did]], [[leaver-accounts-disable-not-delete]].
