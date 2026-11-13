# Clase 11 — Leer un ticket con IA

## De qué trata

La clase usa un modelo de lenguaje (Gemini, de Google) para pasar la foto de un ticket a una tabla. La foto es un dato no estructurado; la tabla, uno estructurado, con una fila por ítem.

La consigna de bitácora pide hacerlo con un ticket propio, comparar lo que devuelve el modelo con una transcripción de referencia y clasificar las diferencias.

## Qué hay en esta carpeta

| Archivo | Qué es |
|---|---|
| `ticket.jpg` | La foto del ticket, con los datos personales tapados. Tienda Inglesa, 23/10/2026. |
| `leer_ticket.py` | Manda la foto a Gemini y guarda la tabla. Es el script de la cátedra con cambios de rutas y de lectura (están anotados arriba del script). La instrucción y el modelo son los mismos. |
| `respuesta_gemini.txt` | Lo que respondió Gemini, tal cual llegó. |
| `ticket_gemini.csv` | Esa respuesta pasada a tabla. |
| `ticket_a_mano.csv` | La referencia: 25 renglones y el TOTAL impreso. |
| `comparar_ticket.py` | Compara las dos tablas ítem por ítem, calcula la tasa de recuperación y el control de consistencia. |
| `salida_leer_ticket.txt` | Lo que mostró `leer_ticket.py` en mi máquina. |
| `salida_comparar.txt` | Lo que mostró `comparar_ticket.py`. |

La clave de la API no está en el repositorio. Va en un archivo `clave_gemini.txt` dentro de esta carpeta, y el `.gitignore` excluye `clave_*.txt`.

Para correrlo, con una clave propia de https://aistudio.google.com guardada en `clave_gemini.txt`:

```
python3 leer_ticket.py
python3 comparar_ticket.py
```

Necesita `requests` y `pandas`. El segundo script se puede correr sin clave, porque lee los dos CSV que ya están.

## La solicitud

| | |
|---|---|
| Fecha y hora | 13/11/2026, 13:42 |
| Modelo | `gemini-3.5-flash-lite` |
| Foto | 942 × 2048 píxeles, 281.276 bytes (375.036 caracteres en base64) |
| Código de estado | 200 |
| Temperatura | 0 |

## Resultados

**El ticket.** Tiene 25 renglones con monto: 13 productos y 12 descuentos (3 "COLECCIONABLE" y 9 "10% DTO. BPS"). Los productos suman $1.928,40, los descuentos −$230,89 y el TOTAL impreso es $1.697,51.

**La comparación.**

| | |
|---|---|
| Ítems en la referencia | 25 |
| Ítems que devolvió Gemini | 25 |
| Iguales en descripción y monto | 25 |
| Diferencias | 0 |
| Tasa de recuperación | 25 / 25 = 1,00 |
| Suma de Gemini − TOTAL impreso | 0,00 |

La foto tenía tres cosas que podían salir mal y no salieron:

- **El papel está curvado.** En la foto cada monto queda un renglón más abajo que su descripción. Gemini los emparejó bien.
- **La papa tiene un renglón de cantidad** ("2 X $169,00 C/U $338,00"). No lo devolvió como un ítem aparte: puso una sola fila con 338,00.
- **Los descuentos.** Los devolvió como filas con monto negativo, aunque la instrucción no dice nada sobre descuentos.

## Las preguntas de la bitácora

**1. Comparar la transcripción con lo que devolvió Gemini y clasificar cada diferencia.**

No hubo diferencias, así que no hay nada para clasificar: ninguna sustitución, omisión, inserción, error de estructura ni alucinación.

Sobre la referencia: sale de la misma foto que leyó Gemini, así que la controlé contra el ticket en papel, renglón por renglón. Sin ese control, que las dos tablas coincidan probaría poco.

**2. ¿Cuántos tokens de entrada usó la solicitud? ¿Cuántos corresponden a la imagen?**

| | Tokens |
|---|---|
| Entrada (`promptTokenCount`) | 1.184 |
| — de la imagen | 1.078 |
| — de la instrucción | 106 |
| Salida | 405 |

El 91 % de la entrada es la foto. La respuesta trae ese reparto en `promptTokensDetails`.

Dos cosas que miré contra el teórico:

- La instrucción tiene 340 caracteres en 106 tokens: 3,2 caracteres por token, cerca de los 4 que da el teórico. La respuesta tiene 669 caracteres en 405 tokens: 1,7 por token. Tiene sentido: está en mayúsculas y llena de números, y los números se cortan dígito por dígito.
- El teórico dice que cada mosaico de la imagen cuenta 258 tokens. 1.078 no es múltiplo de 258 (4 mosaicos serían 1.032 y 5 serían 1.290). No sé cómo cuenta las imágenes este modelo. Queda como pregunta.

**3. ¿Cierra el control de consistencia? Si cierra, ¿alcanza para confiar en la tabla?**

Cierra: los 25 montos suman 1.697,51, igual al TOTAL impreso.

No alcanza solo. La suma no mira las descripciones, dos errores que se compensan también cierran, y el modelo puede acomodar un número para que cierre. En este caso confío en la tabla por la comparación ítem por ítem, no por la suma.

Este ticket permite otro control que no depende del total: cada uno de los nueve descuentos de 10 % es justo el 10 % del producto de arriba (249,00 → 24,90; 50,90 → 5,09). Se cumple en los nueve.

**4. ¿Hubo alguna alucinación? ¿Qué regla del prompt debió evitarla?**

No encontré ninguna. No hay ningún ítem ni monto sin respaldo en la foto, y ningún monto quedó vacío.

La regla que apunta a la alucinación es la última de la instrucción: "si algo no se puede leer, dejalo vacío; no lo inventes". En esta foto todo se leía, así que la regla no llegó a ponerse a prueba.

**5. ¿Qué datos personales tapaste antes de subir la foto?**

- Los últimos cuatro dígitos de la tarjeta.
- El bloque "Mis puntos": número de cliente y puntos.

El ticket no tiene nombre ni cédula. Quedaron a la vista los datos del comercio y los números de ticket y de autorización. La foto no tenía datos de ubicación.

## Qué falló

1. **Abrí `ticket_a_mano.csv` con doble clic y se abrió en Numbers,** que lo guarda en otro formato. Lo edité como texto en RStudio.
2. **La clave quedó a la vista en una captura de pantalla.** No llegó al repositorio, pero una clave que se vio ya no es secreta: la borré en AI Studio al terminar.

## Decisiones

- **Los descuentos van como filas con monto negativo.** Así la suma de las filas da el TOTAL impreso y el control de consistencia se puede hacer.
- **Guardo la respuesta de Gemini antes de tocarla.** `respuesta_gemini.txt` es lo que llegó; `ticket_gemini.csv` es lo que armó mi script. Si hay un error, se puede ver de cuál de los dos es.
- **Para comparar descripciones no cuento diferencias de mayúsculas ni de espacios.**
- **La clave, en un archivo que git ignora.** La excluí en el `.gitignore` antes de crearla.

## Lo que me llevo

- Que salga todo bien en un ticket no dice cuánto se equivoca el modelo. Es una sola foto, nítida y sin nada borroso. Para medirlo harían falta muchos tickets, y alguno desteñido o arrugado.
- La referencia vale lo que vale su control. Si sale del mismo lugar que lo que se quiere evaluar, hay que contrastarla con otra cosa: acá, el papel.
- El control de consistencia es barato y detecta ítems que faltan o sobran, pero cerrar no es lo mismo que estar bien.
- Subir una foto a la API es mandársela a un tercero. Lo que hay que tapar se decide antes de enviarla.

---

Uso de IA: trabajé con un asistente (Claude) para el código, tapar la foto, la transcripción y la redacción. Corrí todo en mi máquina.
