# Case report — Maswer / Rotación de contraseña de la cuenta de rol TLSMP

- **Cliente:** Maswer Spain SL
- **Solicitante:** Sebastian Lazarte Castellón (IT interno) — tarea interna, sin ticket de cliente
- **Cuenta afectada:** `TLSMP@maswer.com` — "Team Leader SMP", **cuenta de rol compartida**
- **Fecha:** 28-ago-2026
- **Estado:** CERRADO en cuanto a la contraseña — aplicada y verificada en on-prem y en
  autenticación cloud. **El segundo factor (MFA) queda sin revisar por decisión expresa** —
  ver "Decisiones tomadas al cierre".

---

## Triaje

| Campo | Valor |
|---|---|
| Categoría | Accounts and Access (rotación de credencial) |
| Prioridad | P3 - Media |
| Grupo | N1 — sin escalado |
| Ventana de mantenimiento | No procede — ver justificación |

---

## Motivo

La contraseña se puso el **23-oct-2024** y **nadie la conoce**. El **14-ago-2026 a las 11:11**
hubo un intento de inicio de sesión fallido en dos DCs (`badPwdCount` = 1), lo que encaja con
que alguien la necesitó y no pudo entrar.

---

## Diagnóstico previo (verificado, solo lectura)

| Dato | Valor | Consecuencia |
|---|---|---|
| DN | `CN=Team Leader SMP,OU=BCN,OU=ES,OU=User Accounts,OU=Office365` | Cuenta on-prem |
| `ms-DS-ConsistencyGuid` | Presente | Sincronizada por AAD Connect (`MEUAZAC011`) |
| `msExchRemoteRecipientType` | 1 | Buzón en Exchange Online (híbrido) |
| `userAccountControl` | 66048 | Habilitada + contraseña sin caducidad |
| Grupos | `MFA-MASWER`, `SSL_VPN`, `Webfilter_Standard`, `Masw_ALL_Intranet_R`, `TPLINK_User` | Tiene MFA obligatorio |
| Último inicio de sesión real | 08-jun-2026 (solo en `MEUAZDC011`) | Uso muy esporádico |
| TGT emitidos en 14 días | **0** | Nada la usaba |
| Sesiones SMB abiertas | Ninguna | El reset no cortaba ninguna sesión |

**Sin ventana de mantenimiento:** cero autenticaciones en 14 días, cero sesiones abiertas, y el
cambio es reversible repitiendo el reset. Impacto en servicio nulo.

---

## Hallazgo que cambió el procedimiento

Al leer la configuración de `MEUAZAC011`:

- **Password Hash Sync: DESACTIVADO**
- **Agente de Pass-through Authentication: instalado y en ejecución**

Maswer autentica con **PTA**, no con sincronización de hash. Consecuencia práctica: **la
contraseña no se sincroniza a M365 en ningún momento** — Entra reenvía cada intento al AD
on-prem y lo valida allí en tiempo real. El cambio es **efectivo en M365 de forma inmediata**,
sin depender de ningún ciclo de sincronización.

El paso del plan que forzaba `Start-ADSyncSyncCycle` era, por tanto, **innecesario para la
contraseña**. Se ejecutó igualmente y sin efectos adversos, pero queda corregido para futuras
rotaciones.

---

## Acción ejecutada

1. Contraseña generada localmente, 22 caracteres, aleatoriedad criptográfica
   (`RandomNumberGenerator`), con mayúsculas, minúsculas, dígitos y símbolos, sin caracteres
   ambiguos. **No se mostró en pantalla ni se escribió en este informe.**
2. `Set-ADAccountPassword -Reset` sobre `MDERZADC003`.
   - **Sin** `-ChangePasswordAtLogon`: en una cuenta compartida obligaría a que el primero en
     entrar fijase una contraseña que nadie más conocería.
   - **Sin** tocar el flag de caducidad: `uac` sigue en 66048 (verificado antes y después).
3. `Sync-ADObject` hacia `MDERZADC004` y `MEUAZDC011`.
4. `Start-ADSyncSyncCycle -PolicyType Delta` en remoto sobre `MEUAZAC011`. El servicio `ADSync`
   **no se reinició** → no procede la alerta de Defender "Entra Connect Sync tampering".
5. Contraseña guardada en fichero temporal **fuera del repositorio**, para traslado a su
   ubicación definitiva y borrado posterior.

---

## Verificación

| Comprobación | Resultado |
|---|---|
| `pwdLastSet` en los tres DCs | 28-ago-2026 09:48:16 en `MDERZADC003`, `MDERZADC004`, `MEUAZDC011` |
| `userAccountControl` | 66048 — sin cambios respecto al estado previo |
| Habilitada / bloqueada | Habilitada, no bloqueada |
| **Validación real de la credencial** | `ValidateCredentials` contra los tres DCs → **VÁLIDA en los tres** |
| Servicio ADSync | `Running`, sin reinicio |

La validación contra el DC es exactamente la operación que ejecuta el agente PTA cuando alguien
inicia sesión en M365. La parte de contraseña está cerrada.

---

## Decisiones tomadas al cierre (28-ago-2026)

**Custodia:** resuelta. El técnico traslada la contraseña a su ubicación y elimina el fichero
temporal. No queda copia en el repositorio ni en ningún canal de ticket.

**Segundo factor: aplazado deliberadamente.** La cuenta pertenece a `MFA-MASWER`. En una cuenta
compartida el método de MFA está registrado en el dispositivo de **una persona concreta**, y el
reset de contraseña **no lo toca**.

> **Riesgo asumido y aceptado:** quien intente usar `TLSMP` puede quedarse bloqueado en el
> segundo factor **pese a tener la contraseña correcta**. Si eso ocurre, no es un fallo del
> reset: es este punto. Resolverlo requiere el módulo `Microsoft.Graph.Identity.SignIns` — no
> instalado en el equipo del técnico — y permisos en Entra para consultar o re-registrar el
> método de autenticación.

---

## Hallazgos colaterales (requieren ticket propio)

1. **Error crónico de exportación en AAD Connect.** El conector `intern.maswer.com` termina el
   perfil `Export` **con 1 error en cada ciclo**: 160 eventos 6100 en 7 días (43 el 25-ago, 48
   el 26, 48 el 27, 21 el 28). Es **anterior a esta intervención** y no guarda relación con
   ella. Hay un objeto atascado que nadie ha revisado.

2. **Las cinco cuentas de rol comparten el mismo problema de fondo:** compartidas, sin rotación
   y sin custodia definida.

   | Cuenta | Nombre | Contraseña desde |
   |---|---|---|
   | `TLusa` | Team Leader USA | dic-2022 |
   | `TLeader` | Team Leader | ene-2024 |
   | `TLSMP` | Team Leader SMP | **rotada hoy** |
   | `TLAgs` | Teamleader Aguascalientes | jul-2025 |
   | `TLSaltillo` | Teamleader Saltillo | jul-2025 |

   Ninguna caduca. Merece una propuesta de modelo: cuentas nominales con buzón compartido, o
   custodia formal en gestor de contraseñas.
