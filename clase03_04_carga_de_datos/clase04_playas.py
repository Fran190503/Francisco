# =============================================================================
# Clase 4 - Carga de un CSV de datos abiertos y perfilado inicial
# Bitácora personal - Introducción a la Ciencia de Datos (UM, FCEE)
# =============================================================================
#
# Datos: residuos_en_kg_retirados_en_playas.csv
#        Kilos de residuos retirados por mes en cada playa de Montevideo.
#
# Parte del script de la clase ("carga de datos en python 2.py"), que estaba
# escrito para otro archivo. Lo adapté a este CSV el 13/11/2026.
#
# Se corre con:  python3 clase04_playas.py
# =============================================================================

from pathlib import Path

import pandas as pd

# -----------------------------------------------------------------------------
# 1. La ruta: se arma desde la carpeta donde está este archivo
# -----------------------------------------------------------------------------
# Así el script corre igual en cualquier computadora y desde cualquier carpeta.
BASE_DIR = Path(__file__).resolve().parent
archivo = "residuos_en_kg_retirados_en_playas.csv"
ruta_csv = BASE_DIR / archivo

# -----------------------------------------------------------------------------
# 2. Verificar que el archivo existe antes de leerlo
# -----------------------------------------------------------------------------
if not ruta_csv.exists():
    raise FileNotFoundError(f"No se encontró el archivo en: {ruta_csv}")

# -----------------------------------------------------------------------------
# 3. Cargar
# -----------------------------------------------------------------------------
df = pd.read_csv(ruta_csv)
print(f"--- Archivo cargado: {ruta_csv.name} ---")

# -----------------------------------------------------------------------------
# 4. Dimensiones y estructura
# -----------------------------------------------------------------------------
print("\n--- 4. Dimensiones y tipos ---")
print("Filas y columnas:", df.shape)
print(df.dtypes)
print("\nPrimeras 5 filas:")
print(df.head())

# -----------------------------------------------------------------------------
# 5. Identificador: qué columna (o columnas) distingue una fila de otra
# -----------------------------------------------------------------------------
# El script original preguntaba por la columna "matricula_letra", que es del
# archivo de la clase y acá no existe: daba KeyError. Lo que corresponde es
# mirar las columnas de este archivo.
print("\n--- 5. Valores únicos por columna ---")
print(df.nunique())

# Ninguna columna sola tiene tantos valores distintos como filas. Cada fila
# es una playa en un mes, así que el candidato a identificador es fecha + playa.
repetidos = df[df.duplicated(subset=["fecha", "playa"], keep=False)]
print("\nCombinaciones fecha + playa repetidas:",
      df.duplicated(subset=["fecha", "playa"]).sum())
print(repetidos.sort_values(["fecha", "playa"]))

# -----------------------------------------------------------------------------
# 6. Faltantes
# -----------------------------------------------------------------------------
print("\n--- 6. Faltantes por columna ---")
print(df.isna().sum())
print("\nFilas con algún faltante:")
print(df[df.isna().any(axis=1)])
print("\nCeldas con texto vacío:", int((df == "").sum().sum()))

# -----------------------------------------------------------------------------
# 7. Duplicados
# -----------------------------------------------------------------------------
print("\n--- 7. Filas exactamente iguales ---")
print(df.duplicated().sum())

# -----------------------------------------------------------------------------
# 8. Coherencia: cosas que el archivo no avisa
# -----------------------------------------------------------------------------
print("\n--- 8. Coherencia ---")

# 8.1 Una playa debería estar siempre en el mismo sector.
sectores_por_playa = df.groupby("playa")["sector"].nunique()
playas_dos_sectores = sectores_por_playa[sectores_por_playa > 1].index
print("Playas que figuran en más de un sector:")
print(df[df["playa"].isin(playas_dos_sectores)]
      .groupby(["playa", "sector"]).size())

# 8.2 Meses con kilos en cero: ¿no se retiró nada o no se cargó el dato?
print("\nFilas con 0 kg:", (df["kg_retirados"] == 0).sum(), "de", len(df))

# 8.3 Cantidad de playas informadas por mes.
playas_por_mes = df.groupby("fecha").size()
print("\nPlayas por mes (cuántos meses tienen cada cantidad):")
print(playas_por_mes.value_counts().sort_index())

# -----------------------------------------------------------------------------
# Control: los números que tienen que salir
# -----------------------------------------------------------------------------
print("\n=== CONTROL ===")
print("Filas:", len(df))
print("Meses:", df["fecha"].nunique(), "de", df["fecha"].min(), "a", df["fecha"].max())
print("Playas:", df["playa"].nunique())
print("Faltantes en sector:", df["sector"].isna().sum())
print("Pares fecha + playa repetidos:",
      df.duplicated(subset=["fecha", "playa"]).sum())
print("Playas en dos sectores:", len(playas_dos_sectores))
