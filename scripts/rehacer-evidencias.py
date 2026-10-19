#!/usr/bin/env python3
"""Vuelve a generar capturas, GIF y video de un alumno a partir de capturas.md
(útil cuando cambia el formato de la marca o las reglas de privacidad).
Uso: python3 scripts/rehacer-evidencias.py <alumno> [lab ...]"""
import os, subprocess, sys
raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
alumno = sys.argv[1]
base = os.path.join(raiz, "alumnos", alumno, "evidencias")
labs = sys.argv[2:] or sorted(d for d in os.listdir(base) if os.path.isdir(os.path.join(base, d)))
ev = os.path.join(raiz, "scripts", "evidencias.py")
for lab in labs:
    idx = os.path.join(base, lab, "capturas.md")
    if not os.path.exists(idx):
        continue
    filas = [l.rstrip("\n").split("|") for l in open(idx, encoding="utf-8") if l.strip()]
    filas = [f for f in filas if len(f) >= 4 and os.path.exists(f[3])]
    if not filas:
        print("sin orígenes:", lab); continue
    os.remove(idx)
    for nombre, pie, _, origen in filas:
        subprocess.run([sys.executable, ev, "captura", alumno, lab, origen, nombre[:-4], pie], check=True, stdout=subprocess.DEVNULL)
    marcos = [f[3] for f in filas if "consola" in f[0] or "navegador" in f[0]]
    if marcos:
        subprocess.run([sys.executable, ev, "gif", alumno, lab, "recorrido-consola", *marcos], check=True, stdout=subprocess.DEVNULL)
    subprocess.run([sys.executable, ev, "video", alumno, lab], check=True, stdout=subprocess.DEVNULL)
    print("listo:", lab, len(filas))
