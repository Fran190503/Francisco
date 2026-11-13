# Clase 5 — Seudocódigo

## De qué trata

El seudocódigo es escribir los pasos de un programa en palabras, en orden, antes de pasarlos a un lenguaje. Sirve para pensar la lógica sin trabarse con paréntesis y comas.

En clase se vieron dos ejemplos: leer un CSV probando otra codificación si la primera falla, y filtrar un vector de temperaturas. El ejercicio era pasar el segundo a código.

## Qué hay en esta carpeta

| Archivo | Qué es |
|---|---|
| `filtrar_temperaturas.py` | El ejercicio de la clase en Python, en dos versiones. |
| `filtrar_temperaturas.R` | El mismo ejercicio en R, en dos versiones. |
| `ingesta_con_control.py` | El seudocódigo de la lectura con control de codificación, pasado a código y probado. |
| `salida_*.txt` | Lo que respondió cada script en mi máquina. |

La carpeta `datos/` no está subida: la crea `ingesta_con_control.py` cada vez que corre.

## Ejercicio: filtrar temperaturas

El seudocódigo recorre el vector `[18, 22, 15, 25, 30]` y se queda con los valores mayores a 20.

Lo pasé a código de dos formas en cada lenguaje:

| | Versión 1: línea por línea | Versión 2: forma corta |
|---|---|---|
| Python | `for` con `if` y `append` | Comprensión de listas |
| R | `for` con `if` | Filtrado vectorizado: `temperaturas[temperaturas > 20]` |

Las cuatro dan `22 25 30`.

La versión 1 se puede leer al lado del seudocódigo: cada renglón tiene su línea. La versión 2 es la que se usa en la práctica y es la que se mostró en clase, pero ya no se parece al seudocódigo: el `PARA CADA` y el `SI` quedan escondidos adentro de una sola expresión.

## Lectura con control de codificación

El seudocódigo dice: intentar leer en UTF-8 y, si falla por la codificación, avisar y volver a intentar en latin-1.

Para probarlo, el script crea dos archivos con el mismo contenido, uno guardado en UTF-8 y otro en latin-1, y los lee con la misma función.

- El archivo en UTF-8 se lee al primer intento.
- El archivo en latin-1 falla, muestra el aviso y se lee en el segundo intento.
- Las dos tablas quedan iguales, con "RAMÍREZ" y "MALVÍN" bien escritos.

Es el mismo error que apareció en el ejercicio 5 del práctico B de la clase 3 (`UnicodeDecodeError`). Allá se resolvía a mano, declarando la codificación; acá el programa prueba la segunda opción solo.

## Seudocódigo propio: el perfilado de playas

Para practicar al revés, escribí en seudocódigo lo que hace mi script de la clase 4 (`clase04_playas.py`).

```text
INICIO Perfilar_Playas

    // 1. Ubicar el archivo
    DEFINIR ruta = carpeta de este script + "residuos_en_kg_retirados_en_playas.csv"

    SI ruta NO EXISTE ENTONCES
        DETENER con el mensaje "No se encontró el archivo en: " + ruta
    FIN SI

    // 2. Cargar
    Cargar CSV en 'df'

    // 3. Estructura
    IMPRIMIR cantidad de filas y columnas de df
    IMPRIMIR tipo de cada columna

    // 4. Identificador
    PARA CADA columna EN df
        IMPRIMIR cantidad de valores distintos de columna
    FIN PARA
    CONTAR pares (fecha, playa) repetidos
    IMPRIMIR las filas de esos pares

    // 5. Faltantes y duplicados
    PARA CADA columna EN df
        IMPRIMIR cantidad de celdas vacías de columna
    FIN PARA
    IMPRIMIR cantidad de filas exactamente iguales

    // 6. Coherencia
    PARA CADA playa EN df
        SI playa figura en más de un sector ENTONCES
            IMPRIMIR playa y cuántos meses tiene en cada sector
        FIN SI
    FIN PARA
    IMPRIMIR cantidad de filas con 0 kg

FIN Perfilar_Playas
```

## Qué falló

1. **En R, el vector vacío no se puede "agrandar" como una lista de Python.** No existe un `append` que modifique el vector: hay que armar uno nuevo con `c(vector_filtrado, temp)` y volver a guardarlo con el mismo nombre.
2. **El código de la lectura no se podía correr tal como estaba en la clase**, porque no definía qué archivo leer. Hubo que crear archivos de prueba para ver funcionar el segundo intento.

## Lo que me llevo

- Escribir primero los pasos en palabras ordena el problema. En el perfilado de playas, el seudocódigo muestra que son seis bloques simples, aunque el script tenga cien líneas.
- El mismo seudocódigo da código distinto según el lenguaje, y la forma corta de cada lenguaje se aleja de los pasos escritos.

## Fechas y uso de IA

- Trabajé con un asistente de IA (Claude) para escribir los scripts y redactar este texto. Corrí todo en mi máquina; los archivos `salida_*.txt` son esas corridas.
