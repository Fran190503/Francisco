# =============================================================================
# Clase 2 - La caja negra: de lo que tocamos a una tabla de datos
# Bitácora personal - Introducción a la Ciencia de Datos (UM, FCEE)
# =============================================================================
#
# Qué hace este script
#   Parte A  Lee la tabla que armé en clase con los objetos de la caja
#            (objetos_caracteristicas.xlsx), la revisa y le da a cada variable
#            su tipo.
#   Parte B  Con el ejemplo de la clase (10 objetos con peso estimado) repite
#            los dos métodos para generar más datos: bootstrap y generación
#            paramétrica.
#
# Cómo correrlo en RStudio
#   1. Session > Set Working Directory > To Source File Location
#   2. Botón "Source" (o Cmd + Shift + S)
#
# Paquete necesario: readxl  ->  install.packages("readxl")
# Salidas: caja_caracteristicas.png y caja_pesos_sinteticos.png, en esta carpeta
# =============================================================================

library(readxl)

ARCHIVO <- "objetos_caracteristicas.xlsx"

# Antes de leer, verifico que el archivo esté donde lo busco.
if (!file.exists(ARCHIVO)) {
  stop("No encuentro ", ARCHIVO, " en ", getwd(),
       ". Falta el paso 1: Session > Set Working Directory > To Source File Location.")
}


# =============================================================================
# PARTE A. La tabla de la clase
# =============================================================================

# -----------------------------------------------------------------------------
# A1. Lectura ingenua: leer la hoja entera, sin decirle nada a R
# -----------------------------------------------------------------------------
ingenua <- read_excel(ARCHIVO)

cat("\n--- A1. Lectura ingenua ---\n")
cat("Filas y columnas:", dim(ingenua), "\n")
cat("Tipo de la columna objeto:", class(ingenua$objeto), "\n")
print(tail(ingenua[, 1:2], 3))

# Qué falló: la hoja tiene 11 objetos, pero R leyó 13 filas, y la columna
# "objeto" (que son números del 1 al 11) quedó como texto. La causa es una
# nota escrita debajo de la tabla ("Marcar con 1 la característica..."): R la
# toma como una fila más y, como es texto, convierte toda la columna a texto.
# No dio ningún mensaje de error.

# -----------------------------------------------------------------------------
# A2. Lectura correcta: solo el rango donde está la tabla
# -----------------------------------------------------------------------------
objetos <- read_excel(ARCHIVO, sheet = "Objetos", range = "A1:P12")

cat("\n--- A2. Lectura con rango ---\n")
cat("Filas y columnas:", dim(objetos), "\n")
cat("Tipo de la columna objeto:", class(objetos$objeto), "\n")

# Nombres de columna sin espacios ni barras, para poder usarlos en el código.
names(objetos)[names(objetos) == "identificado como"] <- "identificado_como"
names(objetos)[names(objetos) == "redondo / anillo"]  <- "redondo_anillo"

# -----------------------------------------------------------------------------
# A3. Perfilado: qué hay antes de tocar nada
# -----------------------------------------------------------------------------
cat("\n--- A3. Celdas vacías por columna ---\n")
print(colSums(is.na(objetos)))

# -----------------------------------------------------------------------------
# A4. Decisión 1: los objetos 7 a 11 no se registraron
# -----------------------------------------------------------------------------
# En la planilla quedaron en amarillo, "para completar". No tienen ningún
# dato, así que los saco. No son objetos sin características: son objetos que
# no se midieron.
filas_antes <- nrow(objetos)
objetos <- objetos[!is.na(objetos$identificado_como), ]

cat("\n--- A4. Objetos registrados ---\n")
cat("Filas antes:", filas_antes, " Filas después:", nrow(objetos), "\n")

# -----------------------------------------------------------------------------
# A5. Decisión 2: la celda vacía de una característica vale "no la tiene"
# -----------------------------------------------------------------------------
# En clase marcamos con 1 lo que el objeto tenía y dejamos vacío lo demás.
# Convierto cada característica en una variable binaria (TRUE / FALSE).
# Límite de esta decisión: la planilla no distingue "no la tiene" de "no la
# anoté". El objeto 6 ("varias cosas de plástico") solo tiene marcado
# plástico; es probable que el resto no se haya registrado.
CARACTERISTICAS <- c("cubo", "rectangular", "redondo_anillo", "amorfo", "liso",
                     "suave", "rugoso", "duro", "plastico", "metal", "tela",
                     "papel", "hueco")

for (columna in CARACTERISTICAS) {
  objetos[[columna]] <- !is.na(objetos[[columna]]) & objetos[[columna]] == 1
}

# -----------------------------------------------------------------------------
# A6. El tipo de cada variable
# -----------------------------------------------------------------------------
# objeto             identificador (entero)
# identificado_como  texto: lo que creímos que era al tocarlo
# 13 características binarias (TRUE / FALSE)
# rigidez            ordinal: flexible < rigido. El orden hay que declararlo;
#                    si no, R la trata como texto y la ordena alfabéticamente.
objetos$objeto  <- as.integer(objetos$objeto)
objetos$rigidez <- factor(objetos$rigidez, levels = c("flexible", "rigido"),
                          ordered = TRUE)

cat("\n--- A6. Estructura final ---\n")
str(as.data.frame(objetos))

# -----------------------------------------------------------------------------
# A7. Qué dice la tabla
# -----------------------------------------------------------------------------
conteo <- sort(colSums(objetos[, CARACTERISTICAS]), decreasing = TRUE)

cat("\n--- A7. Cantidad de objetos con cada característica ---\n")
print(conteo)
cat("\nRigidez:\n")
print(table(objetos$rigidez))
cat("\nObjetos más rígidos que 'flexible':", sum(objetos$rigidez > "flexible"), "\n")

png("caja_caracteristicas.png", width = 1600, height = 1100, res = 200)
par(mar = c(4.5, 8, 3.5, 1))
barplot(rev(conteo), horiz = TRUE, las = 1, col = "#2E86AB", border = NA,
        xlim = c(0, nrow(objetos)),
        main = "Objetos de la caja con cada característica",
        xlab = paste0("Cantidad de objetos (de ", nrow(objetos), " registrados)"))
invisible(dev.off())


# =============================================================================
# PARTE B. El ejemplo de la clase: cómo se generan más datos
# =============================================================================
# Mi tabla no tiene ninguna variable numérica continua, así que para esta
# parte uso el dataset de ejemplo de la clase 2 (10 objetos, con peso estimado).

datos_caja <- data.frame(
  objeto_id          = 1:10,
  textura            = c("suave", "rugoso", "poroso", "suave", "rugoso",
                         "suave", "poroso", "rugoso", "suave", "poroso"),
  rigidez            = c("blando", "rígido", "medio", "blando", "rígido",
                         "rígido", "blando", "medio", "medio", "blando"),
  num_aristas        = c(0, 8, 0, 4, 12, 0, 0, 6, 4, 0),
  peso_estimado_g    = c(45.0, 120.5, 15.0, 85.0, 210.0,
                         35.0, 18.5, 95.0, 70.0, 22.0),
  certeza_observador = c(5, 4, 3, 5, 4, 2, 4, 3, 4, 3)
)

# Tipos: nominal, ordinal y ordinal con escala fija de 1 a 5.
datos_caja$textura <- factor(datos_caja$textura)
datos_caja$rigidez <- factor(datos_caja$rigidez,
                             levels = c("blando", "medio", "rígido"),
                             ordered = TRUE)
datos_caja$certeza_observador <- factor(datos_caja$certeza_observador,
                                        levels = 1:5, ordered = TRUE)

cat("\n--- B. Dataset de ejemplo de la clase ---\n")
str(datos_caja)

# -----------------------------------------------------------------------------
# B1. Bootstrap: sacar filas con reposición hasta tener 100
# -----------------------------------------------------------------------------
set.seed(42)   # semilla fija: el resultado es el mismo cada vez que se corre
filas_elegidas <- sample(nrow(datos_caja), size = 100, replace = TRUE)
df_bootstrap   <- datos_caja[filas_elegidas, ]

cat("\n--- B1. Bootstrap ---\n")
cat("Filas:", nrow(df_bootstrap),
    " Objetos distintos:", length(unique(df_bootstrap$objeto_id)), "\n")
cat("Veces que aparece cada objeto:\n")
print(table(df_bootstrap$objeto_id))
cat("Peso medio original:", mean(datos_caja$peso_estimado_g),
    " Peso medio bootstrap:", round(mean(df_bootstrap$peso_estimado_g), 1), "\n")

# Qué muestra: hay 100 filas pero siguen siendo los mismos 10 objetos,
# repetidos. El bootstrap no crea información nueva.

# -----------------------------------------------------------------------------
# B2. Generación paramétrica: 500 pesos con distribución normal
# -----------------------------------------------------------------------------
mu    <- mean(datos_caja$peso_estimado_g)
sigma <- sd(datos_caja$peso_estimado_g)

pesos_sinteticos <- rnorm(500, mean = mu, sd = sigma)
imposibles       <- sum(pesos_sinteticos <= 0)

# Un peso no puede ser cero ni negativo: los llevo a un mínimo de 1 gramo.
pesos_corregidos <- pmax(pesos_sinteticos, 1)

cat("\n--- B2. Generación paramétrica ---\n")
cat("Media:", round(mu, 1), "g   Desvío:", round(sigma, 1), "g\n")
cat("Pesos generados que dieron cero o negativos:", imposibles, "de 500\n")
cat("Rango de los pesos reales:", range(datos_caja$peso_estimado_g), "\n")
cat("Rango de los sintéticos corregidos:", round(range(pesos_corregidos), 1), "\n")

# Qué muestra: la normal genera pesos negativos, que en la caja no pueden
# existir, y pesos intermedios que no corresponden a ningún objeto real.

png("caja_pesos_sinteticos.png", width = 1600, height = 1100, res = 200)
hist(pesos_corregidos, breaks = 30, col = "#D4A373", border = "white",
     main = "Pesos sintéticos (500) y pesos reales de la clase (10)",
     xlab = "Peso estimado (g)", ylab = "Cantidad de pesos sintéticos")
rug(datos_caja$peso_estimado_g, col = "#5C3A21", lwd = 3, ticksize = 0.06)
legend("topright", bty = "n",
       legend = c("Sintéticos (normal)", "Reales (marcas en el eje)"),
       fill = c("#D4A373", "#5C3A21"), border = NA)
invisible(dev.off())


# =============================================================================
# Control: estos son los números que tienen que salir
# =============================================================================
cat("\n=== CONTROL ===\n")
cat("Objetos registrados:", nrow(objetos), "\n")
cat("Objetos de plástico:", sum(objetos$plastico), "\n")
cat("Objetos distintos en el bootstrap:", length(unique(df_bootstrap$objeto_id)), "\n")
cat("Pesos imposibles generados:", imposibles, "\n")
cat("Figuras guardadas:", file.exists("caja_caracteristicas.png"),
    file.exists("caja_pesos_sinteticos.png"), "\n")
