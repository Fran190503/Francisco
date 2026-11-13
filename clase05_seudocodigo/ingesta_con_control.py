# =============================================================================
# Clase 5 - Del seudocódigo al código: ingesta con control de codificación
# Bitácora personal - Introducción a la Ciencia de Datos (UM, FCEE)
# =============================================================================
#
# Seudocódigo de la clase:
#
#   INICIO Ingesta_Datos
#       IMPRIMIR "Lectura de CSV..."
#       INTENTAR
#           Cargar CSV en 'df_raw' (UTF-8)
#       SI FALLA POR CODIFICACIÓN ENTONCES
#           IMPRIMIR "[AVISO]: Error UTF-8, reintentando con latin-1..."
#           Cargar CSV en 'df_raw' (latin-1)
#       FIN INTENTAR
#   FIN Ingesta_Datos
#
# En el material de la clase este código está marcado para no ejecutarse,
# porque no define el archivo a leer. Acá lo pruebo con dos archivos que crea
# el propio script: uno guardado en UTF-8 y otro en latin-1, con el mismo
# contenido.
#
# Se corre con:  python3 ingesta_con_control.py
# =============================================================================

from pathlib import Path

import pandas as pd

CARPETA = Path(__file__).resolve().parent / "datos"
CARPETA.mkdir(exist_ok=True)

# -----------------------------------------------------------------------------
# Preparación: el mismo contenido guardado con dos codificaciones
# -----------------------------------------------------------------------------
contenido = "playa,sector,kg_retirados\nPLAYA RAMÍREZ,Este,38329\nPLAYA MALVÍN,Este,9248\n"

(CARPETA / "ejemplo_utf8.csv").write_text(contenido, encoding="utf-8")
(CARPETA / "ejemplo_latin1.csv").write_text(contenido, encoding="latin-1")


# -----------------------------------------------------------------------------
# El seudocódigo, traducido
# -----------------------------------------------------------------------------
def ingesta_datos(ruta_csv):                                  # INICIO Ingesta_Datos
    print(f"Lectura de CSV: {ruta_csv.name}")                 # IMPRIMIR
    try:                                                      # INTENTAR
        df_raw = pd.read_csv(ruta_csv, encoding="utf-8")      #   Cargar (UTF-8)
        print("  Leído con UTF-8.")
    except UnicodeDecodeError:                                # SI FALLA POR CODIFICACIÓN
        print("  [AVISO]: Error UTF-8, reintentando con latin-1...")
        df_raw = pd.read_csv(ruta_csv, encoding="latin-1")    #   Cargar (latin-1)
        print("  Leído con latin-1.")
    return df_raw                                             # FIN Ingesta_Datos


# -----------------------------------------------------------------------------
# Prueba con los dos archivos
# -----------------------------------------------------------------------------
df_utf8 = ingesta_datos(CARPETA / "ejemplo_utf8.csv")
print(df_utf8, "\n")

df_latin1 = ingesta_datos(CARPETA / "ejemplo_latin1.csv")
print(df_latin1, "\n")

# -----------------------------------------------------------------------------
# Control: por los dos caminos se llega a la misma tabla
# -----------------------------------------------------------------------------
print("Las dos tablas son iguales:", df_utf8.equals(df_latin1))
