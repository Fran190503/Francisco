# Clases 3 y 4 — Carga de datos

## De qué tratan

- **Clase 3.** Escribir un dataset en un archivo y volver a leerlo. El práctico A va del diccionario de Python al archivo; el práctico B lee archivos armados por otros, sin documentación.
- **Clase 4.** Cargar un CSV de datos abiertos con rutas que funcionen en cualquier máquina y hacerle un primer perfilado: identificador, faltantes y duplicados.

## Qué hay en esta carpeta

| Archivo | Qué es |
|---|---|
| `generar_archivos.py` | Script de la cátedra, sin cambios. Crea la carpeta `datos/` con los cuatro CSV del práctico B. |
| `clase03a_practico.py` | Práctico A (ejercicios 1 a 4). Consignas de la cátedra; lo que está debajo de cada `COMPLETAR` lo resolví yo. |
| `clase03b_practico.py` | Práctico B (ejercicios 5 a 8). Igual criterio. |
| `clase04_playas.py` | Carga y perfilado del CSV de playas, en Python. |
| `clase04_playas.R` | El mismo recorrido, en R. |
| `residuos_en_kg_retirados_en_playas.csv` | Kilos de residuos retirados por mes en cada playa de Montevideo. |
| `salida_*.txt` | Lo que respondió cada script en mi máquina. |

La carpeta `datos/` no está subida: se regenera con `generar_archivos.py`.

## Cómo correrlo

Parado en esta carpeta:

```
python3 generar_archivos.py
python3 clase03a_practico.py
python3 clase03b_practico.py
python3 clase04_playas.py
```

`clase04_playas.R` se corre en RStudio con *Session > Set Working Directory > To Source File Location* y el botón *Source*.

Necesita `pandas`, y `pyarrow` para la parte de parquet del ejercicio 4.

---

## Práctico A — del diccionario al archivo

| Ejercicio | Qué pedía | Resultado |
|---|---|---|
| 1. Tipos | Declarar `textura` como nominal, y `rigidez` y `certeza_observador` como ordinales. | Ninguna columna quedó como texto genérico. 6 objetos son más rígidos que "blando". La escala de certeza incluye el 1 aunque no aparezca en los datos. |
| 2. Validación | Escribir las restricciones como código. | El dataset original no tiene problemas. La copia con errores devuelve los 3 que se habían introducido: un peso no positivo, un conteo de aristas negativo y un `objeto_id` repetido. |
| 3. Diccionario de variables | Documentar las 6 variables. | 6 filas y 6 columnas, sin celdas vacías en `faltante`. |
| 4. Ida y vuelta | Guardar en CSV y volver a leer. | El CSV agregó una columna `Unnamed: 0` y `rigidez` volvió a ser texto. Guardando sin índice y volviendo a declarar el orden, quedó igual que el original. |

**Parquet (ejercicio 4, parte 3).** `rigidez` volvió del archivo como categórica ordenada, sin reconstruir nada. `certeza_observador` no: volvió como número entero y perdió la escala de 1 a 5. Parquet conserva más que el CSV, pero no todo; igual hay que revisar los tipos después de leer.

### Preguntas para la bitácora

**En `num_aristas`, un objeto esférico tiene 0. ¿Ese cero es una medición o un "no aplica"? ¿Cambia si el observador no supo contar las aristas?**

Si el observador tocó el objeto y no encontró ningún borde, el 0 es una medición: contó y dio cero. Si no pudo contar (se le acabó el tiempo, la forma era complicada), no es un cero sino un dato que falta, y la celda tendría que quedar vacía. La respuesta cambia, y el problema es que en el archivo los dos casos se ven iguales.

**¿Qué columna del diccionario habría evitado el problema del 0?**

La columna `faltante`, que dice cómo se anota un dato que falta. En mi diccionario, para `num_aristas` el faltante es la celda vacía, distinta de 0, y en `rango_valido` aclaré que 0 significa "se contó y no tiene aristas".

---

## Práctico B — del archivo al DataFrame

| Ejercicio | Qué fallaba | Resultado |
|---|---|---|
| 5. El CSV que armó Excel | Separador `;`, decimal con coma y codificación latin-1. | Con los tres argumentos, el peso se lee como número y la media da 71,6 g. |
| 6. Dónde está el archivo | La ruta dependía de la carpeta desde donde se corre. | Armé la ruta desde la ubicación del propio script y agregué un control que avisa dónde buscó. |
| 7. El -99 | Cuatro formas de anotar un faltante: `-99`, `s/d`, `NA` y celda vacía. | `read_csv()` reconoce solas dos (vacía y `NA`). Declarando las otras dos, la media del peso pasa de 48,45 g a 85,31 g. |
| 8. El archivo del equipo vecino | Punto de miles leído como decimal, nombres con espacios, fecha como texto y espacios sobrantes en `sucursal`. | La media del monto pasa de 169,28 a 1.471,50. Las sucursales pasan de 4 a 3. La fecha queda como fecha, del 02/03/2026 al 10/04/2026. |

### Preguntas para la bitácora

**Ejercicio 5. Mensaje de error del intento ingenuo y a qué causa del anexo corresponde.**

```
UnicodeDecodeError : 'utf-8' codec can't decode byte 0xed in position 107: invalid continuation byte
```

Es la causa F del anexo ("El archivo"), fila "Codificación equivocada": el archivo está guardado en latin-1 y se intentó leer como UTF-8. El byte `0xed` es la "í" de "rígido".

**¿Omitir `decimal=','` habría hecho fallar el código?**

No. El archivo se lee igual, sin ningún mensaje, y la columna del peso queda como texto (`'45,0'`, `'120,5'`). Es peor que un error, porque el código sigue adelante con datos mal tipados.

**Ejercicio 6. ¿Por qué una ruta como `C:/Users/jodavyt/Documents/GitHub/.../caja_negra.csv` rompe el trabajo en equipo?**

Porque tiene adentro el nombre de usuario y las carpetas de la computadora de quien la escribió. En cualquier otra máquina esa ruta no existe y el script falla en la primera línea. En mi salida se ve: la ruta que arma el script empieza con mi usuario, pero no la escribí yo; la calcula el script según dónde está guardado.

**Ejercicio 7. La diferencia entre las dos medias, ¿es un problema de programación o de medición?**

De medición, o más exactamente de cómo se registró el dato. El código hizo lo que se le pidió: promedió todos los números de la columna. El problema es que alguien usó `-99` para decir "no tengo el dato" y no lo dejó escrito en ningún lado. Dos celdas alcanzaron para bajar la media de 85,31 a 48,45. Se arregla con una línea de código, pero se evita con el diccionario de variables.

**Ejercicio 8. Tres afirmaciones sobre el proceso que generó el archivo y una pregunta para el equipo.**

1. Los montos se exportaron con formato en español: el punto separa los miles (`1.295`) y no hay decimales.
2. La sucursal se cargó a mano o viene de más de una fuente: "Centro" aparece con y sin espacio al final, y "Carrasco" con un espacio adelante.
3. Hay exactamente una operación por día durante 40 días seguidos, fines de semana incluidos, con identificadores correlativos del 1001 al 1040. No parece el registro completo de un comercio, sino un resumen o una muestra.

Pregunta para el equipo: ¿cada fila es una operación o es el total de un día?

---

## Clase 4 — el CSV de playas

**Origen del archivo.** No lo tengo registrado: no anoté el link ni la fecha de descarga. Es lo primero que la clase pide documentar y queda pendiente.

El CSV tiene 1.063 filas y 4 columnas (`fecha`, `playa`, `sector`, `kg_retirados`). Cubre 43 meses, de enero de 2023 a julio de 2026, y 25 playas. Los scripts de Python y de R dan los mismos números.

| Chequeo | Qué encontré |
|---|---|
| Identificador | Ninguna columna sola identifica la fila. El candidato es `fecha` + `playa`, pero hay 2 pares repetidos, los dos en marzo de 2025: Playa Buceo (7.196 kg y 0 kg) y Playa Ramírez (38.329 kg y 29.243 kg). |
| Faltantes | Uno solo: Playa Honda, febrero de 2025, sin sector. |
| Duplicados | No hay filas exactamente iguales. |
| Coherencia del sector | Dos playas figuran en los dos sectores: Capurro (41 meses Oeste, 2 Este) y Del Gas (33 Este, 9 Oeste). |
| Ceros | 182 filas con 0 kg. El archivo no dice si es "no se retiró nada" o "no se cargó el dato". |
| Cobertura | La mayoría de los meses tiene 25 playas; 12 meses tienen 24, uno tiene 23 y marzo de 2025 tiene 27 por los repetidos. |

No corregí nada: es un perfilado, no una limpieza. Antes de usar estos datos habría que decidir qué hacer con los dos pares repetidos y con el sector de Capurro y Del Gas.

---

## Qué falló

1. **Mi script de playas daba `KeyError: 'matricula_letra'`.** Lo había armado a partir del script de la clase y quedó una línea que preguntaba por una columna del archivo de la profesora, que en el CSV de playas no existe. Es la causa E del anexo ("la columna no existe").
2. **El script de R buscaba un archivo que yo no tenía**, en una carpeta `clases/clase4` que en mi repositorio no existe. Lo adapté para que lea el CSV de playas desde su misma carpeta.
3. **Ordenar los valores únicos dio `TypeError`** en el ejercicio 7: al pasar la columna a texto, el faltante sigue sin ser texto y no se puede comparar con los demás. Dejé el primer intento en el script para que se vea el error, y después la versión que funciona.
4. **`pyarrow` no estaba instalado.** La primera corrida del práctico A no pudo probar parquet. Lo instalé y volví a correr.
5. **El práctico B solo corre parado en su carpeta.** El ejercicio 6 arma su ruta desde la ubicación del script, pero los otros tres usan rutas relativas al directorio de trabajo, que vienen así en la consigna.

## Fechas y uso de IA

- Los prácticos son del comienzo del curso. Los resolví el 13/11: en su momento no llevé la bitácora al día.
- Trabajé con un asistente de IA (Claude) para completar el código y redactar este texto. Corrí todo en mi máquina; los archivos `salida_*.txt` son esas corridas.
