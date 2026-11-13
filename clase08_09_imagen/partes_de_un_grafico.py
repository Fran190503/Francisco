# =============================================================================
# Clases 8 y 9 - Las partes de un gráfico (Python, matplotlib)
# Bitácora personal - Introducción a la Ciencia de Datos (UM, FCEE)
# =============================================================================
#
# Rehace las tres figuras del teórico "Las partes de un gráfico":
#   01_partida.png     el gráfico del que se parte, con sus problemas
#   02_geometria.png   las dos capas por separado: la línea y los puntos
#   03_corregida.png   el mismo gráfico, corregido
#
# Los datos son los de la clase: ozono medio mensual, enero a abril de 2024.
# Código de la cátedra; adapté las rutas para que guarde en imagenes_python/,
# al lado de este archivo, y agregué los comentarios de cada parte.
#
# Se corre con:  python3 partes_de_un_grafico.py
# =============================================================================

from pathlib import Path

import matplotlib
matplotlib.use("Agg")          # guarda las figuras sin abrir ventanas
import matplotlib.pyplot as plt
import pandas as pd

CARPETA = Path(__file__).resolve().parent / "imagenes_python"
CARPETA.mkdir(exist_ok=True)


def tema_minimal(ax):
    """Grilla y bordes: sin marco, con grilla suave."""
    for lado in ("top", "right", "left", "bottom"):
        ax.spines[lado].set_visible(False)
    ax.grid(True, color="#e5e5e5", linewidth=0.8)
    ax.set_axisbelow(True)
    ax.tick_params(length=0)


def guardar(fig, nombre):
    """Guardado: 300 puntos por pulgada y fondo blanco."""
    fig.savefig(CARPETA / nombre, dpi=300, facecolor="white", bbox_inches="tight")
    plt.close(fig)
    print("Guardada:", nombre)


# Datos: una serie, cuatro observaciones.
ozono_mes = pd.DataFrame({
    "mes":          [1, 2, 3, 4],
    "o3_medio_mes": [29.1, 35.5, 24.0, 25.7],
})

# -----------------------------------------------------------------------------
# 1. El gráfico de partida
# -----------------------------------------------------------------------------
# Problemas: el eje horizontal marca 1.5, 2.5 y 3.5, que no son meses; las
# etiquetas "Fecha" y "Valores" no dicen qué se mide ni en qué unidad; el eje
# vertical no arranca en cero; no dice de dónde salen los datos.
fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(ozono_mes["mes"], ozono_mes["o3_medio_mes"], color="blue", linewidth=2)
ax.scatter(ozono_mes["mes"], ozono_mes["o3_medio_mes"], color="red", s=60, zorder=3)
tema_minimal(ax)
ax.set_title("Concentración de Ozono en el ambiente, por mes, 2024", loc="left")
ax.set_xlabel("Fecha")
ax.set_ylabel("Valores")
guardar(fig, "01_partida.png")

# -----------------------------------------------------------------------------
# 2. La geometría: dos capas
# -----------------------------------------------------------------------------
# La línea dice que hay continuidad entre un mes y el siguiente. Los puntos
# marcan dónde hay una medición de verdad.
fig, (ax_linea, ax_puntos) = plt.subplots(1, 2, figsize=(10, 4))

ax_linea.plot(ozono_mes["mes"], ozono_mes["o3_medio_mes"], color="blue", linewidth=2)
tema_minimal(ax_linea)
ax_linea.set_title("Solo la línea", loc="left")

ax_puntos.scatter(ozono_mes["mes"], ozono_mes["o3_medio_mes"], color="red", s=60, zorder=3)
tema_minimal(ax_puntos)
ax_puntos.set_title("Solo los puntos", loc="left")

guardar(fig, "02_geometria.png")

# -----------------------------------------------------------------------------
# 3. La versión corregida
# -----------------------------------------------------------------------------
# Mismos datos y mismas geometrías. Cambian las marcas del eje horizontal, el
# rango del vertical, el título, las etiquetas con unidad y la fuente al pie.
fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(ozono_mes["mes"], ozono_mes["o3_medio_mes"], color="blue", linewidth=2)
ax.scatter(ozono_mes["mes"], ozono_mes["o3_medio_mes"], color="red", s=60, zorder=3)
ax.set_xticks([1, 2, 3, 4], ["Ene", "Feb", "Mar", "Abr"])      # marcas: meses que existen
ax.set_ylim(0, 40)                                             # rango: desde cero
ax.set_yticks(range(0, 41, 5))
tema_minimal(ax)
ax.set_title("Ozono troposférico: media mensual, enero a abril de 2024", loc="left")
ax.set_xlabel("Mes (2024)")
ax.set_ylabel("Ozono (µg/m³)")                                 # variable y unidad
fig.text(0.99, 0.01, "Fuente: valores leídos del gráfico original de la clase.",
         ha="right", va="bottom", fontsize=8, color="gray")    # pie: la fuente
guardar(fig, "03_corregida.png")

print("Figuras en:", CARPETA.name)
