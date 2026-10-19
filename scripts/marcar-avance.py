#!/usr/bin/env python3
"""Marca un lab como completado en alumnos/<alumno>/README.md
Uso: python3 scripts/marcar-avance.py <alumno> <lab-id>"""
import os, sys
raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
alumno, lab = sys.argv[1], sys.argv[2]
p = os.path.join(raiz, "alumnos", alumno, "README.md")
d = os.path.join(raiz, "alumnos", alumno, "evidencias", lab)
n_img = len([f for f in os.listdir(d) if f.endswith(".png")])
n_vid = len([f for f in os.listdir(d) if f.endswith((".gif", ".mp4"))])
lineas = open(p, encoding="utf-8").read().splitlines()
for i, l in enumerate(lineas):
    if f"../../labs/{lab}/README.md" in l:
        lineas[i] = l.replace("⬜ Pendiente", f"✅ Completado ({n_img} capturas, {n_vid} videos)")
open(p, "w", encoding="utf-8").write("\n".join(lineas) + "\n")
print("ok", lab, n_img, n_vid)
