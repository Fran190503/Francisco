# =============================================================================
# Clase 4 - Carga de un CSV de datos abiertos y perfilado inicial (versión R)
# Bitácora personal - Introducción a la Ciencia de Datos (UM, FCEE)
# =============================================================================
#
# Mismo recorrido que clase04_playas.py, en R.
# Parte del script de la clase (clase5_cargadatos2.R), que buscaba otro
# archivo en otra carpeta. Lo adapté a este CSV el 13/11/2026.
#
# Cómo correrlo en RStudio
#   1. Session > Set Working Directory > To Source File Location
#   2. Botón "Source"
# No necesita ningún paquete.
# =============================================================================

# 1. Ruta relativa: el archivo está en la misma carpeta que este script
archivo <- "residuos_en_kg_retirados_en_playas.csv"

# 2. Verificar que existe antes de leerlo
if (!file.exists(archivo)) {
  stop("No encuentro ", archivo, " en ", getwd(),
       ". Falta: Session > Set Working Directory > To Source File Location.")
}

# 3. Cargar. na.strings = "" hace que la celda vacía se lea como faltante;
#    sin eso, R la deja como un texto vacío y is.na() no la cuenta.
df <- read.csv(archivo, na.strings = "", stringsAsFactors = FALSE)
cat("--- Archivo cargado:", archivo, "---\n")

# 4. Dimensiones y estructura
cat("\n--- 4. Dimensiones y tipos ---\n")
cat("Filas y columnas:", dim(df), "\n")
str(df)
print(head(df, 5))

# 5. Identificador: valores únicos por columna
cat("\n--- 5. Valores únicos por columna ---\n")
print(sapply(df, function(x) length(unique(x))))

# Ninguna columna sola identifica la fila. Candidato: fecha + playa.
clave <- paste(df$fecha, df$playa)
cat("\nCombinaciones fecha + playa repetidas:", sum(duplicated(clave)), "\n")
print(df[clave %in% clave[duplicated(clave)], ])

# 6. Faltantes
cat("\n--- 6. Faltantes por columna ---\n")
print(colSums(is.na(df)))
print(df[!complete.cases(df), ])

# 7. Duplicados
cat("\n--- 7. Filas exactamente iguales ---\n")
print(sum(duplicated(df)))

# 8. Coherencia
cat("\n--- 8. Coherencia ---\n")
sectores_por_playa <- tapply(df$sector, df$playa,
                             function(x) length(unique(x[!is.na(x)])))
playas_dos_sectores <- names(sectores_por_playa[sectores_por_playa > 1])
cat("Playas que figuran en más de un sector:\n")
con_dos <- df[df$playa %in% playas_dos_sectores, ]
print(table(con_dos$playa, con_dos$sector))

cat("\nFilas con 0 kg:", sum(df$kg_retirados == 0), "de", nrow(df), "\n")

cat("\nPlayas por mes (cuántos meses tienen cada cantidad):\n")
print(table(table(df$fecha)))

# Control: los números que tienen que salir
cat("\n=== CONTROL ===\n")
cat("Filas:", nrow(df), "\n")
cat("Meses:", length(unique(df$fecha)), "de", min(df$fecha), "a", max(df$fecha), "\n")
cat("Playas:", length(unique(df$playa)), "\n")
cat("Faltantes en sector:", sum(is.na(df$sector)), "\n")
cat("Pares fecha + playa repetidos:", sum(duplicated(clave)), "\n")
cat("Playas en dos sectores:", length(playas_dos_sectores), "\n")
