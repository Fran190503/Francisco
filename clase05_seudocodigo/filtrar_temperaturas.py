# =============================================================================
# Clase 5 - Del seudocódigo al código: filtrar temperaturas (Python)
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
# Se corre con:  python3 filtrar_temperaturas.py
# =============================================================================

# -----------------------------------------------------------------------------
# Versión 1. Traducción línea por línea del seudocódigo
# -----------------------------------------------------------------------------
temperaturas = [18, 22, 15, 25, 30]          # DEFINIR temperaturas

vector_filtrado = []                         # CREAR vector_filtrado VACÍO

for temp in temperaturas:                    # PARA CADA temp EN temperaturas
    if temp > 20:                            #     SI temp > 20 ENTONCES
        vector_filtrado.append(temp)         #         AGREGAR temp A vector_filtrado

print("Versión 1 (bucle):      ", vector_filtrado)   # IMPRIMIR vector_filtrado

# -----------------------------------------------------------------------------
# Versión 2. La forma corta de Python: comprensión de listas
# -----------------------------------------------------------------------------
# Hace lo mismo en una línea. Es la que se vio en clase.
vector_corto = [temp for temp in temperaturas if temp > 20]

print("Versión 2 (comprensión):", vector_corto)

# -----------------------------------------------------------------------------
# Control: las dos versiones tienen que dar lo mismo
# -----------------------------------------------------------------------------
print("Las dos versiones coinciden:", vector_filtrado == vector_corto)
