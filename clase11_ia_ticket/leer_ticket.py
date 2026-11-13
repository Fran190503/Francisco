# =====================================================================
# leer_ticket.py — Mandar la foto de un ticket a Gemini y recibir una tabla
# Clase 11 — Introducción a la Ciencia de Datos — UM, FCEE
#
# Es el script de la cátedra (clases/clase11/clase_ia/leer_ticket.py).
# La instrucción (prompt), el modelo y la solicitud son los mismos.
# Lo que cambié:
#   - las rutas salen de la carpeta donde está este archivo
#   - acepta la foto en .jpg, .jpeg, .png o .heic
#   - guarda la respuesta tal cual llegó, antes de tocarla
#   - separa los tokens de entrada en imagen y texto
#   - lee el CSV cortando por la última coma (por si una descripción trae comas)
#
# Antes de correrlo, en esta carpeta tiene que haber:
#   clave_gemini.txt   la clave de https://aistudio.google.com  (NO se sube a GitHub)
#   ticket.jpg         la foto del ticket, con los datos personales tapados
# =====================================================================

import base64
import csv
from datetime import datetime
from pathlib import Path

import requests

# ---------------------------------------------------------------------
# 1. Datos de la solicitud
# ---------------------------------------------------------------------
CARPETA = Path(__file__).resolve().parent
MODELO = "gemini-3.5-flash-lite"
BASE = "https://generativelanguage.googleapis.com/v1beta/models/" + MODELO
URL = BASE + ":generateContent"

TIPOS = {".jpg": "image/jpeg", ".jpeg": "image/jpeg",
         ".png": "image/png", ".heic": "image/heic"}

INSTRUCCION = """Transcribí los ítems de este ticket de compra.
Respondé solo con una tabla CSV, sin ningún otro texto, con dos columnas:
descripcion,monto
- monto con punto decimal y sin separador de miles (1.250,00 se escribe 1250.00)
- no incluyas SUBTOTAL, IVA, TOTAL, EFECTIVO, CAMBIO ni TARJETA
- si algo no se puede leer, dejalo vacío; no lo inventes"""

archivo_clave = CARPETA / "clave_gemini.txt"
if not archivo_clave.exists():
    raise SystemExit("Falta clave_gemini.txt en " + str(CARPETA))
CLAVE = archivo_clave.read_text(encoding="utf-8").strip()   # nunca se imprime

fotos = [f for f in sorted(CARPETA.iterdir())
         if f.stem.lower() == "ticket" and f.suffix.lower() in TIPOS]
if len(fotos) == 0:
    raise SystemExit("Falta la foto: ticket.jpg (o .jpeg, .png, .heic) en " + str(CARPETA))
FOTO = fotos[0]
TIPO = TIPOS[FOTO.suffix.lower()]

print("Fecha y hora de la solicitud:", datetime.now().strftime("%d/%m/%Y %H:%M"))
print("Modelo:", MODELO)
print("Foto:", FOTO.name, "(" + TIPO + ")")

# ---------------------------------------------------------------------
# 2. Pasar la foto a base64 (texto), porque el JSON solo admite texto
# ---------------------------------------------------------------------
bytes_foto = FOTO.read_bytes()
imagen_base64 = base64.b64encode(bytes_foto).decode("ascii")

print("La foto pesa", len(bytes_foto), "bytes")
print("En base64 son", len(imagen_base64), "caracteres")

# ---------------------------------------------------------------------
# 3. Armar el cuerpo de la solicitud (un diccionario que se envía como JSON)
# ---------------------------------------------------------------------
cuerpo = {
    "contents": [{
        "parts": [
            {"text": INSTRUCCION},
            {"inline_data": {"mime_type": TIPO, "data": imagen_base64}},
        ]
    }],
    "generationConfig": {"temperature": 0},
}

# ---------------------------------------------------------------------
# 4. Enviar la solicitud: método POST, con la clave en un encabezado
# ---------------------------------------------------------------------
respuesta = requests.post(URL, headers={"x-goog-api-key": CLAVE}, json=cuerpo, timeout=120)

print("Código de estado:", respuesta.status_code)   # 200 = todo bien
if respuesta.status_code != 200:
    print(respuesta.text.replace(CLAVE, "<clave>"))   # el mensaje de error del servidor
    raise SystemExit("La solicitud falló: revisar el código de estado")

# ---------------------------------------------------------------------
# 5. Leer la respuesta
# ---------------------------------------------------------------------
datos = respuesta.json()                                   # JSON -> diccionario
partes = datos["candidates"][0]["content"]["parts"]
texto = "".join(p.get("text", "") for p in partes if not p.get("thought"))

(CARPETA / "respuesta_gemini.txt").write_text(texto, encoding="utf-8")   # tal cual llegó
print()
print("--- Respuesta de Gemini, tal cual llegó ---")
print(texto)
print("--- fin de la respuesta ---")
print()

# ---------------------------------------------------------------------
# 6. Tokens: cuántos entraron, cuántos son de la imagen, cuántos salieron
# ---------------------------------------------------------------------
uso = datos["usageMetadata"]
print("Tokens de entrada (imagen + instrucción):", uso["promptTokenCount"])

detalle = uso.get("promptTokensDetails")
if detalle:
    # la respuesta ya trae la entrada separada por tipo
    for d in detalle:
        print("   de tipo", d.get("modality"), ":", d.get("tokenCount"))
else:
    # si no la trae: cuento los tokens de la instrucción sola y resto
    try:
        r = requests.post(BASE + ":countTokens", headers={"x-goog-api-key": CLAVE},
                          json={"contents": [{"parts": [{"text": INSTRUCCION}]}]}, timeout=60)
        de_texto = r.json()["totalTokens"]
        print("   de la instrucción sola (countTokens):", de_texto)
        print("   de la imagen (por diferencia):", uso["promptTokenCount"] - de_texto)
    except Exception as error:
        print("   no pude separar imagen y texto:", type(error).__name__)

if "thoughtsTokenCount" in uso:
    print("Tokens de razonamiento interno:", uso["thoughtsTokenCount"])
print("Tokens de salida (la respuesta):", uso.get("candidatesTokenCount"))

# ---------------------------------------------------------------------
# 7. Pasar el texto a tabla y guardarla
# ---------------------------------------------------------------------
limpio = texto.replace("```csv", "").replace("```", "").strip()   # por si la envuelve
lineas = [l.strip() for l in limpio.splitlines() if l.strip() != ""]

filas = []
for linea in lineas[1:]:                       # la primera es el encabezado
    if "," in linea:
        descripcion, monto = linea.rsplit(",", 1)   # corto por la ÚLTIMA coma
    else:
        descripcion, monto = linea, ""
    filas.append([descripcion.strip().strip('"'), monto.strip().strip('"')])

with open(CARPETA / "ticket_gemini.csv", "w", encoding="utf-8", newline="") as archivo:
    escritor = csv.writer(archivo)
    escritor.writerow(["descripcion", "monto"])
    escritor.writerows(filas)

import pandas as pd

tabla = pd.read_csv(CARPETA / "ticket_gemini.csv")
tabla["monto"] = pd.to_numeric(tabla["monto"], errors="coerce")   # lo que no sea número queda vacío
print()
print(tabla.to_string())
print()
print("Ítems leídos:", len(tabla), "  Montos vacíos:", int(tabla["monto"].isna().sum()))
print("Suma de los ítems:", round(float(tabla["monto"].sum()), 2))   # comparar con el TOTAL impreso
