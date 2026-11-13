# =============================================================================
# Clases 8 y 9 - Las partes de un gráfico aplicadas a un gráfico propio
# Bitácora personal - Introducción a la Ciencia de Datos (UM, FCEE)
# =============================================================================
#
# Toma el ozono mensual de 2024 que calculé en la clase 7 y lo grafica dos
# veces: primero con lo mínimo ("de partida") y después corrigiendo cada parte.
# Acá hay dos series (dos estaciones), así que entra la segunda parte del
# teórico: un color por grupo y la leyenda.
#
#   04_propio_partida.png
#   05_propio_corregido.png
#
# Usa el archivo de datos de la clase 7. Si no está, hay que correr antes
# clase07_carga_y_rutas/carga_aire.R, que lo descarga.
#
# Se corre en RStudio con el botón "Source".
# Paquetes: ggplot2 y here.
# =============================================================================

library(ggplot2)
library(here)

here::i_am("clase08_09_imagen/grafico_propio.R")

RUTA_DATOS <- here("clase07_carga_y_rutas", "datos", "automaticas_24.csv")
CARPETA    <- here("clase08_09_imagen", "imagenes_r")
dir.create(CARPETA, showWarnings = FALSE)

if (!file.exists(RUTA_DATOS)) {
  stop("Falta el archivo de datos. Correr antes clase07_carga_y_rutas/carga_aire.R")
}

guardar <- function(p, nombre, ancho = 8, alto = 5) {
  ggsave(file.path(CARPETA, nombre), p, width = ancho, height = alto,
         dpi = 300, bg = "white")
  cat("Guardada:", nombre, "\n")
}


# =============================================================================
# 1. La tabla: ozono medio por mes y por estación (igual que en la clase 7)
# =============================================================================
aire  <- read.csv(RUTA_DATOS, stringsAsFactors = FALSE)
ozono <- aire[aire$pollutant_id == "O3", ]
ozono$mes  <- as.integer(substr(ozono$date, 6, 7))
ozono$zona <- ifelse(ozono$ID_estacion == "Colon 2", "Colón", "Curva de Maroñas")

ozono_mes <- aggregate(pollutant_value ~ zona + mes, data = ozono,
                       FUN = function(x) c(media = mean(x, na.rm = TRUE),
                                           con_dato = sum(!is.na(x)),
                                           total = length(x)),
                       na.action = na.pass)
ozono_mes <- data.frame(zona = ozono_mes$zona, mes = ozono_mes$mes,
                        ozono_mes$pollutant_value)
ozono_mes$confiable <- ozono_mes$con_dato / ozono_mes$total >= 0.75
ozono_mes <- ozono_mes[order(ozono_mes$zona, ozono_mes$mes), ]

cat("Meses en la tabla:", nrow(ozono_mes),
    " Confiables:", sum(ozono_mes$confiable), "\n")


# =============================================================================
# 2. El gráfico de partida: lo mínimo para que salga algo
# =============================================================================
# Lo único que hace bien es poner la estación dentro de aes(): con eso ggplot
# dibuja una línea por estación, les da un color y arma la leyenda.
# Lo que tiene mal:
#   - une todos los meses, también los que casi no tienen datos;
#   - el eje horizontal son números, no meses;
#   - las etiquetas son los nombres de las columnas ("media", "zona");
#   - no dice la unidad, el año ni la fuente.
con_dato <- ozono_mes[!is.na(ozono_mes$media), ]

p_partida <- ggplot(con_dato, aes(x = mes, y = media, color = zona)) +
  geom_line() +
  geom_point()
guardar(p_partida, "04_propio_partida.png")


# =============================================================================
# 3. El gráfico corregido, parte por parte
# =============================================================================
MESES <- c("Ene", "Feb", "Mar", "Abr", "May", "Jun",
           "Jul", "Ago", "Set", "Oct", "Nov", "Dic")

# Para la línea uso solo los meses confiables: en los otros dejo un hueco, así
# la línea no afirma una continuidad que los datos no respaldan.
ozono_mes$media_linea <- ifelse(ozono_mes$confiable, ozono_mes$media, NA)

# Para los puntos, una etiqueta que diga si el mes es confiable.
con_dato <- ozono_mes[!is.na(ozono_mes$media), ]
con_dato$respaldo <- ifelse(con_dato$confiable,
                            "75 % o más de las horas", "Menos de 75 %")

p_corregido <-
  # Datos y mapeo: el color distingue la estación.
  ggplot(ozono_mes, aes(x = mes, y = media, color = zona)) +
  # Geometría 1: la línea, cortada donde el mes no es confiable.
  geom_line(aes(y = media_linea), linewidth = 1, na.rm = TRUE) +
  # Geometría 2: los puntos; la forma dice cuánto respaldo tiene cada mes.
  geom_point(data = con_dato, aes(shape = respaldo), size = 3) +
  # Marcas y rango: los doce meses con su nombre, y el eje vertical desde cero.
  scale_x_continuous(breaks = 1:12, labels = MESES, limits = c(1, 12)) +
  scale_y_continuous(limits = c(0, 70), breaks = seq(0, 70, 10)) +
  # Escalas de color y de forma, elegidas a mano.
  scale_color_manual(values = c("Colón" = "#2E86AB", "Curva de Maroñas" = "#7B4B2A")) +
  scale_shape_manual(values = c("75 % o más de las horas" = 16, "Menos de 75 %" = 1)) +
  # Grilla y bordes.
  theme_minimal() +
  theme(panel.grid.minor = element_blank(), legend.position = "bottom",
        legend.box = "vertical") +
  # Título, etiquetas con unidad, nombres de las leyendas y pie.
  labs(title = "Ozono en Montevideo: media mensual por estación, 2024",
       x = "Mes (2024)", y = "Ozono (µg/m³)",
       color = "Estación", shape = "Horas con dato en el mes",
       caption = paste("Fuente: Intendencia de Montevideo, datos abiertos.",
                       "Colón no tiene datos de setiembre a diciembre."))
guardar(p_corregido, "05_propio_corregido.png")

cat("Figuras en:", basename(CARPETA), "\n")
