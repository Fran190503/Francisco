# =============================================================================
# Clase 10 - Tránsito y calidad del aire, junio de 2024: ejercicios
# Bitácora personal - Introducción a la Ciencia de Datos (UM, FCEE)
# =============================================================================
#
# Las consignas son de la cátedra. Lo que está debajo de cada "RESOLUCIÓN" lo
# completé yo. Los ejercicios 4 y 5 traían el código hecho en clase.
#
# Primero corre el script de análisis de la clase (analisis_transito_aire.R),
# que carga la tabla y crea las variables y los modelos que usan los
# ejercicios. Ese script muestra 20 gráficos en la pestaña Plots.
#
# Cómo correrlo en RStudio
#   1. Session > Set Working Directory > To Source File Location
#   2. Botón "Source"
#
# Paquetes: dplyr, readr, lubridate, ggplot2 y here.
# Salidas: cuatro figuras en la carpeta imagenes/
# =============================================================================

library(dplyr)
library(readr)
library(lubridate)
library(ggplot2)
library(here)

here::i_am("clase10_transito_aire/ejercicios_transito_aire.R")
theme_set(theme_minimal(base_size = 12))

source(here("clase10_transito_aire", "analisis_transito_aire.R"), encoding = "UTF-8")

CARPETA <- here("clase10_transito_aire", "imagenes")
dir.create(CARPETA, showWarnings = FALSE)

guardar <- function(p, nombre, ancho = 8, alto = 5) {
  ggsave(file.path(CARPETA, nombre), p, width = ancho, height = alto,
         dpi = 300, bg = "white")
  cat("Guardada:", nombre, "\n")
}


# =============================================================================
# EJERCICIO 1. FALTANTES
# =============================================================================
# Contar los faltantes de la tabla datos, agregando las variables nuevas:
# franja, tipo_dia, transito_rel y log_pm25.
# -----------------------------------------------------------------------------
# RESOLUCIÓN
faltantes_datos <- datos |>
  group_by(estacion) |>
  summarise(filas            = n(),
            sin_transito     = sum(is.na(transito)),
            sin_no2          = sum(is.na(no2)),
            sin_pm25         = sum(is.na(pm25)),
            sin_franja       = sum(is.na(franja)),
            sin_tipo_dia     = sum(is.na(tipo_dia)),
            sin_transito_rel = sum(is.na(transito_rel)),
            sin_log_pm25     = sum(is.na(log_pm25)))

cat("\n=== EJERCICIO 1 ===\n")
print(as.data.frame(faltantes_datos))
# Qué vemos: las variables que salen de la hora (franja, tipo_dia) y del
#   tránsito (transito_rel) no tienen faltantes, porque la hora y el tránsito
#   están completos. log_pm25 tiene exactamente los mismos faltantes que pm25:
#   una variable derivada hereda los huecos de la variable de la que sale.


# =============================================================================
# EJERCICIO 2. ¿ESTÁ BIEN DEFINIDA LA HORA PICO?
# =============================================================================
# En la Parte 2 se creó hora_pico: las horas 7, 8, 9, 17, 18 y 19.
# 1. Mirar el gráfico: ¿las horas en color son las de más tránsito?
#    Anotar qué horas están mal clasificadas.
# 2. Crear en datos una variable nueva que marque las horas que según el
#    gráfico tienen más tránsito.
# 3. Repetir el gráfico usando la variable nueva en lugar de hora_pico.
# -----------------------------------------------------------------------------
por_hora <- datos |>
  filter(estacion == "Tres Cruces", tipo_dia == "lunes a viernes") |>
  group_by(h, hora_pico) |>
  summarise(transito = mean(transito), .groups = "drop")

# RESOLUCIÓN
cat("\n=== EJERCICIO 2 ===\n")
cat("Tránsito promedio por hora, de mayor a menor (Tres Cruces, lunes a viernes):\n")
print(as.data.frame(por_hora |> arrange(desc(transito)) |>
                      mutate(transito = round(transito))), row.names = FALSE)

# En vez de elegir las horas a ojo, tomo las que superan 40.000 vehículos por
# hora en promedio. El corte sale de la tabla de arriba: hay ocho horas por
# encima de 40.000 y la siguiente ya queda en 39.000.
UMBRAL <- 40000
horas_altas <- sort(por_hora$h[por_hora$transito > UMBRAL])
cat("\nHoras con más de", UMBRAL, "vehículos por hora:", horas_altas, "\n")
cat("Horas marcadas como pico que no están entre ellas:",
    setdiff(c(7, 8, 9, 17, 18, 19), horas_altas), "\n")
cat("Horas que están entre ellas y no se marcaron como pico:",
    setdiff(horas_altas, c(7, 8, 9, 17, 18, 19)), "\n")

datos <- datos |>
  mutate(transito_alto = ifelse(h %in% horas_altas, "tránsito alto", "resto"))

por_hora_nueva <- datos |>
  filter(estacion == "Tres Cruces", tipo_dia == "lunes a viernes") |>
  group_by(h, transito_alto) |>
  summarise(transito = mean(transito), .groups = "drop")

g_ej2 <- ggplot(por_hora_nueva, aes(h, transito, fill = transito_alto)) +
  geom_col() +
  geom_hline(yintercept = UMBRAL, linetype = "dashed", color = "grey40") +
  scale_fill_manual(values = c("tránsito alto" = "#5C3A21", "resto" = "grey75")) +
  scale_x_continuous(breaks = seq(0, 23, 2)) +
  labs(title = "Tránsito promedio por hora del día, Tres Cruces, lunes a viernes",
       subtitle = "En color, las horas con más de 40.000 vehículos por hora",
       x = "Hora del día", y = "Vehículos por hora", fill = NULL)
guardar(g_ej2, "ej2_transito_por_hora.png")


# =============================================================================
# EJERCICIO 3. PM2.5 POR FRANJA HORARIA
# =============================================================================
# 1. Copiar el código de g9 y cambiarlo para graficar pm25 en lugar de
#    transito_rel. Cambiar también el título, el nombre del eje y el color.
# 2. La línea punteada en 1 ya no tiene sentido: sacarla.
# 3. ¿En qué franja es máximo el PM2.5? ¿Coincide con la del tránsito?
# -----------------------------------------------------------------------------
# RESOLUCIÓN
g_ej3 <- ggplot(por_franja, aes(franja, pm25)) +
  geom_col(fill = COL_PM25) +
  facet_wrap(~ estacion) +
  labs(title = "PM2.5 promedio por franja horaria, junio de 2024",
       x = NULL, y = "PM2.5 (µg/m³)")
guardar(g_ej3, "ej3_pm25_por_franja.png", ancho = 9, alto = 4.5)

maximos <- por_franja |>
  group_by(estacion) |>
  summarise(franja_max_pm25     = franja[which.max(pm25)],
            franja_max_transito = franja[which.max(transito_rel)])

cat("\n=== EJERCICIO 3 ===\n")
print(as.data.frame(maximos), row.names = FALSE)
# Qué vemos: en las tres estaciones el PM2.5 es máximo de noche y el tránsito
#   es máximo de tarde. No coinciden.


# =============================================================================
# EJERCICIO 4. AGREGAR UNA VARIABLE AL MODELO
# =============================================================================
# 1. Copiar el código de modelo_tc3 y agregar la variable franja.
# 2. Mostrar los coeficientes y el R².
# 3. ¿Mejoró el R²? ¿Mucho o poco?
# -----------------------------------------------------------------------------
modelo_tc4 <- lm(no2 ~ transito_miles + pm25 + franja, data = tc)

cat("\n=== EJERCICIO 4 ===\n")
print(round(coef(modelo_tc4), 2))
cat("R² sin franja (modelo_tc3):", round(summary(modelo_tc3)$r.squared, 3), "\n")
cat("R² con franja (modelo_tc4):", round(summary(modelo_tc4)$r.squared, 3), "\n")
# Qué vemos: el R² pasa de 0,473 a 0,486. Mejora poco: la franja agrega tres
#   coeficientes y explica apenas un punto más.


# =============================================================================
# EJERCICIO 5. UNA VARIABLE BINARIA A PARTIR DEL RESULTADO
# =============================================================================
# 1. Crear en tc la variable noche: vale 1 si la franja es "noche" y 0 si no.
# 2. Ajustar modelo_tc5 con transito_miles, pm25 y noche (sin franja).
# 3. Mostrar los coeficientes y el R². ¿Cuánto suma la noche?
# -----------------------------------------------------------------------------
tc$noche <- ifelse(tc$franja == "noche", 1, 0)

modelo_tc5 <- lm(no2 ~ transito_miles + pm25 + noche, data = tc)

cat("\n=== EJERCICIO 5 ===\n")
print(round(coef(modelo_tc5), 2))
cat("R² (modelo_tc5):", round(summary(modelo_tc5)$r.squared, 3), "\n")
# Qué vemos: a igual tránsito y PM2.5, una hora de la noche tiene 3,8 µg/m³
#   más de NO2. El R² es 0,481: casi lo mismo que con las cuatro franjas, con
#   dos coeficientes menos.


# =============================================================================
# EJERCICIO 6. INTERACCIONES
# =============================================================================
# 1. Mirar el gráfico g17: ¿qué franja tiene la recta más empinada?
# 2. Crear en tc una variable binaria para esa franja.
# 3. Ajustar modelo_tc7 con la interacción entre transito_miles y la variable
#    nueva. Mostrar los coeficientes y el R².
# -----------------------------------------------------------------------------
COL_FRANJA <- c("madrugada" = "#0072B2", "mañana" = "#E69F00",
                "tarde" = "#009E73", "noche" = "#CC79A7")

g17 <- ggplot(tc, aes(transito_miles, no2, color = franja)) +
  geom_point(size = 2.5, alpha = 0.6) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, linewidth = 1.2) +
  scale_color_manual(values = COL_FRANJA) +
  labs(title = "Tránsito y NO2 en Tres Cruces, por franja horaria",
       x = "Miles de vehículos por hora", y = "NO2 (µg/m³)", color = NULL)
guardar(g17, "ej6_rectas_por_franja.png")

# RESOLUCIÓN
# En vez de decidir a ojo cuál es la más empinada, calculo la pendiente de
# cada franja por separado.
pendientes <- tc |>
  group_by(franja) |>
  summarise(horas     = n(),
            pendiente = coef(lm(no2 ~ transito_miles))[2])

cat("\n=== EJERCICIO 6 ===\n")
cat("Pendiente de la recta en cada franja (µg/m³ por cada mil vehículos):\n")
print(as.data.frame(pendientes |> mutate(pendiente = round(pendiente, 2))),
      row.names = FALSE)

tc$madrugada <- ifelse(tc$franja == "madrugada", 1, 0)

modelo_tc7 <- lm(no2 ~ transito_miles * madrugada, data = tc)
print(round(coef(modelo_tc7), 2))
cat("R² solo con tránsito (modelo_tc):", round(summary(modelo_tc)$r.squared, 3), "\n")
cat("R² con la interacción (modelo_tc7):", round(summary(modelo_tc7)$r.squared, 3), "\n")
# Qué vemos: la madrugada es la más empinada. Fuera de la madrugada el NO2
#   sube 0,58 por cada mil vehículos; en la madrugada sube 0,58 + 2,36 = 2,94.


# =============================================================================
# EJERCICIO 7. ¿QUÉ PASA EN LA TARDE?
# =============================================================================
# En el gráfico g17 los puntos de la tarde forman dos grupos separados.
# 1. Crear la tabla tarde con las filas de tc cuya franja es "tarde".
# 2. Copiar el código de g17 y cambiarlo para usar la tabla tarde y colorear
#    por tipo_dia en lugar de franja.
# 3. ¿Qué son los dos grupos?
# 4. Pensar teóricamente o hacer en código un nuevo modelo que tenga en cuenta
#    esta característica.
# -----------------------------------------------------------------------------
# RESOLUCIÓN
tarde <- tc |> filter(franja == "tarde")

g_ej7 <- ggplot(tarde, aes(transito_miles, no2, color = tipo_dia)) +
  geom_point(size = 2.5, alpha = 0.7) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, linewidth = 1.2) +
  scale_color_manual(values = c("fin de semana" = COL_PM25,
                                "lunes a viernes" = COL_TRANSITO)) +
  labs(title = "Tránsito y NO2 en Tres Cruces, horas de la tarde",
       x = "Miles de vehículos por hora", y = "NO2 (µg/m³)", color = NULL)
guardar(g_ej7, "ej7_tarde_por_tipo_de_dia.png")

grupos_tarde <- tarde |>
  group_by(tipo_dia) |>
  summarise(horas           = n(),
            transito_minimo = round(min(transito_miles), 1),
            transito_medio  = round(mean(transito_miles), 1),
            transito_maximo = round(max(transito_miles), 1),
            no2_medio       = round(mean(no2), 1))

cat("\n=== EJERCICIO 7 ===\n")
print(as.data.frame(grupos_tarde), row.names = FALSE)

# Un modelo que tiene en cuenta el tipo de día, sobre toda la tabla tc.
modelo_tc8 <- lm(no2 ~ transito_miles + pm25 + noche + tipo_dia, data = tc)
print(round(coef(modelo_tc8), 2))
cat("R² sin tipo de día (modelo_tc5):", round(summary(modelo_tc5)$r.squared, 3), "\n")
cat("R² con tipo de día (modelo_tc8):", round(summary(modelo_tc8)$r.squared, 3), "\n")
# Qué vemos: los dos grupos son el fin de semana (menos tránsito) y los días
#   de semana. Agregar el tipo de día al modelo casi no cambia el R²: lo que
#   distingue a los dos grupos es el tránsito, y el tránsito ya está en el
#   modelo.


# =============================================================================
# Control: los números que tienen que salir
# =============================================================================
cat("\n=== CONTROL ===\n")
cat("Filas de datos:", nrow(datos), "  Horas con NO2 en Tres Cruces:", nrow(tc), "\n")
cat("Horas de tránsito alto:", horas_altas, "\n")
cat("R² de los modelos 3, 4, 5, 7 y 8:",
    round(c(summary(modelo_tc3)$r.squared, summary(modelo_tc4)$r.squared,
            summary(modelo_tc5)$r.squared, summary(modelo_tc7)$r.squared,
            summary(modelo_tc8)$r.squared), 3), "\n")
cat("Figuras guardadas:", length(list.files(CARPETA, pattern = "png$")), "\n")
