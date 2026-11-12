# %%
from pathlib import Path
import pandas as pd

# 1. Definir la ruta raíz del proyecto o del directorio donde está el archivo .py
BASE_DIR = Path(__file__).resolve().parent
BASE_DIR

# 2. Construir la ruta relativa de forma segura utilizando el operador /
archivo = "residuos_en_kg_retirados_en_playas.csv"
ruta_csv = BASE_DIR / archivo

# 3. Verificar que el archivo realmente existe antes de cargarlo
if not ruta_csv.exists():
    raise FileNotFoundError(f"No se encontró el archivo en: {ruta_csv}")

# 4. Cargar el archivo CSV
df = pd.read_csv(ruta_csv)

# 5. Inspección inicial de los datos
print(f"--- Archivo cargado exitosamente desde: {ruta_csv.name} ---")
print(df.info())
print("\nPrimeras 5 filas:")
print(df.head())

## 5.1. Dimensiones y estructura de los datos (Equivalente a str(df))
df.info()
df.shape

# 5.2. Filas únicas: detectando la columna que contiene el ID
df["matricula_letra"].nunique()

print("\nValores únicos por columna (Buscar candidatos a ID):")
print(df.nunique())

# 5.3 Datos faltantes

df.isnull().sum()  # Conteo de NA por columna
(df == "").sum()   # Falsos nulos (cadenas vacías)

## 5.4 Duplicados
df.duplicated().sum() # Cantidad de filas exactamente iguales

## 5.5. Primeras filas
print("\nPrimeras 5 filas:")
print(df.head())