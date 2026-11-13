# Clase 6 — Encuesta

## De qué trata

Una pregunta de encuesta es una medición: según cómo se redacta, cambia lo que la gente responde y cambia la tabla que queda al final.

La clase recorre los tipos de pregunta y la variable que genera cada uno, las reglas de redacción, el orden del cuestionario y el libro de códigos.

Esta carpeta no tiene código. Tiene los dos ejercicios de la clase, resueltos por escrito.

---

## Ejercicio 1 — Seis preguntas con problemas

Para cada una: cuál es el problema, cómo la reescribiría, y qué variable y cuántas columnas produce.

### 1. "¿Está conforme con lo que gasta en comida y en transporte?"

**Problema.** Son dos preguntas en una. Quien está conforme con lo que gasta en comida pero no con el transporte no tiene cómo responder.

**Reescritura.** Separarla en dos, con la misma escala:

> ¿Qué tan conforme está con lo que gastó en comida en los últimos 30 días?
> 1 Nada conforme · 2 · 3 · 4 · 5 Muy conforme
>
> ¿Qué tan conforme está con lo que gastó en transporte en los últimos 30 días?
> 1 Nada conforme · 2 · 3 · 4 · 5 Muy conforme

**Variable.** Dos columnas ordinales.

### 2. "¿No le parece que gasta demasiado en salidas?"

**Problema.** Induce la respuesta: la palabra "demasiado" ya opina. Además tiene una negación, y contestar "no" puede querer decir las dos cosas.

**Reescritura.**

> ¿Cuánto gastó en salidas en los últimos 30 días? $ ____

**Variable.** Una columna cuantitativa. Si se teme que la gente no recuerde el monto, se puede preguntar por tramos, y entonces sería ordinal.

### 3. "¿Cuánto gastó últimamente en ropa?"

**Problema.** No tiene período de referencia. "Últimamente" es una semana para uno y seis meses para otro, y las respuestas no se pueden comparar.

**Reescritura.**

> ¿Cuánto gastó en ropa en los últimos 30 días? $ ____

**Variable.** Una columna cuantitativa.

### 4. "Gasto en transporte: ☐ $0 a $1.000 ☐ $1.000 a $3.000 ☐ $3.000 a $6.000"

**Problema.** Los tramos se pisan: $1.000 y $3.000 caen en dos casillas. Y no cubren todo: quien gastó más de $6.000 no tiene dónde marcar. Tampoco dice en qué período.

**Reescritura.**

> ¿Cuánto gastó en transporte en los últimos 30 días?
> ☐ Nada ☐ Hasta $1.000 ☐ $1.001 a $3.000 ☐ $3.001 a $6.000 ☐ Más de $6.000

**Variable.** Una columna ordinal. Separé "Nada" de "Hasta $1.000" porque no gastar es distinto de gastar poco.

### 5. "¿Cómo paga sus gastos? ☐ Efectivo ☐ Tarjeta ☐ Ambos ☐ Transferencia"

**Problema.** Es una selección múltiple disfrazada. La opción "Ambos" muestra que se puede responder más de una cosa, y con tres medios de pago ni siquiera queda claro cuáles dos son "ambos".

**Reescritura.**

> ¿Con qué medios pagó sus gastos en los últimos 30 días? Marque todos los que correspondan.
> ☐ Efectivo ☐ Tarjeta ☐ Transferencia

**Variable.** No es una variable sino tres columnas binarias, una por medio de pago.

### 6. (Primera pregunta del cuestionario) "¿Cuál es el ingreso mensual exacto de su hogar?"

**Problema.** Son dos. Es una pregunta sensible puesta al principio: si la persona abandona ahí, se pierde todo el cuestionario. Y pide una precisión que casi nadie tiene: pocos saben el ingreso exacto de todo el hogar.

**Reescritura.** Pasarla al final y preguntar por tramos:

> ¿En cuál de estos tramos está el ingreso mensual de su hogar?
> ☐ Hasta $40.000 ☐ $40.001 a $80.000 ☐ $80.001 a $150.000 ☐ Más de $150.000 ☐ Prefiere no responder

**Variable.** Una columna ordinal. Los cortes de los tramos los puse yo como ejemplo; en una encuesta real habría que fijarlos con datos de ingresos.

### Libro de códigos de las preguntas reescritas

Las seis preguntas originales pasan a ser siete y producen nueve columnas.

| Variable | Tipo | Valores | Faltante |
|---|---|---|---|
| `conforme_comida` | ordinal | 1 < 2 < 3 < 4 < 5 | NA |
| `conforme_transporte` | ordinal | 1 < 2 < 3 < 4 < 5 | NA |
| `gasto_salidas` | cuantitativa | pesos, mayor o igual a 0 | NA |
| `gasto_ropa` | cuantitativa | pesos, mayor o igual a 0 | NA |
| `gasto_transporte_tramo` | ordinal | Nada < Hasta 1.000 < 1.001 a 3.000 < 3.001 a 6.000 < Más de 6.000 | NA |
| `pago_efectivo` | binaria | 0, 1 | NA |
| `pago_tarjeta` | binaria | 0, 1 | NA |
| `pago_transferencia` | binaria | 0, 1 | NA |
| `ingreso_hogar_tramo` | ordinal | Hasta 40.000 < 40.001 a 80.000 < 80.001 a 150.000 < Más de 150.000 | NA si no contestó; "Prefiere no responder" se guarda con un código aparte |

---

## Ejercicio 2 — De la tabla al cuestionario

La consigna da la tabla que se quiere obtener de una encuesta a clientes de la cafetería de la facultad (13 columnas) y pide escribir el cuestionario que la produce.

### Cuestionario

1. En los últimos 30 días, ¿cuántas veces compró en la cafetería de la facultad?
   ☐ Nunca ☐ 1 a 3 veces ☐ 4 a 8 veces ☐ Más de 8 veces
   *Si marcó "Nunca", pase a la pregunta 5.*
2. En esos 30 días, ¿qué compró? Marque todo lo que corresponda.
   ☐ Café ☐ Comida ☐ Bebidas frías ☐ Otros
3. ¿Cómo calificaría la atención que recibió en esos 30 días?
   1 Muy mala · 2 · 3 · 4 · 5 Muy buena
4. En esos 30 días, ¿con qué medios pagó? Marque todos los que correspondan.
   ☐ Efectivo ☐ Tarjeta ☐ Transferencia
5. ¿Es estudiante de esta facultad?
   ☐ Sí ☐ No
6. ¿Qué mejoraría de la cafetería? ____________
7. ¿Cuántos años tiene? ____

### De qué pregunta sale cada columna

| Pregunta | Columnas que produce | Cantidad |
|---|---|:-:|
| (número de formulario) | `id` | 1 |
| 1 | `frecuencia` | 1 |
| 2 | `prod_cafe`, `prod_comida`, `prod_frias`, `prod_otros` | 4 |
| 3 | `atencion` | 1 |
| 4 | `pago_efectivo`, `pago_tarjeta`, `pago_transferencia` | 3 |
| 5 | `estudiante` | 1 |
| 6 | `mejora` | 1 |
| 7 | `edad` | 1 |
| | **Total** | **13** |

Siete preguntas, trece columnas.

### Control contra lo que pide la consigna

| Qué se verifica | Cómo quedó |
|---|---|
| Período de referencia | Las preguntas 1 a 4, que son las de conducta, se refieren a los últimos 30 días. |
| Filtro después de `frecuencia` | Quien marca "Nunca" salta a la pregunta 5. |
| `prod_*` y `pago_*` como selección múltiple | Preguntas 2 y 4, con "marque todo lo que corresponda" y sin opción "ambos". |
| `atencion` con extremos etiquetados | 1 Muy mala y 5 Muy buena: más alto es mejor. |
| `edad` al final | Es la pregunta 7. |

### Los faltantes que deja el filtro

Quien responde "Nunca" en la pregunta 1 no contesta la 2, la 3 ni la 4. Esas ocho columnas le quedan vacías por diseño, no porque no haya querido responder. En la tabla hay que poder distinguir ese vacío del de alguien que debía contestar y no lo hizo.

---

## Decisiones

| Decisión | Alternativa descartada | Por qué |
|---|---|---|
| En la pregunta 2 del ejercicio 1, preguntar el monto gastado. | Preguntar la opinión con una escala. | La original quería saber si gasta mucho; el monto lo mide sin sugerir la respuesta. |
| Usar "los últimos 30 días" en todas las preguntas. | "En un mes típico". | Uno pide recordar y el otro estimar; hay que elegir uno y sostenerlo en todo el cuestionario. |
| Ingreso del hogar por tramos y al final. | Monto exacto. | Se pierde precisión, pero responde más gente. No se puede deshacer después de salir a campo. |

## Lo que me llevo

- El problema de una pregunta mal hecha no se ve en la pregunta sino en la tabla: columnas que mezclan dos cosas, tramos donde un valor cae dos veces, textos que después hay que separar a mano.
- Conviene diseñar primero la tabla que se quiere y después las preguntas, que es lo que obliga a hacer el ejercicio 2.
- Una celda vacía puede ser tres cosas distintas: no corresponde, no quiso responder o se salteó la pregunta. Si no se anota cuál es, después no hay forma de saberlo.

---

Uso de IA: trabajé con un asistente (Claude) para resolver los ejercicios y redactar el texto.
