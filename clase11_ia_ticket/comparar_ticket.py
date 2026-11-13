# =====================================================================
# comparar_ticket.py — Comparar mi transcripción a mano con la de Gemini
# Clase 11 — Introducción a la Ciencia de Datos — UM, FCEE
#
# Lee:
#   ticket_a_mano.csv   la referencia: lo que copié yo mirando el ticket.
#                       Columnas descripcion,monto. La última fila es el
#                       TOTAL impreso en el ticket.
#   ticket_gemini.csv   lo que devolvió Gemini (lo genera leer_ticket.py)
#
# Calcula:
#   - la comparación ítem por ítem
#   - la tasa de recuperación
#   - el control de consistencia (suma de ítems contra el TOTAL impreso)
#
# El script marca DÓNDE hay diferencias. El tipo de error de cada una
# (sustitución, omisión, inserción, estructura, alucinación) lo decido yo
# mirando el ticket, y queda en el README.
# =====================================================================

import csv
import re
from difflib import SequenceMatcher
from pathlib import Path

CARPETA = Path(__file__).resolve().parent
PARECIDO_MINIMO = 0.6      # desde qué parecido tomo dos descripciones como el mismo ítem


def leer_tabla(nombre):
    """Lee descripcion,monto cortando por la última coma. Devuelve [descripcion, monto]."""
    ruta = CARPETA / nombre
    if not ruta.exists():
        raise SystemExit("Falta el archivo " + nombre)
    lineas = [l.strip() for l in ruta.read_text(encoding="utf-8-sig").splitlines() if l.strip() != ""]
    filas = []
    for numero, linea in enumerate(lineas[1:], start=2):
        fila = next(csv.reader([linea]))
        if len(fila) == 2:
            descripcion, monto = fila
        elif "," in linea:
            descripcion, monto = linea.rsplit(",", 1)
        else:
            descripcion, monto = linea, ""
        descripcion, monto = descripcion.strip(), monto.strip()
        if monto == "":
            valor = None                                   # monto vacío: no se pudo leer
        elif re.fullmatch(r"-?\d+(\.\d+)?", monto):
            valor = float(monto)
        else:
            raise SystemExit(f"{nombre}, línea {numero}: el monto '{monto}' no es un número "
                             "con punto decimal (ejemplo: 1250.00)")
        if nombre == "ticket_a_mano.csv" and re.search(r"\d,\d{2}$", linea):
            print(f"AVISO: {nombre}, línea {numero}: revisar si el monto quedó escrito con coma "
                  "(va con punto: 1.250,00 se escribe 1250.00)")
        filas.append([descripcion, valor])
    return filas


def normalizar(texto):
    """Para comparar descripciones: sin diferencia de mayúsculas ni espacios repetidos."""
    return " ".join(texto.upper().split())


def parecido(a, b):
    return SequenceMatcher(None, normalizar(a), normalizar(b)).ratio()


def plata(valor):
    return "(vacío)" if valor is None else f"{valor:.2f}"


def suma(filas):
    return round(sum(m for _, m in filas if m is not None), 2)


# ---------------------------------------------------------------------
# 1. Leer las dos tablas
# ---------------------------------------------------------------------
mano = leer_tabla("ticket_a_mano.csv")
gemini = leer_tabla("ticket_gemini.csv")

if any("COMO ESTA IMPRESO" in d.upper() for d, _ in mano):
    raise SystemExit("ticket_a_mano.csv todavía tiene las filas de ejemplo: falta la transcripción")
if len(mano) == 0 or normalizar(mano[-1][0]) != "TOTAL" or mano[-1][1] is None:
    raise SystemExit("La última fila de ticket_a_mano.csv tiene que ser TOTAL,<monto impreso>")

TOTAL = mano[-1][1]
mano = mano[:-1]

print("REFERENCIA (a mano):", len(mano), "ítems, suma", plata(suma(mano)),
      "  TOTAL impreso:", plata(TOTAL))
print("GEMINI:             ", len(gemini), "ítems, suma", plata(suma(gemini)))
print()

# ---------------------------------------------------------------------
# 2. Emparejar los ítems de una tabla con los de la otra
#    Cada ítem se usa una sola vez (por si hay dos renglones iguales).
# ---------------------------------------------------------------------
libres = list(range(len(gemini)))          # ítems de Gemini todavía sin pareja
pareja = {}                                # índice a mano -> (índice Gemini, resultado)


def emparejar(condicion, resultado):
    for i, (desc_m, monto_m) in enumerate(mano):
        if i in pareja:
            continue
        candidatos = [j for j in libres if condicion(desc_m, monto_m, gemini[j][0], gemini[j][1])]
        if candidatos:
            j = max(candidatos, key=lambda j: parecido(desc_m, gemini[j][0]))
            pareja[i] = (j, resultado)
            libres.remove(j)


# a) descripción y monto iguales
emparejar(lambda dm, mm, dg, mg: normalizar(dm) == normalizar(dg) and mm == mg, "igual")
# b) misma descripción, otro monto
emparejar(lambda dm, mm, dg, mg: normalizar(dm) == normalizar(dg), "distinto monto")
# c) mismo monto, descripción parecida
emparejar(lambda dm, mm, dg, mg: mm == mg and parecido(dm, dg) >= PARECIDO_MINIMO,
          "distinta descripción")
# d) descripción parecida, otro monto
emparejar(lambda dm, mm, dg, mg: parecido(dm, dg) >= PARECIDO_MINIMO,
          "distinta descripción y monto")

# ---------------------------------------------------------------------
# 3. Mostrar la comparación ítem por ítem
# ---------------------------------------------------------------------
print("COMPARACIÓN ÍTEM POR ÍTEM")
print("(se toman como iguales las descripciones que solo cambian en mayúsculas o espacios)")
print()
cuenta = {}
for i, (desc_m, monto_m) in enumerate(mano, start=1):
    if i - 1 in pareja:
        j, resultado = pareja[i - 1]
        desc_g, monto_g = gemini[j]
    else:
        resultado, desc_g, monto_g = "FALTA en Gemini", "—", None
    cuenta[resultado] = cuenta.get(resultado, 0) + 1
    print(f"{i:>2}. a mano : {desc_m}  |  {plata(monto_m)}")
    if resultado == "FALTA en Gemini":
        print("    Gemini : —")
    else:
        print(f"    Gemini : {desc_g}  |  {plata(monto_g)}")
    print(f"    -> {resultado}")

for j in libres:
    cuenta["SOBRA en Gemini"] = cuenta.get("SOBRA en Gemini", 0) + 1
    print(" +. a mano : —")
    print(f"    Gemini : {gemini[j][0]}  |  {plata(gemini[j][1])}")
    print("    -> SOBRA en Gemini")
print()

# ---------------------------------------------------------------------
# 4. Resumen, tasa de recuperación y control de consistencia
# ---------------------------------------------------------------------
print("RESUMEN")
for resultado in ["igual", "distinto monto", "distinta descripción",
                  "distinta descripción y monto", "FALTA en Gemini", "SOBRA en Gemini"]:
    print(f"   {resultado:<30} {cuenta.get(resultado, 0)}")
print()

recuperados = len(pareja)
iguales = cuenta.get("igual", 0)
print("TASA DE RECUPERACIÓN")
print(f"   ítems de la referencia que aparecen en lo leído: {recuperados} de {len(mano)}"
      f" = {recuperados / len(mano):.2f}")
print(f"   de esos, sin ninguna diferencia:                 {iguales} de {len(mano)}"
      f" = {iguales / len(mano):.2f}")
print()

dif_gemini = round(suma(gemini) - TOTAL, 2)
dif_mano = round(suma(mano) - TOTAL, 2)
print("CONTROL DE CONSISTENCIA (suma de ítems - TOTAL impreso)")
print(f"   Gemini: {plata(suma(gemini))} - {plata(TOTAL)} = {dif_gemini:.2f}",
      "-> CIERRA" if dif_gemini == 0 else "-> NO CIERRA")
print(f"   a mano: {plata(suma(mano))} - {plata(TOTAL)} = {dif_mano:.2f}",
      "-> CIERRA" if dif_mano == 0 else "-> NO CIERRA")
print()
print("CONTROL:", len(mano), "ítems a mano,", len(gemini), "ítems de Gemini,",
      sum(v for k, v in cuenta.items() if k != "igual"), "diferencias")
