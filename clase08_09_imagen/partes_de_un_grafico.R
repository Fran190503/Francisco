# =============================================================================
# Clases 8 y 9 - Las partes de un gráfico (R, ggplot2)
# Bitácora personal - Introducción a la Ciencia de Datos (UM, FCEE)
# =============================================================================
#
# Rehace las tres figuras del teórico "Las partes de un gráfico":
#   01_partida.png     el gráfico del que se parte, con sus problemas
#   02_geometria.png   las dos capas por separado: la línea y los puntos
#   03_corregida.png   el mismo gráfico, corregido
#
# Los datos son los de la clase: ozono medio mensual, enero a abril de 2024.
# Código de la cátedra; lo adapté para que use solo ggplot2 y here, y guarde en
# imagenes_r/, al lado de este archivo.
#
# Se corre en RStudio con el botón "Source".
# Paquetes: ggplot2 y here.
# =============================================================================

library(ggplot2)
library(here)

here::i_am("clase08_09_imagen/partes_de_un_grafico.R")

CARPETA <- here("clase08_09_imagen", "imagenes_r")
dir.create(CARPETA, showWarnings = FALSE)

# Guardado: 300 puntos por pulgada y fondo blanco (theme_minimal lo deja
# transparente y en algunos visores se ve negro).
guardar <- function(p, nombre, ancho = 8, alto = 5) {
  ggsave(file.path(CARPETA, nombre), p, width = ancho, height = alto,
         dpi = 300, bg = "white")
  cat("Guardada:", nombre, "\n")
}

# Datos: una serie, cuatro observaciones.
ozono_mes <- data.frame(
  mes          = 1:4,
  o3_medio_mes = c(29.1, 35.5, 24.0, 25.7)
)

# -----------------------------------------------------------------------------
# 1. El gráfico de partida
# -----------------------------------------------------------------------------
# Problemas: el eje horizontal muestra números y no meses, y tiene líneas de
# grilla en posiciones intermedias (1.5, 2.5, 3.5) que no son ningún mes; las
# etiquetas "Fecha" y "Valores" no dicen qué se mide ni en qué unidad; el eje
# vertical no arranca en cero; no dice de dónde salen los datos.
p_partida <- ggplot(ozono_mes, aes(x = mes, y = o3_medio_mes)) +   # datos y mapeo
  geom_line(color = "blue", linewidth = 1) +                       # geometría: línea
  geom_point(color = "red", size = 3) +                            # geometría: puntos
  theme_minimal() +                                                # grilla y bordes
  labs(title = "Concentración de Ozono en el ambiente, por mes, 2024",
       x = "Fecha", y = "Valores")                                 # título y etiquetas
guardar(p_partida, "01_partida.png")

# -----------------------------------------------------------------------------
# 2. La geometría: dos capas
# -----------------------------------------------------------------------------
# La línea dice que hay continuidad entre un mes y el siguiente. Los puntos
# marcan dónde hay una medición de verdad. Armo una tabla con una columna que
# dice a qué panel va cada fila y dibujo cada capa solo con sus filas.
capas <- rbind(cbind(ozono_mes, panel = "Solo geom_line()"),
               cbind(ozono_mes, panel = "Solo geom_point()"))

p_geometria <- ggplot(capas, aes(x = mes, y = o3_medio_mes)) +
  geom_line(data = subset(capas, panel == "Solo geom_line()"),
            color = "blue", linewidth = 1) +
  geom_point(data = subset(capas, panel == "Solo geom_point()"),
             color = "red", size = 3) +
  facet_wrap(~ panel) +                                            # un panel por capa
  theme_minimal() +
  labs(x = NULL, y = NULL)
guardar(p_geometria, "02_geometria.png", ancho = 10, alto = 4)

# -----------------------------------------------------------------------------
# 3. La versión corregida
# -----------------------------------------------------------------------------
# Mismos datos y mismas geometrías. Cambian las marcas del eje horizontal, el
# rango del vertical, el título, las etiquetas con unidad y la fuente al pie.
p_corregida <- ggplot(ozono_mes, aes(x = mes, y = o3_medio_mes)) +
  geom_line(color = "blue", linewidth = 1) +
  geom_point(color = "red", size = 3) +
  scale_x_continuous(breaks = 1:4,
                     labels = c("Ene", "Feb", "Mar", "Abr")) +     # marcas: meses que existen
  scale_y_continuous(limits = c(0, 40), breaks = seq(0, 40, 5)) +  # rango: desde cero
  theme_minimal() +
  theme(panel.grid.minor = element_blank()) +                      # sin grilla secundaria
  labs(title = "Ozono troposférico: media mensual, enero a abril de 2024",
       x = "Mes (2024)", y = "Ozono (µg/m³)",                      # variable y unidad
       caption = "Fuente: valores leídos del gráfico original de la clase.")  # pie
guardar(p_corregida, "03_corregida.png")

cat("Figuras en:", basename(CARPETA), "\n")
