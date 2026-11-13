# =============================================================================
# Clase 5 - Del seudocódigo al código: filtrar temperaturas (R)
# Bitácora personal - Introducción a la Ciencia de Datos (UM, FCEE)
# =============================================================================
#
# Seudocódigo de la clase:
#
#   INICIO Filtrar_Temperaturas
#       DEFINIR temperaturas = [18, 22, 15, 25, 30]
#       CREAR vector_filtrado VACÍO
#       PARA CADA temp EN temperaturas
#           SI temp > 20 ENTONCES
#               AGREGAR temp A vector_filtrado
#           FIN SI
#       FIN PARA
#       IMPRIMIR vector_filtrado
#   FIN Filtrar_Temperaturas
#
# Se corre en RStudio con el botón "Source". No necesita paquetes.
# =============================================================================

# -----------------------------------------------------------------------------
# Versión 1. Traducción línea por línea del seudocódigo
# -----------------------------------------------------------------------------
temperaturas <- c(18, 22, 15, 25, 30)          # DEFINIR temperaturas

vector_filtrado <- c()                         # CREAR vector_filtrado VACÍO

for (temp in temperaturas) {                   # PARA CADA temp EN temperaturas
  if (temp > 20) {                             #     SI temp > 20 ENTONCES
    vector_filtrado <- c(vector_filtrado, temp)  #       AGREGAR temp A vector_filtrado
  }                                            #     FIN SI
}                                              # FIN PARA

cat("Versión 1 (bucle):       ", vector_filtrado, "\n")   # IMPRIMIR vector_filtrado

# -----------------------------------------------------------------------------
# Versión 2. La forma corta de R: filtrado vectorizado
# -----------------------------------------------------------------------------
# temperaturas > 20 devuelve TRUE o FALSE para cada elemento, y los corchetes
# se quedan con los TRUE. Es la que se vio en clase.
vector_corto <- temperaturas[temperaturas > 20]

cat("Versión 2 (vectorizada): ", vector_corto, "\n")

# -----------------------------------------------------------------------------
# Control: las dos versiones tienen que dar lo mismo
# -----------------------------------------------------------------------------
cat("Las dos versiones coinciden:", identical(vector_filtrado, vector_corto), "\n")
