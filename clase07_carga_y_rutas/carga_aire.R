# =============================================================================
# Clase 7 - Carga de datos con rutas: calidad del aire de Montevideo, 2024
# Bitácora personal - Introducción a la Ciencia de Datos (UM, FCEE)
# =============================================================================
#
# Recorre los pasos de la clase 7 (carga, perfilado, tipos, variables nuevas e
# información agregada) sobre el archivo público de la Intendencia de
# Montevideo con las medidas horarias de 2024 de las estaciones automáticas.
#
# Cómo correrlo en RStudio
#   1. Session > Set Working Directory > To Source File Location
#   2. Botón "Source"
#
# Paquete necesario: here  ->  install.packages("here")
# Salidas: aire_cobertura.png y aire_ozono_mensual.png, en esta carpeta
# =============================================================================

library(here)


# =============================================================================
# 1. Rutas: todo se arma desde la raíz del proyecto
# =============================================================================
# here() busca la raíz del proyecto subiendo carpetas hasta encontrarla, y arma
# las rutas a partir de ahí. Con i_am() le digo dónde está este script dentro
# del proyecto. No hay ningún setwd() ni ninguna ruta con mi nombre de usuario.
here::i_am("clase07_carga_y_rutas/carga_aire.R")

CARPETA_CLASE <- here("clase07_carga_y_rutas")
CARPETA_DATOS <- here("clase07_carga_y_rutas", "datos")
RUTA_DATOS    <- here("clase07_carga_y_rutas", "datos", "automaticas_24.csv")

cat("--- 1. Rutas ---\n")
cat("Raíz del proyecto:", basename(here()), "\n")
cat("Archivo de datos :", sub(here(), "", RUTA_DATOS, fixed = TRUE), "\n")


# =============================================================================
# 2. Obtener el dato: si el archivo no está, se descarga
# =============================================================================
# Fuente: Intendencia de Montevideo, Portal de Datos Abiertos, conjunto "Red de
#         monitoreo de la calidad del aire de Montevideo", recurso "Medidas de
#         la calidad del aire - 2024". Licencia: dag-uy, según el portal.
# El archivo crudo no se sube al repositorio: se sube este código, que lo baja.
URL_DATOS <- paste0(
  "https://ckan-data.montevideo.gub.uy/dataset/",
  "13c5b4a6-ff33-454f-8e9f-c3871052f464/resource/",
  "e2beee51-f90b-4712-aec7-a336784a23cb/download/automaticas_24.csv")

if (!file.exists(RUTA_DATOS)) {
  dir.create(CARPETA_DATOS, showWarnings = FALSE, recursive = TRUE)
  options(timeout = 600)
  download.file(URL_DATOS, RUTA_DATOS, mode = "wb")
}

cat("\n--- 2. Archivo ---\n")
cat("Tamaño:", round(file.size(RUTA_DATOS) / 1e6, 1), "MB\n")
cat("Descargado el:", format(file.mtime(RUTA_DATOS), "%d/%m/%Y"), "\n")


# =============================================================================
# 3. Carga
# =============================================================================
aire <- read.csv(RUTA_DATOS, stringsAsFactors = FALSE)


# =============================================================================
# 4. Perfilado: qué hay antes de tocar nada
# =============================================================================
cat("\n--- 4.1 Dimensiones y tipos ---\n")
cat("Filas y columnas:", dim(aire), "\n")
str(aire)

cat("\n--- 4.2 Valores distintos por columna ---\n")
print(sapply(aire, function(x) length(unique(x))))

# Dos columnas tienen un solo valor en todo el archivo: no distinguen nada.
cat("\nPeríodo de promedio (horas):", unique(aire$pollutant_averaging), "\n")
cat("Unidad:", unique(aire$pollutant_unit), "\n")

cat("\n--- 4.3 Qué mide cada estación ---\n")
print(table(aire$ID_estacion, aire$pollutant_id))

cat("\n--- 4.4 Identificador ---\n")
# Cada fila es un contaminante, en una estación, en una hora.
clave <- paste(aire$pollutant_id, aire$ID_estacion, aire$date)
cat("Combinaciones contaminante + estación + hora repetidas:",
    sum(duplicated(clave)), "\n")
cat("Filas exactamente iguales:", sum(duplicated(aire)), "\n")

cat("\n--- 4.5 Faltantes por columna ---\n")
print(colSums(is.na(aire)))


# =============================================================================
# 5. Tipos y limpieza
# =============================================================================

# 5.1 La fecha llega como texto. La paso a fecha y hora.
# El archivo no dice la zona horaria; tomo la hora tal como viene.
aire$fecha_hora <- as.POSIXct(aire$date, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")

cat("\n--- 5.1 Fechas ---\n")
cat("Tipo antes:", class(aire$date), "  Tipo después:", class(aire$fecha_hora)[1], "\n")
cat("Fechas que no se pudieron convertir:", sum(is.na(aire$fecha_hora)), "\n")
cat("Desde", format(min(aire$fecha_hora), "%d/%m/%Y %H:%M"),
    "hasta", format(max(aire$fecha_hora), "%d/%m/%Y %H:%M"), "\n")

# 5.2 Nombre de las estaciones.
# El archivo escribe "Ciudad Vieja2", sin espacio. En la tabla de estaciones del
# mismo conjunto de datos figura como "Ciudad Vieja 2". Si se quisiera unir las
# dos tablas por nombre, esa estación quedaría afuera. Lo corrijo.
aire$ID_estacion[aire$ID_estacion == "Ciudad Vieja2"] <- "Ciudad Vieja 2"

# Para los gráficos agrego el nombre de la zona, con tildes.
ZONAS <- c("Ciudad Vieja 2"   = "Ciudad Vieja",
           "Colon 2"          = "Colón",
           "Curva de Maronas" = "Curva de Maroñas",
           "Tres Cruces 4"    = "Tres Cruces")
aire$zona <- unname(ZONAS[aire$ID_estacion])

cat("\n--- 5.2 Estaciones ---\n")
print(unique(aire[, c("station_id", "ID_estacion", "zona")]), row.names = FALSE)
cat("Estaciones sin zona asignada:", sum(is.na(aire$zona)), "\n")

# 5.3 Nombre del contaminante.
# El archivo llama "PM2" al material particulado menor de 2,5 micras.
aire$contaminante <- ifelse(aire$pollutant_id == "PM2", "PM2.5", aire$pollutant_id)


# =============================================================================
# 6. Variables nuevas
# =============================================================================
aire$mes  <- as.integer(format(aire$fecha_hora, "%m"))
aire$hora <- as.integer(format(aire$fecha_hora, "%H"))
aire$dia  <- as.Date(aire$fecha_hora)

# La grilla está completa: 366 días por 24 horas en cada serie.
cat("\n--- 6. Horas por serie ---\n")
cat("Horas de 2024:", 366 * 24, "\n")
print(table(table(paste(aire$zona, aire$contaminante))))


# =============================================================================
# 7. Cobertura: cuántas horas tienen dato de verdad
# =============================================================================
# Antes de promediar nada hay que saber cuántas horas respaldan cada promedio.
cobertura <- aggregate(pollutant_value ~ zona + contaminante, data = aire,
                       FUN = function(x) sum(!is.na(x)), na.action = na.pass)
names(cobertura)[3] <- "horas_con_dato"
cobertura$porcentaje <- round(100 * cobertura$horas_con_dato / (366 * 24), 1)
cobertura <- cobertura[order(cobertura$porcentaje), ]

cat("\n--- 7. Cobertura por estación y contaminante ---\n")
print(cobertura, row.names = FALSE)
cat("\nCeldas sin dato en todo el archivo:", sum(is.na(aire$pollutant_value)),
    "de", nrow(aire), "(",
    round(100 * mean(is.na(aire$pollutant_value)), 1), "%)\n")

png(file.path(CARPETA_CLASE, "aire_cobertura.png"),
    width = 1800, height = 1100, res = 200)
par(mar = c(4.5, 12, 3.5, 2))
colores <- ifelse(cobertura$porcentaje >= 75, "#2E86AB", "#C0504D")
barplot(cobertura$porcentaje, horiz = TRUE, las = 1, col = colores, border = NA,
        names.arg = paste(cobertura$zona, "-", cobertura$contaminante),
        xlim = c(0, 100),
        main = "Horas con dato en 2024, por estación y contaminante",
        xlab = "Porcentaje de las 8.784 horas del año")
abline(v = 75, lty = 2)
legend("bottomright", bty = "n", fill = c("#2E86AB", "#C0504D"), border = NA,
       legend = c("75 % o más", "Menos de 75 %"))
invisible(dev.off())


# =============================================================================
# 8. Información agregada: ozono por mes
# =============================================================================
ozono <- aire[aire$contaminante == "O3", ]

media_mes <- aggregate(pollutant_value ~ zona + mes, data = ozono,
                       FUN = function(x) mean(x, na.rm = TRUE), na.action = na.pass)
horas_mes <- aggregate(pollutant_value ~ zona + mes, data = ozono,
                       FUN = function(x) sum(!is.na(x)), na.action = na.pass)
total_mes <- aggregate(pollutant_value ~ zona + mes, data = ozono,
                       FUN = length, na.action = na.pass)

ozono_mes <- data.frame(zona           = media_mes$zona,
                        mes            = media_mes$mes,
                        o3_medio       = round(media_mes$pollutant_value, 1),
                        horas_con_dato = horas_mes$pollutant_value,
                        horas_del_mes  = total_mes$pollutant_value)
ozono_mes$cobertura <- round(100 * ozono_mes$horas_con_dato / ozono_mes$horas_del_mes, 1)

# Un promedio mensual con pocas horas detrás no representa al mes. Marco como
# confiables solo los meses con 75 % o más de las horas.
ozono_mes$confiable <- ozono_mes$horas_con_dato / ozono_mes$horas_del_mes >= 0.75
ozono_mes <- ozono_mes[order(ozono_mes$zona, ozono_mes$mes), ]

cat("\n--- 8. Ozono medio por mes (ug/m3) ---\n")
print(ozono_mes, row.names = FALSE)

MESES <- c("Ene", "Feb", "Mar", "Abr", "May", "Jun",
           "Jul", "Ago", "Set", "Oct", "Nov", "Dic")
COLOR_ZONA <- c("Colón" = "#2E86AB", "Curva de Maroñas" = "#7B4B2A")

png(file.path(CARPETA_CLASE, "aire_ozono_mensual.png"),
    width = 1800, height = 1100, res = 200)
par(mar = c(4.5, 4.5, 3.5, 1))
plot(NA, xlim = c(1, 12), ylim = c(0, max(ozono_mes$o3_medio, na.rm = TRUE) * 1.15),
     xaxt = "n", las = 1,
     main = "Ozono: media mensual por estación, 2024",
     xlab = "Mes (2024)", ylab = "Ozono (µg/m³)")
axis(1, at = 1:12, labels = MESES)
grid(nx = NA, ny = NULL)
for (z in names(COLOR_ZONA)) {
  d <- ozono_mes[ozono_mes$zona == z, ]
  lines(d$mes, ifelse(d$confiable, d$o3_medio, NA), col = COLOR_ZONA[z], lwd = 2)
  points(d$mes[d$confiable], d$o3_medio[d$confiable], col = COLOR_ZONA[z], pch = 19)
  points(d$mes[!d$confiable], d$o3_medio[!d$confiable], col = COLOR_ZONA[z], pch = 1)
}
legend("topleft", bty = "n", col = c(COLOR_ZONA, "black", "black"),
       lwd = c(2, 2, NA, NA), pch = c(19, 19, 19, 1),
       legend = c(names(COLOR_ZONA), "Mes con 75 % o más de las horas",
                  "Mes con menos de 75 %"))
mtext("Fuente: Intendencia de Montevideo, datos abiertos.", side = 1, line = 3.5,
      adj = 1, cex = 0.7, col = "gray40")
invisible(dev.off())


# =============================================================================
# Control: los números que tienen que salir
# =============================================================================
cat("\n=== CONTROL ===\n")
cat("Filas:", nrow(aire), "\n")
cat("Series (estación + contaminante):", nrow(cobertura), "\n")
cat("Celdas sin dato:", sum(is.na(aire$pollutant_value)), "\n")
cat("Series con menos de 75 % de cobertura:", sum(cobertura$porcentaje < 75), "\n")
cat("Meses de ozono confiables:", sum(ozono_mes$confiable), "de", nrow(ozono_mes), "\n")
cat("Figuras guardadas:",
    file.exists(file.path(CARPETA_CLASE, "aire_cobertura.png")),
    file.exists(file.path(CARPETA_CLASE, "aire_ozono_mensual.png")), "\n")
