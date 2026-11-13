# Bitácora personal — Introducción a la Ciencia de Datos

Universidad de Montevideo, FCEE. Año 2026.

## Qué es este repositorio

Es mi bitácora personal del curso. Hay una carpeta por clase.

En cada carpeta están los scripts, lo que respondieron al correrlos y un `README.md` que cuenta qué se hizo, qué dio, qué falló y qué decidí.

## Índice

| Carpeta | Clase | Qué hay |
|---|---|---|
| [`clase02_caja`](clase02_caja/) | 2 — Caja negra | La tabla de los 6 objetos que toqué sin ver, leída desde Excel, y un ejemplo de datos sintéticos. |
| [`clase03_04_carga_de_datos`](clase03_04_carga_de_datos/) | 3 y 4 — Carga de datos | Los prácticos A y B (del diccionario al archivo y del archivo al DataFrame) y el perfilado del CSV de playas: 1.063 filas, 25 playas. |
| [`clase05_seudocodigo`](clase05_seudocodigo/) | 5 — Seudocódigo | Del seudocódigo al código en Python y en R, y una lectura que prueba otra codificación si la primera falla. |
| [`clase06_encuesta`](clase06_encuesta/) | 6 — Encuesta | Seis preguntas con problemas, reescritas, y un cuestionario diseñado a partir de la tabla que se quiere obtener. |
| [`clase07_carga_y_rutas`](clase07_carga_y_rutas/) | 7 — Carga de datos con rutas | La calidad del aire de Montevideo en 2024 (70.272 filas), bajada por código y leída con rutas relativas. Cobertura por serie y ozono por mes. |
| [`clase08_09_imagen`](clase08_09_imagen/) | 8 y 9 — Imagen | Las partes de un gráfico, en Python y en R, y un gráfico propio antes y después de corregirlo. |
| [`clase10_transito_aire`](clase10_transito_aire/) | 10 — Tránsito y aire | El script de análisis de la clase y los siete ejercicios sobre la tabla de junio de 2024 (2.160 filas). |
| [`clase11_ia_ticket`](clase11_ia_ticket/) | 11 — IA para leer un ticket | La foto de un ticket propio leída con Gemini y comparada ítem por ítem con una referencia. |

## Cómo leer cada carpeta

- **`README.md`**: empezar por ahí. Tiene los resultados con sus números, lo que falló y las decisiones.
- **Scripts `.R` y `.py`**: el código de la clase.
- **`salida_*.txt`**: lo que mostró cada script cuando lo corrí en mi máquina.
- **Imágenes `.png`**: las figuras que generan los scripts.

## Cómo correr el código

Lo corrí con R 4.4.0 y Python 3.12.

| | Paquetes |
|---|---|
| R | `readxl`, `here`, `ggplot2`, `dplyr`, `readr`, `lubridate` |
| Python | `pandas`, `numpy`, `pyarrow`, `matplotlib`, `requests` |

- **Scripts de R:** abrirlos en RStudio, *Session > Set Working Directory > To Source File Location* y *Source*.
- **Scripts de Python:** `python3 nombre_del_script.py`, parado en la carpeta del script.
- Ningún script tiene `setwd()` ni rutas con mi nombre de usuario. En R las rutas se arman con `here`; en Python, desde la ubicación del script.
- `clase08_09_imagen/grafico_propio.R` usa los datos de la clase 7: hay que correr antes `clase07_carga_y_rutas/carga_aire.R`, que los descarga.
- `clase11_ia_ticket/leer_ticket.py` necesita una clave propia de Gemini. El README de esa carpeta explica dónde va.

## Qué no está en el repositorio

Lo excluye el `.gitignore`:

- **Las carpetas `datos/`.** Tienen archivos que el código genera o descarga. Se versiona el código que los obtiene, no el dato.
- **La clave de la API de Gemini.**
- **Archivos del sistema** (`.DS_Store`, `.Rhistory`, `.RData`).

## Fechas

Las fechas de los commits son las reales.

- 13/08 y 18/08: creé el repositorio y subí la tabla de la caja.
- 12/11: subí lo que tenía hecho en clase.
- 13/11: armé las carpetas. Resolví los ejercicios de cada clase con el material del curso y escribí los README.

No llevé la bitácora semana a semana, como pide el programa. Lo que hay acá está hecho después, todo junto.

## Uso de IA

Trabajé con un asistente de IA (Claude) en todas las carpetas, para el código y para la redacción. Corrí todo en mi máquina: las salidas guardadas son esas corridas. El README de cada clase lo indica al final.
